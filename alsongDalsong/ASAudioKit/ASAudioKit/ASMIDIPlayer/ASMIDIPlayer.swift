import AVFoundation

enum Constant {
    static var soundFontURL: URL {
        Bundle.main.url(forResource: "Robot", withExtension: "wav")!
    }
}

public actor ASMIDIPlayer {
    private var globalTunning: Float = 0.0
    private var overallGain: Float = 10.0
    
    private let audioEngine = AVAudioEngine()
    private let audioSampler = AVAudioUnitSampler()
    private var sequencer: AVAudioSequencer?
    
    public init() {}
    
    public var onPlaybackFinished: (@Sendable () async -> Void)?
    
    public func startPlaying(
        midiURL: URL,
        option: PlayType = .full
    ) throws {
        do {
            try configureAudioEngine()
            try loadSoundFont(from: Constant.soundFontURL)
            try loadMIDI(from: midiURL)
        } catch {
            throw ASAudioErrors(
                type: .startPlaying,
                reason: error.localizedDescription,
                file: #file,
                line: #line
            )
        }
        sequencer?.currentPositionInBeats = 0
        try sequencer?.start()
        
        switch option {
        case .full:
            Task {
                await self.monitorPlayback()
            }
        case .partial(time: let seconds):
            Task {
                await self.monitorPlayback()
            }
            Task {
                try await Task.sleep(for: .seconds(seconds))
                if self.sequencer?.isPlaying == true {
                    await self.stopPlaying()
                }
            }
        }
    }
    
    public func stopPlaying() async {
        audioEngine.stop()
        sequencer?.stop()
    }
    
    public func setOnPlaybackFinished(_ handler: @Sendable @escaping () async -> Void) {
        onPlaybackFinished = handler
    }
    
    private func monitorPlayback() async {
        while sequencer?.isPlaying == true {
            try? await Task.sleep(for: .seconds(0.1))
        }
        if let callback = onPlaybackFinished {
            await callback()
        }
    }
    
    private func configureAudioEngine() throws {
        audioEngine.attach(audioSampler)
        audioEngine.connect(audioSampler, to: audioEngine.mainMixerNode, format: nil)
        
        try audioEngine.start()
    }
    
    private func loadSoundFont(from url: URL) throws {
        audioSampler.globalTuning = globalTunning
        audioSampler.overallGain = overallGain
        try audioSampler.loadAudioFiles(at: [url])
    }
    
    private func loadMIDI(from url: URL) throws {
        sequencer = AVAudioSequencer(audioEngine: audioEngine)
        try sequencer?.load(from: url, options: .smf_ChannelsToTracks)
    }
    
    public func isPlaying() -> Bool {
        if let sequencer {
            return sequencer.isPlaying
        }
        return false
    }
}
