import SwiftUI

struct GroupRowView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    let group: TransGroup
    @State private var showAddGroupView = false

    // Computed property to calculate the progress based on current and budget
    var progress: Double {
        return min(group.current, group.budget)
    }
    
//    func resetProgress() {
//        if (group.period == "daily" && checkNewDay()) ||
//            (group.period == "weekly" && checkNewWeek()) ||
//            (group.period == "monthly" && checkNewMonth()) ||
//            (group.period == "yearly" && checkNewYear()) {
//            if var grp = viewModel.groups.first(where:{$0.id == group.id}) {
//                grp.current = 0
//            }
//        }
//    }

//    // Helper function to determine if the period has reset
//    func resetProgress() -> Double {
//        let period = group.period // Assuming `group.period` is a string
//        let now = Date()
//        var startOfCurrentPeriod: Date?
//
//        // Determine the start of the current period based on the string value of the period
//        switch period.lowercased() {
//        case "daily":
//            startOfCurrentPeriod = Calendar.current.startOfDay(for: now)
//        case "weekly":
//            startOfCurrentPeriod = Calendar.current.dateInterval(of: .weekOfYear, for: now)?.start
//        case "monthly":
//            startOfCurrentPeriod = Calendar.current.dateInterval(of: .month, for: now)?.start
//        case "yearly":
//            startOfCurrentPeriod = Calendar.current.dateInterval(of: .year, for: now)?.start
//        default:
//            return group.current // Return current if period is invalid
//        }
//
//        let lastResetDateKey = "\(group.id)_lastReset"
//        let lastResetDate = UserDefaults.standard.object(forKey: lastResetDateKey) as? Date
//
//        // If the last reset is not within the current period, reset the progress
//        if lastResetDate == nil || (startOfCurrentPeriod != nil && lastResetDate! < startOfCurrentPeriod!) {
//            UserDefaults.standard.set(now, forKey: lastResetDateKey)
//            return 0.0
//        }
//
//        return group.current
//    }


    var body: some View {
        VStack() {
            HStack {
                // Group Name
                Text(group.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                // Total Budget
                Text("$\(String(format: "%.2f", group.budget))")
                    .font(.headline)
                //.foregroundColor(.gray)
            }
            HStack{
                // Progress Bar
                ProgressBarView(value: group.current, targetValue: group.budget)
                    .frame(height: 20)
                
                // Total Budget
                Text("$\(String(format: "%.2f", group.current))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            NavigationLink(destination: AddGroupView(group: group, isPresented: $showAddGroupView)) {}
        }
        .padding(.vertical, 8)
    }
    
}

// Extension to map `DateComponents` to a calendar unit
extension DateComponents {
    var calendarUnit: Calendar.Component? {
        if day == 1 { return .day }
        if weekOfYear == 1 { return .weekOfYear }
        if month == 1 { return .month }
        if year == 1 { return .year }
        return nil
    }
}

#Preview {
    GroupRowView(
        group: TransGroup(
            id: "1",
            name: "Food",
            type: "expense",
            current: 80.0,
            budget: 100.0,
            period: "daily" // Daily period defualt
        )
    )
    .frame(width: 350)
}

func checkNewDay() -> Bool {
    if let referenceDate = UserDefaults.standard.object(forKey: "reference") as? Date {
        // reference date has been set, now check if date is not today
        if !Calendar.current.isDateInToday(referenceDate) {
            // if date is not today, do things
            // update the reference date to today
            UserDefaults.standard.set(Date(), forKey: "reference")
            return true
        }
    } else {
        // reference date has never been set, so set a reference date into UserDefaults
        UserDefaults.standard.set(Date(), forKey: "reference")
        return true
    }
    return false
}

var checkNewWeek: Bool {
    if let referenceDate = UserDefaults.standard.object(forKey: "referenceWeek") as? Date {
        print(referenceDate)
        print(Date())
        //print(Date()-604800)
        // Check if the stored date is in the same week as today
        if Calendar.current.component(.weekOfYear, from: Date()) != Calendar.current.component(.weekOfYear, from: referenceDate) {
            // If it's not the same week, update the reference date and return true
//            UserDefaults.standard.set(Date(), forKey: "referenceWeek")
//            print("just updating refernece date")
            return true
        }
    } //else {
//        // Reference date has never been set, so set it now
//        UserDefaults.standard.set(Date(), forKey: "referenceWeek")
//        print("setting new refernce date")
//        return true
//    }
    print("somehow only returned fasle")
    return false
}

func resetProgress() {
    
}

func checkNewMonth() -> Bool {
    if let referenceDate = UserDefaults.standard.object(forKey: "referenceMonth") as? Date {
        // Check if the stored date is in the same month as today
        if !Calendar.current.isDate(Date(), equalTo: referenceDate, toGranularity: .month) {
            // If it's not the same month, update the reference date and return true
            UserDefaults.standard.set(Date(), forKey: "referenceMonth")
            return true
        }
    } else {
        // Reference date has never been set, so set it now
        UserDefaults.standard.set(Date(), forKey: "referenceMonth")
        return true
    }
    return false
}

func checkNewYear() -> Bool {
    if let referenceDate = UserDefaults.standard.object(forKey: "referenceYear") as? Date {
        // Check if the stored date is in the same year as today
        if !Calendar.current.isDate(Date(), equalTo: referenceDate, toGranularity: .year) {
            // If it's not the same year, update the reference date and return true
            UserDefaults.standard.set(Date(), forKey: "referenceYear")
            return true
        }
    } else {
        // Reference date has never been set, so set it now
        UserDefaults.standard.set(Date(), forKey: "referenceYear")
        return true
    }
    return false
}
