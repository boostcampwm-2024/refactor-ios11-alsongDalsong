import AVFoundation
import Foundation

public enum ASAudioAnalyzer {
    public static func analyze(data: Data, samplesCount: Int) async throws -> [CGFloat] {
        do {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".m4a")
            try data.write(to: tempURL)
            let file = try AVAudioFile(forReading: tempURL)

            guard
                let format = AVAudioFormat(
                    commonFormat: .pcmFormatFloat32,
                    sampleRate: file.fileFormat.sampleRate,
                    channels: file.fileFormat.channelCount,
                    interleaved: false
                ),
                let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(file.length))
            else {
                return []
            }

            try file.read(into: buffer)
            guard let floatChannelData = buffer.floatChannelData else {
                return []
            }

            let frameLength = Int(buffer.frameLength)
            let samples = Array(UnsafeBufferPointer(start: floatChannelData[0], count: frameLength))
            try? FileManager.default.removeItem(at: tempURL)
            return processSamples(samples, samplesCount: samplesCount)
        } catch {
            throw ASAudioErrors(type: .analyze, reason: error.localizedDescription, file: #file, line: #line)
        }
    }
    
    public static func analyzeMIDI(url: URL, samplesCount: Int) async throws -> [CGFloat] {
        let engine = AVAudioEngine()
        let sampler = AVAudioUnitSampler()
        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)
        try sampler.loadAudioFiles(at: [Constant.soundFontURL])
        
        let sequencer = AVAudioSequencer(audioEngine: engine)
        try sequencer.load(from: url, options: .smf_ChannelsToTracks)
        sequencer.currentPositionInSeconds = 0
        
        let outputFormat = engine.outputNode.inputFormat(forBus: 0)
        let maxFrames: AVAudioFrameCount = 4096
        try engine.enableManualRenderingMode(.offline, format: outputFormat, maximumFrameCount: maxFrames)
        
        try engine.start()
        try sequencer.start()
        
        let sequenceLengthInBeats = sequencer.tracks.map(\.lengthInBeats).max() ?? 0
        let durationSeconds = sequencer.seconds(forBeats: sequenceLengthInBeats)
        let totalFrameCount = AVAudioFrameCount(durationSeconds * outputFormat.sampleRate)
        
        var renderedSamples = [Float]()
        while engine.manualRenderingSampleTime < totalFrameCount {
            guard let buffer = AVAudioPCMBuffer(pcmFormat: outputFormat, frameCapacity: maxFrames) else { break }
            let framesToRender = min(maxFrames, totalFrameCount - AVAudioFrameCount(engine.manualRenderingSampleTime))
            let status = try engine.renderOffline(framesToRender, to: buffer)
            if status == .success, let channelData = buffer.floatChannelData?[0] {
                let frameLength = Int(buffer.frameLength)
                renderedSamples.append(contentsOf: UnsafeBufferPointer(start: channelData, count: frameLength))
            } else {
                break
            }
        }
        
        engine.stop()
        
        return processSamples(renderedSamples.map { $0 * 10 }, samplesCount: samplesCount)
    }
    
    private static func processSamples(_ samples: [Float], samplesCount: Int) -> [CGFloat] {
        let chunkSize = max(samples.count / samplesCount, 1)
        let chunkedSamples = samples.chunked(into: chunkSize)
        var result = [CGFloat]()
        
        for chunk in chunkedSamples {
            let squaredSum = chunk.reduce(0) { $0 + $1 * $1 }
            let averagePower = squaredSum / Float(chunk.count)
            let decibels = 10 * log10(max(averagePower, Float.ulpOfOne))
            let newAmplitude = 1.8 * pow(10.0, decibels / 20.0)
            let clampedAmplitude = min(max(CGFloat(newAmplitude), 0), 1)
            result.append(clampedAmplitude)
        }
        return result
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
