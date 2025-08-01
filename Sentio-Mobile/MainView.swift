
import SwiftUI

struct MainView: View {
    @State private var selectedTab: String = "home"
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case "home":
                    HomeView()
                case "notifications":
                    NotificationsView()
                default:
                    HomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("background2Color").ignoresSafeArea())
            VStack {
                Spacer()
                CustomNavBar(selectedTab: $selectedTab)
                    .frame(maxWidth: .infinity)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

#Preview {
    MainView()
}
