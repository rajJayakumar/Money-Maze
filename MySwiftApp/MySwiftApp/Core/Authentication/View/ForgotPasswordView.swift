//
//  ForgotPasswordView.swift
//  MySwiftApp
//
//  Created by Rajaselvam Jayakumar on 12/24/24.
//

import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var email = ""
    @State private var message = "" // To store feedback messages
    @State private var isError = false // To track whether it's an error message
    
    var body: some View {
        NavigationStack {
            VStack {
                // Image
                Image("appLogo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .padding(.vertical, 32)
                
                // Form fields
                Text("Password Recovery")
                    .font(.title)
                
//                InputView(text: $email, title: "Email Address", placeholder: "name@example.com", numerical: false, isSecureField: false)
                
                Button {
                    Task {
                        do {
                            try await viewModel.resetPassword(email: email)
                            message = "Password recovery email sent successfully."
                            isError = false
                        } catch {
                            message = "Error: \(error.localizedDescription)"
                            isError = true
                        }
                    }
                } label: {
                    HStack {
                        Text("Send Recovery Email")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
                .background(Color(.systemBlue))
                .cornerRadius(10)
                .padding(.top, 24)
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
                
                // Feedback message
                if !message.isEmpty {
                    Text(message)
                        .foregroundColor(isError ? .red : .green)
                        .font(.footnote)
                        .padding(.top, 8)
                }
            }
            .padding()
        }
    }
}

extension ForgotPasswordView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
    }
}

#Preview {
    ForgotPasswordView()
}
