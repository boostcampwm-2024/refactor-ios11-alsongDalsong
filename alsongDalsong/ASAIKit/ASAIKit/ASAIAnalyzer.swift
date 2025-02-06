import AVFoundation
import CoreML
import Foundation
import SoundAnalysis

public typealias AudioAnalyeResult = (bestClassification: String, confidence: Double)

public enum ASAIAnalyzer {
    static let model = try? ASmlModel(configuration: MLModelConfiguration())

    public enum SoundAnalyzerMode {
        case overlap(overlapFactor: Double = 0.5, windowDuration: CMTime = .init(seconds: 2, preferredTimescale: 12000))
        case full(sampleRate: Int32 = 12000)
    }

    public static func analzeAudioFile(audioData: Data, mode: SoundAnalyzerMode) async -> AudioAnalyeResult? {
        switch mode {
        case let .overlap(overlapFactor, windowDuration):
            return await overlapAnalyze(audioData: audioData, overlapFactor: overlapFactor, windowDuration: windowDuration)
        case let .full(sampleRate):
            return await fullAnalyze(audioData: audioData, sampleRate: sampleRate)
        }
    }

    private static func fullAnalyze(
        audioData: Data,
        sampleRate: Int32
    ) async -> AudioAnalyeResult? {
        guard let fileURL = makeFile(audioData) else { return nil }
        defer {
            removeFile(fileURL)
        }

        guard let model = model else { return nil }

        let samples = decodeAudioFile(url: fileURL, targetSampleCount: Int(sampleRate))
        if samples.isEmpty { return nil }

        let truncatedSamples = Array(samples.prefix(Int(sampleRate)))
        let mlData = truncatedSamples.withUnsafeBufferPointer { buffer in
            Data(buffer: buffer)
        }
        let mlShapedArray = MLShapedArray<Float32>(data: mlData, shape: [1, 1, Int(sampleRate)])
        let input = ASmlModelInput(audioSamples: mlShapedArray)

        if let output = try? await model.prediction(input: input) {
            return output.targetProbability
                .sorted { $0.value > $1.value }
                .first
                .map { ($0.key, $0.value) }
        }
        return nil
    }

    private static func overlapAnalyze(
        audioData: Data,
        overlapFactor: Double,
        windowDuration: CMTime
    ) async -> AudioAnalyeResult? {
        await withCheckedContinuation { continuation in
            analyze(
                audioData: audioData,
                overlapFactor: overlapFactor,
                windowDuration: windowDuration
            ) { result in
                continuation.resume(returning: result)
            }
        }
    }
}

// MARK: 부가적인 Method

extension ASAIAnalyzer {
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

    private static func analyze(
        audioData: Data,
        overlapFactor: Double = 0.5,
        windowDuration: CMTime = .init(seconds: 2, preferredTimescale: 12000),
        handler: @escaping (AudioAnalyeResult?) -> Void
    ) {
        guard let fileURL = makeFile(audioData) else {
            handler(nil)
            return
        }

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

        let observer = AudioStreamObserver()
        observer.completion = { result in
            handler(result)
            removeFile(fileURL)
        }
        try? analyzer.add(request, withObserver: observer)
        analyzer.analyze()
    }
}
