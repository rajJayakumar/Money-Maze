import SwiftUI

struct AddGoalView: View {
    let goal: Goal?
    @Binding var isPresented: Bool
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State private var name = ""
    @State private var description = ""
    @State private var amount = ""
    @State private var progress = 0.0
    @State private var recurring = false
    @State private var period = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Text input for "Goal Name"
//            Text("Goal Name")
//                .foregroundColor(Color(.darkGray))
//                .fontWeight(.semibold)
//                .font(.footnote)
//            TextField("Enter goal name", text: $name)
//                .padding()
//                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
            
            InputView(text: $name, title: "Goal Name", placeholder: "Enter goal name", numerical: false, isSecureField: false)
                .padding(.top)
            
//            // Toggle for "Recurring"
//            Text("Recurring")
//                .foregroundColor(Color(.darkGray))
//                .fontWeight(.semibold)
//                .font(.footnote)
//            Picker("Recurring", selection: $recurring) {
//                Text("Yes").tag(true)
//                Text("No").tag(false)
//            }
//            .pickerStyle(SegmentedPickerStyle())
            
            // Number input for "Amount"
//            Text("Amount")
//                .foregroundColor(Color(.darkGray))
//                .fontWeight(.semibold)
//                .font(.footnote)
//            TextField("0.00", text: Binding(
//                get: { String(format: "%.2f", amount) },
//                set: { newValue in
//                    if let value = Double(newValue) {
//                        amount = value
//                    }
//                }
//            ))
//            .keyboardType(.decimalPad)
//            .padding()
//            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
            
            InputView(text: $amount, title: "Amount", placeholder: "0.00", numerical: true, isSecureField: false)
            
            // Text Input for "Description"
//            Text("Description")
//                .foregroundColor(Color(.darkGray))
//                .fontWeight(.semibold)
//                .font(.footnote)
//            TextEditor(text: $description)
//                .frame(height: 100)
//                .padding(4)
//                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
            
            // Date Picker for "Start Date"
            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
                .foregroundColor(Color(.darkGray))
                .fontWeight(.semibold)
                .font(.footnote)
            
            // Date Picker for "End Date"
            DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
                .foregroundColor(Color(.darkGray))
                .fontWeight(.semibold)
                .font(.footnote)
        
            // Period selection (only shows if recurring is true)
            if recurring {
                HStack {
                    Text("Period")
                        .foregroundColor(Color(.darkGray))
                        .fontWeight(.semibold)
                        .font(.footnote)
                    Spacer()
                    Picker("Select Period", selection: $period) {
                        Text("Daily").tag("Daily")
                        Text("Weekly").tag("Weekly")
                        Text("Monthly").tag("Monthly")
                        Text("Yearly").tag("Yearly")
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            
            // Save Button
//            Button {
//                isPresented = false
//                Task {
//                    do {
//                        try await viewModel.addGoal(
//                            name: name,
//                            description: description,
//                            amount: Double(amount) ?? 0.0,
//                            progress: 0.00,
//                            recurring: recurring,
//                            period: period,
//                            startDate: startDate,
//                            endDate: endDate)
//                        if !name.isEmpty {
//                            await viewModel.deleteGoal(goalId: goal?.id ?? "")
//                        }
//                    } catch {
//                        print("Failed to add goal: \(error.localizedDescription)")
//                    }
//                }
//            } label: {
//                SettingsRowView(imageName: "arrow.left.circle.fill",
//                                title: "Save Goal",
//                                tintColor: Color(.red))
//            }
//            .disabled(!formIsValid)
//            .opacity(formIsValid ? 1.0 : 0.5)
            
            HStack {
                FloatButtonView(title: "Save", imageName: "checkmark.circle.fill", color: Colors().darkGreen) {
                    isPresented = false
                    Task {
                        do {
                            try await viewModel.addGoal(
                                name: name,
                                description: description,
                                amount: Double(amount) ?? 0.0,
                                progress: 0.00,
                                recurring: recurring,
                                period: period,
                                startDate: startDate,
                                endDate: endDate)
                            if !name.isEmpty {
                                await viewModel.deleteGoal(goalId: goal?.id ?? "")
                            }
                        } catch {
                            print("Failed to add goal: \(error.localizedDescription)")
                        }
                    }
                }
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
                
                //Delete Button
                if !name.isEmpty {
                    FloatButtonView(title: "Delete", imageName: "xmark.circle.fill", color: Colors().cherryRed) {
                        isPresented = false
                        Task {
                            await viewModel.deleteGoal(goalId: goal?.id ?? "")
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
            name = goal?.name ?? ""
            description = goal?.description ?? ""
            amount = String(goal?.amount ?? 0.0)
            progress = goal?.progress ?? 0.0
            recurring = goal?.recurring ?? false
            period = goal?.period ?? ""
            startDate = goal?.startDate ?? Date()
            endDate = goal?.endDate ?? Date()
        }
    }
}

extension AddGoalView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !name.isEmpty
        && !amount.isEmpty
        && endDate > startDate
    }
}
//#Preview {
//    AddGoalView(goal: Goal(id: "difnwn", name: "inufnc", description: "isncinnininiwu", amount: 89.90, progress: 0.00, recurring: true, period: DateComponents(), startDate: Date(), endDate: Date()))
//}
