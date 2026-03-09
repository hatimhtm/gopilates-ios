import SwiftUI

// MARK: - Streak Calendar View

struct StreakCalendarView: View {
    @EnvironmentObject var userProfile: UserProfile
    @State private var displayedMonth: Date = Date()
    @State private var appear = false
    @State private var selectedDate: Date? = nil

    private let calendar = Calendar.current
    private let dayLabels = ["L", "M", "M", "J", "V", "S", "D"]

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.champagneBlush.opacity(0.4), Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        headerSection
                        statsRow
                        calendarCard
                        legendSection
                        if let date = selectedDate {
                            selectedDayCard(for: date)
                        }
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                    appear = true
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Votre Calendrier")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.deepCharcoal)
                Text("Suivez votre progression")
                    .font(.system(size: 14))
                    .foregroundColor(.deepCharcoal.opacity(0.6))
            }
            Spacer()
            // Flame badge
            if userProfile.currentStreak > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.vintagePink)
                    Text("\(userProfile.currentStreak)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.deepCharcoal)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .glassCard()
            }
        }
        .padding(.top, 8)
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
    }

    // MARK: - Stats Row
    private var statsRow: some View {
        HStack(spacing: 12) {
            calendarStat(
                value: "\(userProfile.currentStreak)",
                label: "Streak actuel",
                icon: "flame.fill",
                color: .vintagePink
            )
            calendarStat(
                value: "\(userProfile.longestStreak)",
                label: "Meilleur streak",
                icon: "trophy.fill",
                color: .metallicGold
            )
            calendarStat(
                value: "\(userProfile.workoutsThisMonth)",
                label: "Ce mois-ci",
                icon: "calendar.badge.checkmark",
                color: .deepCharcoal
            )
        }
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 24)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.15), value: appear)
    }

    private func calendarStat(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 15))
            }
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.deepCharcoal)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.deepCharcoal.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .glassCard()
    }

    // MARK: - Calendar Card
    private var calendarCard: some View {
        VStack(spacing: 16) {
            // Month navigation
            HStack {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.deepCharcoal)
                        .frame(width: 36, height: 36)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }

                Spacer()

                Text(monthYearLabel)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.deepCharcoal)
                    .animation(.easeInOut, value: displayedMonth)

                Spacer()

                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.deepCharcoal)
                        .frame(width: 36, height: 36)
                        .background(canGoForward ? .ultraThinMaterial : .regularMaterial)
                        .clipShape(Circle())
                }
                .disabled(!canGoForward)
                .opacity(canGoForward ? 1 : 0.3)
            }

            // Day-of-week labels
            HStack(spacing: 0) {
                ForEach(dayLabels, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.deepCharcoal.opacity(0.4))
                        .frame(maxWidth: .infinity)
                }
            }

            // Day grid
            let days = daysInDisplayedMonth()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 6) {
                ForEach(Array(days.enumerated()), id: \.offset) { index, dayOpt in
                    if let date = dayOpt {
                        dayCell(for: date, index: index)
                    } else {
                        Color.clear.frame(height: 38)
                    }
                }
            }
        }
        .padding(18)
        .glassCard()
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 30)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.25), value: appear)
    }

    private func dayCell(for date: Date, index: Int) -> some View {
        let isToday = calendar.isDateInToday(date)
        let isDone = userProfile.isDateCompleted(date)
        let isFuture = date > Date()
        let isSelected = selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false

        return Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedDate = isSelected ? nil : date
            }
            HapticManager.selection()
        }) {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        isDone ? Color.vintagePink :
                        isToday ? Color.metallicGold.opacity(0.15) :
                        isFuture ? Color.white.opacity(0.4) :
                        Color.black.opacity(0.04) // Clear light-gray box for past missed days against the white gradient
                    )
                    .frame(height: 38)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                isToday ? Color.metallicGold :
                                isSelected ? Color.vintagePink :
                                (isFuture == false && !isDone && !isToday) ? Color.black.opacity(0.06) : Color.clear,
                                lineWidth: isToday || isSelected || (isFuture == false && !isDone && !isToday) ? 1.5 : 0
                            )
                    )

                if isDone {
                    VStack(spacing: 1) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                        Text("\(calendar.component(.day, from: date))")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.white)
                    }
                } else {
                    Text("\(calendar.component(.day, from: date))")
                        .font(.system(size: 13, weight: isToday ? .bold : .medium))
                        .foregroundColor(
                            isToday ? .metallicGold :
                            isFuture ? .deepCharcoal.opacity(0.3) :
                            .deepCharcoal.opacity(0.8)
                        )
                }
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .opacity(appear ? 1 : 0)
        .scaleEffect(appear ? 1.0 : 0.7)
        .animation(
            .spring(response: 0.4, dampingFraction: 0.7).delay(Double(index) * 0.01 + 0.3),
            value: appear
        )
    }

    // MARK: - Legend
    private var legendSection: some View {
        HStack(spacing: 20) {
            legendItem(color: .vintagePink, label: "Séance complétée")
            legendItem(color: .metallicGold.opacity(0.4), label: "Aujourd'hui", bordered: true)
            legendItem(color: .black.opacity(0.04), label: "Jour manqué", bordered: true)
        }
        .padding(.horizontal, 4)
        .opacity(appear ? 1 : 0)
        .animation(.easeInOut.delay(0.5), value: appear)
    }

    private func legendItem(color: Color, label: String, bordered: Bool = false) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 5)
                .fill(color)
                .frame(width: 14, height: 14)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(bordered ? Color.metallicGold : Color.clear, lineWidth: 1.5)
                )
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.deepCharcoal.opacity(0.7))
        }
    }

    // MARK: - Selected Day Card
    private func selectedDayCard(for date: Date) -> some View {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "EEEE d MMMM"
        let label = formatter.string(from: date).capitalized
        let isDone = userProfile.isDateCompleted(date)
        let isToday = calendar.isDateInToday(date)
        let isFuture = date > Date()

        return VStack(spacing: 10) {
            Text(label)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.deepCharcoal)

            if isDone {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.vintagePink)
                    Text("Séance complétée ce jour-là")
                        .font(.system(size: 14))
                        .foregroundColor(.deepCharcoal.opacity(0.8))
                }
            } else if isFuture {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .foregroundColor(.metallicGold)
                    Text("Jour à venir — restez motivée !")
                        .font(.system(size: 14))
                        .foregroundColor(.deepCharcoal.opacity(0.8))
                }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: isToday ? "clock.fill" : "xmark.circle.fill")
                        .foregroundColor(isToday ? .metallicGold : .deepCharcoal.opacity(0.4))
                    Text(isToday ? "Aujourd'hui — allez-y !" : "Pas de séance ce jour")
                        .font(.system(size: 14))
                        .foregroundColor(.deepCharcoal.opacity(0.7))
                }
            }
        }
        .padding(16)
        .glassCard()
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Helpers

    private var monthYearLabel: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "fr_FR")
        f.dateFormat = "MMMM yyyy"
        return f.string(from: displayedMonth).capitalized
    }

    private var canGoForward: Bool {
        let now = Date()
        return calendar.compare(displayedMonth, to: now, toGranularity: .month) == .orderedAscending
    }

    private func changeMonth(by value: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            displayedMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) ?? displayedMonth
        }
        HapticManager.selection()
    }

    /// Returns an array of 42 optional Dates for a 6-week grid (Monday-first)
    private func daysInDisplayedMonth() -> [Date?] {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2 // Monday
        let components = cal.dateComponents([.year, .month], from: displayedMonth)
        guard let firstOfMonth = cal.date(from: components) else { return [] }

        let firstWeekday = cal.component(.weekday, from: firstOfMonth)
        // weekday: 1=Sun,2=Mon... with firstWeekday=2: offset = (weekday-2+7)%7
        let offset = (firstWeekday - 2 + 7) % 7

        let range = cal.range(of: .day, in: .month, for: firstOfMonth)!
        let daysInMonth = range.count

        var days: [Date?] = Array(repeating: nil, count: offset)
        for d in 1...daysInMonth {
            var dc = components
            dc.day = d
            days.append(cal.date(from: dc))
        }
        // Pad to full weeks
        while days.count % 7 != 0 { days.append(nil) }
        return days
    }
}

#Preview {
    StreakCalendarView()
        .environmentObject(UserProfile())
}
