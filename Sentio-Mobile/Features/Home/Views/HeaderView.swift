import SwiftUI

struct HeaderView: View {
    let user: User
    let selectedDate: Date

    // Extract initials from full name
    private var initials: String {
        let components = user.name.split(separator: " ")
        let first = components.first?.first.map { String($0) } ?? ""
        let last = components.dropFirst().first?.first.map { String($0) } ?? ""
        return (first + last).uppercased()
    }
    
    private var firstName: String {
        return user.name.split(separator: " ").first.map { String($0) } ?? user.name
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"  // e.g. August 19
        return formatter.string(from: selectedDate)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hey, \(firstName)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color("TextPrimary"))
                
                Text("How are you doing today?")
                    .font(.subheadline)
                    .foregroundColor(Color("TextSecondary"))
                
                Text(formattedDate)
                    .font(.footnote)
                    .foregroundColor(Color("TextSecondary"))
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.blue.gradient)
                    .frame(width: 50, height: 50)
                
                Text(initials)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("Background"))
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    let mockUser = User(
        id: "123",
        name: "Rahul Patil",
        email: "rahul@example.com",
        createdAt: "2025-08-02T12:00:00Z",
        isOnboarded: true,
        city: "San Francisco",
        country: "USA",
        profession: "Software Engineer",
        goals: ["Personal growth", "Fitness"]
    )
    
    HeaderView(user: mockUser, selectedDate: Date())
}
