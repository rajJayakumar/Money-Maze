//
//  ProfileView.swift
//  MySwiftApp
//
//  Created by Rajaselvam Jayakumar on 10/13/24.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State var validateAlert = false
    @State var wrongPasswordAlert = false
    @State var areYouSureAlert = false
    @State var successAlert = false
    @State var password = ""
    @State var editInfo = false
    @State var newName = ""
    @State var newEmail = ""
    @State var message = ""
    @State var messageShow = false
    @State var showAlert = false
    
    var body: some View {
        if let user = viewModel.currentUser {
            NavigationStack {
            List {
                Section {
                    HStack {
                        Text(user.initials)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(.white))
                            .frame(width: 72, height: 72)
                            .background(Color(.systemGray3))
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.fullname)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.top, 4)
                            
                            Text(user.email)
                                .font(.footnote)
                                .foregroundStyle(Color(.gray))
                        }
                    }
                }
                .onTapGesture {
                    editInfo.toggle()
                }
                .sheet(isPresented: $editInfo) {
                    InputView(text: $newName, title: "Name", placeholder: "Enter name", numerical: false, isSecureField: false)
                    InputView(text: $newEmail, title: "Email", placeholder: "name@example.com", numerical: false, isSecureField: false)
                    FloatButtonView(title: "Send verification email", imageName: "checkmark.circle.fill", color: Colors().forestGreen) {
                        Task {
                            message = try await viewModel.updateUser(withEmail: newEmail, fullname: newName)
                        }
                        messageShow = true
                    }
                    FloatButtonView(title: "Cancel", imageName: "xmark.circle.fill", color: Colors().darkRed) {
                        editInfo = false
                    }
//                    if messageShow {
//                        Text(message)
//                            .font(.footnote)
//                        FloatButtonView(title: "OK", imageName: "xmark.circle.fill", color: Colors().darkRed) {
//                            editInfo = false
//                        }
//                    }
                }
                .onAppear {
                    newName = viewModel.currentUser?.fullname ?? ""
                    newEmail = viewModel.currentUser?.email ?? ""
                }
                .alert(message, isPresented: $messageShow) {
                    Button("OK", role: .cancel) { editInfo = false }
                }
                
