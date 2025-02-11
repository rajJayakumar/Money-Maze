//
//  LoginView.swift
//  MySwiftApp
//
//  Created by Rajaselvam Jayakumar on 10/8/24.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var notValidLogin = false
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                //image
                Image("appLogo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .padding(.vertical, 32)
                    .clipShape(Circle())
                //form fields
                VStack(spacing: 24) {
                    InputView(text: $email,
                              title: "Email Address", 
                              placeholder: "name@example.com",
                              numerical: false,
                              isSecureField: false)
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    
                    InputView(text: $password,
                              title: "Password", 
                              placeholder: "Enter you password",
                              numerical: false,
                              isSecureField: true)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                //sign in
                
                Button {
                    Task {
                        notValidLogin = try await viewModel.signIn(withEmail: email, password: password)
                    }
                } label: {
                    HStack {
                        Text("SIGN IN")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
                .background(Color(.systemBlue))
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
                .cornerRadius(10)
                .padding(.top, 24)
                .alert("Invalid email or password", isPresented: $notValidLogin) {
                    Button("OK", role: .cancel) {}
                }
                
                Spacer()
                
                //forgot password
                NavigationLink {
                    ForgotPasswordView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack(spacing: 3) {
                        Text("Forgot Password")
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 14))
                }
                
                //sign up
                NavigationLink {
                    RegistrationView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack(spacing: 3) {
                        Text("Don't have an account?")
                        Text("Sign Up")
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 14))
                }

            }
        }
    }
}

// MARK - AuthenticationFormProtocol
// password checking logic
extension LoginView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
}

#Preview {
    LoginView()
}
