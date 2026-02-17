import Foundation
import CoreData
import Combine
import SwiftUI

final class SummaryViewModel: ObservableObject {

    // MARK: - Filters
    @Published var selectedRange: SummaryRange = .allTime
    @Published var selectedCategories: Set<String> = []

    // MARK: Persist selected currency
    @Published var selectedCurrency: String = "IDR" {
        didSet {
            applyCurrencyConversion()
            rebuildChartData()
        }
    }

    // MARK: - Output (Base Currency = IDR)
    @Published private(set) var metrics = SummaryMetrics(
        totalIncome: 0,
        totalExpense: 0,
        transactionCount: 0
    )

    @Published private(set) var chartData: [SummaryChartEntry] = []

    // MARK: - Converted Values
    @Published private(set) var convertedIncome: Double = 0
    @Published private(set) var convertedExpense: Double = 0
    @Published private(set) var convertedBalance: Double = 0

    // MARK: - Currency
    @Published private(set) var rates: [String: Double] = [:]
    @Published var isLoadingRate = false

    // MARK: - Private
    private let context: NSManagedObjectContext
    private let currencyService: CurrencyServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var lastFilteredTransactions: [TransactionEntity] = []

    // MARK: - Init
    init(
        context: NSManagedObjectContext,
        currencyService: CurrencyServiceProtocol = CurrencyService()
    ) {
        self.context = context
        self.currencyService = currencyService

        
        bindFilters()
        bindCoreDataChanges()

        reloadSummary()
        fetchExchangeRates()
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

    func toggleCategory(_ category: String) {
        let key = category.lowercased()
        if selectedCategories.contains(key) {
            selectedCategories.remove(key)
        } else {
            selectedCategories.insert(key)
        }
    }

    func resetCategory() {
        selectedCategories.removeAll()
    }

    // MARK: - Currency

    func fetchExchangeRates() {
        isLoadingRate = true

        currencyService.fetchRates(base: "IDR") { [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {
                self.isLoadingRate = false

                switch result {
                case .success(let fetchedRates):
                    self.rates = fetchedRates
                case .failure:
                    self.rates = [:]
                }

                self.applyCurrencyConversion()
                self.rebuildChartData()
            }
        }
    }

    private func applyCurrencyConversion() {

        guard selectedCurrency != "IDR",
              let rate = rates[selectedCurrency] else {
            convertedIncome = metrics.totalIncome
            convertedExpense = metrics.totalExpense
            convertedBalance = metrics.balance
            return
        }

        convertedIncome = metrics.totalIncome * rate
        convertedExpense = metrics.totalExpense * rate
        convertedBalance = metrics.balance * rate
        
        print("Selected currency:", selectedCurrency)
        print("Rate:", rates[selectedCurrency] ?? -1)
        print("Metrics balance:", metrics.balance)
    }

    // MARK: - Reload Summary

    private func reloadSummary() {
        let transactions = fetchTransactions()

        let filtered = transactions.filter { tx in
            guard let date = tx.date,
                  selectedRange.contains(date) else {
                return false
            }

            if selectedCategories.isEmpty {
                return true
            }

            let txCategory = (tx.category ?? "").lowercased()
            return selectedCategories.contains(txCategory)
        }

        lastFilteredTransactions = filtered

        metrics = calculateSummaryMetrics(from: filtered)
        rebuildChartData()
        applyCurrencyConversion()
    }

    // MARK: - Chart

    private func rebuildChartData() {
        guard !lastFilteredTransactions.isEmpty else {
            chartData = []
            return
        }

        let grouped = Dictionary(grouping: lastFilteredTransactions) { tx in
            chartLabel(for: tx.date ?? Date())
        }

        chartData = grouped
            .map { key, values in
                let baseTotal = values.reduce(0) { $0 + $1.amount }

                let finalTotal: Double
                if selectedCurrency == "IDR" {
                    finalTotal = baseTotal
                } else {
                    let rate = rates[selectedCurrency] ?? 0
                    finalTotal = baseTotal * rate
                }

                return SummaryChartEntry(
                    id: key,
                    label: key,
                    total: finalTotal
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
        let request: NSFetchRequest<TransactionEntity> =
            TransactionEntity.fetchRequest()

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
