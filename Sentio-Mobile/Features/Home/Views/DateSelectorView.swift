import SwiftUI

struct DateSelectorView: View {
    @Binding var selectedDate: Date
    private var calendar = Calendar.current
    
    public init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
    }

    @State private var currentWeekIndex: Int = 50  // Default to "today" week
    @State private var scrollToWeekIndex: Int? = nil  // Used by Scroll-To-Today button

    private let daysPerWeek = 7
    private let bufferWeeks = 100  // 100 past weeks

    /// Start of week (aligned to calendar)
    private var startOfCurrentWeek: Date {
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        return calendar.date(byAdding: .day, value: -(weekday - calendar.firstWeekday), to: today) ?? today
    }

    /// Weeks from -buffer to 0 (prevent future weeks)
    private var weeks: [[Date]] {
        (-bufferWeeks...0).map { weekOffset in
            let startOfWeek = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: startOfCurrentWeek)!
            return (0..<daysPerWeek).compactMap {
                calendar.date(byAdding: .day, value: $0, to: startOfWeek)
            }
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            TabView(selection: $currentWeekIndex) {
                ForEach(weeks.indices, id: \.self) { index in
                    let week = weeks[index]

                    HStack(spacing: 10) {
                        ForEach(week, id: \.self) { date in
                            let isFuture = date > Date()

                            VStack(spacing: 6) {
                                Text(DateUtils.localizedShortDay(from: date))
                                    .font(.caption)
                                    .foregroundColor(isFuture ? .gray : Color("TextSecondary"))

                                Text(DateUtils.localizedDayNumber(from: date))
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(isFuture ? .gray : Color("TextPrimary"))
                            }
                            .frame(width: 44, height: 64)
                            .cornerRadius(28)
                            .background(
                                Group {
                                    if calendar.isDate(date, inSameDayAs: selectedDate) {
                                        RoundedRectangle(cornerRadius: 28)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color("Surface"), Color("SurfaceSecondary")],
                                                    startPoint: .bottom,
                                                    endPoint: .top
                                                ),
                                                lineWidth:3
                                            )
                                            .background(
                                                RoundedRectangle(cornerRadius: 28)
                                                    .fill(Color("Background").opacity(0.55))
                                            )                                    }
                                }
                            )
                            .onTapGesture {
                                if !isFuture {
                                    selectedDate = date
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 70)
            .onAppear {
                currentWeekIndex = weeks.count - 1  // Last index is this week
            }
        }
    }
}

#Preview {
    struct DateSelectorPreview: View {
        @State private var mockDate = Date()

        var body: some View {
            ZStack {
                Color("Background").ignoresSafeArea()
                DateSelectorView(selectedDate: $mockDate)
                    .foregroundColor(Color("TextPrimary"))
            }
        }
    }
    return DateSelectorPreview().environment(\.colorScheme, .dark)
}
