//
//  HomeViewModel.swift
//  Sentio-Mobile
//
//  Created by Rahul Patil on 7/22/25.
//

import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var habits: [Habit] = []
    @Published var todos: [Todo] = []
    @Published var reminders: [Reminder] = []
    @Published var emotionalState: EmotionalState?
    @Published var user: User?
    
    @Published var pastHabits: [Habit] = []
    @Published var pastTodos: [Todo] = []
    @Published var pastReminders: [Reminder] = []
    @Published var pastEmotions: [EmotionalState] = []
    @Published var notifications: [NotificationItem] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Fetch Data
    func fetchData() async {
        isLoading = true
        errorMessage = nil

        do {
            async let habitsResponse: [Habit] = APIClient.shared.request(endpoint: "/habits", requiresAuth: true)
            async let todosResponse: [Todo] = APIClient.shared.request(endpoint: "/todos", requiresAuth: true)
            async let remindersResponse: [Reminder] = APIClient.shared.request(endpoint: "/reminders", requiresAuth: true)
            async let emotionResponse: EmotionalState = APIClient.shared.request(endpoint: "/emotional-state", requiresAuth: true)
            async let userResponse: User = APIClient.shared.request(endpoint: "/user/profile", requiresAuth: true)
            async let pastHabitsResponse: [Habit] = APIClient.shared.request(endpoint: "/habits/history", requiresAuth: true)
            async let pastTodosResponse: [Todo] = APIClient.shared.request(endpoint: "/todos/history", requiresAuth: true)
            async let pastRemindersResponse: [Reminder] = APIClient.shared.request(endpoint: "/reminders/history", requiresAuth: true)
            async let pastEmotionsResponse: [EmotionalState] = APIClient.shared.request(endpoint: "/emotional-state/history", requiresAuth: true)
            async let notificationsResponse: [NotificationItem] = APIClient.shared.request(endpoint: "/notifications", requiresAuth: true)

            // Current data
            habits = try await habitsResponse
            todos = try await todosResponse
            reminders = try await remindersResponse
            emotionalState = try await emotionResponse
            user = try await userResponse

            // Past data
            pastHabits = try await pastHabitsResponse
            pastTodos = try await pastTodosResponse
            pastReminders = try await pastRemindersResponse
            pastEmotions = try await pastEmotionsResponse

            // Notifications
            notifications = try await notificationsResponse
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Logout
    func logout() {
        TokenManager.shared.accessToken = nil
        AppState.shared.isLoggedIn = false
    }
}

// MARK: - Models
struct Habit: Decodable, Identifiable {
    let id: String
    let title: String
    let description: String?
    let frequency: String
}

struct Todo: Decodable, Identifiable {
    let id: String
    let title: String
    let completed: Bool
    let dueDate: String?
    let priority: Int
}

struct Reminder: Decodable, Identifiable {
    let id: String
    let title: String
    let remindAt: String
}

struct EmotionalState: Decodable, Identifiable {
    let id: String
    let state: String
    let intensity: Int
    let note: String
    let date: String // ISO Date String for history
}

struct User: Decodable, Identifiable {
    let id: String
    let name: String
    let email: String
    let createdAt: String // ISO Date String
}

struct NotificationItem: Decodable, Identifiable {
    let id: String
    let title: String
    let message: String
    let date: String // ISO Date String
    let isRead: Bool
}
