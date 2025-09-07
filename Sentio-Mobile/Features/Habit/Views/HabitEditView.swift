import SwiftUI

struct HabitEditView: View {
    @Environment(\.dismiss) private var dismiss

    @State var habit: Habit
    let onSave: (Habit) -> Void
    let onDelete: () -> Void

    @State private var title: String = ""
    @State private var descriptionText: String = ""
    @State private var frequency: String = "daily"
    @State private var reminderTime: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date? = nil
    @State private var hasEndDate: Bool = false
    @State private var isAccepted: Bool = true

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
                        .placeholder("Description", when: descriptionText.isEmpty)
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
                    Text("Basic").foregroundColor(Color("TextSecondary"))
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

                Section {
                    Button(role: .destructive) {
                        onDelete()
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Delete Habit")
                                .font(.body.weight(.semibold))
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color("Surface"))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(.red.opacity(0.4), lineWidth: 1)
                        )
                    }
                    .listRowBackground(Color("Background"))
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("Background").ignoresSafeArea())
            .navigationTitle("Edit Habit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let updated = Habit(
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
                        onSave(updated)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            title = habit.title
            descriptionText = habit.description ?? ""
            frequency = habit.frequency
            reminderTime = habit.reminderTime ?? ""
            startDate = habit.startDate
            endDate = habit.endDate
            hasEndDate = habit.endDate != nil
            isAccepted = habit.isAccepted
        }
    }
}
