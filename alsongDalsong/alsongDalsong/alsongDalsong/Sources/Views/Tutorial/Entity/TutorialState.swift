enum TutorialState {
    case start
}

enum TutorialViewType {
    case lobby
    case selectMusic
    case humming
    case rehumming
    case submitAnswer
    case result
    case finished

    var title: String {
        switch self {
            case .lobby:
                "튜토리얼"
            case .selectMusic:
                "노래 선택"
            case .humming:
                "허밍"
            case .rehumming:
                "리허밍"
            case .submitAnswer:
                "정답 맞추기"
            case .result:
                "게임 종료!"
            case .finished:
                "완료"
        }
    }

    var description: String {
        switch self {
            case .lobby: "알쏭달쏭에 오신걸 환영합니다~🎉"
            case .selectMusic: "문제로 제출할 노래를 고르세요."
            case .humming: "다음 사람에게 고른 노래를 전달하세요."
            case .rehumming: "허밍을 듣고 따라 허밍해 보세요."
            case .submitAnswer: "허밍을 듣고 무슨 노래인지 맞춰 보세요."
            case .result: "결과 화면으로 이동합니다."
            case .finished: "축하합니다! 모든 단계를 마쳤습니다~🎉"
        }
    }

    var caution: String? {
        switch self {
            case .lobby:
                """
                이곳에서 여러분의 허밍은 곧 음악이 됩니다.
                
                간단한 연습을 통해 기본 컨트롤과 플레이 방식을 익히고
                친구들과 창의적인 음악 여정을 시작해 보세요.
                
                아래의 시작 버튼을 눌러 우리의 첫 허밍에 도전해볼까요?
                """
            case .selectMusic:
                """
                이제 여러분이 친구들에게 문제로 제출할 노래를 고릅니다.
                
                제출 전까지 선택을 바꿀 수는 있지만
                한번 제출을 완료하면 다시 바꿀 수 없으니 주의하세요!
                
                또한 선택한 노래를 허밍으로 불러야 한다는 사실도 잊지마세요!
                
                그럼 이제 노래를 고르러 가볼까요?
                """
            case .humming:
                """
                드디어 여러분의 목소리를 음악으로 만들 시간입니다.
                
                여러분이 녹음한 허밍을 친구들이 듣고 어떤 노래인지
                맞추게 되니 제목이나 가사를 힌트로 주는 건 신중해야겠죠?!
                
                참고로 노래의 어느 부분을 불러도 상관 없답니다!
                
                물도 마시고 목소리도 가다듬었다면 시작해볼까요?
                """
            case .rehumming:
                """
                리허밍 설명이다
                """
            case .submitAnswer:
                """
                허밍 제출 후에는 친구의 허밍을 듣고 노래를 맞춥니다.
                
                노래 제출과 마찬가지로 한번 제출을 완료하면
                다시 바꿀 수 없으니 주의하세요!
                
                튜토리얼 알쏭이는 얼마나 잘 불렀는지 확인해볼까요?
                """
            case .result:
                """
                노래, 허밍, 그리고 정답 제출까지 모두 익혔습니다!
                
                위 과정이 모두 끝나면 선택된 노래의 허밍
                그리고 친구들의 정답을 확인하는 결과 화면이 시작됩니다.
                
                여러분의 허밍을 들은 알쏭이의 정답을 확인하러 가볼까요?
                """
            case .finished:
                """
                튜토리얼을 통해 "허밍" 모드를 익히셨습니다.
                
                다른 모드들도 준비되어 있으니 친구들과 함께
                마음껏 실력을 발휘해 보세요!
                
                그럼 이제 본격적으로 시작해볼까요?
                """
        }
    }

    var symbol: (systemName: String, color: String)? {
        switch self {
            case .lobby:
                (systemName: "lightbulb.max", color: "FFCC00")
            case .selectMusic:
                (systemName: "music.note.list", color: "508DFD")
            case .humming:
                (systemName: "microphone", color: "FD5050")
            case .rehumming:
                (systemName: "microphone", color: "FD5050")
            case .submitAnswer:
                (systemName: "music.note.list", color: "508DFD")
            case .result:
                nil
            case .finished:
                (systemName: "hand.thumbsup", color: "28A745")
        }
    }

    var topButton: TutorialButtonStyle {
        switch self {
            case .lobby:
                TutorialButtonStyle(text: "튜토리얼 시작!")
            default:
                TutorialButtonStyle(isHidden: true)
        }
    }

    var bottomButton: TutorialButtonStyle {
        switch self {
            case .lobby:
                TutorialButtonStyle(imageName: nil, text: "나는 이 게임을 해봤어요!", backgroundColor: "asMint")
            case .selectMusic:
                TutorialButtonStyle(text: "선택하기!")
            case .humming:
                TutorialButtonStyle(text: "녹음하기!")
            case .rehumming:
                TutorialButtonStyle(text: "다시 녹음하기!")
            case .submitAnswer:
                TutorialButtonStyle(text: "다음으로!")
            case .result:
                TutorialButtonStyle(text: "결과보기!")
            case .finished:
                TutorialButtonStyle(text: "시작하기!")
        }
    }

    struct TutorialButtonStyle {
        var isHidden: Bool = false
        var imageName: String? = "play.fill"
        var text: String = ""
        var backgroundColor: String = "asYellow"
    }
}
