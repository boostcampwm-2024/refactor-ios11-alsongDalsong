import Foundation

public struct Room: Codable {
    public var number: String?
    public var host: Player?
    public var players: [Player]?
    public var mode: Mode?
    public var round: UInt8?
    public var status: Status?
    public var recordOrder: UInt8?
    public var records: [Record]?
    public var answers: [Answer]?
    public var dueTime: Date?
    public var selectedRecords: [UInt8]?
    public var submits: [Answer]?
}
