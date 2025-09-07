import Foundation

// MARK: - Server payloads

/// TODAY payload (includes habits once)
// MARK: - Full Daily Data (with habits)
struct DailyDataFullResponse: Decodable {
    let success: Bool
    let message: String
    let data: DailyDataFull
}

struct DailyDataFull: Decodable {
    let habits: [Habit]
    let incompleteTodos: [Todo]          // Incomplete todos (for today)
    let upcomingReminders: [Reminder]    // Only for today
    let emotionalStates: [EmotionalState]
    let transcripts: [Transcript]
}

// MARK: - Today Snapshot (no habits here)
struct DailyDataResponse: Decodable {
    let success: Bool
    let message: String
    let data: DailyData
}

struct DailyData: Decodable {
    let todos: [Todo]
    let upcomingReminders: [Reminder]
    let emotionalStates: [EmotionalState]
    let transcripts: [Transcript]
}

// MARK: - Past Day Payload (no habits/reminders, has completedTodos)
struct PastDayResponse: Decodable {
    let success: Bool
    let message: String
    let data: PastDayData
}

struct PastDayData: Decodable {
    let completedTodos: [Todo]           // Completed on that day
    let emotionalStates: [EmotionalState]
    let transcripts: [Transcript]
}

// MARK: - UI-facing snapshot
struct DayDisplay {
    let dayKey: String          // "yyyy-MM-dd" for the date this snapshot represents
    let isToday: Bool
    let todos: [Todo]
    let reminders: [Reminder]   // empty for past days
    let emotionalStates: [EmotionalState]
    let transcripts: [Transcript]
}

// MARK: - Your other types (unchanged)

struct Habit: Decodable, Identifiable {
    let id: String
    let userId: String?
    let title: String
    let description: String?
    let frequency: String
    let streak: Streak
    let completions: [Completion]
    let isDeleted: Bool
    let isAccepted: Bool
    let createdAt: Date
    let startDate: Date
    
    // Optional fields (not always sent by API, but useful to keep)
    let updatedAt: Date?
    let endDate: Date?
    let reminderTime: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId
        case title
        case description
        case frequency
        case streak
        case completions
        case isDeleted
        case isAccepted
        case createdAt
        case startDate
        case updatedAt
        case endDate
        case reminderTime
    }
}

struct Todo: Decodable, Identifiable, Equatable {
    let id: String
    let title: String
    let completed: Bool
    let dueDate: Date?
    let createdBy: String
    let createdAt: Date
    let priority: Int
    
    // Optional fields (not in API right now but good to keep)
    let completedAt: Date?
    let userId: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId
        case title
        case completed
        case dueDate
        case createdBy
        case createdAt
        case priority
        case completedAt
    }
}

struct Reminder: Decodable, Identifiable {
    let id: String
    let title: String
    let remindAt: Date
    let createdBy: String
    let createdAt: Date
}

struct EmotionalState: Decodable, Identifiable {
    let id: String
    let state: String
    let intensity: Int
    let note: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case state
        case intensity
        case note
        case createdAt
    }
}


struct Transcript: Decodable, Identifiable {
    let id: String
    let text: String
    let summary: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case text
        case summary
        case createdAt
    }
}

struct Streak: Decodable {
    let current: Int
    let longest: Int
    let lastCompletedDate: Date?
}

struct Completion: Decodable {
    let date: Date
}


