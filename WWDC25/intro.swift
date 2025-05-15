import SwiftUI

struct AppIntroView: View {
    @AppStorage("hasSeenIntro") var hasSeenIntro: Bool = false
    @State private var showLoginPage = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Header with colorful icon
                    VStack(spacing: 10) {
                        Text("Welcome to \n Bhaava Gita")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding(.top, 40)
                    }

                    
                    
                    
                    
                    // Feature items with colorful icons
                    VStack(alignment: .leading, spacing: 30) {
                        featureItem(
                            icon: "face.smiling.fill",
                            iconColor: .green,
                            title: "Select Your Mood",
                            description: "Select your mood and uncover a message that make you feel better."
                        )
                        
                        featureItem(
                            icon: "quote.bubble.fill",
                            iconColor: .orange,
                            title: "Get Personalized Shlokas",
                            description: "Each mood is matched with a specific shloka from the Bhagavad Gita."
                        )
                        
                        featureItem(
                            icon: "person.2.fill",
                            iconColor: .yellow,
                            title: "Share Your Journey",
                            description: "Connect with friends and family by sharing your mood updates securely."
                        )
                        featureItem(
                                icon: "book.fill",
                                iconColor: .purple,
                                title: "Daily Reflection",
                                description: "Write about your day's ups and downs,Record how you felt today and save your emotional journey"
                            )
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Continue button (matches Reminders style)
                    VStack(spacing: 0) {
                        
                        
                        Button(action: {
                            hasSeenIntro = true
                            showLoginPage = true
                        }) {
                            Text("Continue")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(20)
                                .padding(.horizontal)
                        }
                        
                        .padding(.horizontal, 25)
                        .padding(.top, 20)
                        .padding(.bottom, 70)
                    }
                    
                    // NavigationLink to LoginPage
                    NavigationLink(destination: LoginPageView(), isActive: $showLoginPage) {
                        EmptyView()
                    }
                }
                .padding(.bottom, 20)
            }
            .background(Color(hex: "#F5EAE8"))
        }
    }
    
    func featureItem(icon: String, iconColor: Color, title: String, description: String) -> some View {
        HStack(alignment: .center, spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
