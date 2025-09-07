
import SwiftUI

struct AddHabitSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var descriptionText: String = ""
    @State private var frequency: String = "daily"
    @State private var reminderTime: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date? = nil
    @State private var hasEndDate: Bool = false
    @State private var isAccepted: Bool = true

    let onAdd: (Habit) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("", text: $title)
                        .placeholder("Title", when: title.isEmpty)
                        .foregroundColor(Color("TextPrimary"))
                        .tint(Color("Primary"))
                        .listRowBackground(Color("Surface"))

                    TextField("", text: $descriptionText, axis: .vertical)
                        .placeholder("Description (optional)", when: descriptionText.isEmpty)
                        .lineLimit(1...3)
                        .foregroundColor(Color("TextPrimary"))
                        .tint(Color("Primary"))
                        .listRowBackground(Color("Surface"))

                    Picker("Frequency", selection: $frequency) {
                        Text("Daily").tag("daily")
                        Text("Weekly").tag("weekly")
                        Text("Monthly").tag("monthly")
                    }
                    .pickerStyle(.segmented)
                    .tint(Color("Primary"))
                    .listRowBackground(Color("Surface"))

                    TextField("", text: $reminderTime)
                        .placeholder("Reminder (e.g. 07:00 AM)", when: reminderTime.isEmpty)
                        .textInputAutocapitalization(.never)
                        .foregroundColor(Color("TextPrimary"))
                        .tint(Color("Primary"))
                        .listRowBackground(Color("Surface"))
                } header: {
                    Text("Basics").foregroundColor(Color("TextSecondary"))
                }

                Section {
                    LabeledContent {
                        DatePicker("", selection: $startDate, displayedComponents: .date)
                            .labelsHidden()
                            .tint(Color("Primary"))
                    } label: {
                        Text("Start").foregroundColor(Color("TextSecondary"))
                    }
                    .listRowBackground(Color("Surface"))

                    Toggle(isOn: $hasEndDate.animation()) {
                        Text("Set end date").foregroundColor(Color("TextPrimary"))
                    }
                    .tint(Color("Primary"))
                    .listRowBackground(Color("Surface"))

                    if hasEndDate {
                        LabeledContent {
                            DatePicker("",
                                       selection: Binding(
                                           get: { endDate ?? Date() },
                                           set: { endDate = $0 }
                                       ),
                                       displayedComponents: .date)
                            .labelsHidden()
                            .tint(Color("Primary"))
                        } label: {
                            Text("End").foregroundColor(Color("TextSecondary"))
                        }
                        .listRowBackground(Color("Surface"))
                    }
                } header: {
                    Text("Dates").foregroundColor(Color("TextSecondary"))
                }

                Section {
                    Toggle(isOn: $isAccepted) {
                        Text("Accepted").foregroundColor(Color("TextPrimary"))
                    }
                    .tint(Color("Primary"))
                    .listRowBackground(Color("Surface"))
                } header: {
                    Text("Status").foregroundColor(Color("TextSecondary"))
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("Background").ignoresSafeArea())
            .navigationTitle("New Habit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        let newHabit = Habit(
                            id: UUID().uuidString,
                            userId: "u1", // replace with real logged-in user id
                            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                            description: descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
                            frequency: frequency.lowercased(),
                            streak: Streak(current: 0, longest: 0, lastCompletedDate: nil),
                            completions: [],
                            isDeleted: false,
                            isAccepted: isAccepted,
                            createdAt: Date(),
                            startDate: startDate,
                            updatedAt: nil,
                            endDate: hasEndDate ? endDate : nil,
                            reminderTime: reminderTime.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
                        )
                        onAdd(newHabit)
                        dismiss()
                    } label: {
                        Text("Add")
                            .fontWeight(.semibold)
                            .foregroundColor(
                                title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? Color("TextDisabled")
                                : Color("Primary")
                            )
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .background(Color("Background").ignoresSafeArea())
    }
}
