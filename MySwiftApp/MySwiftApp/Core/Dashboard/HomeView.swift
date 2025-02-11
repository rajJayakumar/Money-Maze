import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: AuthViewModel // Use the AuthViewModel for data access
    let colors = Colors()
    
    var formattedNetWorth: String {
        if viewModel.netWorth < 0 {
            return "-$\(String(format: "%.2f", abs(viewModel.netWorth)))"
        } else {
            return "$\(String(format: "%.2f", viewModel.netWorth))"
        }
    }
    
    var mostRecent: (name: String, date: Date, type: String) {
        // Combine goals and transactions, find the closest date
        let allItems = viewModel.goals.map { ($0.name, $0.endDate, "Goal") } +
                        viewModel.transactions.map { ($0.description ?? "Unknown", $0.date, "Transaction") }

        // Use optional binding to safely unwrap the optional value returned by min
        if let mostRecentItem = allItems.min(by: { $0.1 < $1.1 }) {
            return mostRecentItem
        } else {
            return ("No Upcoming", Date(), "")
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Welcome Message
                Text("Welcome back, \(viewModel.currentUser?.fullname ?? "")")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                // Net Worth
                RoundedRectangle(cornerRadius: 20)
                    .fill(viewModel.netWorth > 0 ? colors.darkGreen : colors.darkRed)
                    .frame(height: 100)
                    .overlay(
                        VStack {
                            Text("Your Total Net Worth")
                                .font(.headline)
                            Text(formattedNetWorth)
                                .font(.title)
                                .fontWeight(.bold)
                        }
                            .foregroundColor(.white)
                    )
                    .padding(.horizontal)
                
                // Budget Tips & Weekly Stats
                HStack(alignment: .top, spacing: 16) {
                    VStack(spacing: 16) {
                        // Budget Tips
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray6))
                            .frame(height: 156)
                            .overlay(
                                VStack {
                                    Text("Daily Tip")
                                        .font(.headline)
                                        .foregroundColor(colors.darkGreen)
                                        .padding(.top)
                                    BudgetTipsView(tips: viewModel.budgetTips)
                                    //.padding()
                                }
                            )
                        
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray6))
                            .frame(height: 100)
                            .overlay(
                                VStack {
                                    let recent = mostRecent
                                    VStack(alignment: .center, spacing: 8) {
                                        Text("Upcoming Date")
                                            .font(.headline)
                                            .foregroundColor(colors.darkGreen)
                                        Text(recent.date, style: .date) // Formats the date automatically
                                            .font(.footnote)
                                            //.fontWeight(.bold)
                                        Text(recent.name)
                                            .font(.footnote)
                                            .fontWeight(.bold)
                                    }
                                }
                            )
                    }
                    // Weekly Stats
                    VStack(spacing: 16) {
                        StatBox(title: "Weekly Income", amount: viewModel.calculateTotalSinceLastSunday(type: "income"), color: .green)
                        StatBox(title: "Weekly Expenses", amount: viewModel.calculateTotalSinceLastSunday(type: "expense"), color: .red)
                        StatBox(title: "Total Savings", amount: viewModel.goals.reduce(0.0) { sum, goal in sum + goal.progress}, color: .blue)
                    }
                }
                .padding(.horizontal)
                
                // Recent Transactions
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Transactions")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView {
                        VStack(spacing: 16) { // Space between the boxes
                            ForEach(viewModel.transactions.sorted { $0.date > $1.date } // Sort by most recent date
                                .prefix(3)                // Get the first `count` transactions
                                .map { $0 }) { transaction in
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color(.systemGray6)) // Background color
                                        .frame(height: 100)
                                        .overlay(
                                            VStack {
                                                TransactionRowView(transaction: transaction)
                                            }
                                                .padding() // Padding for inner content
                                        )
                                        .padding(.horizontal) // Horizontal padding for the box
                                }
                        }
                    }
                    .padding(.bottom)
                }
            }
            .padding(.top, 16)
        }
        .padding()
    }
    
    struct StatBox: View {
        let title: String
        let amount: Double
        let color: Color
        
        var body: some View {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
                .frame(height: 80)
                .overlay(
                    VStack {
                        Text(title)
                            .font(.footnote)
                            .fontWeight(.bold)
                            //.foregroundColor(color)
                        //Spacer()
                        Text("$\(amount, specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(color)
                    }
                        .padding(.horizontal)
                )
        }
    }
    
    //#Preview {
    //    HomeView()
    //        .environmentObject(AuthViewModel()) // Mock environment object for preview
    //}
}
