//
//  DashboardView.swift
//  MySwiftApp
//
//  Created by Rajaselvam Jayakumar on 11/9/24.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var isIncomeSelected = false
    @State private var selectedRange = "Week"
    //@State private var type = ""
    
    var body: some View {
        ScrollView {
            Text("Statistics")
                .fontWeight(.bold)
                .font(.title)
                .padding(.bottom)
            
            // Toggle between Income and Expenses
            Picker("Transaction Type", selection: $isIncomeSelected) {
                Text("Income").tag(true)
                Text("Expenses").tag(false)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            // Toggle for data range
            Picker("Data Range", selection: $selectedRange) {
                Text("Week").tag("Week")
                Text("Month").tag("Month")
                Text("6 Months").tag("6 Months")
                Text("Year").tag("Year")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.bottom)
            //Expense or Income View Picker
//            Text("Type")
//                .foregroundColor(Color(.darkGray))
//                .fontWeight(.semibold)
//                .font(.footnote)
//            Picker("Type", selection: $type) {
//                Text("Expense").tag("expense")
//                Text("Income").tag("income")
//            }
//            .pickerStyle(SegmentedPickerStyle())
//            .padding()
            
            if !isIncomeSelected {
//                Text("Expenses")
//                    .foregroundColor(Color(.darkGray))
//                    .fontWeight(.semibold)
//                    .font(.footnote)
                PieChartView(data: viewModel.transactions.filter { $0.type == "expense"  && $0.date >= calculateStartDate(for: selectedRange)})
            } else {
//                Text("Incomes")
//                    .foregroundColor(Color(.darkGray))
//                    .fontWeight(.semibold)
//                    .font(.footnote)
                PieChartView(data: viewModel.transactions.filter { $0.type == "income"  && $0.date >= calculateStartDate(for: selectedRange)})
            }
            
//            HStack {
//                VStack{
//                    Text("Expenses")
//                        .foregroundColor(Color(.darkGray))
//                        .fontWeight(.semibold)
//                        .font(.footnote)
//                    PieChartView(data: viewModel.transactions.filter { $0.type == "expense" && $0.date >= calculateStartDate(for: selectedRange) })
//                }
//                VStack {
//                    Text("Incomes")
//                        .foregroundColor(Color(.darkGray))
//                        .fontWeight(.semibold)
//                        .font(.footnote)
//                    PieChartView(data: viewModel.transactions.filter { $0.type == "income"  && $0.date >= calculateStartDate(for: selectedRange) })
//                }
//            }
            
            LineGraphView(isIncomeSelected: $isIncomeSelected, selectedRange: $selectedRange)
        }
    }
    
    // Helper function to generate the start date based on the selected date range
    private func calculateStartDate(for dateRange: String) -> Date {
        let currentDate = Date()
        
        switch dateRange.lowercased() {
        case "week":
            return Calendar.current.date(byAdding: .day, value: -7, to: currentDate) ?? currentDate
        case "month":
            return Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
        case "3 months":
            return Calendar.current.date(byAdding: .month, value: -3, to: currentDate) ?? currentDate
        case "6 months":
            return Calendar.current.date(byAdding: .month, value: -6, to: currentDate) ?? currentDate
        case "year":
            return Calendar.current.date(byAdding: .year, value: -1, to: currentDate) ?? currentDate
        default:
            return currentDate
        }
    }
}

#Preview {
    DashboardView()
}
