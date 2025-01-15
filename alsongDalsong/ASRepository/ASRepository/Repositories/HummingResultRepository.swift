import ASEntity
import ASRepositoryProtocol
import Combine
import Foundation

final class HummingResultRepository: HummingResultRepositoryProtocol {
    private var mainRepository: MainRepositoryProtocol

    init(
        mainRepository: MainRepositoryProtocol
    ) {
        self.mainRepository = mainRepository
    }

    func getResult() ->
        AnyPublisher<[(
            answer: Answer,
            records: [ASEntity.Record],
            submit: Answer,
            recordOrder: UInt8
        )], Never>
    {
        Publishers.Zip4(mainRepository.answers, mainRepository.records, mainRepository.submits, mainRepository.recordOrder)
            .compactMap { answers, records, submits, recordOrder in
                answers?.map { answer in
                    let relatedRecords: [ASEntity.Record] = self.getRelatedRecords(for: answer,
                                                                                   from: records,
                                                                                   count: answers?.count ?? 0)
                    let relatedSubmit: Answer = self.getRelatedSubmit(for: answer, from: submits)

                    return (answer: answer, records: relatedRecords, submit: relatedSubmit, recordOrder: recordOrder ?? 0)
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    private func getRelatedRecords(for answer: Answer, from records: [ASEntity.Record]?, count: Int) -> [ASEntity.Record] {
        var filteredRecords: [ASEntity.Record] = []

        for i in 0 ..< count {
            let tempCheck: Int = (((answer.player?.order ?? 0) + i) % count)
            if let filteredRecord = records?.first(where: { record in
                (tempCheck == record.player?.order) &&
                    (record.recordOrder ?? 0 == i)
            }) {
                filteredRecords.append(filteredRecord)
            }
        }

        return filteredRecords
    }

    private func getRelatedSubmit(for answer: Answer, from submits: [Answer]?) -> Answer {
        let temp = (answer.player?.order ?? 0) - 1 + (submits?.count ?? 0)
        let targetOrder = temp % (submits?.isEmpty == true ? 1 : submits?.count ?? 1)

        let submit = submits?.first(where: { submit in
            targetOrder == submit.player?.order
        })

        // TODO: nil 값에 대한 처리 필요
        return submit ?? Answer.answerStub1
    }
}
