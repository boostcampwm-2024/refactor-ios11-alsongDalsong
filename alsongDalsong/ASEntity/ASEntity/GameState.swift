public struct GameState {
    public let mode: Mode?
    public let recordOrder: UInt8?
    public let status: Status?
    public let round: UInt8?
    public let players: [Player]
    public init(
        mode: Mode?,
        recordOrder: UInt8?,
        status: Status?,
        round: UInt8?,
        players: [Player]
    ) {
        self.mode = mode
        self.recordOrder = recordOrder
        self.status = status
        self.round = round
        self.players = players
    }

    public func resolveViewType() -> GameViewType? {
        guard let mode, let status, let recordOrder, let round else {
            return .lobby
        }
        if case .humming = mode {
            return resolveHummingViewType(status: status, recordOrder: recordOrder, round: round)
        } else {
            return nil
        }
    }

    private func resolveHummingViewType(status: Status, recordOrder: UInt8, round: UInt8) -> GameViewType? {
        switch status {
        case .humming:
            if round == 0, recordOrder == 0 {
                return .submitMusic
            } else if round == 1, recordOrder == 0 {
                return .humming
            }
        case .rehumming:
            if players.count <= 2, round == 1, recordOrder == 1 {
                return .submitAnswer
            }

            if round == 1, recordOrder == players.count - 1 {
                return .submitAnswer
            } else if round == 1, recordOrder >= 1 {
                return .rehumming
            }
        case .result:
            if players.count <= 2, recordOrder == 1 {
                return .result
            }
            else if recordOrder >= players.count - 1 {
                return .result
            } else {
                return nil
            }
        default:
            return .lobby
        }
        return nil
    }
}

public enum GameViewType {
    case submitMusic
    case humming
    case rehumming
    case submitAnswer
    case result
    case lobby

    public var title: String {
        switch self {
        case .submitMusic:
            "노래 선택"
        case .humming:
            "허밍"
        case .rehumming:
            "리허밍"
        case .submitAnswer:
            "정답 맞추기"
        case .result:
            "게임 종료!"
        case .lobby:
            ""
        }
    }

    public var description: String {
        switch self {
        case .submitMusic:
            "문제로 제출할 노래를 고르세요"
        case .humming:
            "다음 사람에게 고른 노래를 전달하세요"
        case .rehumming:
            "다음 사람에게 허밍을 전달하세요"
        case .submitAnswer:
            "허밍을 듣고 무슨 노래인지 맞춰 보세요."
        case .result:
            "결과 화면으로 이동합니다.."
        case .lobby:
            ""
        }
    }

    public var caution: String? {
        switch self {
        case .humming:
            "가사나 제목을 직접적으로 전달하지 않도록 주의하세요"
        case .rehumming:
            "가사나 제목을 직접적으로 전달하지 않도록 주의하세요"
        default:
            nil
        }
    }

    public var symbol: (systemName: String, color: String)? {
        switch self {
        case .submitMusic:
            (systemName: "music.note.list", color: "508DFD")
        case .humming:
            (systemName: "microphone", color: "FD5050")
        case .rehumming:
            (systemName: "microphone", color: "FD5050")
        case .submitAnswer:
            (systemName: "music.note.list", color: "508DFD")
        default: nil
        }
    }
}

extension GameState {
    static let submitMusicStub: GameState = GameState(
        mode: .humming,
        recordOrder: 0,
        status: .humming,
        round: 0,
        players: [Player.playerStub1, Player.playerStub2, Player.playerStub3, Player.playerStub4]
    )
    static let hummingStub: GameState = GameState(
        mode: .humming,
        recordOrder: 0,
        status: .humming,
        round: 1,
        players: [Player.playerStub1, Player.playerStub2, Player.playerStub3, Player.playerStub4]
    )
    static let rehummingStub: GameState = GameState(
        mode: .humming,
        recordOrder: 1,
        status: .rehumming,
        round: 1,
        players: [Player.playerStub1, Player.playerStub2, Player.playerStub3, Player.playerStub4]
    )
    static let submitAnswerStub: GameState = GameState(
        mode: .humming,
        recordOrder: 3,
        status: .rehumming,
        round: 1,
        players: [Player.playerStub1, Player.playerStub2, Player.playerStub3, Player.playerStub4]
    )
    static let resultStub: GameState = GameState(
        mode: .humming,
        recordOrder: 3,
        status: .result,
        round: 1,
        players: [Player.playerStub1, Player.playerStub2, Player.playerStub3, Player.playerStub4]
    )
    static let lobbyStub: GameState = GameState(
        mode: .humming,
        recordOrder: nil,
        status: nil,
        round: nil,
        players: [Player.playerStub1, Player.playerStub2, Player.playerStub3, Player.playerStub4]
    )
}
