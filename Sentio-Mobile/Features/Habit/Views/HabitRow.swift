//
//  HabitRow.swift
//  Sentio-Mobile
//
//  Created by Rahul Patil on 8/23/25.
//

import SwiftUI

struct HabitRow: View {
    let habit: Habit
    let day: Date
    let onAccept: () -> Void
    let onReject: () -> Void
    let onCompleteToggle: () -> Void
    let onOpenDetails: () -> Void

    private var completedOnDay: Bool {
        let cal = Calendar.current
        if let last = habit.streak.lastCompletedDate, cal.isDate(last, inSameDayAs: day) { return true }
        return habit.completions.contains { cal.isDate($0.date, inSameDayAs: day) }
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                if habit.isAccepted {
                    Button(action: onCompleteToggle) {
                        Circle()
                            .fill(completedOnDay ? Color.green.opacity(0.8) : Color.gray.opacity(0.35))
                            .frame(width: 26, height: 26)
                            .overlay(
                                Image(systemName: completedOnDay ? "checkmark" : "")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white.opacity(0.95))
                            )
                            .accessibilityLabel(completedOnDay ? "Mark incomplete" : "Mark complete")
                    }
                    .buttonStyle(.plain)
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.35))
                        .frame(width: 26, height: 26)
                        .overlay(Text("⏳").font(.system(size: 11)))
                        .accessibilityHidden(true)
                }

                Button(action: onOpenDetails) {
                    Text(habit.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color("TextPrimary"))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)

                if habit.isAccepted {
                    Button(action: onOpenDetails) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color("TextSecondary"))
                    }.buttonStyle(.plain)
                } else {
                    HStack(spacing: 8) {
                        Button(action: onReject) {
                            Text("Reject")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.red)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(Color.red.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        Button(action: onAccept) {
                            Text("Accept")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.green)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(Color.green.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                    }
                }
            }

            HStack(spacing: 8) {
                FrequencyBadge(text: habit.frequency)
                if habit.streak.current > 0 {
                    StreakBadge(text: "🔥 \(habit.streak.current)", color: .red)
                }
                if habit.streak.longest > 0 {
                    StreakBadge(text: "🏆 \(habit.streak.longest)", color: .yellow)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
                if let time = habit.reminderTime, !time.isEmpty {
                    Label(time, systemImage: "bell")
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                }
                if let desc = habit.description, !desc.isEmpty {
                    Text("• \(desc)")
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                if let last = habit.streak.lastCompletedDate {
                    Text("• Last: \(last.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                Label("Start \(habit.startDate.formatted(date: .abbreviated, time: .omitted))", systemImage: "calendar.badge.plus")
                    .font(.caption2)
                    .foregroundColor(Color("TextSecondary"))

                if let end = habit.endDate {
                    Label("Ends \(end.formatted(date: .abbreviated, time: .omitted))", systemImage: "calendar.badge.minus")
                        .font(.caption2)
                        .foregroundColor(Color("TextSecondary"))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color("Surface"))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview("Habit Row - Accepted") {
    HabitRow(
        habit: Habit.previewHabits.first!,
        day: Date(),
        onAccept: {}, onReject: {}, onCompleteToggle: {}, onOpenDetails: {}
    )
    .padding()
    .background(Color("Background"))
    .environment(\.colorScheme, .dark)
}
