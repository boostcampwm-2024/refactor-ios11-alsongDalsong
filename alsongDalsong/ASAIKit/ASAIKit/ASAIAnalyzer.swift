internal import BasicPitch
internal import MIDIKitSMF
import CoreML
import SoundAnalysis

public enum ASAIAnalyzer {
    private struct ActiveNote {
        let startTime: Double
        let velocity: UInt7
    }
    
    public static func m4aToMIDI(audioURL: URL?) -> URL? {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mid")
        guard let audioURL, let noteCreation = try? BasicPitch.predict(audioURL),
              let midiFile = try? noteCreation.genMidiFile() else { return nil }
        let data = try? midiFile.rawData()
        try? data?.write(to: outputURL)
        return outputURL
    }
    
    public static func analyzeAudioFile(audioData: Data) async -> [TimedNote] {
        guard let fileURL = makeFile(audioData),
              let noteCreation = try? BasicPitch.predict(fileURL),
              let midiFile = try? noteCreation.genMidiFile() else { return [] }

        defer {
            removeFile(fileURL)
        }

        var timedNoteArr = [TimedNote]()
        let secondsPerBeat = 60.0 / getTempo(from: midiFile)
        let secondsPerTick = secondsPerBeat / getTicksPerBeat(from: midiFile) // 1틱이 몇초인지 계산

        var activeNotes = [UInt7: ActiveNote]()

        for track in midiFile.tracks {
            var totalTime: Double = 0

            for event in track.events {
                guard let data = event.event() else { continue }

                totalTime += calcDeltaTime(event: event, secondsPerTick: secondsPerTick)

                switch data {
                    case .noteOn(let noteOn):
                        if noteOn.velocity.midi1Value != 0 {
                            activeNotes[noteOn.note.number] = ActiveNote(
                                startTime: totalTime,
                                velocity: noteOn.velocity.midi1Value
                            )
                        } else if let activeNote = activeNotes[noteOn.note.number] {
                            let timedNote = TimedNote(
                                startTime: activeNote.startTime,
                                endTime: totalTime,
                                pitch: UInt8(noteOn.note.number),
                                velocity: UInt8(activeNote.velocity)
                            )
                            timedNoteArr.append(timedNote)
                            activeNotes[noteOn.note.number] = nil
                        }
                    default: continue
                }
            }
        }
        return timedNoteArr
    }

    private static func calcDeltaTime(event: MIDIFileEvent, secondsPerTick: Double) -> Double {
        // 이 부분은 GPT의 도움을 받아 작성된 코드입니다.
        switch event.delta {
            case .none:
                0
            case .ticks(let ticks):
                Double(ticks) * secondsPerTick // tick을 초 단위로 변환
            case .noteWhole:
                4.0 * secondsPerTick // 온음표 (4분음표 4배 크기)
            case .noteHalf:
                2.0 * secondsPerTick // 반음표 (4분음표 2배 크기)
            case .noteQuarter:
                1.0 * secondsPerTick // 분음표 (기본 박자)
            case .note8th:
                0.5 * secondsPerTick // 8분음표 (분음표의 절반 길이)
            case .note16th:
                0.25 * secondsPerTick // 16분음표
            case .note32nd:
                0.125 * secondsPerTick // 32분음표
            case .note64th:
                0.0625 * secondsPerTick // 64분음표
            case .note128th:
                0.03125 * secondsPerTick // 128분음표
            case .note256th:
                0.015625 * secondsPerTick // 256분음표
        }
    }

    /// MIDI파일에서 ticksPerBeat를 반환하는 함수
    ///
    /// - Note: 예를 들어, 480은 1비트를 480개의 "틱"으로 나누는 것과 같음.
    private static func getTicksPerBeat(from midiFile: MIDIFile) -> Double {
        switch midiFile.timeBase {
            case .musical(let ticksPerQuarterNote):
                Double(ticksPerQuarterNote)
            default:
                480.0
        }
    }

    /// MIDI 파일에서의 템포를 반환하는 함수
    ///
    /// - Note: '템포'는 분당 비트 수로 120 BPM이면 1분 동안 120개의 비트가 재생
    private static func getTempo(from midiFile: MIDIFile) -> Double {
        var tempoInBPM = 120.0

        for chunk in midiFile.chunks {
            guard case .track(let track) = chunk else { continue }
            for event in track.events {
                if case .tempo(_, let event) = event {
                    tempoInBPM = Double(event.bpm)
                    break
                }
            }
        }
        return tempoInBPM
    }
}

