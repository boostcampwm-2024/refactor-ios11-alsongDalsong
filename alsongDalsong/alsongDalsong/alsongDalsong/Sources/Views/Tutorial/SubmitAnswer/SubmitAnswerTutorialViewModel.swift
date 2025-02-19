import ASEntity
import Foundation

final class SubmitAnswerTutorialViewModel: ObservableObject {
    @Published var humming: Music?
    @Published var selectedMusic: Music?
    @Published var selectedMusicData: Data?
    
    init(humming: Music?) {
        self.humming = humming
    }
}
