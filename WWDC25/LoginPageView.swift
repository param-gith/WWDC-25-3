import SwiftUI

struct LoginPageView: View {
    @State private var userName: String = ""
    @State private var showNextScreen = false
    @State private var showLoginPage = false


    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // App Icon
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 80))
                .foregroundStyle(.linearGradient(
                    colors: [.blue, .blue.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)

            // Welcome Text
            VStack(spacing: 8) {
                Text("Welcome !")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)

                Text("Inspired by the Gita, guided by your mood")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            // Name Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Enter your name")
                    .font(.headline)
                    .foregroundColor(.primary)

                TextField("Your Name", text: $userName)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            }
            .padding(.horizontal, 40)

            // Get Started Button
            Button(action: {
                hideKeyboard()
                showNextScreen = true
            }) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 20)
                    .padding()
                    .background(userName.isEmpty ? Color.gray.opacity(0.5) : Color.blue)
                    .cornerRadius(20)
                    .padding(.horizontal, 30)
                    .shadow(color: userName.isEmpty ? .clear : .blue.opacity(0.3), radius: 8, x: 0, y: 5)
            }
            .disabled(userName.isEmpty)

            Spacer()
        }
        .padding()
        .background(Color(hex: "#F5EAE8"))
        .ignoresSafeArea()
        .fullScreenCover(isPresented: $showNextScreen) {
            ContentView() // Replace with your main screen
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}

// MARK: - Hex Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
        default:
            r = 1.0; g = 1.0; b = 1.0
        }
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Hide Keyboard Helper
#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

#Preview {
    LoginPageView()
}
