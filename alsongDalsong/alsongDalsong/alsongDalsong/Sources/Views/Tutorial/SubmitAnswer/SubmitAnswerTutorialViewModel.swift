import ASEntity
import Foundation

final class SubmitAnswerTutorialViewModel: ObservableObject {
    @Published private(set) var humming: Music?
    @Published private(set) var selectedMusic: Music?
    @Published private(set) var selectedMusicData: Data?
}
