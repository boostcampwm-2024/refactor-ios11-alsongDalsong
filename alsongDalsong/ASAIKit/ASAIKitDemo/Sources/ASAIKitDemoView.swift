import SwiftUI

struct ASAIKitDemoView: View {
    @StateObject private var vm = ASAIKitDemoViewModel()
    
    var body: some View {
        VStack {
            Text("알쏭달쏭 데이터 모으기")
                .font(.custom("DoHyeon-Regular", size: 36))
                .padding(.top)
            
            Text("허밍해주세요.. 당신의 소중한 데이터를 기다리고 있습니다. - From.AI")
                .font(.custom("DoHyeon-Regular", size: 16))
                .foregroundStyle(.secondary)
                .padding(.bottom)
            
            Text("내가 제출한 허밍 횟수 \(vm.submitCount)")
                .font(.custom("DoHyeon-Regular", size: 20))
                .padding(.bottom)
            
            
            VStack(alignment: .leading) {
                Text("이름 선택")
                    .font(.custom("DoHyeon-Regular", size: 16))
                    .foregroundStyle(.secondary)
                
                HStack {
                    ForEach(vm.testers, id: \.self) { tester in
                        ASAIKitButton(title: tester, fontSize: 20, color: .mint, isSelected: vm.name == tester) {
                            vm.name == tester ? (vm.name = "") : (vm.name = tester)
                        }
                    }
                }
            }
            .padding(.top)
            
            VStack(alignment: .leading) {
                Text("노래 선택")
                    .font(.custom("DoHyeon-Regular", size: 16))
                    .foregroundStyle(.secondary)
                
                ForEach(vm.songs, id: \.self) { song in
                    ASAIKitButton(title: song, fontSize: 22, color: .mint, isSelected: vm.song == song) {
                        vm.song == song ? (vm.song = "") : (vm.song = song)
                    }
                }
            }
            .padding(.top)
            
            Spacer()
            
            HStack(spacing: 4) {
                Button(action: vm.togglePlaying) {
                    Image(systemName: vm.isRecording ? "circle.fill" : vm.isPlaying ? "stop.fill" : "play.fill")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .foregroundStyle(vm.isRecording ? .red : .primary)
                        .contentTransition(.symbolEffect(.replace))
                }
                .disabled(vm.isRecording)
                .frame(width: 36)
                
                ForEach(vm.amplitudes.indices, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .frame(width: 2, height: min(100, vm.amplitudes[index] * 100 + 4))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .padding()
            .background(Color.orange)
            .cornerRadius(12)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(lineWidth: 4)
            }
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .foregroundStyle(.black)
                    .offset(x: 4, y: 4)
            }
            
            Spacer()
            
            Text("플레이 버튼을 눌러 녹음을 확인해보세요.")
                .font(.custom("DoHyeon-Regular", size: 18))
                .foregroundStyle(vm.recordedData == nil ? .clear : .secondary)
                .padding(.bottom, 8)
            
            HStack {
                ASAIKitButton(title: vm.isRecording ? "녹음 취소" : "녹음 시작", color: .red, action: vm.toggleRecording)
                
                ASAIKitButton(title: "제출 하기", color: .green, isDisabled: vm.submitButtonDisabled, action: vm.uploadData)
            }
        }
        .onChange(of: vm.message) { _, newValue in
            guard !newValue.isEmpty else { return }
            vm.isPresented = true
        }
        .padding()
        .overlay {
            if vm.isPresented {
                Color.black.opacity(0.2).ignoresSafeArea()
                ASAIKitMessage(isPresented: $vm.isPresented, message: $vm.message)
            }
        }
    }
}

#Preview {
    ASAIKitDemoView()
}
