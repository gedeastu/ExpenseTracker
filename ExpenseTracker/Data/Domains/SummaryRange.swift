import Foundation

enum SummaryRange: String, CaseIterable, Identifiable {
    case today
    case yesterday
    case last7Days
    case last30Days
    case lastMonth
    case thisMonth
    case thisYear
    case allTime

    var id: Self { self }
}

// MARK: - UI
extension SummaryRange {
    var title: String {
        switch self {
        case .today: return "Hari Ini"
        case .yesterday: return "Kemarin"
        case .last7Days: return "7 Hari"
        case .last30Days: return "30 Hari"
        case .lastMonth: return "Bulan Lalu"
        case .thisMonth: return "Bulan Ini"
        case .thisYear: return "Tahun Ini"
        case .allTime: return "Semua"
        }
    }
}

// MARK: - Date Logic (FINAL)
extension SummaryRange {

    /// Inclusive calendar-based check (FULL DAY safe)
    func contains(_ date: Date, reference: Date = Date()) -> Bool {
        let calendar = Calendar.current

        let start = startDate(reference: reference)
        let end = endDate(reference: reference)

        let normalizedStart = calendar.startOfDay(for: start)
        let normalizedEnd = calendar
            .date(byAdding: .day, value: 1, to: calendar.startOfDay(for: end))!
            .addingTimeInterval(-1)

        return (normalizedStart ... normalizedEnd).contains(date)
    }

    func startDate(reference: Date = Date()) -> Date {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: reference)

        switch self {
        case .today:
            return todayStart

        case .yesterday:
            return calendar.date(byAdding: .day, value: -1, to: todayStart)!

        case .last7Days:
            return calendar.date(byAdding: .day, value: -6, to: todayStart)!

        case .last30Days:
            return calendar.date(byAdding: .day, value: -29, to: todayStart)!

        case .lastMonth:
            let calendar = Calendar.current
            let thisMonthStart = calendar.date(
                from: calendar.dateComponents([.year, .month], from: reference)
            )!
            return calendar.date(byAdding: .month, value: -1, to: thisMonthStart)!

        case .thisMonth:
            return calendar.date(
                from: calendar.dateComponents([.year, .month], from: reference)
            )!

        case .thisYear:
            return calendar.date(
                from: calendar.dateComponents([.year], from: reference)
            )!

        case .allTime:
            return .distantPast
        }
    }

    func endDate(reference: Date = Date()) -> Date {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: reference)

        switch self {
        case .lastMonth:
            let calendar = Calendar.current
            let thisMonthStart = calendar.date(
                from: calendar.dateComponents([.year, .month], from: reference)
            )!
            return calendar.date(byAdding: .second, value: -1, to: thisMonthStart)!

        case .yesterday:
            return calendar.date(byAdding: .second, value: -1, to: todayStart)!

        case .today,
             .last7Days,
             .last30Days,
             .thisMonth,
             .thisYear:
            return reference

        case .allTime:
            return .distantFuture
        }
    }
}
