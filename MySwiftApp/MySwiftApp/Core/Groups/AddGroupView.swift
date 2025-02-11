import SwiftUI

struct AddGroupView: View {
    let group: TransGroup?
    @Binding var isPresented: Bool
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State private var name = ""
    @State private var type = "expense"
    @State private var current = 0.0
    @State private var budget = 0.0
    @State private var period = "daily"
    private let periods = ["daily", "weekly", "monthly", "yearly"]
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Text input for "Group Name"
            Text("Group Name")
                .foregroundColor(Color(.darkGray))
                .fontWeight(.semibold)
                .font(.footnote)
            TextField("Enter group name", text: $name)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
            
            // Picker for "Type" (Expense or Income)
            Text("Type")
                .foregroundColor(Color(.darkGray))
                .fontWeight(.semibold)
                .font(.footnote)
            Picker("Type", selection: $type) {
                Text("Expense").tag("expense")
                Text("Income").tag("income")
            }
            .pickerStyle(SegmentedPickerStyle())
            
            // Number input for "Current Amount"
            Text("Current Amount")
                .foregroundColor(Color(.darkGray))
                .fontWeight(.semibold)
                .font(.footnote)
            TextField("0.00", text: Binding(
                get: { String(format: "%.2f", current) },
                set: { newValue in
                    if let value = Double(newValue) {
                        current = value
                    }
                }
            ))
            .keyboardType(.decimalPad)
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
            
            // Number input for "Budget Amount"
            Text("Budget Amount")
                .foregroundColor(Color(.darkGray))
                .fontWeight(.semibold)
                .font(.footnote)
            TextField("0.00", text: Binding(
                get: { String(format: "%.2f", budget) },
                set: { newValue in
                    if let value = Double(newValue) {
                        budget = value
                    }
                }
            ))
            .keyboardType(.decimalPad)
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
            
            // Period Picker
            Text("Period")
                .foregroundColor(Color(.darkGray))
                .fontWeight(.semibold)
                .font(.footnote)
            Picker("daily", selection: $period) {
                ForEach(periods, id: \.self) { period in
                    Text(period.capitalized).tag(period)
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            Spacer()
            
            HStack {
                // Save Button
                FloatButtonView(title: "Save", imageName: "checkmark.circle.fill", color: Colors().darkGreen) {
                    isPresented = false
                    Task {
                        do {
                            try await viewModel.addGroup(
                                name: name,
                                type: type,
                                current: current,
                                budget: budget,
                                period: period
                            )
                        } catch {
                            print("Failed to add group: \(error.localizedDescription)")
                        }
                    }
                }
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
                
                // Delete Button
                if ((group?.name.isEmpty) != nil) {
                    FloatButtonView(title: "Delete", imageName: "xmark.circle.fill", color: Colors().cherryRed) {
                        Task {
                            await viewModel.deleteGroup(groupId: group?.id ?? "")
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
            name = group?.name ?? ""
            type = group?.type ?? "expense"
            current = group?.current ?? 0.0
            budget = group?.budget ?? 0.0
            period = group?.period ?? "daily"
        }
    }
    
}

extension AddGroupView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !name.isEmpty
        && current >= 0.00
        && budget >= 0.00
    }
}
