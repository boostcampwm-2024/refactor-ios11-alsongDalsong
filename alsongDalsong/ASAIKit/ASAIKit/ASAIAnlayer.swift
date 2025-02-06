import Foundation
import SoundAnalysis
import AVFoundation
import CoreML

public typealias AudioAnalyeResult = (bestClassification: String, confidence: Double)

public enum ASAIAnlayer {
    static let model = try? ASmlModel(configuration: MLModelConfiguration())
    
    // MARK: - Asynchronous 분석 (SoundAnalysis 프레임워크 이용)
    public static func analyzeAudioFile(
        audioData: Data,
        overlapFactor: Double = 0.5,
        windowDuration: CMTime = .init(seconds: 2, preferredTimescale: 12000),
        handler: @escaping (AudioAnalyeResult?) -> Void)
    {
        // fileData를 임시 m4a 파일로 저장
        guard let fileURL = makeFile(audioData) else {
            handler(nil)
            return
        }
        
        // 모델 및 분석기 생성에 실패하면 임시 파일 삭제 후 nil 반환
        guard let model = model?.model else {
            removeFile(fileURL)
            handler(nil)
            return
        }
        guard let analyzer = try? SNAudioFileAnalyzer(url: fileURL),
              let request = try? SNClassifySoundRequest(mlModel: model)
        else {
            removeFile(fileURL)
            handler(nil)
            return
        }
        request.overlapFactor = overlapFactor
        request.windowDuration = windowDuration

        // 옵저버 생성: 분석 완료 시 결과를 전달하고 임시 파일 삭제
        let observer = AudioStreamObserver()
        observer.completion = { result in
            handler(result)
            removeFile(fileURL)
        }
        try? analyzer.add(request, withObserver: observer)
        analyzer.analyze()
    }
    
    // MARK: - Synchronous 분석 (MLModel 직접 호출)
    public static func analzeAudioFile(audioData: Data, sampleRate: Int32 = 12000) -> AudioAnalyeResult? {
        // fileData를 임시 m4a 파일로 저장
        guard let fileURL = makeFile(audioData) else { return nil }
        // 함수 종료 시 임시 파일 삭제
        defer {
            removeFile(fileURL)
        }
        
        guard let model = model else { return nil }
        
        let samples = decodeAudioFile(url: fileURL, targetSampleCount: Int(sampleRate))
        if samples.isEmpty { return nil }
        
        // 필요 샘플 수(sampleRate)만큼만 사용 (부족하면 이미 패딩되어 있음)
        let truncatedSamples = Array(samples.prefix(Int(sampleRate)))
        let mlData = truncatedSamples.withUnsafeBufferPointer { buffer in
            Data(buffer: buffer)
        }
        let mlShapedArray = MLShapedArray<Float32>(data: mlData, shape: [1, 1, Int(sampleRate)])
        let input = ASmlModelInput(audioSamples: mlShapedArray)
        
        if let output = try? model.prediction(input: input) {
            return output.targetProbability
                .sorted { $0.value > $1.value }
                .first
                .map { ($0.key, $0.value) }
        }
        return nil
    }
    
    // MARK: - 오디오 파일 디코딩
    private static func decodeAudioFile(url: URL, targetSampleCount: Int? = nil) -> [Float] {
        guard let audioFile = try? AVAudioFile(forReading: url) else { return [] }
        let format = audioFile.processingFormat
        let frameCount = AVAudioFrameCount(audioFile.length)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return []
        }
        try? audioFile.read(into: buffer)
        
        let channelCount = Int(buffer.format.channelCount)
        let frameLength = Int(buffer.frameLength)
        var samples: [Float] = []
        
        // 단일 채널이면 그대로 사용
        if channelCount == 1 {
            samples = Array(UnsafeBufferPointer(start: buffer.floatChannelData![0], count: frameLength))
        }
        // 멀티 채널인 경우: 각 채널의 샘플을 평균하여 mono 신호로 변환
        else if channelCount > 1 {
            samples = [Float](repeating: 0.0, count: frameLength)
            for i in 0..<frameLength {
                var sample: Float = 0
                for channel in 0..<channelCount {
                    sample += buffer.floatChannelData![channel][i]
                }
                samples[i] = sample / Float(channelCount)
            }
        }
        
        // targetSampleCount가 지정되어 있고, 부족하면 0으로 패딩
        if let target = targetSampleCount, samples.count < target {
            let padCount = target - samples.count
            let padding = Array(repeating: Float(0.0), count: padCount)
            samples.append(contentsOf: padding)
        }
        return samples
    }
    
    // MARK: - 임시 파일 생성 및 삭제
    /// Data를 m4a 파일로 임시 저장한 후 해당 URL을 반환합니다.
    private static func makeFile(_ data: Data) -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "tempAudio-\(UUID().uuidString).m4a"
        let fileURL = tempDir.appendingPathComponent(fileName)
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("임시 파일 생성 실패: \(error)")
            return nil
        }
    }
    
    /// 지정된 파일 URL의 파일을 삭제합니다.
    private static func removeFile(_ fileURL: URL) {
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("파일 삭제 실패: \(error)")
        }
    }
}

// MARK: - AudioStreamObserver

/// 분석 결과를 받아 처리할 옵저버
/// 각 분석 결과의 identifier별로 발생 횟수와 누적 신뢰도를 저장한 후,
/// 분석 완료 시 해당 identifier의 평균 신뢰도를 계산하여 AudioAnalyeResult로 전달합니다.
private final class AudioStreamObserver: NSObject, SNResultsObserving, ObservableObject {
    var predictCount: [String: Int] = [:]
    var totalConfidence: [String: Double] = [:]

    var completion: ((AudioAnalyeResult) -> Void)?

    /// 분석 결과가 도착하면 호출됩니다.
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let classificationResult = result as? SNClassificationResult else { return }
        guard let bestClassification = classificationResult.classifications.first else { return }
        let identifier = bestClassification.identifier
        let conf = bestClassification.confidence

        predictCount[identifier] = (predictCount[identifier] ?? 0) + 1
        totalConfidence[identifier] = (totalConfidence[identifier] ?? 0.0) + conf
    }

    /// 에러 발생 시 호출됩니다.
    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("Sound analysis failed: \(error.localizedDescription)")
    }

    /// 분석이 완료되었을 때 호출됩니다.
    func requestDidComplete(_ request: SNRequest) {
        guard let bestEntry = predictCount.max(by: { $0.value < $1.value }) else {
            return
        }
        let identifier = bestEntry.key
        let count = bestEntry.value
        let sumConfidence = totalConfidence[identifier] ?? 0.0
        let avgConfidence = sumConfidence / Double(count)
        completion?((identifier, avgConfidence))
    }
}
