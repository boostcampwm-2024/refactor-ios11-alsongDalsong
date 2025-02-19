import ASEntity
import Foundation

struct TutorialPlayer {
    var name: String?
    var avatarURL: URL?
    var selectedMusic: Music?
    var hummingURL: URL?
    var rehummingURL: URL?
    var submittedMusic: Music?
    
    init(name: String?, avatarURL: URL?) {
        self.name = name
        self.avatarURL = avatarURL
    }
}
