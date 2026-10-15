import Foundation

/// Role: Furrow. Day edges fold Calendar.startOfDay to Int YYYYMMDD.
enum DayKey {
    static func current(_ date: Date = Date(), calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month, .day], from: start)
        let year = parts.year ?? 0
        let month = parts.month ?? 0
        let day = parts.day ?? 0
        return year * 10_000 + month * 100 + day
    }

    static func adding(_ days: Int, to daykey: Int, calendar: Calendar = .current) -> Int? {
        let year = daykey / 10_000
        let month = (daykey / 100) % 100
        let day = daykey % 100
        var parts = DateComponents()
        parts.year = year
        parts.month = month
        parts.day = day
        guard let date = calendar.date(from: parts),
              let shifted = calendar.date(byAdding: .day, value: days, to: date) else {
            return nil
        }
        return current(shifted, calendar: calendar)
    }

    static func previous(_ daykey: Int, calendar: Calendar = .current) -> Int? {
        let year = daykey / 10_000
        let month = (daykey / 100) % 100
        let day = daykey % 100
        var parts = DateComponents()
        parts.year = year
        parts.month = month
        parts.day = day
        guard let date = calendar.date(from: parts),
              let prior = calendar.date(byAdding: .day, value: -1, to: date) else {
            return nil
        }
        return current(prior, calendar: calendar)
    }

    /// Counts a run of marked days ending today, or yesterday when today is still open.
    static func streak(in days: Set<Int>, today: Int = current(), calendar: Calendar = .current) -> Int {
        var cursor = today
        if days.contains(cursor) == false {
            guard let yesterday = previous(cursor, calendar: calendar), days.contains(yesterday) else {
                return 0
            }
            cursor = yesterday
        }
        var count = 0
        while days.contains(cursor) {
            count += 1
            guard let prior = previous(cursor, calendar: calendar) else { break }
            cursor = prior
        }
        return count
    }
}
