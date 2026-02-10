import SwiftUI

struct SummaryFilterBar: View {

    @ObservedObject var vm: SummaryViewModel

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            quickRangeSection
            expenseCategorySection
            incomeCategorySection
        }
    }

    // MARK: - Quick Range
    private var quickRangeSection: some View {
        let quickRanges: [SummaryRange] = [
            .allTime,
            .last7Days,
            .last30Days,
            .lastMonth,
            .today
        ]

        return VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(quickRanges, id: \.self) { range in
                        QuickRangeChip(
                            title: range.title,
                            isSelected: vm.selectedRange == range
                        ) {
                            vm.selectedRange = range
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }

    // MARK: - Expense Category
    private var expenseCategorySection: some View {
        CategorySection(
            title: "Expense Category",
            categories: vm.expenseCategories,
            selected: vm.selectedCategories,
            onToggle: vm.toggleCategory
        )
    }

    // MARK: - Income Category
    private var incomeCategorySection: some View {
        CategorySection(
            title: "Income Category",
            categories: vm.incomeCategories,
            selected: vm.selectedCategories,
            onToggle: vm.toggleCategory
        )
    }
}

// MARK: - QuickRangeChip
private struct QuickRangeChip: View {

    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.subheadline)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            isSelected
                            ? Color(.secondarySystemBackground)
                            : Color(.systemBackground)
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.separator), lineWidth: 1)
                )
                .foregroundColor(.primary)
        }
    }
}

// MARK: - CategorySection
private struct CategorySection: View {

    let title: String
    let categories: [CategoryFilterItem]
    let selected: Set<String>
    let onToggle: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(categories) { category in
                        CategoryChip(
                            title: category.title,
                            icon: category.icon,
                            isSelected: selected.contains(category.rawValue)
                        ) {
                            onToggle(category.rawValue)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 1)
        )
    }
}
