import SwiftUI
import CoreData

struct ContentView: View {

    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var tvm: TransactionViewModel
    @StateObject private var summaryVM: SummaryViewModel
    @AppStorage("appAppearance") private var appAppearance: String = "system"

    // MARK: - Fetch (ONLY ACTIVE DATA)
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \TransactionEntity.date, ascending: true)
        ],
        predicate: NSPredicate(format: "is_deleted == NO"),
        animation: .default
    )
    private var expenses: FetchedResults<TransactionEntity>

    // MARK: - Navigation & State
    @State private var formMode: FormMode?

    @State private var pendingDelete: [TransactionEntity] = []
    @State private var showDeleteConfirm = false
    @State private var recentlyDeleted: [TransactionEntity]? = nil
    @State private var showUndo = false

    @State private var selectedTab: AppTab = .summary

    init(context: NSManagedObjectContext) {
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        // tabAppearance.backgroundColor = .white

        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        // navAppearance.backgroundColor = .white
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.systemGreen
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.systemGreen
        ]

        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance

        let repo = TransactionRepository(context: context)
        _tvm = StateObject(
            wrappedValue: TransactionViewModel(repository: repo)
        )
        _summaryVM = StateObject(wrappedValue: SummaryViewModel(context: context))
    }

    // MARK: - Body
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                // MARK: SUMMARY
                NavigationStack{
                    SummaryView(context: viewContext)
                        .environmentObject(summaryVM)
                        .foregroundColor(.green)
                        .navigationTitle("Summary")
                        .navigationBarTitleDisplayMode(.large)
                        .background(Color.white.ignoresSafeArea())
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Menu {
                                    Button("System") { appAppearance = "system" }
                                    Button("Light") { appAppearance = "light" }
                                    Button("Dark") { appAppearance = "dark" }
                                } label: {
                                    Image(systemName: appAppearance == "dark"
                                          ? "moon.fill"
                                          : appAppearance == "light"
                                          ? "sun.max.fill"
                                          : "circle.lefthalf.filled")
                                }
                            }
                        }
                }.tabItem {
                    Image(systemName: "list.bullet.clipboard.fill")
                    Text("Summary")
                }.padding(.top,20)
                .tag(AppTab.summary)

                NavigationStack{
                    //MARK: TRANSACTIONS
                    TransactionsView(
                        transactions: Array(expenses),
                        onEdit: { transaction in
                            formMode = .edit(transaction)
                        },
                        onDelete: { transactions in
                            handleDelete(transactions)
                        }
                    )
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Menu {
                                Button("System") { appAppearance = "system" }
                                Button("Light") { appAppearance = "light" }
                                Button("Dark") { appAppearance = "dark" }
                            } label: {
                                Image(systemName: appAppearance == "dark"
                                      ? "moon.fill"
                                      : appAppearance == "light"
                                      ? "sun.max.fill"
                                      : "circle.lefthalf.filled")
                            }
                        }
                    }
                }.tabItem {
                    Image(systemName: "list.number")
                    Text("Transactions")
                }.padding(.top,20)
                .tag(AppTab.transactions)
            }
            .tint(.green)
            .safeAreaInset(edge: .bottom) {
                bottomActionBar
            }

            .sheet(item: $formMode) { mode in
                NavigationStack {
                    Group {
                        switch mode {
                        case .create:
                            AddExpenseView(
                                context: viewContext,
                                existingItem: nil,
                                selectedTab: $selectedTab
                            )
                            .environmentObject(summaryVM)

                        case .edit(let transaction):
                            AddExpenseView(
                                context: viewContext,
                                existingItem: transaction,
                                selectedTab: $selectedTab
                            )
                            .environmentObject(summaryVM)
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                formMode = nil
                            } label: {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                .presentationBackground(Color.white)
            }


            // MARK: DELETE CONFIRMATION
            .alert("Hapus Transaksi?",
                   isPresented: $showDeleteConfirm
            ) {

                Button("Hapus", role: .destructive) {
                    handleDelete(pendingDelete)
                    pendingDelete = []
                }

                Button("Batal", role: .cancel) {
                    pendingDelete = []
                }

            } message: {
                Text("Transaksi masih bisa dibatalkan dalam beberapa detik.")
            }
        }
        .preferredColorScheme(
            appAppearance == "light" ? .light :
            appAppearance == "dark" ? .dark : nil
        )

        // MARK: UNDO TOAST
        .overlay(alignment: .bottom) {
            if showUndo, let deleted = recentlyDeleted {
                UndoToast(
                    title: "\(deleted.count) transaksi dihapus",
                    actionTitle: "Undo",
                    onAction: undoDelete
                )
                .padding(.bottom, 90)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: showUndo)
    }

    // MARK: - Delete Logic

    private func handleDelete(_ transactions: [TransactionEntity]) {
        recentlyDeleted = transactions
        tvm.deleteTransactions(transactions)
        showUndo = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            if showUndo {
                finalizeDelete()
            }
        }
    }

    private func undoDelete() {
        guard let transactions = recentlyDeleted else { return }

        tvm.undoDeleteTransactions(transactions)

        recentlyDeleted = nil
        showUndo = false
    }

    private func finalizeDelete() {
        recentlyDeleted = nil
        showUndo = false
    }

    // MARK: - Bottom Action Bar

    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            Button {
                formMode = .create
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 64, height: 64)
                    .background(Color.green)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
        }.padding(.top,20)
    }
}
