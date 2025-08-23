import Foundation

// MARK: - Server payloads

/// TODAY payload (includes habits once)
struct DailyDataFullResponse: Decodable {
    let habits: [Habit]
    let todos: [Todo]                    // Incomplete todos (for today)
    let upcomingReminders: [Reminder]    // Only for today
    let emotionalStates: [EmotionalState]
    let transcripts: [Transcript]
}

/// TODAY snapshot that AppState keeps (no habits here)
struct DailyDataResponse: Decodable {
    let todos: [Todo]
    let upcomingReminders: [Reminder]
    let emotionalStates: [EmotionalState]
    let transcripts: [Transcript]
}

/// PAST day payload (no habits/reminders, has completedTodos)
struct PastDayResponse: Decodable {
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
    let title: String
    let description: String?
    let createdAt: Date
    let updatedAt: Date?
    let startDate: Date
    let endDate: Date?
    let frequency: String
    let reminderTime: String?
    let streak: Streak
    let completions: [Completion]
    let isDeleted: Bool
    let isAccepted: Bool
}

struct Todo: Decodable, Identifiable, Equatable {
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
            ),
            Todo(
                id: "todo3",
                title: "Make Dinner",
                completed: false,
                dueDate: Date().addingTimeInterval(3600), // in 1 hour
                createdBy: "USER",
                createdAt: Date().addingTimeInterval(-3600), // 1 hour ago
                priority: 4,
                completedAt: nil
            ),
            Todo(
                id: "todo4",
                title: "Code the block",
                completed: true,
                dueDate: nil,
                createdBy: "AI",
                createdAt: Date().addingTimeInterval(-86400), // yesterday
                priority: 8,
                completedAt: Date().addingTimeInterval(-1800)
            ),
            Todo(
                id: "todo5",
                title: "Make Anime figure",
                completed: false,
                dueDate: Date().addingTimeInterval(3600), // in 1 hour
                createdBy: "USER",
                createdAt: Date().addingTimeInterval(-3600), // 1 hour ago
                priority: 2,
                completedAt: nil
            ),
            Todo(
                id: "todo6",
                title: "Clean Glasses",
                completed: true,
                dueDate: nil,
                createdBy: "AI",
                createdAt: Date().addingTimeInterval(-86400), // yesterday
                priority: 6,
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
            ),
            Reminder(
                id: "reminder2",
                title: "Drink water",
                remindAt: Calendar.current.date(bySettingHour: 11, minute: 30, second: 0, of: Date())!,
                createdBy: "AI",
                createdAt: Date().addingTimeInterval(-3600)
            ),
            Reminder(
                id: "reminder3",
                title: "Stand & stretch",
                remindAt: Calendar.current.date(bySettingHour: 15, minute: 0, second: 0, of: Date())!,
                createdBy: "USER",
                createdAt: Date().addingTimeInterval(-10800)
            ),
            Reminder(
                id: "reminder4",
                title: "Call mom",
                remindAt: Calendar.current.date(bySettingHour: 18, minute: 30, second: 0, of: Date())!,
                createdBy: "AI",
                createdAt: Date().addingTimeInterval(-5400)
            ),
            Reminder(
                id: "reminder5",
                title: "Plan tomorrow’s tasks",
                remindAt: Calendar.current.date(bySettingHour: 21, minute: 15, second: 0, of: Date())!,
                createdBy: "USER",
                createdAt: Date().addingTimeInterval(-7200)
            ),
            Reminder(
                id: "reminder6",
                title: "Take vitamins",
                remindAt: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!,
                createdBy: "AI",
                createdAt: Date().addingTimeInterval(-14400)
            )
        ],
        emotionalStates: [
            EmotionalState(
                id: "emotion3",
                state: "anxious",
                intensity: 7,
                note: "Before the meeting I felt a wave of anxiety build up in my chest. My thoughts kept circling around possible mistakes and unfinished work. Even though I knew most of it was exaggerated, my body reacted with restlessness and an uneasy heartbeat.",
                createdAt: Date().addingTimeInterval(-10800) // 3h ago
            ),
            EmotionalState(
                id: "emotion4",
                state: "happy",
                intensity: 9,
                note: "Lunch with a close friend brought genuine happiness today. We laughed about old stories, shared updates about our current struggles, and encouraged each other. For a while I forgot about deadlines and responsibilities, and just felt the warmth of being seen and supported by someone I trust.",
                createdAt: Date().addingTimeInterval(-14400) // 4h ago
            ),
            EmotionalState(
                id: "emotion5",
                state: "frustrated",
                intensity: 6,
                note: "The app bug kept resurfacing despite my repeated attempts to fix it. Each failure chipped away at my patience, making me clench my jaw and sigh heavily. I recognized the irritation building and tried stepping back, but the sense of being stuck lingered longer than expected.",
                createdAt: Date().addingTimeInterval(-18000) // 5h ago
            ),
            EmotionalState(
                id: "emotion6",
                state: "content",
                intensity: 7,
                note: "After finishing a long coding session, I leaned back in my chair and felt quietly satisfied. The solution wasn’t perfect, but it worked, and that was enough. I enjoyed the calm that followed progress, sipping tea and appreciating the small victories I often overlook.",
                createdAt: Date().addingTimeInterval(-21600) // 6h ago
            )
            
        ],
        transcripts: [
            Transcript(
                id: "transcript3",
                text: """
            This morning I woke up earlier than usual and spent a quiet half hour just making coffee and sitting near the window. The streets outside were still half asleep, and the light had that pale golden tint that only shows up at sunrise. I didn’t rush to check emails or scroll through my phone. Instead, I just let myself sit there, listening to the hum of the ceiling fan and the occasional sound of a bird outside. It wasn’t anything extraordinary, but it felt grounding. I realized how rarely I give myself that kind of stillness, and I noticed my breathing slow down naturally. It set a peaceful tone for the rest of my day.
            """,
                summary: "Early morning quiet moment, felt grounding and calming.",
                createdAt: Date().addingTimeInterval(-12000)
            ),
            Transcript(
                id: "transcript4",
                text: """
            Work was intense today, but there was also a sense of accomplishment that came with it. I managed to close out a feature that had been hanging over me for weeks. There were a few bugs that almost made me throw in the towel, but after a deep breath and a quick walk, I came back with a clearer mind. By the time I fixed the last issue, I felt a rush of relief mixed with pride. It reminded me that persistence pays off, but also that breaks are not wasted time. I ended the day mentally tired but emotionally satisfied, which feels like a good trade.
            """,
                summary: "Overcame challenges at work, persistence and breaks helped.",
                createdAt: Date().addingTimeInterval(-20000)
            ),
            Transcript(
                id: "transcript5",
                text: """
            I had a long phone call with my parents this afternoon. It wasn’t anything dramatic, just a catch-up, but it left me feeling strangely emotional. Hearing their voices reminded me of how much I miss the small routines at home—the way my mom hums while cooking or how my dad reads the newspaper out loud like it’s breaking news. We talked about ordinary things like groceries and neighbors, yet there was comfort in the ordinary. I sometimes forget that love doesn’t always arrive in grand gestures. Sometimes it’s just being asked whether I’ve eaten lunch, or being reminded to take care of myself. I felt both grateful and a little nostalgic afterward.
            """,
                summary: "Family call evoked comfort, nostalgia, and gratitude.",
                createdAt: Date().addingTimeInterval(-26000)
            ),
            Transcript(
                id: "transcript6",
                text: """
            The evening run was tougher than I expected. My legs felt heavy, and the humid air didn’t make it any easier. For the first ten minutes, I kept bargaining with myself to turn back early, but then something shifted. My breathing found a rhythm, and my body adjusted. By the time I hit the halfway point, I wasn’t fighting anymore—I was just moving. It wasn’t fast or impressive, but it felt steady. When I finally reached home, sweat-soaked and tired, there was a quiet sense of victory. Not every run needs to be amazing. Sometimes showing up and finishing is the real achievement.
            """,
                summary: "Tough run turned into steady progress; resilience paid off.",
                createdAt: Date().addingTimeInterval(-32000)
            )        ]
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
                Completion(date: Date().addingTimeInterval(-86400)),
                Completion(date: Date())
            ],
            isDeleted: false,
            isAccepted: true
        ),
        Habit(
            id: "habit2",
            title: "Read 10 Pages",
            description: "Read from any book of choice",
            createdAt: Date().addingTimeInterval(-86400 * 5),
            updatedAt: nil,
            startDate: Date().addingTimeInterval(-86400 * 5),
            endDate: nil,
            frequency: "daily",
            reminderTime: "21:00",
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
        ),
        Habit(
            id: "habit3",
            title: "Meditation",
            description: "10 minutes of mindfulness meditation",
            createdAt: Date().addingTimeInterval(-86400 * 20),
            updatedAt: nil,
            startDate: Date().addingTimeInterval(-86400 * 20),
            endDate: nil,
            frequency: "daily",
            reminderTime: "06:30",
            streak: Streak(
                current: 6,
                longest: 12,
                lastCompletedDate: Date().addingTimeInterval(-86400)
            ),
            completions: [
                Completion(date: Date().addingTimeInterval(-86400 * 6)),
                Completion(date: Date().addingTimeInterval(-86400 * 5)),
                Completion(date: Date().addingTimeInterval(-86400 * 4)),
                Completion(date: Date().addingTimeInterval(-86400 * 3)),
                Completion(date: Date().addingTimeInterval(-86400 * 2)),
                Completion(date: Date().addingTimeInterval(-86400))
            ],
            isDeleted: false,
            isAccepted: true
        ),
        Habit(
            id: "habit4",
            title: "Drink 2L Water",
            description: "Stay hydrated throughout the day",
            createdAt: Date().addingTimeInterval(-86400 * 15),
            updatedAt: nil,
            startDate: Date().addingTimeInterval(-86400 * 15),
            endDate: nil,
            frequency: "daily",
            reminderTime: nil,
            streak: Streak(
                current: 2,
                longest: 9,
                lastCompletedDate: nil
            ),
            completions: [],
            isDeleted: false,
            isAccepted: true
        ),
        Habit(
            id: "habit5",
            title: "Weekly Meal Prep",
            description: "Prepare healthy meals for the week",
            createdAt: Date().addingTimeInterval(-86400 * 30),
            updatedAt: nil,
            startDate: Date().addingTimeInterval(-86400 * 30),
            endDate: nil,
            frequency: "weekly",
            reminderTime: "17:00",
            streak: Streak(
                current: 3,
                longest: 5,
                lastCompletedDate: Calendar.current.date(byAdding: .day, value: -7, to: Date())
            ),
            completions: [
                Completion(date: Date().addingTimeInterval(-86400 * 7)),
                Completion(date: Date().addingTimeInterval(-86400 * 14)),
                Completion(date: Date().addingTimeInterval(-86400 * 21))
            ],
            isDeleted: false,
            isAccepted: true
        ),
        Habit(
            id: "habit6",
            title: "Gratitude Journal",
            description: "Write 3 things I'm grateful for",
            createdAt: Date().addingTimeInterval(-86400 * 12),
            updatedAt: nil,
            startDate: Date().addingTimeInterval(-86400 * 12),
            endDate: nil,
            frequency: "daily",
            reminderTime: "22:00",
            streak: Streak(
                current: 5,
                longest: 5,
                lastCompletedDate: Date()
            ),
            completions: [
                Completion(date: Date().addingTimeInterval(-86400 * 4)),
                Completion(date: Date().addingTimeInterval(-86400 * 3)),
                Completion(date: Date().addingTimeInterval(-86400 * 2)),
                Completion(date: Date().addingTimeInterval(-86400)),
                Completion(date: Date())
            ],
            isDeleted: false,
            isAccepted: true
        ),
        Habit(
            id: "habit7",
            title: "Sunday Cleaning",
            description: "Tidy and clean the apartment",
            createdAt: Date().addingTimeInterval(-86400 * 40),
            updatedAt: nil,
            startDate: Date().addingTimeInterval(-86400 * 40),
            endDate: nil,
            frequency: "weekly",
            reminderTime: "10:00",
            streak: Streak(
                current: 2,
                longest: 4,
                lastCompletedDate: Calendar.current.date(byAdding: .day, value: -7, to: Date())
            ),
            completions: [
                Completion(date: Date().addingTimeInterval(-86400 * 7)),
                Completion(date: Date().addingTimeInterval(-86400 * 14))
            ],
            isDeleted: false,
            isAccepted: true
        ),
        Habit(
            id: "habit8",
            title: "Monthly Budget Review",
            description: "Check expenses and savings",
            createdAt: Date().addingTimeInterval(-86400 * 60),
            updatedAt: nil,
            startDate: Date().addingTimeInterval(-86400 * 60),
            endDate: nil,
            frequency: "monthly",
            reminderTime: "19:00",
            streak: Streak(
                current: 1,
                longest: 2,
                lastCompletedDate: Calendar.current.date(byAdding: .day, value: -30, to: Date())
            ),
            completions: [
                Completion(date: Date().addingTimeInterval(-86400 * 30)),
                Completion(date: Date().addingTimeInterval(-86400 * 60))
            ],
            isDeleted: false,
            isAccepted: true
        )
    ]
}
