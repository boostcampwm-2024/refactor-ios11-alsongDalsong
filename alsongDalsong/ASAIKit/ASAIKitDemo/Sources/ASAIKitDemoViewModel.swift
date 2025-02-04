import ASAudioKit
import FirebaseStorage
import Foundation

@Observable final class ASAIKitDemoViewModel {
    var name = ""
    var song = ""
    var recordedData: Data?
    var amplitudes: [CGFloat] = []
    
    @ObservationIgnored var id = ""
    
    private let audioPlayer = ASAudioPlayer()
    private let audioRecorder = ASAudioRecorder()
    
    private var url: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(id, conformingTo: .mpeg4Audio)
    }
    
    func upload() {
        guard let data = recordedData else { return }
        
        let storageRef = Storage.storage().reference()
        let fileRef = storageRef.child("\(song)/\(name)-\(id.prefix(8)).m4a")
        
        fileRef.putData(data, metadata: nil) { _, error in
            if let error {
                print("업로드 오류 발생 \(error)")
            }
        }
        
        recordedData = nil
    }
    
    private func startRecording() async throws {
            id = UUID().uuidString
            try await audioRecorder.startRecording(url: url)
    }
    
    private func stopRecording() async throws {
        recordedData = await audioRecorder.stopRecording()
        try FileManager.default.removeItem(at: url)
    }
    
    func startPlaying() {
        Task {
            guard let data = recordedData else { return }
            try await audioPlayer.startPlaying(data: data)
        }
    }
    
    func stopPlaying() {
        Task {
            await audioPlayer.stopPlaying()
        }
    }
}
