import ASLogKit

enum LogHandler {
    static func handleError(_ message: String) {
        Logger.error(message)
    }

    static func handleError(_ error: ASErrors) {
        handleError(error.localizedDescription)
    }

    static func handleDebug(_ message: Any) {
        Logger.debug(message)
    }
}
