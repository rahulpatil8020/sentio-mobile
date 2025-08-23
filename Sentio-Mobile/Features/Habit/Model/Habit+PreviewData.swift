//
//  Habit+PreviewData.swift
//  Sentio-Mobile
//
//  Created by Rahul Patil on 8/23/25.
//

import Foundation

extension Habit {
    static var previewHabits: [Habit] {
        let cal = Calendar.current
        let today = Date()
        let yesterday = cal.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = cal.date(byAdding: .day, value: -2, to: today)!

        return [
            Habit(
                id: "h1",
                title: "Morning Run",
                description: "Run at least 2km",
                createdAt: twoDaysAgo,
                updatedAt: nil,
                startDate: twoDaysAgo,
                endDate: nil,
                frequency: "daily",
                reminderTime: "07:00 AM",
                streak: Streak(current: 5, longest: 12, lastCompletedDate: yesterday),
                completions: [Completion(date: today), Completion(date: twoDaysAgo)],
                isDeleted: false,
                isAccepted: true
            ),
            Habit(
                id: "h2",
                title: "Read Book",
                description: "Read 20 pages of non-fiction",
                createdAt: twoDaysAgo,
                updatedAt: nil,
                startDate: twoDaysAgo,
                endDate: nil,
                frequency: "daily",
                reminderTime: "09:00 PM",
                streak: Streak(current: 2, longest: 4, lastCompletedDate: twoDaysAgo),
                completions: [Completion(date: yesterday)],
                isDeleted: false,
                isAccepted: true
            ),
            Habit(
                id: "h3",
                title: "Meditation",
                description: "15 minutes mindfulness practice",
                createdAt: twoDaysAgo,
                updatedAt: nil,
                startDate: twoDaysAgo,
                endDate: nil,
                frequency: "weekly",
                reminderTime: nil,
                streak: Streak(current: 0, longest: 3, lastCompletedDate: nil),
                completions: [],
                isDeleted: false,
                isAccepted: false
            ),
            Habit(
                id: "h4",
                title: "Stretching Routine",
                description: "5-minute mobility",
                createdAt: twoDaysAgo,
                updatedAt: nil,
                startDate: twoDaysAgo,
                endDate: nil,
                frequency: "monthly",
                reminderTime: "08:00 AM",
                streak: Streak(current: 1, longest: 2, lastCompletedDate: twoDaysAgo),
                completions: [],
                isDeleted: false,
                isAccepted: true
            )
        ]
    }
}