//                Section("General") {
//                    HStack {
//                        SettingsRowView(imageName: "gear",
//                                        title: "Version",
//                                        tintColor: Color(.systemGray))
//                        
//                        Spacer()
//                        
//                        Text("1.0.0")
//                            .font(.subheadline)
//                            .foregroundStyle(Color(.gray))
//                    }
//                }
                
                Section("Account") {
                    //Sign Out Button
                    Button {
                        viewModel.signOut()
                    } label: {
                        SettingsRowView(imageName: "arrow.left.circle.fill",
                                        title: "Sign Out",
                                        tintColor: Color(.red))
                    }
                    
                    //Delete Account Button
                    Button {
                        areYouSureAlert = true
                    } label: {
                        SettingsRowView(imageName: "xmark.circle.fill",
                                        title: "Delete Account",
                                        tintColor: Color(.red))
                    }
                    .alert("Are you sure you want to permanently delete your account?", isPresented: $areYouSureAlert) {
                        Button("Yes") {
                            areYouSureAlert = false
                            validateAlert = true
                            var message = viewModel.deleteUser()
                        }
                        .foregroundStyle(.red)
                        Button("Cancel", role: .cancel) {}
                    }
                    .alert(message, isPresented: $validateAlert) {
                        Button("OK", role: .cancel) {}
                    }
//                    .alert("Account deletion requires validation", isPresented: $validateAlert) {
//                        TextField("Enter password", text: $password)
//                        Button("Submit") {
//                            print("Submitted: \(password)")
//                            validateAlert = false
//                            Task {
//                                if await viewModel.reauthenticateUser(password: password) {
//                                    areYouSureAlert = true
//                                } else {
//                                    wrongPasswordAlert = true
//                                }
//                            }
//                        }
//                        Button("Cancel", role: .cancel) {}
//                    }
//                    .alert("Wrong Password", isPresented: $wrongPasswordAlert) {
//                        Button("OK", role: .cancel) {}
//                    }
//                    .alert("Are you sure you want to permanently delete your account?", isPresented: $areYouSureAlert) {
//                        Button("Delete Account") {
//                            print("User Deleted")
//                            viewModel.deleteUser()
//                        }
//                        Button("Cancel", role: .cancel) {}
//                    }
                    
                    
//                    //Add Transaction Button
//                    NavigationLink(destination: AddTransactionView(transaction: Transaction(
//                        id: UUID().uuidString,
//                        type: "",
//                        amount: 0.00,
//                        category: "",
//                        description: "",
//                        date: Date()), isPresented: false)) {
//                        SettingsRowView(
//                            imageName: "arrow.left.circle.fill",
//                            title: "Add Transaction",
//                            tintColor: Color(.red)
//                        )
//                    }
                    
//                    //History View Button
//                    NavigationLink(destination: TransactionListView()) {
//                        SettingsRowView(
//                            imageName: "arrow.left.circle.fill",
//                            title: "History",
//                            tintColor: Color(.red)
//                        )
//                    }
//                    
//                    //Dashboard View Button
//                    NavigationLink(destination: DashboardView()) {
//                        SettingsRowView(
//                            imageName: "arrow.left.circle.fill",
//                            title: "Dashboard",
//                            tintColor: Color(.red)
//                        )
//                    }
//                    
//                    //Add Goal View Button
////                    NavigationLink(destination: AddGoalView(goal: Goal(
////                        id: UUID().uuidString,
////                        name: "",
////                        description: "",
////                        amount: 0.00,
////                        progress: 0.00,
////                        recurring: true,
////                        period: DateComponents(),
////                        startDate: Date(),
////                        endDate: Date()), isPresented: false)) {
////                        SettingsRowView(
////                            imageName: "arrow.left.circle.fill",
////                            title: "Add Goal",
////                            tintColor: Color(.red)
////                        )
////                    }
//                    
//                    //Goal List View Button
//                    NavigationLink(destination: GoalListView()) {
//                        SettingsRowView(
//                            imageName: "arrow.left.circle.fill",
//                            title: "My Goals",
//                            tintColor: Color(.red)
//                        )
//                    }
//                    
//                    //Goal List View Button
//                    NavigationLink(destination: GroupListView()) {
//                        SettingsRowView(
//                            imageName: "arrow.left.circle.fill",
//                            title: "My Groups",
//                            tintColor: Color(.red)
//                        )
//                    }
//                    
//                    //Line Grap View Button
//                    NavigationLink(destination: LineGraphView()) {
//                        SettingsRowView(
//                            imageName: "arrow.left.circle.fill",
//                            title: "Line Graph",
//                            tintColor: Color(.red)
//                        )
//                    }
//                    
////                    //Chat GPT View Button
////                    NavigationLink(destination: BudgetTipsView()) {
////                        SettingsRowView(
////                            imageName: "arrow.left.circle.fill",
////                            title: "Budget Tips",
////                            tintColor: Color(.red)
////                        )
////                    }
//                    
//                    //Chat Bot View Button
//                    NavigationLink(destination: ChatBotView()) {
//                        SettingsRowView(
//                            imageName: "arrow.left.circle.fill",
//                            title: "Chat Bot",
//                            tintColor: Color(.red)
//                        )
//                    }

                }
                Section("Help") {
                    Link(destination: URL(string: "https://app.websitepolicies.com/policies/view/3a21uuv2")!) {
                        SettingsRowView(imageName: "",
                                        title: "Privacy Policy",
                                        tintColor: Color.red)
                    }
                        
                    // Help/Feedback Alert
                    Button {
                        showAlert = true
                    } label: {
                        SettingsRowView(imageName: "",
                                        title: "Help/Feedback",
                                        tintColor: Color.red)
                    }
                    .alert("For help/feedback, contact: my.rj.acc173@gmail.com", isPresented: $showAlert) {
                        Button("OK", role: .cancel) { }
                    }
                }
            }
        }
        } else {
            LoginView()
        }
    }
}

#Preview {
    ProfileView()
}
