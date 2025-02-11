//
//  TransactionRowView.swift
//  MySwiftApp
//
//  Created by Rajaselvam Jayakumar on 11/5/24.
//

import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction
    let colors = Colors()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(formattedDate(transaction.date)) // Display date
                    .font(.footnote)
                    .foregroundColor(.gray)
                Text(transaction.description ?? "")
                    .font(.headline)
                Text(transaction.category)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 5) {
                Text((transaction.type == "income" ? "+" : "-") + String(format: "$%.2f", transaction.amount))
                    .font(.headline)
                    .foregroundStyle(transaction.type == "income" ? colors.forestGreen : .red)
                
            }
            
            // Circular Edit Button
//            NavigationLink(destination: AddTransactionView(transaction: transaction)) {
////
//            }
        }
        .padding()
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    TransactionRowView(transaction: Transaction(id: UUID().uuidString, type: "expense", amount: 89.90, category: "Food", description: "ate really good food at bros house", date: Date()))
}
