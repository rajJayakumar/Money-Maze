//
//  PieChartView.swift
//  MySwiftApp
//
//  Created by Rajaselvam Jayakumar on 11/9/24.
//

import SwiftUI
import Charts

struct PieChartView: View {
    let data: [Transaction]
    let colors = Colors()
    
    func sumAmountsByCategory(transactions: [Transaction]) -> [String: Double] {
        var sumsByCategory: [String: Double] = [:]

        for transaction in transactions {
            sumsByCategory[transaction.category, default: 0.0] += transaction.amount
        }

        return sumsByCategory
    }
    
    func typeOfData() -> Color {
        do {
            if data.count > 0 {
                return data[0].type == "income" ? colors.darkGreen : colors.cherryRed
            } else {
                return colors.darkGreen
            }
        } catch {
            return colors.darkGreen
        }
    }
    
    var body: some View {
        let sumsByCat = sumAmountsByCategory(transactions: data)
        Chart {
            ForEach(Array(sumsByCat.enumerated()), id: \.offset) { index, categoryAmount in
                let (category, amount) = categoryAmount
                SectorMark(angle: .value("Expenses", amount),
                           innerRadius: .ratio(0.5),
                           angularInset: 1)
                    .foregroundStyle(by: .value("Category", category))
                    .cornerRadius(3)
            }
        }
        .padding(.bottom, 20)
        .padding(.horizontal)
        .frame(minHeight: 320)
        .overlay(
            VStack {
                if data.count > 0 {
                    Text("$\(String(format: "%.2f", data.reduce(0.0) { $0 + $1.amount }))")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(typeOfData())
                        .padding(.horizontal)
                    Text(" ")
                } else {
                    Text("No data to display")
                        .font(.title)
                        .fontWeight(.bold)
                        //.foregroundColor(typeOfData())
                        .padding(.horizontal)
                }
            }
        )
        
    }
}

#Preview {
    PieChartView(data: [])
}
