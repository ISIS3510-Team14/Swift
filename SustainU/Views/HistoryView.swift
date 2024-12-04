import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct HistoryView: View {
    var userProfile: UserProfile
    @Binding var selectedTab: Int
    @Binding var isShowingHistoryView: Bool
    @StateObject private var viewModel = HistoryViewModel()
    @State private var currentMonth = Date()
    @ObservedObject private var connectivityManager = ConnectivityManager.shared
    @State private var showOfflinePopup = false
    
    let calendar = Calendar.current
    let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    let minDate: Date = {
        var components = DateComponents()
        components.year = 2023
        components.month = 1
        components.day = 1
        return Calendar.current.date(from: components) ?? Date()
    }()
    
    var currentMonthDate: Date {
        let components = calendar.dateComponents([.year, .month], from: Date())
        return calendar.date(from: components) ?? Date()
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                ZStack {
                    ScrollView {
                        VStack(spacing: 20) {
                            TopBarView(profilePictureURL: userProfile.picture,
                                     connectivityManager: connectivityManager)
                            
                            Text("Your Recycling History")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.top, 10)
                            
                            VStack(spacing: 20) {
                                HStack {
                                    Button(action: { previousMonth() }) {
                                        Image(systemName: "chevron.left")
                                            .foregroundColor(canGoBack ? .black : .gray)
                                    }
                                    .disabled(!canGoBack)
                                    
                                    Text(monthYearString(from: currentMonth))
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .frame(width: 200)
                                    
                                    Button(action: { nextMonth() }) {
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(canGoForward ? .black : .gray)
                                    }
                                    .disabled(!canGoForward)
                                }
                                .padding(.top)
                                
                                HStack {
                                    ForEach(daysOfWeek, id: \.self) { day in
                                        Text(day)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                                    ForEach(daysInMonth(), id: \.self) { date in
                                        if let date = date {
                                            DayView(date: date, hasPoints: hasPointsForDate(date))
                                        } else {
                                            Text("")
                                                .frame(height: 40)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .navigationBarHidden(true)
                    
                    if showOfflinePopup {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                showOfflinePopup = false
                            }
                        
                        VStack(spacing: 20) {
                            Text("Offline")
                                .font(.title3.bold())
                                .foregroundColor(.black)
                            
                            Text("You are not connected to Wi-Fi.")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                            
                            Button(action: {
                                showOfflinePopup = false
                            }) {
                                Text("OK")
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color("greenLogoColor"))
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 24)
                        .frame(width: 280)
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                }
            }
            .tabItem {
                Image("logoHome")
                    .renderingMode(.template)
                Text("Home")
            }
            .tag(0)
            .onChange(of: selectedTab) { newValue in
                isShowingHistoryView = false
            }
            
            Color.clear
                .tabItem {
                    Image("logoMap")
                        .renderingMode(.template)
                    Text("Map")
                }
                .tag(1)
                .onChange(of: selectedTab) { _ in
                    isShowingHistoryView = false
                }
            
            Color.clear
                .tabItem {
                    Image("logoCamera")
                        .renderingMode(.template)
                    Text("Camera")
                }
                .tag(2)
                .onChange(of: selectedTab) { _ in
                    isShowingHistoryView = false
                }
            
            Color.clear
                .tabItem {
                    Image("logoRecycle")
                        .renderingMode(.template)
                    Text("Recycle")
                }
                .tag(3)
                .onChange(of: selectedTab) { _ in
                    isShowingHistoryView = false
                }
            
            Color.clear
                .tabItem {
                    Image("logoScoreboard")
                        .renderingMode(.template)
                    Text("Scoreboard")
                }
                .tag(4)
                .onChange(of: selectedTab) { _ in
                    isShowingHistoryView = false
                }
        }
        .accentColor(Color("greenLogoColor"))
        .onAppear {
            checkConnectivity()
            viewModel.fetchRecyclingHistory(for: userProfile.email)
        }
    }
    
    private func checkConnectivity() {
        if !connectivityManager.isConnected {
            showOfflinePopup = true
        }
    }
    
    private var canGoBack: Bool {
        calendar.compare(currentMonth, to: minDate, toGranularity: .month) == .orderedDescending
    }
    
    private var canGoForward: Bool {
        let today = currentMonthDate
        return calendar.compare(currentMonth, to: today, toGranularity: .month) != .orderedDescending
    }
    
    private func hasPointsForDate(_ date: Date) -> Bool {
        // Primero verifica que no sea una fecha futura
        guard calendar.compare(date, to: Date(), toGranularity: .day) != .orderedDescending else {
            return false
        }
        
        let dateString = dateToString(date)
        print("Checking date: \(dateString)")
        
        // Verifica si hay puntos para esta fecha en el historial
        return viewModel.history.contains { entry in
            entry.date == dateString && entry.points > 0
        }
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func dateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func previousMonth() {
        withAnimation {
            currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func nextMonth() {
        withAnimation {
            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func daysInMonth() -> [Date?] {
        let interval = calendar.dateInterval(of: .month, for: currentMonth)!
        let firstWeekday = calendar.component(.weekday, from: interval.start)
        let previousMonthDays = Array(repeating: nil as Date?, count: firstWeekday - 1)
        
        let daysInMonth = calendar.dateComponents([.day], from: interval.start, to: interval.end).day!
        let currentMonthDays = (0..<daysInMonth).map { day -> Date? in
            calendar.date(byAdding: .day, value: day, to: interval.start)
        }
        
        let days = previousMonthDays + currentMonthDays
        let remainingDays = Array(repeating: nil as Date?, count: 42 - days.count)
        return days + remainingDays
    }
}

struct DayView: View {
    let date: Date
    let hasPoints: Bool
    
    var body: some View {
        Text("\(Calendar.current.component(.day, from: date))")
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .background(hasPoints ? Color("greenLogoColor") : Color.clear)
            .clipShape(Circle())
            .foregroundColor(hasPoints ? .white : .black)
    }
}
