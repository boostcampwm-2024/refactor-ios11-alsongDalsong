internal import BasicPitch
internal import MIDIKitSMF

public enum ASAIAnalyzer {
    private struct ActiveNote {
        let startTime: Double
        let velocity: UInt7
    }
    
    public static func analyzeAudioFile(audioData: Data) async -> [TimedNote] {
        guard let fileURL = makeFile(audioData),
              let noteCreation = try? BasicPitch.predict(fileURL),
              let midiFile = try? noteCreation.genMidiFile() else { return [] }
        
        defer {
            removeFile(fileURL)
        }
        
        var timedNoteArr = [TimedNote]()
        let secondsPerBeat = 60.0 / getTempo(from: midiFile)
        let secondsPerTick = secondsPerBeat / getTicksPerBeat(from: midiFile) // 1틱이 몇초인지 계산
        
        var activeNotes = [UInt7: ActiveNote]()

        for track in midiFile.tracks {
            var totalTime: Double = 0
            
            for event in track.events {
                guard let data = event.event() else { continue }
                
                totalTime += calcDeltaTime(event: event, secondsPerTick: secondsPerTick)
                
                switch data {
                    case .noteOn(let noteOn):
                        if noteOn.velocity.midi1Value != 0 {
                            activeNotes[noteOn.note.number] = ActiveNote(
                                startTime: totalTime,
                                velocity: noteOn.velocity.midi1Value
                            )
                        } else if let activeNote = activeNotes[noteOn.note.number] {
                            let timedNote = TimedNote(
                                startTime: activeNote.startTime,
                                endTime: totalTime,
                                pitch: UInt8(noteOn.note.number),
                                velocity: UInt8(activeNote.velocity)
                            )
                            timedNoteArr.append(timedNote)
                            activeNotes[noteOn.note.number] = nil
                    }
                    default: continue
                }
            }
        }
        return timedNoteArr
    }
    
    private static func calcDeltaTime(event: MIDIFileEvent, secondsPerTick: Double) -> Double {
        // 이 부분은 GPT의 도움을 받아 작성된 코드입니다.
        switch event.delta {
           case .none:
                return 0
           case .ticks(let ticks):
                return Double(ticks) * secondsPerTick  // tick을 초 단위로 변환
           case .noteWhole:
                return 4.0 * secondsPerTick  // 온음표 (4분음표 4배 크기)
           case .noteHalf:
                return 2.0 * secondsPerTick  // 반음표 (4분음표 2배 크기)
           case .noteQuarter:
                return 1.0 * secondsPerTick  // 분음표 (기본 박자)
           case .note8th:
                return 0.5 * secondsPerTick  // 8분음표 (분음표의 절반 길이)
           case .note16th:
                return 0.25 * secondsPerTick  // 16분음표
           case .note32nd:
                return 0.125 * secondsPerTick  // 32분음표
           case .note64th:
                return 0.0625 * secondsPerTick  // 64분음표
           case .note128th:
                return 0.03125 * secondsPerTick  // 128분음표
           case .note256th:
                return 0.015625 * secondsPerTick  // 256분음표
           }
    }
    
    /// MIDI파일에서 ticksPerBeat를 반환하는 함수
    ///
    /// - Note: 예를 들어, 480은 1비트를 480개의 "틱"으로 나누는 것과 같음.
    private static func getTicksPerBeat(from midiFile: MIDIFile) -> Double {
        switch midiFile.timeBase {
           case .musical(let ticksPerQuarterNote):
               return Double(ticksPerQuarterNote)
           default:
               return 480.0
           }
    }
    
    /// MIDI 파일에서의 템포를 반환하는 함수
    ///
    /// - Note: '템포'는 분당 비트 수로 120 BPM이면 1분 동안 120개의 비트가 재생
    private static func getTempo(from midiFile: MIDIFile) -> Double {
        var tempoInBPM: Double = 120.0
        
        for chunk in midiFile.chunks {
            guard case .track(let track) = chunk else { continue }
            for event in track.events {
                if case let .tempo(_, event) = event {
                    tempoInBPM = Double(event.bpm)
                    break
                }
            }
        }
        return tempoInBPM
    }
}

// MARK: 부가적인 Method

extension ASAIAnalyzer {
    /// Data를 m4a 파일로 임시 저장한 후 해당 URL을 반환합니다.
    private static func makeFile(_ data: Data) -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "tempAudio-\(UUID().uuidString).m4a"
        let fileURL = tempDir.appendingPathComponent(fileName)
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("임시 파일 생성 실패: \(error)")
            return nil
        }
    }

    /// 지정된 파일 URL의 파일을 삭제합니다.
    private static func removeFile(_ fileURL: URL) {
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("파일 삭제 실패: \(error)")
        }
    }
}
