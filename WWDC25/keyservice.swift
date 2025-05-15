import SwiftUICore
import Combine
import SwiftUI
struct AIChatView: View {
    @StateObject private var chatVM = ChatViewModel()
    @State private var messageText: String = ""
    @FocusState private var isInputFocused: Bool
    @State private var showHeader = true
    @Namespace private var namespace
    
    // Modern gradient colors
    let backgroundGradient = LinearGradient(
        colors: [Color(.systemGray6), Color(.systemBackground)],
        startPoint: .top, endPoint: .bottom
    )
    
    var body: some View {
        ZStack {
            backgroundGradient.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Modern header with scroll effects
                if showHeader {
                    VStack(spacing: 4) {
                        Text("Your AI Mentor")
                            .font(.system(.title3, weight: .semibold))
                            .foregroundStyle(.primary)
                        
                        HStack(spacing: 6) {
                            Circle()
                                .fill(.green.gradient)
                                .frame(width: 8, height: 8)
                            
                            Text("Online")
                                .font(.system(.caption2, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
                
                // Messages list with dynamic padding
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(chatVM.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                                    .transition(
                                        .asymmetric(
                                            insertion: .push(from: message.isFromUser ? .trailing : .leading),
                                            removal: .opacity
                                        )
                                    )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, showHeader ? 0 : 16)
                        .padding(.bottom, 20)
                        .background(GeometryReader {
                            Color.clear.preference(
                                key: ViewOffsetKey.self,
                                value: -$0.frame(in: .named("scroll")).origin.y
                            )
                        })
                    }
                    .coordinateSpace(name: "scroll")
                    .scrollIndicators(.hidden)
                    .onPreferenceChange(ViewOffsetKey.self) { offset in
                        withAnimation(.easeInOut) {
                            showHeader = offset < 50
                        }
                    }
                    .onChange(of: chatVM.messages) { _ in
                        scrollToBottom(proxy: proxy)
                    }
                }
                
                // Modern input field
                HStack(alignment: .bottom, spacing: 12) {
                    TextField("Share your thoughts...", text: $messageText, axis: .vertical)
                        .focused($isInputFocused)
                        .textFieldStyle(.plain)
                        .font(.system(.body, design: .rounded))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 18)
                        .background(
                            ZStack {
                                // Material background with tint
                               
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                .primary.opacity(0.1),
                                                .blue.opacity(isInputFocused ? 0.3 : 0.1)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: isInputFocused ? 1.2 : 0.8
                                    )
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        .shadow(color: .black.opacity(isInputFocused ? 0.1 : 0.05), radius: 6, y: 2)
                        .onSubmit { sendMessage() }
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .font(.system(size: 30, weight: .bold))
                            .contentTransition(.symbolEffect(.replace))
                    }
                    .disabled(messageText.isEmpty)
                    .buttonStyle(.plain)
                    .sensoryFeedback(.success, trigger: messageText.isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.regularMaterial)
                .ignoresSafeArea(.container, edges: .bottom)
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Emotional Guide")
                    .font(.system(.headline, weight: .semibold))
            }
        }
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7)) {
            chatVM.sendMessage(messageText)
            messageText = ""
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let lastMessage = chatVM.messages.last else { return }
        withAnimation(.easeOut(duration: 0.3)) {
            proxy.scrollTo(lastMessage.id, anchor: .bottom)
        }
    }
}

// Modern message bubble
struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
                Text(message.text)
                    .font(.system(.body, design: .rounded))
                    .padding(14)
                    .background(.blue.gradient)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: .blue.opacity(0.2), radius: 6, y: 3)
            } else {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "sparkle")
                        .symbolEffect(.bounce, value: message.isTyping)
                        .foregroundStyle(.teal.gradient)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(message.text)
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(.primary)
                        
                        if message.isTyping {
                            TypingIndicator()
                        }
                    }
                    .padding(14)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: .black.opacity(0.05), radius: 3, y: 2)
                }
                Spacer()
            }
        }
        .padding(.horizontal, 4)
    }
}

struct ViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

// Modern typing indicator
struct TypingIndicator: View {
    @State private var scale: [CGFloat] = [0.8, 0.6, 0.8]
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(.teal.gradient)
                    .frame(width: 8, height: 8)
                    .scaleEffect(scale[i])
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(i) * 0.2),
                        value: scale[i]
                    )
            }
        }
        .onAppear {
            scale = [0.6, 0.8, 0.6]
        }
    }
}

// MARK: - ViewModel
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    private var cancellables = Set<AnyCancellable>()
    
    func sendMessage(_ text: String) {
        let userMessage = ChatMessage(text: text, isFromUser: true)
        messages.append(userMessage)
        
        // Show typing indicator
        let typingIndicator = ChatMessage(text: "", isFromUser: false, isTyping: true)
        messages.append(typingIndicator)
        
        // Simulate API delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.messages.removeAll(where: { $0.isTyping })
            self.fetchAIResponse(for: text)
        }
    }
    
    private func fetchAIResponse(for text: String) {
        let prompt = """
        [Role: You're an world best emotional mentor so talk to help user . Respond compassionately in 1-2 short sentences.].NO EXTRA UNWANTED CHARACTERS STARS,HASHTAGS.
        User: \(text)
        AI:
        """
        
        // Replace with actual DeepSeek API call
        DeepSeekAPI.shared.generateResponse(prompt: prompt)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    let aiMessage = ChatMessage(text: response, isFromUser: false)
                    self.messages.append(aiMessage)
                }
            )
            .store(in: &cancellables)
    }
}

// MARK: - Data Models
struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    var isTyping: Bool = false
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id &&
        lhs.text == rhs.text &&
        lhs.isFromUser == rhs.isFromUser &&
        lhs.isTyping == rhs.isTyping
    }
}

// MARK: - API Service
class DeepSeekAPI {
    static let shared = DeepSeekAPI()
    private let apiKey = "sk-cd4c3c59d53641ceba9b70c021c7ec0d" // Store securely in production
    
    func generateResponse(prompt: String) -> Future<String, Error> {
        return Future { [self] promise in
            let url = URL(string: "https://api.deepseek.com/v1/chat/completions")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            
            let requestBody: [String: Any] = [
                "model": "deepseek-chat",
                "messages": [["role": "user", "content": prompt]],
                "temperature": 0.7,
                "max_tokens": 150
            ]
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
                
                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    guard let data = data,
                          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let choices = json["choices"] as? [[String: Any]],
                          let message = choices.first?["message"] as? [String: Any],
                          let content = message["content"] as? String else {
                        promise(.success("I couldn't process that. Please try again."))
                        return
                    }
                    
                    promise(.success(content))
                }.resume()
            } catch {
                promise(.failure(error))
            }
        }
    }
}

// MARK: - Typing Indicator


// MARK: - Preview
struct AIChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AIChatView()
        }
    }
}
