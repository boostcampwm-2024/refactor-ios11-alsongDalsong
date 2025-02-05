import ASEntity
import SwiftUI

struct SelectMusicTutorialView: View {
    @State private var text = ""
    @State private var isPlaying = false
    @State private var selectedMusic: Music?
    var handler: (Music?) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ASMusicItemCell(music: selectedMusic) { url in
                    guard let url else { return nil }
                    return try? await URLSession.shared.data(from: url).0
                }
                .scaleEffect(1.1)
                
                Spacer()
                
                Button {
                    isPlaying ? stopMusic() : playMusic()
                    isPlaying.toggle()
                } label: {
                    if #available(iOS 17.0, *) {
                        Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                            .font(.largeTitle)
                            .contentTransition(.symbolEffect(.replace.offUp))
                    } else {
                        Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                            .font(.largeTitle)
                    }
                }
                .tint(.primary)
                .frame(width: 60)
            }
            .padding(16)
            
            ASSearchBar(text: $text, placeHolder: String(localized: "곡 제목을 검색하세요"))
            
            List([TutorialData.superShy, TutorialData.loser]) { music in
                Button {
                    selectedMusic = music
                    playMusic()
                    isPlaying = true
                    handler(selectedMusic)
                } label: {
                    ASMusicItemCell(music: music) { url in
                        guard let url else { return nil }
                        return try? await URLSession.shared.data(from: url).0
                    }
                    .tint(.black)
                }
            }
            .listStyle(.plain)
            .scrollDismissesKeyboard(.immediately)
        }
        .background(.asLightGray)
    }
    
    func playMusic() {
        Task {
            guard let url = selectedMusic?.previewUrl else { return }
            
            let musicData = try await URLSession.shared.data(from: url).0
            await AudioHelper.shared.startPlaying(musicData)
        }
    }
    
    func stopMusic() {
        Task {
            await AudioHelper.shared.stopPlaying()
        }
    }
}

#Preview {
    SelectMusicTutorialView { _ in }
}
