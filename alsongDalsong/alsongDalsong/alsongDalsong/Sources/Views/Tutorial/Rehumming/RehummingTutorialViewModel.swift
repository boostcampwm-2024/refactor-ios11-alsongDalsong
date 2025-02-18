import ASEntity
import Combine
import Foundation

final class RehummingTutorialViewModel: ObservableObject {
    @Published var panelData: Music?
    @Published var isRecording = false
    @Published var recordedData: Data?

    init(selectedMusic: Music? = TutorialData.superShy) {
        self.panelData = selectedMusic
    }
}
