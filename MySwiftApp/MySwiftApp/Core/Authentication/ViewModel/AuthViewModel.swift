//
//  AuthViewModel.swift
//  MySwiftApp
//
//  Created by Rajaselvam Jayakumar on 10/13/24.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestoreCombineSwift

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var transactions: [Transaction] = []
    @Published var goals : [Goal] = []
    @Published var groups : [TransGroup] = []
    @Published var budgetTips: String = "..."
    @Published var lastLogin: Date = Date()
    
    var uid: String {
        guard let uid = Auth.auth().currentUser?.uid else { return "" }
        return uid
    }
    
    
    
    var checkNewWeek: Bool {
        if let referenceDate = UserDefaults.standard.object(forKey: "referenceDate") as? Date {
            print(referenceDate)
            print(Date())
            lastLogin = referenceDate
            //print(Date()-604800)
            // Check if the stored date is in the same week as today
            if Calendar.current.component(.weekOfYear, from: Date()) != Calendar.current.component(.weekOfYear, from: referenceDate) {
                // If it's not the same week, update the reference date and return true
    //            UserDefaults.standard.set(Date(), forKey: "referenceWeek")
    //            print("just updating refernece date")
                return true
            }
        } else {
            // Reference date has never been set, so set it now
            UserDefaults.standard.set(Date(), forKey: "referenceDate")
            print("setting new refernce date")
            return true
        }
        print("somehow only returned fasle")
        return false
    }
    
    var checkNewDay: Bool {
        if let referenceDate = UserDefaults.standard.object(forKey: "referenceDate") as? Date {
            return Calendar.current.component(.day, from: Date()) != Calendar.current.component(.day, from: referenceDate)
        }
        return false
    }
    
    var checkNewMonth: Bool {
        if let referenceDate = UserDefaults.standard.object(forKey: "referenceDate") as? Date {
            return Calendar.current.component(.month, from: Date()) != Calendar.current.component(.month, from: referenceDate)
        }
        return false
    }
    
    var checkNewYear: Bool {
        if let referenceDate = UserDefaults.standard.object(forKey: "referenceDate") as? Date {
            return Calendar.current.component(.year, from: Date()) != Calendar.current.component(.year, from: referenceDate)
        }
        return false
    }
    
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUser()
        }
    }
    
    func signIn(withEmail email:String, password: String) async throws -> Bool {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
            return false
        } catch {
            print("DEBUG: Failed to login with error \(error.localizedDescription)")
            return true
        }
    }
    
    func createUser(withEmail email:String, password: String, fullname: String) async throws -> Bool {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullname: fullname, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            UserDefaults.standard.set(Date(), forKey: "referenceDate")
            await fetchUser()
            try await addGroup(name: "Food", type: "expense", current: 0.00, budget: 100.00, period: "weekly")
            try await addGroup(name: "Entertainment", type: "expense", current: 0.00, budget: 100.00, period: "weekly")
            try await addGroup(name: "Job", type: "income", current: 0.00, budget: 100.00, period: "monthly")
            try await addGroup(name: "Stocks", type: "income", current: 0.00, budget: 100.00, period: "weekly")
            return false
        } catch {
            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
            return true
        }
    }
    
    func updateUser(withEmail newEmail: String, fullname: String) async throws -> String {
        guard let userID = userSession?.uid else {
            throw NSError(domain: "com.yourapp.errors", code: 0, userInfo: ["message": "Failed to retrieve user ID"])
        }
        
        // Update user info in Authentication (optional)
        var emailSuccess = "Verification email sent successfully"
        if let user = userSession {
            do {
                try await user.sendEmailVerification(beforeUpdatingEmail: newEmail)
            } catch {
                print("Error sending verification email: \(error.localizedDescription)")
                emailSuccess = "Error sending verification email: \(error.localizedDescription)"
            }
        }

        // Update user data in Firestore
        var updatedUserData = [String: Any]()
        updatedUserData["email"] = newEmail
        updatedUserData["fullname"] = fullname
        
        Firestore.firestore().collection("users").document(userID).updateData(updatedUserData)
        
        currentUser?.fullname = fullname
        currentUser?.email = newEmail
        // Update user session (optional)
        //await fetchUser() // Call this function to refresh user data
        return emailSuccess
    }
    
    func addTransaction(type: String, amount: Double, category: String, description: String, date: Date) async throws {
        do {
            guard let uid = self.currentUser?.id else { return }
            let transaction = Transaction(id: UUID().uuidString, type: type, amount: amount, category: category, description: description, date: date)
            // Find the matching group and update its current value
            if let groupIndex = self.groups.firstIndex(where: { $0.name == category }) {
                self.groups[groupIndex].current += transaction.amount
                
                // Save the updated group back to Firestore
                let updatedGroup = self.groups[groupIndex]
                let encodedGroup = try Firestore.Encoder().encode(updatedGroup)
                try await Firestore.firestore().collection("users").document(uid).collection("groups").document(updatedGroup.id).setData(encodedGroup)
            }
            self.transactions.append(transaction)
            let encodedTrans = try Firestore.Encoder().encode(transaction)
            try await Firestore.firestore().collection("users").document(uid).collection("transactions").document(transaction.id).setData(encodedTrans)
        } catch {
            print("DEBUG: Failed to add transaction with error \(error.localizedDescription)")
            throw error
        }
    }
    
    func addGoal(name: String, description: String, amount: Double, progress: Double, recurring: Bool, period: String, startDate: Date, endDate: Date) async throws {
        do {
            guard let uid = self.currentUser?.id else { return }
            let goal = Goal(id: UUID().uuidString, name: name, description: description, amount: amount, progress: progress, recurring: recurring, period: period, startDate: startDate, endDate: endDate)
            self.goals.append(goal)
            let encodedGoal = try Firestore.Encoder().encode(goal)
            try await Firestore.firestore().collection("users").document(uid).collection("goals").document(goal.id).setData(encodedGoal)
        } catch {
            print("DEBUG: Failed to add goal with error \(error.localizedDescription)")
            throw error
        }
    }
    
    func addToGoal(amount: String, goal: Goal) async throws{
        do {
            //guard let uid = Auth.auth().currentUser?.uid else { return }
            guard let amountToAdd = Double(amount) else { return }
            guard let goalIndex = goals.firstIndex(where: { $0.id == goal.id }) else {return}
            goals[goalIndex].progress += amountToAdd
            try await Firestore.firestore().collection("users").document(uid).collection("goals").document(goal.id).updateData(["progress": goals[goalIndex].progress])
        } catch {
            print("DEBUG: Failed to add goal with error \(error.localizedDescription)")
            throw error
        }
    }
    
    func addGroup(name: String, type: String, current: Double, budget: Double, period: String) async throws {
        do {
            guard let uid = self.currentUser?.id else { return }
            let group = TransGroup(id: UUID().uuidString, name: name, type: type, current: current, budget: budget, period: period)
            self.groups.append(group)
            let encodedGroup = try Firestore.Encoder().encode(group)
            try await Firestore.firestore().collection("users").document(uid).collection("groups").document(group.id).setData(encodedGroup)
        } catch {
            print("DEBUG: Failed to add group with error \(error.localizedDescription)")
            throw error
        }
    }
    
    func deleteTransaction(transactionId: String) async {
        //guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            let transactionRef = Firestore.firestore()
                .collection("users")
                .document(uid)
                .collection("transactions")
                .document(transactionId)
            
            try await transactionRef.delete()
            print("Transaction deleted successfully.")
            
            // Optionally, update local transactions list
            if let index = transactions.firstIndex(where: { $0.id == transactionId }) {
                transactions.remove(at: index)
            }
        } catch {
            print("Failed to delete transaction: \(error.localizedDescription)")
        }
    }
    
    func deleteGoal(goalId: String) async {
        //guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            let goalRef = Firestore.firestore()
                .collection("users")
                .document(uid)
                .collection("goals")
                .document(goalId)
            
            try await goalRef.delete()
            print("Goal deleted successfully.")
            
            // Optionally, update local goal list
            if let index = goals.firstIndex(where: { $0.id == goalId }) {
                goals.remove(at: index)
            }
        } catch {
            print("Failed to delete goal: \(error.localizedDescription)")
        }
    }
    
    func deleteGroup(groupId: String) async {
        //guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            let groupRef = Firestore.firestore()
                .collection("users")
                .document(uid)
                .collection("groups")
                .document(groupId)
            
            try await groupRef.delete()
            print("Group deleted successfully.")
            
            // Optionally, update local goal list
            if let index = groups.firstIndex(where: { $0.id == groupId }) {
                groups.remove(at: index)
            }
        } catch {
            print("Failed to delete group: \(error.localizedDescription)")
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut() // signs user out on backend
            self.userSession = nil // wipes out user session and takes back to login screen
            self.currentUser = nil // wipes out current user data model
        } catch {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
//    func fetchUser() async {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
//        self.currentUser = try? snapshot.data(as: User.self)
//        await fetchTransactions()
//        await fetchGoals()
//        await fetchGroups()
//        fetchTips()
//        resetProgress()
//    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("DEBUG: No current user found")
            return
        }
        
        do {
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            self.currentUser = try snapshot.data(as: User.self)
            print("DEBUG: User fetched successfully: \(self.currentUser?.fullname ?? "No Name")")
            
            await fetchTransactions()
            await fetchGoals()
            await fetchGroups()
            fetchTips()
            resetProgress()
            addFutureTransactions()
            
            //Set lastLogin
            UserDefaults.standard.set(Date(), forKey: "referenceDate")
        } catch {
            print("DEBUG: Failed to fetch user: \(error.localizedDescription)")
        }
    }
    
    func fetchTransactions() async {
        //guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).collection("transactions").getDocuments() else { return }
        self.transactions = snapshot.documents.compactMap { document in
            try? document.data(as: Transaction.self)
        }
    }
    
    func fetchGoals() async {
        //guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).collection("goals").getDocuments() else { return }
        self.goals = snapshot.documents.compactMap { goal in
            try? goal.data(as: Goal.self)
        }
    }
    
    func fetchGroups() async {
        //guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).collection("groups").getDocuments() else { return }
        self.groups = snapshot.documents.compactMap { group in
            try? group.data(as: TransGroup.self)
        }
    }
    
    var totalIncome: Double {
        let income = transactions
            .filter { $0.type == "income" }
            .reduce(0) { $0 + $1.amount }
        return income
    }
    
    var totalExpense: Double {
        let expense = transactions
            .filter { $0.type == "expense" }
            .reduce(0) { $0 + $1.amount }
        return expense
    }
    
    var netWorth: Double {
        return totalIncome-totalExpense
    }
    
    var weekIncome: Double = 0.0
    var weekExpense: Double = 0.0
    
    func calculateTotalSinceLastSunday(type: String) -> Double {
        // Get the current calendar
        let calendar = Calendar.current
        let today = Date()
        
        // Find the last Sunday
        guard let lastSunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else {
            return 0.0 // Default to 0 if we can't find the date
        }
        
        // Filter transactions to include only those after last Sunday
        let filteredTransactions = transactions.filter { $0.date >= lastSunday } .filter {$0.type == type}
        
        // Sum up the amounts of the filtered transactions
        let total = filteredTransactions.reduce(0.0) { sum, transaction in
            sum + transaction.amount
        }
        
        return total
    }
    
    func calculateTotalThisWeek(type: String) {
        let calendar = Calendar.current
        let today = Date()

        // Get the start of the current week (Sunday)
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start else { return }

        // Filter transactions for this week and calculate total amount
        let total = transactions
            .filter { transaction in
                transaction.date >= startOfWeek && transaction.date <= today && transaction.type == type
            }
            .reduce(0.0) { sum, transaction in
                sum + transaction.amount
            }

        if type == "income" {
            weekIncome = total
        } else {
            weekExpense = total
        }
    }
        
    // Fetch ChatGPT response asynchronously
    func fetchTips() {
        let apiKey = "********"
        let prompt = """
        You are a friendly chatbot in a budgeting app. Here is the user's data: Transactions: \(transactions). Categories: \(groups). Goals: \(goals). Using this data, give a SHORT & SIMPLE tip for the user to improve their spending habits. Only give the tip, no extra text to indicate that you are ChatGPT. Make sure to give it all in plain text and no formatting to prevent any errors in the app.
        """
        
        Task {
            do {
                let chatResponse = try await fetchChatGPTResponse(prompt: prompt, apiKey: apiKey)
                budgetTips = chatResponse
            } catch {
                budgetTips = "Error fetching tips: \(error.localizedDescription)"
            }
        }
    }
    
    func resetProgress() {
        //guard let uid = Auth.auth().currentUser?.uid else { return }
        for group in groups {
            //let group = groups[index]
            print("resetProgress running")
            if ((group.period == "daily" && checkNewDay) ||
                (group.period == "weekly" && checkNewWeek) ||
                (group.period == "monthly" && checkNewMonth) ||
                (group.period == "yearly" && checkNewYear)) {
                print("if statement true")
                if var grp = groups.first(where:{$0.id == group.id}) {
                    grp.current = 0.00
                    let groupRef = Firestore.firestore()
                        .collection("users")
                        .document(uid)
                        .collection("groups")
                        .document(group.id)
                    
                    groupRef.updateData(["current" : 0.00])
                    print("gorup reset \(grp.current) \(grp)")
                }
            }
        }
    }
    
    func resetPassword(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            throw error // Re-throw error to handle it in the view
        }
    }
    
    func addFutureTransactions() {
        if checkNewDay {
            //guard let uid = Auth.auth().currentUser?.uid else { return }
            let filterTrans = transactions.filter { trans in trans.date <= Date() && trans.date > lastLogin }
            for tran in filterTrans {
                if var group = groups.first(where:{$0.type == tran.type}) {
                    group.current += tran.amount
                    let groupRef = Firestore.firestore()
                        .collection("users")
                        .document(uid)
                        .collection("groups")
                        .document(group.id)
                    
                    groupRef.updateData(["current" : group.current])
                }
            }
        }
    }
    
    func reauthenticateUser(password: String) async -> Bool {
        guard let user = userSession else { return false }

        let credential = EmailAuthProvider.credential(withEmail: currentUser?.email ?? "", password: password) // Replace with actual password

        //var valid = true
        do {
            try await user.reauthenticate(with: credential)
        } catch {
            print("Re-authentication failed: \(error.localizedDescription)")
            return false
        }
        
        return true
    }
    
    func deleteUser() -> String {
        guard let user = userSession else { return "" }
        var message = "Account Deleted"
        let UID = uid
        
        user.delete { error in
            if let error = error {
                print("Error deleting user: \(error.localizedDescription)")
                message = "Error: \(error.localizedDescription)"
                //valid = false
            } else {
                print("User deleted successfully.")
            }
        }
        
        if message == "Account Deleted" {
            print("skibidi")
            Firestore.firestore().collection("users").document(UID).delete { error in
                if let error = error {
                    print("Error deleting user: \(error.localizedDescription)")
                } else {
                    print("User successfully deleted!")
                }
            }
            signOut()
        }
        
        
        return message
        
    }
    
    func updateUserInfo(newFullName: String, newEmail: String) {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        
        db.collection("users").document(user.uid).updateData(["fullname": newFullName]) { error in
            if let error = error {
                print("Error updating name: \(error.localizedDescription)")
                return
            }
        }

        user.__sendEmailVerificationBeforeUpdating(email: newEmail) { error in
            if let error = error {
                print("Error updating email: \(error.localizedDescription)")
            } else {
                print("Profile updated successfully!")
            }
        }
    }
}
