import ASAudioKit
import Combine
import SwiftUI
import FirebaseStorage
import Foundation

final class ASAIKitDemoViewModel: ObservableObject {
    @AppStorage("submitCount") var submitCount = 0
    @AppStorage("name") var name = ""
    @AppStorage("song") var song = ""
    
    @Published var recordedData: Data?
    @Published var amplitudes: [CGFloat] = Array(repeating: 0.0, count: 48)
    @Published var isRecording: Bool = false
    @Published var isPlaying: Bool = false
    @Published var message = ""
    @Published var isPresented = false
        
    var submitButtonDisabled: Bool {
        recordedData == nil || name.isEmpty || song.isEmpty
    }
    
    let testers = ["민하", "숲", "승재", "인예", "현준"]
    let songs = ["NewJeans - Super Shy", "BIGBANG - LOSER"]
    
    private var uuidString = ""
    private var recordingTask: Task<Void, Never>?
    private var playingTask: Task<Void, Never>?
    private var cancellable: AnyCancellable?
    private var addedAmplitudeCount = 0
    
    private let audioPlayer = ASAudioPlayer()
    private let audioRecorder = ASAudioRecorder()
    
    private var url: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(uuidString, conformingTo: .mpeg4Audio)
    }
    
    func toggleRecording() {
        isRecording ? cancelRecording() : startRecording()
    }
    
    func togglePlaying() {
        isPlaying ? stopPlaying() : startPlaying()
    }
    
    func uploadData() {
        guard let data = recordedData else { return }
        
        let storageReference = Storage.storage().reference()
        let bucketReference = storageReference.child("data/\(song)/\(name)-\(uuidString.prefix(8)).m4a")
        
        message = "업로드 중..."
        
        bucketReference.putData(data, metadata: nil) { [weak self] _, error in
            Task { @MainActor in
                if let error {
                    self?.message = "업로드 도중 오류가 발생했습니다. Error: \(error)"
                    return
                }
                
                self?.submitCount += 1
                self?.message = "성공적으로 업로드 되었습니다. 당신의 노고에 감사드립니다."
                
                self?.recordedData = nil
                self?.amplitudes = Array(repeating: 0, count: 48)
                self?.addedAmplitudeCount = 0
            }
        }
    }
}

// MARK: - Private Methods

extension ASAIKitDemoViewModel {
    private func startRecording() {
        stopPlaying()
        amplitudes = Array(repeating: 0, count: 48)
        addedAmplitudeCount = 0
        recordingTask?.cancel()
        
        recordingTask = Task { @MainActor in
            isRecording = true
            recordedData = nil
            uuidString = UUID().uuidString
            
            do {
                try await audioRecorder.startRecording(url: url)
                
                cancellable = Timer.publish(every: 0.125, on: .main, in: .common)
                    .autoconnect()
                    .sink { [weak self] _ in
                        Task {
                            await self?.audioRecorder.updateMeters()
                            
                            guard let averagePower = await self?.audioRecorder.getAveragePower(),
                                  let index = self?.addedAmplitudeCount, index < 48 else { return }
                            
                            let newAmplitude = 1.8 * pow(10.0, averagePower / 20.0)
                            let clampedAmplitude = min(max(newAmplitude, 0), 1)
                            self?.amplitudes[index] = CGFloat(clampedAmplitude)
                            self?.addedAmplitudeCount += 1
                        }
                    }
                
                try await Task.sleep(for: .seconds(6))
                
                recordedData = await audioRecorder.stopRecording()
                try FileManager.default.removeItem(at: url)
            } catch is CancellationError {
                // 녹음이 CancelRecording 으로 취소된 경우는 메시지를 표시하지 않음
            } catch {
                message = "녹음 중 오류가 발생했습니다. Error: \(error)"
            }
            
            isRecording = false
            cancellable?.cancel()
        }
    }
    
    private func cancelRecording() {
        recordingTask?.cancel()
        cancellable?.cancel()
        
        recordingTask = Task { @MainActor in
            isRecording = false
            recordedData = nil
            await audioRecorder.stopRecording()
            try? FileManager.default.removeItem(at: url)
        }
        
        amplitudes = Array(repeating: 0, count: 48)
        addedAmplitudeCount = 0
    }
    
    private func startPlaying() {
        guard let data = recordedData else {
            message = "녹음 된 허밍이 없습니다!"
            return
        }
        
        playingTask?.cancel()
        
        playingTask = Task { @MainActor in
            isPlaying = true
            
            do {
                try await audioPlayer.startPlaying(data: data)
                await audioPlayer.setOnPlaybackFinished { @MainActor [weak self] in
                    self?.isPlaying = false
                }
            } catch {
                isPlaying = false
                message = "플레이어 재생 중 오류가 발생했습니다."
            }
        }
    }
    
    private func stopPlaying() {
        playingTask?.cancel()
        
        playingTask = Task { @MainActor in
            await audioPlayer.stopPlaying()
            isPlaying = false
        }
    }
}
