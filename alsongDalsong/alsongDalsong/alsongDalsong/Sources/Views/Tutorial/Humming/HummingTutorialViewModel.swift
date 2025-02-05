import ASEntity
import Combine
import Foundation

final class HummingTutorialViewModel: ObservableObject {
    @Published var panelData: Music? = TutorialData.superShy
    @Published var isRecording = false
    @Published var recordedData: Data?
}
