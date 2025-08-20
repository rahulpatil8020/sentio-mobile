import Foundation

struct DailyDataResponse: Decodable {
    let todos: [Todo]
    let upcomingReminders: [Reminder]
    let emotionalStates: [EmotionalState]
    let transcripts: [Transcript]
}

struct Habit: Decodable, Identifiable {
    let id: String
    let title: String
    let description: String?
    let createdAt: Date
    let updatedAt: Date?
    let startDate: Date
    let endDate: Date?
    let frequency: String // "daily" | "weekly" | "monthly"
    let reminderTime: String?
    let streak: Streak
    let completions: [Completion]
    let isDeleted: Bool
    let isAccepted: Bool
}

struct Todo: Decodable, Identifiable {
    let id: String
    let title: String
    let completed: Bool
    let dueDate: Date?
    let createdBy: String
    let createdAt: Date
    let priority: Int
    let completedAt: Date?
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
}

struct Transcript: Decodable, Identifiable {
    let id: String
    let text: String
    let summary: String?
    let createdAt: Date
}

struct Streak: Decodable {
    let current: Int
    let longest: Int
    let lastCompletedDate: Date?
}

struct Completion: Decodable {
    let date: Date
}

extension DailyDataResponse {
    static let mock: DailyDataResponse = DailyDataResponse(
        todos: [
            Todo(
                id: "todo1",
                title: "Finish journal entry",
                completed: false,
                dueDate: Date().addingTimeInterval(3600), // in 1 hour
                createdBy: "USER",
                createdAt: Date().addingTimeInterval(-3600), // 1 hour ago
                priority: 2,
                completedAt: nil
            ),
            Todo(
                id: "todo2",
                title: "Read for 30 minutes",
                completed: true,
                dueDate: nil,
                createdBy: "AI",
                createdAt: Date().addingTimeInterval(-86400), // yesterday
                priority: 5,
                completedAt: Date().addingTimeInterval(-1800)
            )
        ],
        upcomingReminders: [
            Reminder(
                id: "reminder1",
                title: "Evening meditation",
                remindAt: Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!,
                createdBy: "USER",
                createdAt: Date().addingTimeInterval(-7200)
            )
        ],
        emotionalStates: [
            EmotionalState(
                id: "emotion1",
                state: "calm",
                intensity: 6,
                note: "Felt relaxed after the walk",
                createdAt: Date().addingTimeInterval(-5400)
            ),
            EmotionalState(
                id: "emotion2",
                state: "relaxed",
                intensity: 8,
                note: "Felt relaxed after the walk",
                createdAt: Date().addingTimeInterval(-8400)
            )
        ],
        transcripts: [
            Transcript(
                id: "transcript1",
                text: "Today I felt really good after my morning workout. I think this routine is helping.",
                summary: "Positive reflection on workout",
                createdAt: Date().addingTimeInterval(-3000)
            ),
            Transcript(
                id: "transcript2",
                text: "Today I felt really good after my morning workout. I think this routine is helping.",
                summary: "Positive reflection on workout",
                createdAt: Date().addingTimeInterval(-8000)
            ),
        ]
    )
}

extension Habit {
    static let mockList: [Habit] = [
        Habit(
            id: "habit1",
            title: "Morning Run",
            description: "Run 3km every morning",
            createdAt: Date().addingTimeInterval(-86400 * 10),
            updatedAt: nil,
            startDate: Date().addingTimeInterval(-86400 * 10),
            endDate: nil,
            frequency: "daily",
            reminderTime: "07:00",
            streak: Streak(
                current: 4,
                longest: 7,
                lastCompletedDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())
            ),
            completions: [
                Completion(date: Date().addingTimeInterval(-86400 * 3)),
                Completion(date: Date().addingTimeInterval(-86400 * 2)),
                Completion(date: Date().addingTimeInterval(-86400 * 1)),
                Completion(date: Date())
            ],
            isDeleted: false,
            isAccepted: true
        ),
        Habit(
            id: "habit2",
            title: "Read 10 pages",
            description: "From any book",
            createdAt: Date().addingTimeInterval(-86400 * 5),
            updatedAt: nil,
            startDate: Date().addingTimeInterval(-86400 * 5),
            endDate: nil,
            frequency: "daily",
            reminderTime: nil,
            streak: Streak(
                current: 1,
                longest: 3,
                lastCompletedDate: Date().addingTimeInterval(-86400)
            ),
            completions: [
                Completion(date: Date().addingTimeInterval(-86400))
            ],
            isDeleted: false,
            isAccepted: true
        )
    ]
}
