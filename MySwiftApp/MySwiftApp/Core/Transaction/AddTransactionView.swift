import SwiftUI

struct AddTransactionView: View {
    let transaction: Transaction?
    @Binding var isPresented: Bool
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State private var type = "income"
    @State private var amount = 0.00
    @State private var date = Date()
    @State private var description = ""
    @State private var category = "Select"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Dropdown input for "Type"
            Text("Type")
                .foregroundColor(Color(.darkGray))
                .fontWeight(.semibold)
                .font(.footnote)
            Picker("Type", selection: $type) {
                Text("Expense").tag("expense")
                Text("Income").tag("income")
            }
            .pickerStyle(SegmentedPickerStyle())
            
            // Dropdown input for "Category"
            Text("Category")
                .foregroundColor(Color(.darkGray))
                .fontWeight(.semibold)
                .font(.footnote)
            if type == "income" {
                Picker("Select", selection: $category) {
                    Text("Select").tag("Select")
                    ForEach(viewModel.groups.filter { $0.type == "income"}, id: \.id) { group in
                        Text(group.name).tag(group.name)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            } else {
                Picker("Select", selection: $category) {
                    Text("Select").tag("Select")
                    ForEach(viewModel.groups.filter { $0.type == "expense"}, id: \.id) { group in
                        Text(group.name).tag(group.name)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            // Number input for "Amount"
            Text("Amount")
                .foregroundColor(Color(.darkGray))
                .fontWeight(.semibold)
                .font(.footnote)
            TextField("0.00", text: Binding(
                get: { String(format: "%.2f", amount) }, // Display as a string with two decimal places
                set: { newValue in
                    if let value = Double(newValue) { // Convert String back to Double
                        amount = value
                    }
                }
            ))
                .keyboardType(.decimalPad)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
            
            // Text Input for Descirption
            Text("Description")
                .foregroundColor(Color(.darkGray))
                .fontWeight(.semibold)
                .font(.footnote)
            TextEditor(text: $description)
                .frame(height: 100)
                .padding(4)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
            
            // Date input for "Date"
            DatePicker("Date", selection: $date, displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
                .foregroundColor(Color(.darkGray))
                .fontWeight(.semibold)
                .font(.footnote)
            
            HStack {
                //Save Button
                FloatButtonView(title: "Save", imageName: "checkmark.circle.fill", color: Colors().darkGreen) {
                    isPresented = false
                    Task {
                        do {
                            try await viewModel.addTransaction(
                                type: type,
                                amount: amount,
                                category: category,
                                description: description,
                                date: date)
                            if !type.isEmpty {
                                await viewModel.deleteTransaction(transactionId: transaction?.id ?? "")
                            }
                        } catch {
                            print("Failed to add transaction: \(error.localizedDescription)")
                        }
                        
                    }
                } 
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
                
                //Delete Button
                if !type.isEmpty {
                    FloatButtonView(title: "Delete", imageName: "xmark.circle.fill", color: Colors().cherryRed) {
                        isPresented = false
                        Task {
                            await viewModel.deleteTransaction(transactionId: transaction?.id ?? "")
                        }
                    }
                }
            }
            
            Button("Cancel") {
                isPresented = false // Dismiss the sheet
            }
            .foregroundColor(.red)
            .padding()
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .onAppear {
            type = transaction?.type ?? "expense"
            category = transaction?.category ?? ""
            amount = transaction?.amount ?? 0.00
            description = transaction?.description ?? ""
            date = transaction?.date ?? Date()
        }
    }
}

extension AddTransactionView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !description.isEmpty
        && amount != 0.00
        && category != "Select"
    }
}

//#Preview {
//    AddTransactionView(transaction: Transaction(id: "hdhd", type: "expense", amount: 99.00, category: "FOOD", description: "hella food yeye", date: Date()))
//}
