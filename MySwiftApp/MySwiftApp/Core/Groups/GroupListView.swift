import SwiftUI

struct GroupListView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State private var showAddGroupView: Bool = false
    @State private var editGroupView: Bool = false
    @State private var isExpenseGroup: Bool = true // Toggles between expense and income groups
    @State private var selectedGroup: TransGroup? = nil
    @State private var transactionType: String = "Income" // Default selection for first picker
    //@State private var timeframe: String = "daily"       // Default selection for second picker
    
    let transactionTypes = ["Income", "Expense"]
    let timeframes = ["daily", "weekly", "monthly", "yearly"]
    
    func filteredGroups(timeframe: String) -> [TransGroup] {
        //let timeframe: String
        return viewModel.groups.filter { group in
            // Filter by transactionType
            transactionType.lowercased() == group.type
        }.filter { group in
            group.period == timeframe
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                // Title with toggle functionality
                Text("Budget Groups")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                Text("Hold to Edit")
                    .font(.footnote)
                    .foregroundStyle(Color(.systemGray))
                    .padding(.bottom, 15)
                
                // First Picker: Income or Expense
                Picker("Transaction Type", selection: $transactionType) {
                    ForEach(transactionTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle()) // Display as segmented control
                .padding([.leading, .trailing], 20)
                
                //            // Second Picker: Timeframe
                //            Picker("Timeframe", selection: $timeframe) {
                //                ForEach(timeframes, id: \.self) { period in
                //                    Text(period.capitalized.prefix(1)) // Use abbreviation (e.g., D, W, M, Y)
                //                        .tag(period)
                //                }
                //            }
                //            .pickerStyle(SegmentedPickerStyle()) // Display as segmented control
                //            .padding([.leading, .trailing], 20)
                
                //            // Add Group Button
                //            Button(action: {
                //                showAddGroupView.toggle()
                //            }) {
                //                HStack {
                //                    Image(systemName: "plus.circle.fill")
                //                        .foregroundColor(.blue)
                //                        .font(.system(size: 20))
                //                    Text("Add Group")
                //                        .fontWeight(.semibold)
                //                        .foregroundColor(.blue)
                //                }
                //            }
                //            .padding()
                //            .sheet(isPresented: $showAddGroupView) {
                //                AddGroupView(group: TransGroup(id: UUID().uuidString, name: "", type: isExpenseGroup ? "expense" : "income", current: 0.00, budget: 0.00, period: "daily"), isPresented: $showAddGroupView)
                //            }
                
                ScrollView {
                    VStack(spacing: 16) { // Space between the boxes
                        ForEach(timeframes, id: \.self) { timeframe in
                            let filtered = filteredGroups(timeframe: timeframe)
                            if !filtered.isEmpty {
                                Text(timeframe.capitalized)
                                    .font(.footnote)
                            }
                            
                            ForEach(filtered) { group in
                                //print(group)
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(.systemGray6)) // Background color
                                    .frame(height: group.current >= group.budget ? 120 : 100) // Height of the box
                                    .overlay(
                                        VStack {
                                            if group.current >= group.budget {
                                                Text("Over Budget!")
                                                    .font(.headline)
                                                    .bold()
                                                    .foregroundStyle(.red)
                                            }
                                            HStack {
                                                GroupRowView(group: group)
                                                    .onLongPressGesture {
                                                        selectedGroup = group
                                                        editGroupView = true
                                                        print(group)
                                                    }
                                            }
                                        }
                                            .padding() // Padding for inner content
                                    )
                                    .padding(.horizontal) // Horizontal padding for the box
                            }
                        }
                        //
                        //                    // Use the filtered groups to display
                        //                    ForEach(filteredGroups) { group in
                        //                        RoundedRectangle(cornerRadius: 20)
                        //                            .fill(Color(.systemGray6)) // Background color
                        //                            .frame(height: group.current >= group.budget ? 120 : 100) // Height of the box
                        //                            .overlay(
                        //                                VStack {
                        //                                    if group.current >= group.budget {
                        //                                        Text("Over Budget!")
                        //                                            .font(.headline)
                        //                                            .bold()
                        //                                            .foregroundStyle(.red)
                        //                                    }
                        //                                    HStack {
                        //                                        GroupRowView(group: group)
                        //                                            .onLongPressGesture {
                        //                                                selectedGroup = group
                        //                                                editGroupView = true
                        //                                            }
                        //                                    }
                        //                                }
                        //                                .padding() // Padding for inner content
                        //                            )
                        //                            .padding(.horizontal) // Horizontal padding for the box
                        //                    }
                    }
                    //.padding(.bottom, 80)
                    .sheet(isPresented: $editGroupView, onDismiss: {
                        selectedGroup = nil // Clear the selection after dismissing the sheet
                    }) {
                        if let selectedGroup = selectedGroup {
                            AddGroupView(group: selectedGroup, isPresented: $editGroupView)
                        } else {
                            Text("No group selected")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            
            VStack {
                Spacer()
                
                FloatButtonView(title: "Add Group", imageName: "plus.circle.fill", color: Colors().darkGreen) {
                    showAddGroupView.toggle()
                }
                .sheet(isPresented: $showAddGroupView) {
                    AddGroupView(group: TransGroup(id: UUID().uuidString, name: "", type: isExpenseGroup ? "expense" : "income", current: 0.00, budget: 0.00, period: "daily"), isPresented: $showAddGroupView)
                }
            }
        }
    }
}

