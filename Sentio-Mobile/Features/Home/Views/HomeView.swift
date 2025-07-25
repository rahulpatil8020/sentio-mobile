//
//  HomeView.swift
//  Sentio-Mobile
//
//  Created by Rahul Patil on 7/22/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 🔥 Habits Card
                    if !vm.habits.isEmpty {
                        DashboardCardView(
                            title: "Habits",
                            color: .blue,
                            icon: "flame.fill"
                        ) {
                            ForEach(vm.habits) { habit in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(habit.title)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    if let desc = habit.description {
                                        Text(desc)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    Divider()
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    
                    // 🔥 Todos Card
                    if !vm.todos.isEmpty {
                        DashboardCardView(
                            title: "Todos",
                            color: .green,
                            icon: "checkmark.circle.fill"
                        ) {
                            ForEach(vm.todos) { todo in
                                HStack {
                                    Text(todo.title)
                                        .font(.body)
                                    Spacer()
                                    if todo.completed {
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundColor(.green)
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.vertical, 4)
                                Divider()
                            }
                        }
                    }
                    
                    // 🔥 Reminders Card
                    if !vm.reminders.isEmpty {
                        DashboardCardView(
                            title: "Reminders",
                            color: .purple,
                            icon: "bell.fill"
                        ) {
                            ForEach(vm.reminders) { reminder in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(reminder.title)
                                        .font(.body)
                                    Text("Remind at: \(reminder.remindAt)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Divider()
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: vm.logout) {
                        Label("Logout", systemImage: "arrow.backward.square.fill")
                    }
                    .foregroundColor(.red)
                }
            }
            .task {
                await vm.fetchData()
            }
            .overlay(
                Group {
                    if vm.isLoading {
                        ProgressView("Loading your data...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                            .scaleEffect(1.5)
                    } else if let error = vm.errorMessage {
                        VStack(spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.red)
                            Text("Error: \(error)")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.red)
                            Button("Retry") {
                                Task { await vm.fetchData() }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                    }
                }
            )
        }
    }
}

#Preview {
    HomeView()
}
