import ASLogKit
import AVFoundation
enum Constant {
    static var soundFontURL: URL {
        Bundle.main.url(forResource: "Robot", withExtension: "wav")!
    }
}
public actor ASMIDIPlayer {
    private var globalTunning: Float = 0.0
    private var overallGain: Float = 0.0
    
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
            Logger.error("재생 실패 reason: \(error)")
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
                    Logger.debug("MIDI \(seconds)초 재생 완료")
                }
            }
        }
    }
    
    public func stopPlaying() async {
        audioEngine.stop()
        sequencer?.stop()
        Logger.debug("MIDI 재생 중지")
    }
    
    public func setOnPlaybackFinished(_ handler: @Sendable @escaping () async -> Void) {
        onPlaybackFinished = handler
    }
    
    private func monitorPlayback() async {
        while sequencer?.isPlaying == true {
            try? await Task.sleep(for: .seconds(0.1))
        }
        if let callback = onPlaybackFinished {
            Logger.debug("전체 MIDI 재생 완료")
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
        Logger.debug("사운드 폰트 로드 성공")
    }
    
    private func loadMIDI(from url: URL) throws {
        sequencer = AVAudioSequencer(audioEngine: audioEngine)
        try sequencer?.load(from: url, options: .smf_ChannelsToTracks)
        Logger.debug("MIDI 파일 로드 성공")
    }
    
    public func isPlaying() -> Bool {
        if let sequencer {
            return sequencer.isPlaying
        }
        return false
    }
}
