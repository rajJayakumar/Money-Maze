import SwiftUI

struct GoalRowView: View {
    let goal: Goal
    @State private var showPopup = false
    @State private var inputValue = ""
    
    var currentPeriodDates: (start: Date, end: Date) {
        getCurrentPeriodDates()
    }

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        
                        VStack(alignment: .leading) {
                            //                    // Date Range
                            Text("\(formattedDate(currentPeriodDates.start)) - \(formattedDate(currentPeriodDates.end))")
                                .font(.footnote)
                                .foregroundColor(.gray)
                            
                            // Goal Name
                            HStack {
                                Text(goal.name)
                                    .font(.headline)
                                    .bold()
                                Spacer()
                                // Target Amount
                                Text("$\(String(format: "%.2f", goal.amount))")
                                    .font(.headline)
                            }
                        }
                    }
                    
                    // Progress Bar with Progress Text Inside
                    HStack {
                        ProgressBarView(value: goal.progress, targetValue: goal.amount)
                            .frame(height: 12)
                            .padding(.top, 4)
                        Text("$\(String(format: "%.2f", goal.progress))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }

    func getCurrentPeriodDates() -> (start: Date, end: Date) {
        // If not recurring, return the original dates
        guard goal.recurring else {
            return (goal.startDate, goal.endDate)
        }

        // Calculate the closest period end date that is before or on today
        let calendar = Calendar.current
        var currentStartDate = goal.startDate
        
        var currentEndDate = calendar.date(byAdding: goal.periodToDC(), to: currentStartDate)!

        while currentEndDate < Date() {
            currentStartDate = currentEndDate
            currentEndDate = calendar.date(byAdding: goal.periodToDC(), to: currentStartDate)!
        }

        return (currentStartDate, currentEndDate)
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

//#Preview {
//    GoalRowView(goal: Goal(id: "", name: "Save for Xbox", description: "I want to get an xbox for black friday!!", amount: 500.00, progress: 45.00, recurring: true, period: DateComponents(weekOfYear: 1), startDate: Date(), endDate: Date()))
//}
