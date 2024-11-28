import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    var userEmail: String

    var body: some View {
        VStack {
            // Top Bar
            TopBarView(
                profilePictureURL: "https://example.com/profile_picture.jpg",
                connectivityManager: ConnectivityManager.shared
            ) {
                // Acción de perfil
            }

            // Título
            Text("Your Recycling History")
                .font(.title)
                .padding()

            // Calendario interactivo
            CalendarView(
                highlightedDates: viewModel.recyclingDates
            )
            .padding()

            Spacer()
        }
        .onAppear {
            viewModel.fetchRecyclingHistory(for: userEmail)
        }
    }
}

struct CalendarView: View {
    var highlightedDates: [Date]

    @State private var currentDate = Date() // Fecha actual

    var body: some View {
        VStack {
            // Encabezado del mes
            HStack {
                Button(action: {
                    currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
                }) {
                    Image(systemName: "chevron.left")
                }

                Spacer()

                Text(getMonthYearString(from: currentDate))
                    .font(.headline)

                Spacer()

                Button(action: {
                    currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()

            // Días de la semana
            HStack {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(.subheadline)
                }
            }

            // Días del mes
            let days = getDaysForMonth(date: currentDate)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(days, id: \.self) { day in
                    if let day = day {
                        Circle()
                            .fill(highlightedDates.contains(day) ? Color.green : Color.clear)
                            .overlay(
                                Text("\(Calendar.current.component(.day, from: day))")
                                    .foregroundColor(.black)
                            )
                            .frame(width: 40, height: 40)
                    } else {
                        Text("")
                    }
                }
            }
        }
        .padding()
    }

    // Obtener el nombre del mes y año
    func getMonthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    // Obtener los días del mes actual
    func getDaysForMonth(date: Date) -> [Date?] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)!
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)

        for day in range {
            if let dayDate = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(dayDate)
            }
        }

        return days
    }
}
