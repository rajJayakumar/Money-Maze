import SwiftUI

struct GoalListView: View {
    @EnvironmentObject var viewModel: AuthViewModel// Your list of goals
    @State private var showAddGroupView: Bool = false
    @State private var editGroupView: Bool = false
    @State private var showPopup = false
    @State private var inputValue = ""
    @State private var selectedGoal: Goal? = nil // Track the goal for the popup
    let colors = Colors()
    
    var body: some View {
        ZStack {
            VStack {
                // Add Group Button
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
                //            .sheet(isPresented: $showAddGroupView) {
                //                AddGoalView(goal: Goal(id: UUID().uuidString, name: "", description: "", amount: 0.00, progress: 0.00, recurring: false, period: "daily", startDate: Date(), endDate: Date()), isPresented: $showAddGroupView)
                //            }
                Text("My Goals")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                Text("Hold to Edit")
                    .font(.footnote)
                    .foregroundStyle(Color(.systemGray))
                    .padding(.bottom, 15)
                ScrollView {
                    VStack(spacing: 16) { // Space between the boxes
                        ForEach(viewModel.goals) { goal in
                            RoundedRectangle(cornerRadius: 20)
                                .fill(goal.progress >= goal.amount ? Color.green.opacity(0.3) : Color(.systemGray6)) // Background color
                                .frame(height: goal.progress >= goal.amount ? 120 : 100) // Height of the box
                                .overlay(
                                    VStack {
                                        if goal.progress >= goal.amount {
                                            Text("Goal Met!")
                                                .font(.headline)
                                                .bold()
                                                .foregroundStyle(colors.darkGreen)
                                        }
                                        HStack {
                                            Button(action: {
                                                withAnimation {
                                                    showPopup = true
                                                    selectedGoal = goal
                                                }
                                            }) {
                                                Image(systemName: "plus")
                                                    .font(.system(size: 24, weight: .bold))
                                                    .foregroundColor(colors.darkGreen)
                                            }
                                            .buttonStyle(BorderlessButtonStyle())
                                            
                                            GoalRowView(goal: goal)
                                                .onLongPressGesture {
                                                    selectedGoal = goal
                                                    editGroupView = true
                                                }
                                        }
                                    }
                                        .padding() // Padding for inner content
                                )
                                .padding(.horizontal) // Horizontal padding for the box
                        }
                    }
                    .sheet(isPresented: $editGroupView) {
                        if let selectedGoal = selectedGoal {
                            AddGoalView(goal: selectedGoal, isPresented: $editGroupView)
                        }
                    }
                }
                
                //Pop-up
                if showPopup, let goal = selectedGoal {
                    PopUpView(
                        title: "Add Money To \(goal.name)",
                        goal: goal,
                        onSave: viewModel.addToGoal,
                        onCancel: { showPopup = false }
                    )
                    .transition(.scale) // Animation for the popup
                    .zIndex(1) // Ensure it appears above other views
                }
            }
            
            VStack {
                Spacer()
                
                FloatButtonView(title: "Add Goal", imageName: "plus.circle.fill", color: Colors().darkGreen) {
                    showAddGroupView.toggle()
                }
                .sheet(isPresented: $showAddGroupView) {
                    AddGoalView(goal: Goal(id: UUID().uuidString, name: "", description: "", amount: 0.00, progress: 0.00, recurring: false, period: "daily", startDate: Date(), endDate: Date()), isPresented: $showAddGroupView)
                }
            }
        }
    }
}

struct GoalListView_Previews: PreviewProvider {
    static var previews: some View {
        GoalListView()
    }
}
