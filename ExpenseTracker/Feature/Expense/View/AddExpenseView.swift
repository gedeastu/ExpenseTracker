import SwiftUI
import CoreData

struct AddExpenseView: View {

    // MARK: - Environment
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    // MARK: - ViewModel
    @StateObject private var tvm: TransactionViewModel

    // MARK: - Mode
    let existingItem: TransactionEntity?

    // MARK: - Form State
    @State private var title: String = ""
    @State private var amountText: String = ""
    @State private var amountValue: Double = 0
    @State private var selectedType: TransactionType = .expense
    @State private var selectedCategory: String = ""
    @State private var date: Date = Date()
    @State private var isPrefilling = false

    // MARK: - Validation
    @State private var showTitleError = false
    @State private var showAmountError = false

    @Binding var selectedTab: AppTab

    // MARK: - Init
    init(
        context: NSManagedObjectContext,
        existingItem: TransactionEntity? = nil,
        selectedTab: Binding<AppTab>
    ) {
        let repository = TransactionRepository(context: context)
        _tvm = StateObject(
            wrappedValue: TransactionViewModel(repository: repository)
        )
        self.existingItem = existingItem
        self._selectedTab = selectedTab
    }

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // 🔹 Live Preview
                Text(existingItem == nil ? "Live Preview" : "Live Preview (Edit)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)

                TransactionPreviewCard(
                    title: title,
                    amount: amountValue,
                    type: selectedType,
                    category: selectedCategory,
                    date: date,
                    onEdit: {}
                )

                // MARK: - Title
                fieldSection(title: "Title") {
                    floatingTextField(
                        placeholder: "Masukkan Title",
                        text: $title,
                        showError: showTitleError
                    )
                    if showTitleError {
                        errorText("Title tidak boleh kosong")
                    }
                }
                .onChange(of: title) { _ in showTitleError = false }

                // MARK: - Amount
                fieldSection(title: "Amount") {
                    floatingTextField(
                        placeholder: "Masukkan Amount",
                        text: $amountText,
                        keyboard: .numberPad,
                        showError: showAmountError
                    )
                    if showAmountError {
                        errorText("Amount harus lebih dari 0")
                    }
                }
                .onChange(of: amountText) { _ in
                    showAmountError = false
                    formatAmount()
                }

                // MARK: - Transaction Type
                fieldSection(title: "Transaction Type") {
                    Picker("Type", selection: $selectedType) {
                        ForEach(TransactionType.allCases, id: \.self) {
                            Text($0.displayName).tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .onChange(of: selectedType) { _ in
                    if !isPrefilling {
                        selectedCategory = ""
                    }
                }

                // MARK: - Category
                fieldSection(title: "Category") {
                    Menu {
                        ForEach(categoryOptions) { item in
                            Button {
                                selectedCategory = item.rawValue 
                            } label: {
                                Label(item.title, systemImage: item.icon)
                            }
                        }
                    } label: {
                        HStack {
                            Text(
                                selectedCategory.isEmpty
                                ? "Pilih Category"
                                : categoryTitle(for: selectedCategory)
                            )
                            .foregroundColor(
                                selectedCategory.isEmpty ? .gray : .primary
                            )
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray3))
                        )
                    }
                }

                // MARK: - Date
                fieldSection(title: "Date") {
                    DatePicker(
                        "",
                        selection: $date,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(edges: .bottom)
        .onAppear(perform: preloadIfEditing)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(existingItem == nil ? "Add Transaction" : "Edit Transaction")
                    .foregroundColor(.green)
                    .font(.system(size: 20, weight: .bold))
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Simpan", action: save).foregroundColor(.green)
                    .disabled(
                        title.isEmpty ||
                        amountText.isEmpty ||
                        selectedCategory.isEmpty
                    )
            }
        }
    }
}

// MARK: - Logic
extension AddExpenseView {

    private func preloadIfEditing() {
        guard let item = existingItem else { return }

        isPrefilling = true

        title = item.title ?? ""

        amountValue = item.amount
        amountText = NumberFormatter.currencyID.string(
            from: NSNumber(value: item.amount)
        ) ?? ""

        selectedType = TransactionType(rawValue: item.type ?? "") ?? .expense
        selectedCategory = item.category ?? ""
        date = item.date ?? Date()

        DispatchQueue.main.async {
            isPrefilling = false
        }
    }


    private func save() {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            showTitleError = true
            return
        }

        let rawAmount = amountText
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: ".")

        guard let amountValue = Double(rawAmount), amountValue > 0 else {
            showAmountError = true
            return
        }

        if let item = existingItem {
            tvm.updateTransaction(
                transaction: item,
                title: title,
                amount: amountValue,
                type: selectedType,
                category: selectedCategory,
                date: date
            )
        } else {
            tvm.addTransaction(
                title: title,
                amount: amountValue,
                type: selectedType,
                category: selectedCategory,
                date: date
            )
        }

        selectedTab = .transactions
        dismiss()
    }

    private func formatAmount() {
        let digits = amountText.filter { $0.isNumber }
        guard let number = Double(digits) else {
            amountText = ""
            amountValue = 0
            return
        }

        amountValue = number

        amountText = NumberFormatter.currencyID.string(
            from: NSNumber(value: number)
        ) ?? digits
    }
}

// MARK: - Helpers
extension AddExpenseView {

    private var categoryOptions: [CategoryFilterItem] {
        switch selectedType {
        case .expense:
            return ExpenseCategory.allCases.map { $0.filterItem }
        case .income:
            return IncomeCategory.allCases.map { $0.filterItem }
        }
    }

    private func fieldSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.gray)
            content()
        }
    }

    private func floatingTextField(
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default,
        showError: Bool
    ) -> some View {
        ZStack(alignment: .leading) {
            if text.wrappedValue.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(.leading, 12)
            }

            TextField("", text: text)
                .keyboardType(keyboard)
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(showError ? .red : Color(.systemGray3))
                )
        }
    }

    private func errorText(_ message: String) -> some View {
        Text(message)
            .font(.caption)
            .foregroundColor(.red)
            .padding(.leading, 12)
    }
    
    private func categoryTitle(for raw: String) -> String {
        if let expense = ExpenseCategory(rawValue: raw) {
            return expense.title
        }
        if let income = IncomeCategory(rawValue: raw) {
            return income.title
        }
        return raw
    }
}
