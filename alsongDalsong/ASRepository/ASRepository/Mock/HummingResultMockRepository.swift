import ASEntity
import ASRepositoryProtocol
import Combine

public final class HummingResultMockRepository: HummingResultRepositoryProtocol {
    private let answers = [
        Answer.answerStub1,
        Answer.answerStub2,
        Answer.answerStub3,
        Answer.answerStub4
    ]
    private let records = [
        [Record.recordStub1_1, Record.recordStub2_2, Record.recordStub3_3],
        [Record.recordStub2_1, Record.recordStub3_2, Record.recordStub4_3],
        [Record.recordStub3_1, Record.recordStub4_2, Record.recordStub1_3],
        [Record.recordStub4_1, Record.recordStub1_2, Record.recordStub2_3],
    ]
    private let submits = [
        Answer.answerStub4,
        Answer.answerStub3,
        Answer.answerStub2,
        Answer.answerStub1
    ]
    private var recordOrders: UInt8 = 3
    private var index = 0

    public init() {}

    public func getResult() ->
        AnyPublisher<[(
            answer: Answer,
            records: [ASEntity.Record],
            submit: Answer,
            recordOrder: UInt8
        )], Never>
    {
        let result = answers.map { answer in
            let records = self.records[index]
            let submit = submits[index]
            let recordOrder = recordOrders
            recordOrders += 1
            index += 1
            return (answer, records, submit, recordOrder)
        }
        return Just(result)
            .eraseToAnyPublisher()
    }
}
