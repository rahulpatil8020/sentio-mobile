import Foundation

enum DateUtils {
    static func localizedShortDay(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }

    static func localizedDayNumber(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    static func localizedFullDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
