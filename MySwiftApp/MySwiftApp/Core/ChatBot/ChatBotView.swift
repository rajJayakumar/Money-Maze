import SwiftUI

struct ChatBotView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var messages: [ChatMessage] = []
    @State private var userInput: String = ""
    @State private var isSending: Bool = false
    let colors = Colors()

    var body: some View {
        VStack(spacing: 15) {
            Text("AI Budget Assistant")
                //.frame(width: 200, height: 100)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Text("Ask anything: financial advice, budget planning, etc.")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(.systemGray))
                //.padding
            // Chat History
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(messages) { message in
                            HStack {
                                if message.isBot {
                                    Text(message.content)
                                        .padding()
                                        .background(Color(.white))
                                        .cornerRadius(12)
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: 250, alignment: .leading)
                                        .padding(.leading, 10)
                                        .padding(.trailing, 50)
                                } else {
                                    Spacer()
                                    Text(message.content)
                                        .padding()
                                        .background(colors.darkGreen)
                                        .cornerRadius(12)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: 250, alignment: .trailing)
                                        .padding(.trailing, 10)
                                        .padding(.leading, 50)
                                }
                            }
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) {
                    withAnimation {
                        proxy.scrollTo(messages.last?.id, anchor: .bottom)
                    }
                }
            }

            // Input Section
            HStack {
                TextField("Type a message...", text: $userInput)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .disabled(isSending)

                if isSending {
                    ProgressView()
                        .padding(.leading, 5)
                } else {
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(colors.darkGreen)
                            .padding()
                    }
                }
            }
            .padding()
        }
        //.navigationTitle("Chat with BudgetBot")
        //.navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    // Function to send user message and fetch bot response
    private func sendMessage() {
        guard !userInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        // Add the user's message to the chat
        let userMessage = ChatMessage(id: UUID(), content: userInput, isBot: false)
        messages.append(userMessage)
        userInput = ""

        // Mark as sending
        isSending = true

        // Prepare the prompt
        let prompt = """
        You are a friendly budgeting chatbot. The user has sent the following message: "\(userMessage.content)".
        Based on the user's transactions, categories, and goals: \(viewModel.transactions), \(viewModel.groups), and \(viewModel.goals), provide personalized budgeting advice. Try to stay short and concise, limiting
        responses to be around 60 words at the max.
        """

        // Call ChatGPT API
        Task {
            do {
                let apiKey = "********"
                let botResponse = try await fetchChatGPTResponse(prompt: prompt, apiKey: apiKey)

                // Add the bot's response to the chat
                let botMessage = ChatMessage(id: UUID(), content: botResponse, isBot: true)
                await MainActor.run {
                    messages.append(botMessage)
                    isSending = false
                }
            } catch {
                // Handle errors gracefully
                let errorMessage = ChatMessage(id: UUID(), content: "Something went wrong: \(error.localizedDescription)", isBot: true)
                await MainActor.run {
                    messages.append(errorMessage)
                    isSending = false
                }
            }
        }
    }
}

// Chat Message Model
struct ChatMessage: Identifiable {
    let id: UUID
    let content: String
    let isBot: Bool
}

#Preview {
    ChatBotView()
}
