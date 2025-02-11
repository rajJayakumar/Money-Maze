//
//  RegistrationView.swift
//  MySwiftApp
//
//  Created by Rajaselvam Jayakumar on 10/13/24.
//

import SwiftUI

struct RegistrationView: View {
    @State private var email = ""
    @State private var fullname = ""
    @State private var password = ""
    @State private var confirmpassword = ""
    @State private var isChecked = false
    @State private var emailNotValid = false
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack {
            //Image
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
                
                InputView(text: $fullname,
                          title: "Full Name",
                          placeholder: "Enter you name",
                          numerical: false,
                          isSecureField: false)
                
                InputView(text: $password,
                          title: "Password",
                          placeholder: "Enter you password",
                          numerical: false,
                          isSecureField: true)
                
                ZStack(alignment: .trailing) {
                    InputView(text: $confirmpassword,
                              title: "Confirm Password",
                              placeholder: "Confirm you password",
                              numerical: false,
                              isSecureField: true)
                    
                    if !password.isEmpty && !confirmpassword.isEmpty {
                        if password == confirmpassword {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundStyle(Color(.systemGreen))
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundStyle(Color(.systemRed))
                        }
                    }
                }
                
                HStack {
                    Toggle("", isOn: $isChecked)
                        .labelsHidden()
                        .scaleEffect(0.7)
                    
                    Text("I agree with the ")
                        .foregroundColor(Color(.darkGray))
                        .fontWeight(.semibold)
                        .font(.footnote)

                    Link("Privacy Policy", destination: URL(string: "https://app.websitepolicies.com/policies/view/3a21uuv2")!)
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                        .font(.footnote)
                }
                
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            Button {
                Task {
                    emailNotValid = try await viewModel.createUser(
                        withEmail: email,
                        password: password,
                        fullname: fullname
                    )
                }
            } label: {
                HStack {
                    Text("SIGN UP")
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
            .alert("Email already in use with existing account", isPresented: $emailNotValid) {
                Button("OK", role: .cancel) {}
            }
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                HStack(spacing: 3) {
                    Text("Already have an account?")
                    Text("Sign In")
                        .fontWeight(.bold)
                }
                .font(.system(size: 14))
            }

        }
    }
}

// MARK - AuthenticationFormProtocol
// password checking logic
extension RegistrationView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
        && confirmpassword == password
        && !fullname.isEmpty
        && isChecked
    }
}

#Preview {
    RegistrationView()
}