// MARK: 부가적인 Method

extension ASAIAnalyzer {
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

public typealias AudioAnalyeResult = (bestClassification: String, confidence: Double)

// CoreML과 SoundAnalysis를 사용하여 오디오 파일을 분석하는 메서드입니다.

extension ASAIAnalyzer {
    static let model = try? ASmlModel(configuration: MLModelConfiguration())

    public enum SoundAnalyzerMode {
        // window overlap 방식
        case overlap(overlapFactor: Double = 0.5, windowDuration: CMTime = .init(seconds: 2, preferredTimescale: 12000))
        // 전체 오디오 파일을 분석하는 방식
        case full(sampleRate: Int32 = 12000)
    }

    public static func analzeAudioFile(audioData: Data, mode: SoundAnalyzerMode) async -> AudioAnalyeResult? {
        switch mode {
            case .overlap(let overlapFactor, let windowDuration):
                await overlapAnalyze(audioData: audioData, overlapFactor: overlapFactor, windowDuration: windowDuration)
            case .full(let sampleRate):
                await fullAnalyze(audioData: audioData, sampleRate: sampleRate)
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

        guard let model else { return nil }

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

    public static func analyzeAudioURL(audioURL: URL, mode: SoundAnalyzerMode) async -> AudioAnalyeResult? {
        var shouldRemoveTempFile = false
        var fileURL = audioURL
        if fileURL.pathExtension == "mid" {
            let tempOutputURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("m4a")
            do {
                try convertMIDIToAudio(midiURL: fileURL, outputURL: tempOutputURL)
                fileURL = tempOutputURL
                shouldRemoveTempFile = true
            } catch {
                return nil
            }
        }

        guard let audioData = try? Data(contentsOf: fileURL) else {
            return nil
        }

        if shouldRemoveTempFile {
            try? FileManager.default.removeItem(at: fileURL)
        }

        return await analzeAudioFile(audioData: audioData, mode: mode)
    }

    private static func convertMIDIToAudio(midiURL: URL, outputURL: URL) throws {
        let engine = AVAudioEngine()
        let sampler = AVAudioUnitSampler()
        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)
        let soundbankURL = Bundle.main.url(forResource: "Robot", withExtension: "wav")!
        try sampler.loadAudioFiles(at: [soundbankURL])
        let sequencer = AVAudioSequencer(audioEngine: engine)
        try sequencer.load(from: midiURL)
        guard let renderFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                               sampleRate: 12000,
                                               channels: 1,
                                               interleaved: false)
        else {
            throw NSError(domain: "convertMIDIToAudio", code: -1, userInfo: [NSLocalizedDescriptionKey: "렌더 포맷 생성 실패"])
        }
        let maxFrames: AVAudioFrameCount = 4096
        try engine.enableManualRenderingMode(.offline, format: renderFormat, maximumFrameCount: maxFrames)
        let outputFile = try AVAudioFile(forWriting: outputURL, settings: engine.manualRenderingFormat.settings)
        try engine.start()
        sequencer.currentPositionInBeats = 0
        try sequencer.start()

        guard let buffer = AVAudioPCMBuffer(pcmFormat: renderFormat, frameCapacity: maxFrames) else {
            return
        }

        let totalFrameCount = AVAudioFrameCount(sequencer.duration * renderFormat.sampleRate)
        var renderedFrames: AVAudioFrameCount = 0

        while renderedFrames < totalFrameCount {
            let framesToRender = min(maxFrames, totalFrameCount - renderedFrames)
            let status = try engine.renderOffline(framesToRender, to: buffer)
            switch status {
                case .success:
                    try outputFile.write(from: buffer)
                    renderedFrames += framesToRender
                case .insufficientDataFromInputNode:
                    try outputFile.write(from: buffer)
                    renderedFrames += framesToRender
                case .cannotDoInCurrentContext:
                    continue
                case .error:
                    throw NSError(domain: "OfflineRendering",
                                  code: -1,
                                  userInfo: [NSLocalizedDescriptionKey: "오프라인 렌더링 중 오류 발생"])
                @unknown default:
                    break
            }
        }
        sequencer.stop()
        engine.stop()
        engine.disableManualRenderingMode()
    }
}

extension AVAudioSequencer {
    var duration: TimeInterval {
        let maxBeats = tracks.map(\.lengthInBeats).max() ?? 0
        let defaultBPM = 120.0
        return maxBeats / (defaultBPM / 60.0)
    }
}
