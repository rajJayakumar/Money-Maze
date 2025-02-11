//
//  TransactionListView.swift
//  MySwiftApp
//
//  Created by Rajaselvam Jayakumar on 11/3/24.
//

import SwiftUI


struct TransactionListView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showAddGroupView: Bool = false
    @State private var editGroupView: Bool = false
    @State private var selectedTran: Transaction? = nil
    @State private var transType: String = "All"
    @State private var sortType: String = "Date Up"
    @State private var category: String = "All"
    
    let colors = Colors()
    
    func sortedTransactions(transList: [Transaction]) -> [Transaction] {
        var sorted = transList
        
        if transType != "All" {
            sorted = sorted.filter { $0.type == transType}
        }
        
        if category != "All" {
            sorted = sorted.filter { $0.category == category}
        }
        
        switch sortType {
        case "Date Up":
            sorted = sorted.sorted { $0.date > $1.date }
        case "Date Down":
            sorted = sorted.sorted { $0.date < $1.date }
        case "Amount Up":
            sorted = sorted.sorted { $0.amount > $1.amount }
        case "Amount Down":
            sorted = sorted.sorted { $0.amount < $1.amount }
        default:
            print("thats not supposed to happen!!!")
        }
        
        return sorted
    }
    
    var body: some View {
        ZStack {
            VStack {
                Text("All Transactions")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                Text("Hold to Edit")
                    .font(.footnote)
                    .foregroundStyle(Color(.systemGray))
                    .padding(.bottom, 15)
                
                //Filter
                HStack {
                    Picker("All", selection: $transType) {
                        Text("All").tag("All")
                        Text("Incomes").tag("income")
                        Text("Expenses").tag("expense")
                    }
                    .padding(.leading)
                    .tint(.white)
                    
                    Picker("Date Up", selection: $sortType) {
                        HStack {
                            Text("Date")
                            Image(systemName: "arrow.up.circle.fill")
                                .imageScale(.small)
                                .font(.title)
                                .foregroundStyle(.black)
                        }.tag("Date Up")
                        HStack {
                            Text("Date")
                            Image(systemName: "arrow.down.circle.fill")
                                .imageScale(.small)
                                .font(.title)
                                .foregroundStyle(.black)
                        }.tag("Date Down")
                        HStack {
                            Text("Amount")
                            Image(systemName: "arrow.up.circle.fill")
                                .imageScale(.small)
                                .font(.title)
                                .foregroundStyle(.black)
                        }.tag("Amount Up")
                        HStack {
                            Text("Amount")
                            Image(systemName: "arrow.down.circle.fill")
                                .imageScale(.small)
                                .font(.title)
                                .foregroundStyle(.black)
                        }.tag("Amount Down")
                    }
                    .tint(.white)
                    
                    Picker("All", selection: $category) {
                        Text("All").tag("All")
                        ForEach(viewModel.groups) { group in
                            Text(group.name).tag(group.name)
                        }
                    }
                    .padding(.trailing)
                    .tint(.white)
                }
                .foregroundStyle(Color.white)
                .background(colors.darkGreen)
                .cornerRadius(50)
                .padding(.vertical, 10)
                
                
                ScrollView {
                    VStack(spacing: 16) { // Space between the boxes
                        ForEach(sortedTransactions(transList: viewModel.transactions)) { transaction in
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemGray6)) // Background color
                                .frame(height: 100)
                                .overlay(
                                    VStack {
                                        
                                        TransactionRowView(transaction: transaction)
                                            .onLongPressGesture {
                                                editGroupView = true
                                                selectedTran = transaction
                                                editGroupView = true
                                            }
                                    }
                                        .padding() // Padding for inner content
                                )
                                .padding(.horizontal) // Horizontal padding for the box
                        }
                    }
                    .sheet(isPresented: $editGroupView) {
                        if let selectedTran = selectedTran {
                            AddTransactionView(transaction: selectedTran, isPresented: $editGroupView)
                        }
                    }
                }
            }
            
            VStack {
                Spacer()
                
                FloatButtonView(title: "Add Transaction", imageName: "plus.circle.fill", color: Colors().darkGreen) {
                    showAddGroupView.toggle()
                }
                .sheet(isPresented: $showAddGroupView) {
                    AddTransactionView(transaction: Transaction(id: UUID().uuidString, type: "", amount: 0.00, category: "", description: "", date: Date()), isPresented: $showAddGroupView)
                }
            }
        }
    }
}

#Preview {
    TransactionListView()
}
