import Foundation
import CoreData
import Combine

final class SummaryViewModel: ObservableObject {

    // MARK: - Filters
    @Published var selectedRange: SummaryRange = .allTime
    /// Menyimpan category rawValue (lowercased)
    @Published var selectedCategories: Set<String> = []

    // MARK: - Output
    @Published private(set) var metrics = SummaryMetrics(
        totalIncome: 0,
        totalExpense: 0,
        transactionCount: 0
    )

    @Published private(set) var chartData: [SummaryChartEntry] = []

    // MARK: - Dependencies
    private let context: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(context: NSManagedObjectContext) {
        self.context = context
        bindCoreDataChanges()
        bindFilters()
        reloadSummary()
    }

    // MARK: - Bindings
    private func bindFilters() {
        Publishers.CombineLatest($selectedRange, $selectedCategories)
            .debounce(for: .milliseconds(150), scheduler: RunLoop.main)
            .sink { [weak self] _, _ in
                self?.reloadSummary()
            }
            .store(in: &cancellables)
    }

    private func bindCoreDataChanges() {
        NotificationCenter.default
            .publisher(for: .NSManagedObjectContextObjectsDidChange, object: context)
            .debounce(for: .milliseconds(150), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.reloadSummary()
            }
            .store(in: &cancellables)
    }

    // MARK: - Category Helpers
    var expenseCategories: [CategoryFilterItem] {
        ExpenseCategory.allCases.map { $0.filterItem }
    }

    var incomeCategories: [CategoryFilterItem] {
        IncomeCategory.allCases.map { $0.filterItem }
    }

    /// Toggle category. Jika semua di-unselect → fallback ke ALL (no filter)
    func toggleCategory(_ category: String) {
        let key = category.lowercased()
        if selectedCategories.contains(key) {
            selectedCategories.remove(key)
        } else {
            selectedCategories.insert(key)
        }
    }

    /// Explicit reset ke ALL
    func resetCategory() {
        selectedCategories.removeAll()
    }

    // MARK: - Core Reload
    private func reloadSummary() {
        let transactions = fetchTransactions()

        let filtered = transactions.filter { tx in
            // 1) Date filter
            guard let date = tx.date, selectedRange.contains(date) else {
                return false
            }

            // 2) Category filter
            // Jika tidak ada category dipilih → TAMPILKAN SEMUA (ALL)
            guard !selectedCategories.isEmpty else {
                return true
            }

            let txCategory = (tx.category ?? "").lowercased()
            return selectedCategories.contains(txCategory)
        }

        metrics = calculateSummaryMetrics(from: filtered)
        buildChartData(from: filtered)
    }

    // MARK: - Chart Builder
    private func buildChartData(from transactions: [TransactionEntity]) {
        guard !transactions.isEmpty else {
            chartData = []
            return
        }

        let grouped = Dictionary(grouping: transactions) { tx in
            chartLabel(for: tx.date ?? Date())
        }

        chartData = grouped
            .map { key, values in
                SummaryChartEntry(
                    id: key,
                    label: key,
                    total: values.reduce(0) { $0 + $1.amount }
                )
            }
            .sorted { $0.label < $1.label }
    }

    private func chartLabel(for date: Date) -> String {
        let formatter = DateFormatter()

        switch selectedRange {
        case .today, .yesterday:
            formatter.dateFormat = "HH"
        case .last7Days:
            formatter.dateFormat = "EEE"
        case .last30Days, .lastMonth:
            formatter.dateFormat = "d MMM"
        case .thisMonth:
            formatter.dateFormat = "d"
        case .thisYear:
            formatter.dateFormat = "MMM"
        case .allTime:
            formatter.dateFormat = "MMM yyyy"
        }

        return formatter.string(from: date)
    }

    // MARK: - Fetch
    private func fetchTransactions() -> [TransactionEntity] {
        let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "is_deleted == NO")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TransactionEntity.date, ascending: true)
        ]

        do {
            return try context.fetch(request)
        } catch {
            print("❌ Failed to fetch transactions:", error)
            return []
        }
    }
}

