import SwiftUI

struct DateSelectorView: View {
    @Binding var selectedDate: Date   // always UTC internally
    private var calendar = Calendar.current

    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
    }
    
    /// Past 7 days + today (still in UTC)
    private var dates: [Date] {
        let todayUTC = Date()   // full UTC timestamp
        return (-7...0).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: todayUTC)
        }
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(dates, id: \.self) { date in
                        VStack(spacing: 6) {
                            Text(DateUtils.localizedShortDay(from: date)) // local
                                .font(.caption)
                                .foregroundColor(Color("TextSecondary"))
                            
                            Text(DateUtils.localizedDayNumber(from: date)) // local
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("TextPrimary"))
                        }
                        .frame(width: 44, height: 64)
                        .cornerRadius(28)
                        .background(
                            Group {
                                if calendar.isDate(date, inSameDayAs: selectedDate) {
                                    RoundedRectangle(cornerRadius: 28)
                                        .stroke(Color("SurfaceSecondary"), lineWidth: 4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 28)
                                                .fill(Color("SurfaceSecondary").opacity(0.55))
                                        )
                                }
                            }
                        )
                        .onTapGesture {
                            // Just set the raw UTC date (no midnight truncation)
                            selectedDate = date
                            print("🕒 selected (UTC): \(selectedDate)")
                            print("📅 selected (local): \(DateUtils.localizedFullDate(from: selectedDate))")
                        }
                        .id(date)
                        .frame(width: 44, height: 68)
                    }
                    Color.clear
                        .frame(width: 1, height: 1)
                        .id("end")
                }
                .padding(.horizontal)
            }
            .onAppear {
                DispatchQueue.main.async {
                    withAnimation {
                        proxy.scrollTo("end", anchor: .trailing)
                    }
                }
            }
        }
    }
}


#Preview {
    struct DateSelectorPreview: View {
        @State private var mockDate = Date()  // starts at "now" UTC
        
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
