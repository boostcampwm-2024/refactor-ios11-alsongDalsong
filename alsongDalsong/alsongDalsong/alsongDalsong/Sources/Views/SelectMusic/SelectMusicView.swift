import SwiftUI

struct SelectMusicView: View {
    @ObservedObject var viewModel: SelectMusicViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ASMusicItemCell(music: viewModel.selectedMusic, fetchArtwork: { url in
                    await viewModel.downloadArtwork(url: url)
                })
                .scaleEffect(1.1)
                Spacer()
                Button {
                    if viewModel.selectedMusic != nil {
                        viewModel.isPlaying.toggle()
                    }
                } label: {
                    if #available(iOS 17.0, *) {
                        Image(systemName: viewModel.isPlaying ? "stop.fill" : "play.fill")
                            .font(.largeTitle)
                            .contentTransition(.symbolEffect(.replace.offUp))
                    } else {
                        Image(systemName: viewModel.isPlaying ? "stop.fill" : "play.fill")
                            .font(.largeTitle)
                    }
                }
                .tint(.primary)
                .frame(width: 60)
            }
            .padding(16)

            ASSearchBar(text: $viewModel.searchTerm, placeHolder: String(localized: "곡 제목을 검색하세요"))
                .padding(.bottom, 8)

            if viewModel.searchTerm.isEmpty {
                VStack(alignment: .center) {
                    Spacer()
                    Text("음악을 선택하세요!")
                        .font(.doHyeon(size: 36))
                    Spacer()
                }
            } else {
                if viewModel.isSearching {
                    VStack {
                        Spacer()
                        ProgressView()
                            .scaleEffect(2.0)
                        Spacer()
                    }
                    .scrollDismissesKeyboard(.immediately)
                } else {
                    List(viewModel.searchList) { music in
                        Button {
                            viewModel.handleSelectedSong(with: music)
                        } label: {
                            ASMusicItemCell(music: music, fetchArtwork: { url in
                                await viewModel.downloadArtwork(url: url)
                            })
                            .tint(.black)
                        }
                    }
                    .listStyle(.plain)
                    .scrollDismissesKeyboard(.immediately)
                }
            }
        }
        .background(.asLightGray)
    }
}

#Preview {
//    SelectMusicView(v)
}
