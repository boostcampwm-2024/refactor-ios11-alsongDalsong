import Foundation

struct TimedNote {
  let startTime: Float
  let endTime: Float
  let pitch: Int
  let velocity: Int
}

public struct ASBPAnalyzer {
    // MARK: - 최종 함수

    func getSimularity(songTimedNote: [TimedNote], targetTimedNote: [TimedNote]) -> Double {
        let aVector = convertToVector(timedNotes: songTimedNote)
        let bVector = convertToVector(timedNotes: targetTimedNote)
        
        let distance = dtwDistance(sequence1: aVector, sequence2: bVector)
        let maxDistance = 383.2346332942436
        let simularity = (1 - (distance / maxDistance)) * 100
        
        return simularity.rounded()
    }
}

extension ASBPAnalyzer {
    // MARK: - 피치를 Piano Roll 벡터로 변환하는 함수

    private func convertToVector(timedNotes: [TimedNote]) -> [[Int]] {
        let endTime = timedNotes.map { $0.endTime }.max() ?? 30
        var result = [[Int]]()
        
        for time in stride(from: 0, to: endTime, by: 0.1) {
            var pitches = Array(repeating: 0, count: 128)
            
            for timedNote in timedNotes {
                if timedNote.startTime...timedNote.endTime ~= time {
                    pitches[timedNote.pitch] = 1
                }
            }
            
            result.append(pitches)
        }
        
        return result
    }

    // MARK: - DTW 거리 계산 함수 (다차원 시계열)
    
    private func dtwDistance(sequence1: [[Int]], sequence2: [[Int]]) -> Double {
        let n = sequence1.count
        let m = sequence2.count

        // (n+1) x (m+1) 크기의 dtw 행렬을 매우 큰 값으로 초기화합니다.
        var dtw = Array(
            repeating: Array(repeating: Double.greatestFiniteMagnitude, count: m + 1),
            count: n + 1
        )
        
        dtw[0][0] = 0.0
        
        let cache = NSCache<NSString, NSString>()

        // 경계값 설정 (첫 행, 첫 열)
        for i in 1...n {
            dtw[i][0] = Double.greatestFiniteMagnitude
        }
        
        for j in 1...m {
            dtw[0][j] = Double.greatestFiniteMagnitude
        }

        // DTW 동적 계획법 수행
        for i in 1...n {
            for j in 1...m {
                let cost = euclideanDistance(sequence1[i - 1], sequence2[j - 1])
                let minPrev = min(dtw[i - 1][j], dtw[i][j - 1])
                let lastMin = min(minPrev, dtw[i - 1][j - 1])
                dtw[i][j] = cost + lastMin
            }
        }
        
        return dtw[n][m]
    }
    
    // MARK: - 벡터 간 유클리드 거리 계산 함수
    
    private func euclideanDistance(_ a: [Int], _ b: [Int]) -> Double {
        precondition(a.count == b.count, "벡터의 차원이 같아야 합니다.")
        var sum = 0
        for i in 0..<a.count {
            let diff = a[i] - b[i]
            sum += diff * diff
        }
        return sqrt(Double(sum))
    }
}
