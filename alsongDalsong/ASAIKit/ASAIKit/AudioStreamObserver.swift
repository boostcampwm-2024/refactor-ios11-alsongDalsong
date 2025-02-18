import SoundAnalysis

/// 분석 결과를 받아 처리할 옵저버
/// 각 분석 결과의 identifier별로 발생 횟수와 누적 신뢰도를 저장한 후,
/// 분석 완료 시 해당 identifier의 평균 신뢰도를 계산하여 AudioAnalyeResult로 전달합니다.
final class AudioStreamObserver: NSObject, SNResultsObserving, ObservableObject {
    var predictCount: [String: Int] = [:]
    var totalConfidence: [String: Double] = [:]

    var completion: ((AudioAnalyeResult) -> Void)?

    /// 분석 결과가 도착하면 호출됩니다.
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let classificationResult = result as? SNClassificationResult else { return }
        guard let bestClassification = classificationResult.classifications.first else { return }
        let identifier = bestClassification.identifier
        let conf = bestClassification.confidence

        predictCount[identifier] = (predictCount[identifier] ?? 0) + 1
        totalConfidence[identifier] = (totalConfidence[identifier] ?? 0.0) + conf
        print(predictCount)
        print(totalConfidence)
    }

    /// 에러 발생 시 호출됩니다.
    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("Sound analysis failed: \(error.localizedDescription)")
    }

    /// 분석이 완료되었을 때 호출됩니다.
    func requestDidComplete(_ request: SNRequest) {
        guard let bestEntry = predictCount.max(by: { $0.value < $1.value }) else {
            return
        }
        let identifier = bestEntry.key
        let count = bestEntry.value
        let sumConfidence = totalConfidence[identifier] ?? 0.0
        let avgConfidence = sumConfidence / Double(count)
        completion?((identifier, avgConfidence))
        predictCount = [:]
        totalConfidence = [:]
    }
}
