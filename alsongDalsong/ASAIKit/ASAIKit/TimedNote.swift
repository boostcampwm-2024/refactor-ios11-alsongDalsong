import MIDIKitCore

public struct TimedNote: Sendable {
    let startTime: Double
    let endTime: Double
    let pitch: UInt7
    let velocity: UInt7
}
