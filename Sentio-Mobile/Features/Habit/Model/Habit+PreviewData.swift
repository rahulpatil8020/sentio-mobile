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
        let threeDaysAgo = cal.date(byAdding: .day, value: -3, to: today)!
        let lastWeek = cal.date(byAdding: .day, value: -7, to: today)!
        let lastMonth = cal.date(byAdding: .month, value: -1, to: today)!


        return [
            Habit(
                id: "h1",
                userId: "u1",
                title: "Hydration",
                description: "Drink at least 2 liters of water daily.",
                frequency: "daily",
                streak: Streak(current: 5, longest: 10, lastCompletedDate: yesterday),
                completions: [
                    Completion(date: today),
                    Completion(date: yesterday),
                    Completion(date: threeDaysAgo)
                ],
                isDeleted: false,
                isAccepted: true,
                createdAt: lastWeek,
                startDate: lastWeek,
                updatedAt: nil,
                endDate: nil,
                reminderTime: "10:00 AM"
            ),
            Habit(
                id: "h2",
                userId: "u1",
                title: "Evening Walk",
                description: "Walk for 20 minutes after dinner.",
                frequency: "daily",
                streak: Streak(current: 2, longest: 6, lastCompletedDate: today),
                completions: [
                    Completion(date: today),
                    Completion(date: yesterday)
                ],
                isDeleted: false,
                isAccepted: true,
                createdAt: lastMonth,
                startDate: lastMonth,
                updatedAt: nil,
                endDate: nil,
                reminderTime: "08:30 PM"
            ),
            Habit(
                id: "h3",
                userId: "u1",
                title: "Weekly Review",
                description: "Review personal goals and progress.",
                frequency: "weekly",
                streak: Streak(current: 0, longest: 3, lastCompletedDate: nil),
                completions: [],
                isDeleted: false,
                isAccepted: false, // still pending
                createdAt: lastWeek,
                startDate: lastWeek,
                updatedAt: nil,
                endDate: nil,
                reminderTime: "Sunday 06:00 PM"
            ),
            Habit(
                id: "h4",
                userId: "u1",
                title: "Journal Writing",
                description: "Write daily reflection before bed.",
                frequency: "daily",
                streak: Streak(current: 1, longest: 4, lastCompletedDate: today),
                completions: [
                    Completion(date: today)
                ],
                isDeleted: false,
                isAccepted: true,
                createdAt: today,
                startDate: today,
                updatedAt: nil,
                endDate: nil,
                reminderTime: "10:00 PM"
            ),
            Habit(
                id: "h5",
                userId: "u1",
                title: "Volunteer Work",
                description: "Spend 2 hours on community service.",
                frequency: "monthly",
                streak: Streak(current: 0, longest: 1, lastCompletedDate: lastMonth),
                completions: [
                    Completion(date: lastMonth)
                ],
                isDeleted: false,
                isAccepted: true,
                createdAt: lastMonth,
                startDate: lastMonth,
                updatedAt: nil,
                endDate: nil,
                reminderTime: nil
            )
        ]
    }
}
