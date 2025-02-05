import ASRepositoryProtocol
import ASEntity

final class SaveDataRepository: SaveDataRepositoryProtocol {
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()

    func savePlayer(tutorialPlayer: Player) {
        if let encoded = try? encoder.encode(tutorialPlayer){
            defaults.setValue(encoded, forKey: "tutorialPlayer")
        }
    }
}
