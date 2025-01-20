import Foundation
import Testing

struct ASAudioRecorderTests {
    private let recorder: ASAudioRecorder

    init() async throws {
        recorder = ASAudioRecorder()
    }

    @Test("녹음 시작 테스트") func startRecording() async throws {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("녹음성공테스트")
        
        await recorder.startRecording(url: url)
        let isRecording = await recorder.isRecording()
        #expect(isRecording)
    }

    @Test("녹음 완료 후 저장 테스트") func stopRecording() async throws {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("녹음저장성공테스트")
        
        await recorder.startRecording(url: url)
        await recorder.stopRecording()
        #expect(FileManager.default.fileExists(atPath: url.path))
    }
}
