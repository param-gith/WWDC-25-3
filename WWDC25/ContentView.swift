import SwiftUI
import AVFoundation
import Charts
import ContactsUI
import MessageUI

struct Mood: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let memoji: String
    let Shloka: String
    let quote: String
    let backgroundGradient: LinearGradient
    
    static func == (lhs: Mood, rhs: Mood) -> Bool {
        return lhs.id == rhs.id
    }
}
// home screen content
struct ContentView: View {
    var body: some View {
        TabView {
            NavigationView {
                ZStack {
                    Color(hex: "#F5EAE8")
                        .ignoresSafeArea()

                    MoodSelectionView()
                        .navigationTitle("How are you feeling today?")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            
            NavigationStack {
                        ZStack {
                            Color(hex: "#F5EAE8")
                                .ignoresSafeArea()
                            
                            AIChatView() // Your AI chatbot view
                        }
                        .navigationTitle("AI Mentor")
                        .navigationBarTitleDisplayMode(.inline)
                    }
                    .tabItem {
                        Label("Chat", systemImage: "message.fill")
                    }

            NavigationView {
                ZStack {
                    Color(hex: "#F5EAE8")
                        .ignoresSafeArea()

                    WriteFeelingView(reflectionManager: ReflectionManager())
                        
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            .tabItem {
                Label("Write", systemImage: "square.and.pencil")
            }

            NavigationView {
                ZStack {
                    Color(hex: "#F5EAE8")
                        .ignoresSafeArea()

                    SharingView()
                        .navigationTitle("Sharing")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            .tabItem {
                Label("Sharing", systemImage: "person.2.fill")
            }
        }
    }
}


// second functionality of app writing feelings
import SwiftUI

struct MoodEntry: Identifiable, Equatable {
    let id = UUID()
    let mood: String
    let text: String
    let date: Date
}

struct WriteFeelingView: View {
    @ObservedObject var reflectionManager: ReflectionManager
    @State private var feelingText: String = ""
    @State private var selectedMood: String? = nil
    @State private var showMoodSheet = false
    @State private var showConfirmation = false
    @State private var isFirstAppearance: Bool = true
    @State private var weeklySummary: MoodSummary?
    @State private var showWeeklySummary = false
    @State private var isLoadingSummary = false

    let moods: [(emoji: String, name: String)] = [
        ("😊", "Happy"), ("😢", "Sad"), ("😡", "Angry"), ("😌", "Peaceful"),
        ("😟", "Anxious"), ("😴", "Tired"), ("😞", "Lonely"), ("🤩", "Excited"),
        ("🤯", "Overwhelmed"), ("🛡️", "Protective"), ("🥳", "Overjoyed")
    ]

    private func backgroundColor(for mood: String) -> Color {
        switch mood.lowercased() {
        case "happy": return Color.yellow.opacity(0.2)
        case "sad": return Color.blue.opacity(0.2)
        case "angry": return Color.red.opacity(0.2)
        case "peaceful": return Color.green.opacity(0.2)
        case "anxious": return Color.orange.opacity(0.2)
        case "tired": return Color.gray.opacity(0.2)
        case "lonely": return Color.purple.opacity(0.2)
        case "excited": return Color.pink.opacity(0.2)
        case "overwhelmed": return Color.indigo.opacity(0.2)
        case "protective": return Color.teal.opacity(0.2)
        case "overjoyed": return Color.mint.opacity(0.2)
        default: return Color.secondary.opacity(0.2)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func emoji(for mood: String) -> String {
        return moods.first { $0.name.lowercased() == mood.lowercased() }?.emoji ?? "🙂"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                
                if isLoadingSummary {
                        Color.black.opacity(0.25)
                            .ignoresSafeArea()
                        
                        ProgressView("Analyzing your week...")
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(16)
                            .shadow(radius: 10)
                    }
                
                
                Color(hex: "#F5EAE8").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Text Editor Section
                        VStack(spacing: 20) {
                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $feelingText)
                                    .scrollContentBackground(.hidden)
                                    .background(Color(.systemGray6))
                                    .frame(minHeight: 120)
                                    .cornerRadius(20)
                                
                                if feelingText.isEmpty {
                                    Text("Write your thoughts here...")
                                        .foregroundColor(.secondary)
                                        .padding(.top, 8)
                                        .padding(.leading, 5)
                                        .allowsHitTesting(false)
                                }
                            }
                            
                            if !feelingText.isEmpty && selectedMood != nil {
                                Button(action: saveEntry) {
                                    Text("Save Reflection")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.large)
                                .cornerRadius(15)
                            }
                            
                        }
                        .padding(.horizontal, 20)
                        
                        // Reflections List
                        if !reflectionManager.reflections.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Your Reflections")
                                    .font(.title2.bold())
                                    .padding(.horizontal, 20)
                                    .padding(.top)
                                
                                ForEach(reflectionManager.reflections) { reflection in
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Spacer()
                                            Text(reflection.text)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        HStack {
                                            Spacer()
                                            Text(formattedDate(reflection.date))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(backgroundColor(for: reflection.mood))
                                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                    )
                                    .overlay(
                                        Text(emoji(for: reflection.mood))
                                            .font(.system(size: 30))
                                            .frame(width: 50, height: 50)
                                            .background(backgroundColor(for: reflection.mood).opacity(1.0))
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                                            .offset(x: -10, y: -10),
                                        alignment: .topLeading
                                    )
                                    .padding(.horizontal, 20)
                                    .padding(.top, 20)
                                }
                            }
                            .animation(.easeInOut, value: reflectionManager.reflections)
                        }
                    }
                    .padding(.vertical, 16)
                }
            }
            .toolbar {
                // Week in Review icon button
                ToolbarItem(placement: .navigationBarLeading) {
                    if !reflectionManager.reflections.isEmpty {
                        Button(action: {
                            isLoadingSummary = true
                            
                            // Simulate delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                weeklySummary = WeeklyMoodAnalyzer.analyzeWeek(reflections: reflectionManager.reflections)
                                isLoadingSummary = false
                                showWeeklySummary = true
                            }
                        }) {
                            Image(systemName: "chart.bar")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(.blue)
                        }
                        .disabled(isLoadingSummary)
                    }
                }


                
                // Plus button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showMoodSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Reflect")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showMoodSheet) {
                MoodPickerView(moods: moods, selectedMood: $selectedMood)
                    .onDisappear {
                        if selectedMood != nil {
                            feelingText = ""
                        }
                    }
            }
            .sheet(isPresented: $showWeeklySummary) {
                if let summary = weeklySummary {
                    WeeklySummaryView(summary: summary)
                }
            }
            .alert("Reflection Saved", isPresented: $showConfirmation) {
                Button("OK", role: .cancel) { }
            }
            .onAppear {
                if isFirstAppearance {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showMoodSheet = true
                        isFirstAppearance = true
                    }
                }
            }
        }
    }

    private func saveEntry() {
        guard let mood = selectedMood, !feelingText.isEmpty else { return }
        let emoji = emoji(for: mood)
        reflectionManager.addReflection(mood: mood, emoji: emoji, text: feelingText)
        feelingText = ""
        selectedMood = nil
        showConfirmation = true
    }
}

struct WriteFeelingView_Previews: PreviewProvider {
    static var previews: some View {
        WriteFeelingView(reflectionManager: ReflectionManager())
    }
}


    private func color(for mood: String) -> Color {
        switch mood.lowercased() {
        case "happy": return .yellow
        case "sad": return .blue
        case "angry": return .red
        case "peaceful": return .green
        case "anxious": return .orange
        case "tired": return .gray
        case "lonely": return .purple
        case "excited": return .pink
        case "overwhelmed": return .indigo
        case "protective": return .mint
        case "overjoyed": return .teal
        default: return .secondary
        }
    }
// Ensure that MoodReflection conforms to Codable, which includes both Encodable and Decodable
struct MoodReflection: Identifiable, Codable {
    let id = UUID()  // Unique identifier
    let mood: String  // Mood name
    let emoji: String  // Emoji representing the mood
    let text: String  // User's feeling text
    let date: Date
    
}
// Mood Picker View remains the same as in your original code
struct MoodPickerView: View {
    let moods: [(emoji: String, name: String)]
    @Binding var selectedMood: String?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                
                
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                    ForEach(moods, id: \.name) { mood in
                        Button {
                            selectedMood = mood.name
                            dismiss()
                        } label: {
                            VStack(spacing: 8) {
                                Text(mood.emoji)
                                    .font(.system(size: 32))
                                Text(mood.name)
                                    .font(.subheadline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(
                                selectedMood == "\(mood.emoji) \(mood.name)"
                                ? Color.accentColor.opacity(0.2)
                                : Color(.systemGray5)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .background(Color(hex: "#F5EAE8"))
            .navigationTitle("Select Mood")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            
            
        }
        .presentationDetents([.medium])
        .presentationCornerRadius(24)
    }
    
    
}



// MARK: - Mood Selection View
struct MoodSelectionView: View {
    let moods: [Mood] = [
        Mood(name: "Happy", memoji: "😀", Shloka: "योगस्थः कुरु कर्माणि सङ्गं त्यक्त्वा धनञ्जय", quote: "Perform your duty equipoised, O Arjuna, abandoning all attachment to success or failure", backgroundGradient: LinearGradient(colors: [Color.yellow.opacity(0.6), Color.orange.opacity(0.4)], startPoint: .top, endPoint: .bottom)),
        
        Mood(name: "Sad", memoji: "😢", Shloka: "न त्वं शोचितुमर्हसि।", quote: "You should not grieve for what is impermanent.", backgroundGradient: LinearGradient(colors: [Color.blue.opacity(0.5), Color.cyan.opacity(0.3)], startPoint: .top, endPoint: .bottom)),
        
        Mood(name: "Peace", memoji: "🧘", Shloka: "शान्तिं निर्वाणपरमां मत्संस्थामधिगच्छति।", quote: "One who attains peace reaches the supreme abode of the Divine.", backgroundGradient: LinearGradient(colors: [Color.green.opacity(0.5), Color.mint.opacity(0.3)], startPoint: .top, endPoint: .bottom)),
        
        Mood(name: "Worried", memoji: "😰", Shloka: "सर्वधर्मान्परित्यज्य मामेकं शरणं व्रज।", quote: "Abandon all varieties of duties and surrender unto Me alone.", backgroundGradient: LinearGradient(colors: [Color.gray.opacity(0.5), Color.white.opacity(0.3)], startPoint: .top, endPoint: .bottom)),
        
        Mood(name: "Anxiety", memoji: "😟", Shloka: "मात्रास्पर्शास्तु कौन्तेय शीतोष्णसुखदुःखदाः।", quote: "O son of Kunti, the non-permanent appearance of happiness and distress is like seasons, they come and go.", backgroundGradient: LinearGradient(colors: [Color.purple.opacity(0.5), Color.pink.opacity(0.3)], startPoint: .top, endPoint: .bottom)),
        
        Mood(name: "Anger", memoji: "😠", Shloka: "क्रोधाद्भवति सम्मोहः सम्मोहात्स्मृतिविभ्रमः।", quote: "From anger comes delusion, and from delusion, bewilderment of memory. (BG 2.63)", backgroundGradient: LinearGradient(colors: [Color.red.opacity(0.5), Color.orange.opacity(0.3)], startPoint: .top, endPoint: .bottom)),
        
        Mood(name: "Laziness", memoji: "😴", Shloka: "उद्धरेदात्मनाऽऽत्मानं नात्मानमवसादयेत्।", quote: "Rise and act! Laziness is the enemy of success.", backgroundGradient: LinearGradient(colors: [Color.orange.opacity(0.5), Color.yellow.opacity(0.3)], startPoint: .top, endPoint: .bottom)),
        
        Mood(name: "Loneliness", memoji: "😔", Shloka: "यो मां पश्यति सर्वत्र सर्वं च मयि पश्यति।", quote: "One who sees Me everywhere and sees everything in Me, is never separated from Me", backgroundGradient: LinearGradient(colors: [Color.gray.opacity(0.5), Color.blue.opacity(0.3)], startPoint: .top, endPoint: .bottom)),

        // ➕ New Mood: Excited
        Mood(name: "Excited", memoji: "🤩", Shloka: "न हि कश्चित्क्षणमपि जातु तिष्ठत्यकर्मकृत्।", quote: "Indeed, no one can remain inactive even for a moment.", backgroundGradient: LinearGradient(colors: [Color.pink.opacity(0.5), Color.yellow.opacity(0.4)], startPoint: .top, endPoint: .bottom)),

        // ➕ New Mood: Overwhelmed
        Mood(name: "Overwhelmed", memoji: "🤯", Shloka: "व्यासप्रसादाच्छ्रुतवानेतद्गुह्यमहं परम्।", quote: "By the grace of Vyasa, I heard this supreme secret from Krishna Himself.", backgroundGradient: LinearGradient(colors: [Color.indigo.opacity(0.5), Color.red.opacity(0.4)], startPoint: .top, endPoint: .bottom)),
        // ➕ New Mood: Protective
        Mood(name: "Protective", memoji: "🛡️", Shloka: "कौन्तेय प्रतिजानीहि न मे भक्तः प्रणश्यति।", quote: "O Arjuna, declare it boldly: My devotee never perishes.", backgroundGradient: LinearGradient(colors: [Color.teal.opacity(0.5), Color.blue.opacity(0.4)], startPoint: .top, endPoint: .bottom)),

        // ➕ New Mood: Overjoyed
        Mood(name: "Overjoyed", memoji: "😇", Shloka: "दिवि सूर्यसहस्रस्य भवेद्युगपदुत्थिता।", quote: "If a thousand suns were to rise at once in the sky, that would be like the splendor of the Supreme.", backgroundGradient: LinearGradient(colors: [Color.orange.opacity(0.6), Color.yellow.opacity(0.4)], startPoint: .top, endPoint: .bottom))
        
    ]

    
    @State private var selectedMood: Mood? = nil
    @State private var headerOffset: CGFloat = 0
    @AppStorage("userName") private var userName: String = ""
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Hi, \(userName.isEmpty ? "User" : userName)!")
                            .font(.title3)
                            .fontWeight(.medium)
                            .padding(.leading, 20)
                        Spacer()
                    }

                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 5), GridItem(.flexible(), spacing: 5)], spacing: 15) {
                        ForEach(moods) { mood in
                            NavigationLink(destination: QuoteView(mood: mood)) {
                                VStack(spacing: 10) {
                                    Text(mood.memoji)
                                        .font(.system(size: selectedMood == mood ? 100 : 85))
                                        .padding(15)
                                        .background(
                                            RoundedRectangle(cornerRadius: 25)
                                                .fill(Color.white.opacity(0.3))
                                                .blur(radius: 10)
                                        )
                                        .scaleEffect(selectedMood == mood ? 1.1 : 1.0)
                                        .animation(.spring(), value: selectedMood)

                                    Text(mood.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                }
                                .frame(width: 160, height: 190)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(mood.backgroundGradient)
                                        .background(.ultraThinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 25))
                                )
                                .shadow(radius: 5)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .onTapGesture {
                                withAnimation {
                                    selectedMood = mood
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity)
                .offset(y: headerOffset > 0 ? -headerOffset : 0)
            }
        }
        .navigationTitle("How are you feeling today?")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Quote View
struct QuoteView: View {
    let mood: Mood

    let moodShlokas: [String: [Shloka]] = [
        "Happy": [
            Shloka(number: "2.66", sanskrit: "नास्ति बुद्धिरयुक्तस्य न चायुक्तस्य भावना।\nन चाभावयतः शान्तिरशान्तस्य कुतः सुखम्॥", Thought: "A restless person has no knowledge, no meditation, and no inner peace. Without peace, how can there be happiness?", Meaning: "When your mind is constantly running—jumping from one thought to another, worrying about the future, or regretting the past—you never feel truly at ease. Even if you achieve success, wealth, or pleasure, there will always be something missing because your mind is unsettled. True happiness comes not from external things but from a calm and peaceful mind. When you slow down, focus on the present, and let go of unnecessary worries, you naturally feel happier. A peaceful person finds joy in small things, is less affected by ups and downs, and experiences true contentment."),
            Shloka(number: "14.24-25", sanskrit: "समदुःखसुखः स्वस्थः समलोष्टाश्मकाञ्चनः।\nतुल्यप्रियाप्रियो धीरस्तुल्यनिन्दात्मसंस्तुतिः॥", Thought: "A wise person stays the same in happiness and sadness. They see gold, a stone, and dirt as equal.", Meaning: "Imagine if your happiness depended only on good times—what happens when things don’t go your way? If we chase pleasure and avoid pain, we become like a leaf in the wind, constantly tossed around by circumstances. But when we learn to stay centered, we find a deeper, unshakable happiness. The comparison to gold, stone, and dirt reminds us not to give too much importance to material things. Whether it's wealth, possessions, or status, they are all temporary. When we stop attaching our happiness to them, we become truly free."),
            Shloka(number: "18.38", sanskrit: "यत्तदग्रे विषमिव परिणामेऽमृतोपमम्।\nतत्सुखं सात्त्विकं प्रोक्तमात्मबुद्धिप्रसादजम्॥", Thought: "The pleasure from material things feels good at first but turns into pain later.", Meaning: "This means that real joy doesn’t come from external pleasures but from inner peace and contentment. When we rely on temporary things for happiness, we also invite future disappointment because everything in life changes."),
            Shloka(number: "2.50", sanskrit: "बुद्धियुक्तो जहातीह उभे सुकृतदुष्कृते।\nतस्माद्योगाय युज्यस्व योगः कर्मसु कौशलम्॥", Thought: "One who is wise abandons both good and bad deeds, finding skill in action.", Meaning: "Happiness comes from acting with wisdom and detachment, focusing on the process rather than the results."),
            Shloka(number: "5.23", sanskrit: "शक्नोतीहैव यः सोढुं प्राक्शरीरविमोक्षणात्।\nकामक्रोधोद्भवं वेगं स युक्तः स सुखी नरः॥", Thought: "He who can withstand the urges of desire and anger is a happy man.", Meaning: "Controlling impulses leads to a steady, joyful state, free from the turbulence of fleeting emotions."),
            Shloka(number: "6.32", sanskrit: "आत्मौपम्येन सर्वत्र समं पश्यति योऽर्जुन।\nसुखं वा यदि वा दुःखं स योगी परमो मतः॥", Thought: "One who sees happiness and distress equally in all is the highest yogi.", Meaning: "True happiness arises from equanimity, seeing all experiences as part of life’s flow."),
            Shloka(number: "9.27", sanskrit: "यत्करोषि यदश्नासि यज्जुहोषि ददासि यत्।\nयत्तपस्यसि कौन्तेय तत्कुरुष्व मदर्पणम्॥", Thought: "Offer all actions to Me, and find joy in devotion.", Meaning: "Dedication of daily tasks to a higher purpose brings lasting happiness and fulfillment."),
            Shloka(number: "10.9", sanskrit: "मच्चित्ता मद्गतप्राणा बोधयन्तः परस्परम्।\nकथयन्तश्च मां नित्यं तुष्यन्ति च रमन्ति च॥", Thought: "Those who focus on Me are ever content and delighted.", Meaning: "A mind centered on the divine finds constant joy and satisfaction."),
            Shloka(number: "12.13-14", sanskrit: "अद्वेष्टा सर्वभूतानां मैत्रः करुण एव च।\nनिर्ममो निरहङ्कारः समदुःखसुखः क्षमी॥", Thought: "One free from hatred and ego, equal in joy and sorrow, is truly happy.", Meaning: "Happiness stems from a heart free of malice and a mind balanced in all circumstances."),
            Shloka(number: "18.54", sanskrit: "ब्रह्मभूतः प्रसन्नात्मा न शोचति न काङ्क्षति।\nसमः सर्वेषु भूतेषु मद्भक्तिं लभते पराम्॥", Thought: "One who realizes the divine within is joyful and free from desire or grief.", Meaning: "Inner realization brings a happiness untouched by external ups and downs.")
        ],
        "Sad": [
            Shloka(number: "2.47", sanskrit: "कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।\nमा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि॥", Thought: "You have the right to perform your duty, but never to the fruits of your actions.", Meaning: "Often, sadness comes when things don’t go as expected—maybe you worked hard but didn’t get the result you wanted, or life feels unfair. This verse teaches that your focus should be on doing your duty (karma) with sincerity, without worrying about the outcome."),
            Shloka(number: "6.6", sanskrit: "उद्धरेदात्मनात्मानं नात्मानमवसादयेत्।\nआत्मैव ह्यात्मनो बन्धुरात्मैव रिपुरात्मनः॥", Thought: "A person must uplift themselves and not degrade themselves. The mind is both a friend and an enemy.", Meaning: "It teaches that you are your own greatest supporter or worst enemy, depending on how you train your mind. When you believe in yourself, stay disciplined, and think positively, your mind becomes your best friend—it pushes you forward. But if you give in to negativity, self-doubt, or laziness, your mind becomes your worst enemy—it holds you back. When feeling down, remind yourself that your progress is in your own hands."),
            Shloka(number: "3.30", sanskrit: "मयि सर्वाणि कर्माणि संन्यस्याध्यात्मचेतसा।\nनिराशीर्निर्ममो भूत्वा युध्यस्व विगतज्वरः॥", Thought: "Surrender all actions to Me, free from desire and possessiveness, and fight without anxiety.", Meaning: "Teaches a profound lesson on trust, surrender, and inner peace, especially when life feels overwhelming. By letting go of attachment to results, sadness can be replaced with calm acceptance."),
            Shloka(number: "2.14", sanskrit: "मात्रास्पर्शास्तु कौन्तेय शीतोष्णसुखदुःखदाः।\nआगमापायिनोऽनित्यास्तांस्तितिक्षस्व भारत॥", Thought: "Pleasure and pain come and go like seasons; endure them.", Meaning: "Sadness is temporary, like cold or heat. Understanding its impermanence helps you bear it with strength."),
            Shloka(number: "2.20", sanskrit: "न जायते म्रियते वा कदाचिन्\nनायं भूत्वा भविता वा न भूयः।\nअजो नित्यः शाश्वतोऽयं पुराणो\nन हन्यते हन्यमाने शरीरे॥", Thought: "The soul is never born nor dies; it is eternal.", Meaning: "When sadness strikes from loss, know that the essence of life endures beyond the physical."),
            Shloka(number: "2.27", sanskrit: "जातस्य हि ध्रुवो मृत्युर्ध्रुवं जन्म मृतस्य च।\nतस्मादपरिहार्येऽर्थे न त्वं शोचितुमर्हसि॥", Thought: "Death is certain for the born, and birth for the dead; do not grieve.", Meaning: "Sadness over inevitable changes is futile; accept life’s natural cycles."),
            Shloka(number: "2.56", sanskrit: "दुःखेष्वनुद्विग्नमनाः सुखेषु विगतस्पृहः।\nवीतरागभयक्रोधः स्थितधीर्मुनिरुच्यते॥", Thought: "One unshaken by misery and unattached to joy is a sage.", Meaning: "Rising above sadness through detachment brings inner stability."),
            Shloka(number: "5.20", sanskrit: "न प्रहृष्येत्प्रियं प्राप्य नोद्विजेत्प्राप्य चाप्रियम्।\nस्थिरबुद्धिरसम्मूढो ब्रह्मविद्ब्रह्मणि स्थितः॥", Thought: "Do not rejoice in pleasure nor despair in pain.", Meaning: "Equanimity in all situations reduces the sting of sadness."),
            Shloka(number: "6.22", sanskrit: "यं लब्ध्वा चापरं लाभं मन्यते नाधिकं ततः।\nयस्मिन्स्थितो न दुःखेन गुरुणापि विचाल्यते॥", Thought: "Having gained this, no greater gain exists; no sorrow can shake it.", Meaning: "Finding inner truth lifts you beyond sadness."),
            Shloka(number: "12.17", sanskrit: "यो न हृष्यति न द्वेष्टि न शोचति न काङ्क्षति।\nशुभाशुभपरित्यागी भक्तिमान्यः स मे प्रियः॥", Thought: "He who neither rejoices nor grieves is dear to Me.", Meaning: "Letting go of extremes frees you from sadness’s grip.")
        ],
        "Peace": [
            Shloka(number: "5.29", sanskrit: "भोक्तारं यज्ञतपसां सर्वलोकमहेश्वरम्।\nसुहृदं सर्वभूतानां ज्ञात्वा मां शान्तिमृच्छति॥", Thought: "One who understands that God is the supreme enjoyer and the well-wisher of all beings attains peace.", Meaning: "True peace comes when we understand and accept God's role in our lives. When we recognize that He is our true friend, we no longer feel alone or burdened by worldly struggles."),
            Shloka(number: "6.27", sanskrit: "प्रशान्तमनसं ह्येनं योगिनं सुखमुत्तमम्।\nउपैति शान्तराजसं ब्रह्मभूतमकल्मषम्॥", Thought: "A yogi with a peaceful mind, free from passions, attains supreme happiness.", Meaning: "True peace comes from within. When the mind is free from restlessness, desires, and distractions, it becomes peaceful like a still lake, leading to deep serenity."),
            Shloka(number: "2.70", sanskrit: "आपूर्यमाणमचलप्रतिष्ठं\nसमुद्रमापः प्रविशन्ति यद्वत्।\nतद्वत्कामा यं प्रविशन्ति सर्वे\nस शान्तिमाप्नोति न कामकामी॥", Thought: "He who remains steady amidst desires attains peace.", Meaning: "Like the ocean unmoved by rivers, peace comes to one undisturbed by cravings."),
            Shloka(number: "2.71", sanskrit: "विहाय कामान्यः सर्वान्पुमांश्चरति निःस्पृहः।\nनिर्ममो निरहङ्कारः स शान्तिमधिगच्छति॥", Thought: "One who abandons desires and ego finds peace.", Meaning: "Letting go of selfishness and attachment brings a calm, peaceful state."),
            Shloka(number: "5.12", sanskrit: "युक्तः कर्मफलं त्यक्त्वा शान्तिमाप्नोति नैष्ठिकीम्।\nअयुक्तः कामकारेण फले सक्तो निबध्यते॥", Thought: "The disciplined one, renouncing fruits of action, attains lasting peace.", Meaning: "Peace arises from selfless action, free from expectation."),
            Shloka(number: "6.15", sanskrit: "युञ्जन्नेवं सदात्मानं योगी नियतमानसः।\nशान्तिं निर्वाणपरमां मत्संस्थामधिगच्छति॥", Thought: "The yogi with a controlled mind attains supreme peace.", Meaning: "Discipline and focus lead to a peace that transcends worldly turmoil."),
            Shloka(number: "9.31", sanskrit: "क्षिप्रं भवति धर्मात्मा शश्वच्छान्तिं निगच्छति।\nकौन्तेय प्रतिजानीहि न मे भक्तः प्रणश्यति॥", Thought: "My devotee quickly attains righteousness and eternal peace.", Meaning: "Faith in the divine ensures lasting tranquility."),
            Shloka(number: "12.12", sanskrit: "श्रेयो हि ज्ञानमभ्यासाज्ज्ञानाद्ध्यानं विशिष्यते।\nध्यानात्कर्मफलत्यागस्त्यागाच्छान्तिरनन्तरम्॥", Thought: "Renunciation of fruits brings peace after meditation.", Meaning: "Peace follows a mind refined by knowledge and detachment."),
            Shloka(number: "18.62", sanskrit: "तमेव शरणं गच्छ सर्वभावेन भारत।\nतत्प्रसादात्परां शान्तिं स्थानं प्राप्स्यसि शाश्वतम्॥", Thought: "Surrender to Him and find supreme peace.", Meaning: "Trust in the divine grants eternal peace and stability."),
            Shloka(number: "6.7", sanskrit: "जितात्मनः प्रशान्तस्य परमात्मा समाहितः।\nशीतोष्णसुखदुःखेषु तथा मानापमानयोः॥", Thought: "The self-controlled one finds peace in all conditions.", Meaning: "Mastery over the self brings unshakable peace.")
        ],
        "Worried": [
            Shloka(number: "9.22", sanskrit: "अनन्याश्चिन्तयन्तो मां ये जनाः पर्युपासते।\nतेषां नित्याभियुक्तानां योगक्षेमं वहाम्यहम्॥", Thought: "For those who worship Me with unwavering devotion, I provide what they lack and preserve what they have.", Meaning: "It means that if a person worships God with unwavering faith and devotion, without any doubts or selfish desires, then God Himself takes care of all their needs. Whatever they lack, He provides, and whatever they already have, He protects. This is a message of trust and surrender—there is no need to worry."),
            Shloka(number: "18.66", sanskrit: "सर्वधर्मान्परित्यज्य मामेकं शरणं व्रज।\nअहं त्वां सर्वपापेभ्यो मोक्षयिष्यामि मा शुचः॥", Thought: "Abandon all duties and take refuge in Me alone. I will free you from all sins. Do not grieve.", Meaning: "Krishna tells us to abandon all worries and fears and trust in the divine plan. When we surrender with full faith, He takes responsibility for our well-being, freeing us from anxiety."),
            Shloka(number: "2.48", sanskrit: "योगस्थः कुरु कर्माणि सङ्गं त्यक्त्वा धनञ्जय।\nसिद्ध्यसिद्ध्योः समो भूत्वा समत्वं योग उच्यते॥", Thought: "Perform actions with detachment, balanced in success and failure.", Meaning: "Worries lessen when you act without clinging to outcomes."),
            Shloka(number: "3.27", sanskrit: "प्रकृतेः क्रियमाणानि गुणैः कर्माणि सर्वशः।\nअहङ्कारविमूढात्मा कर्ताहमिति मन्यते॥", Thought: "All actions are performed by nature; the deluded think they are the doer.", Meaning: "Release worry by understanding you’re not the sole controller of events."),
            Shloka(number: "4.14", sanskrit: "न मां कर्माणि लिम्पन्ति न मे कर्मफले स्पृहा।\nइति मां योऽभिजानाति कर्मभिर्न स बध्यते॥", Thought: "Actions do not taint Me, nor do I desire their fruits.", Meaning: "Knowing the divine is beyond worry frees you from its chains."),
            Shloka(number: "6.35", sanskrit: "असंशयं महाबाहो मनो दुर्निग्रहं चलम्।\nअभ्यासेन तु कौन्तेय वैराग्येण च गृह्यते॥", Thought: "The mind is restless, but practice and detachment tame it.", Meaning: "Worries can be controlled through consistent effort and letting go."),
            Shloka(number: "7.14", sanskrit: "दैवी ह्येषा गुणमयी मम माया दुरत्यया।\nमामेव ये प्रपद्यन्ते मायामेतां तरन्ति ते॥", Thought: "My divine illusion is hard to overcome, but surrender transcends it.", Meaning: "Surrendering to the divine lifts you above worldly worries."),
            Shloka(number: "11.33", sanskrit: "तस्मात्त्वमुत्तिष्ठ यशो लभस्व\nजित्वा शत्रून्भुङ्क्ष्व राज्यं समृद्धम्।\nमयैवैते निहताः पूर्वमेव\nनिमित्तमात्रं भव सव्यसाचिन्॥", Thought: "Rise and act; I have already ordained the outcome.", Meaning: "Worry not, for the divine plan is already in motion."),
            Shloka(number: "12.7", sanskrit: "तेषामहं समुद्धर्ता मृत्युसंसारसागरात्।\nभवामि नचिरात्पार्थ मय्यावेशितचेतसाम्॥", Thought: "I deliver those who fix their minds on Me from the ocean of death.", Meaning: "Faith in the divine removes all cause for worry."),
            Shloka(number: "18.58", sanskrit: "मच्चित्तः सर्वदुर्गाणि मत्प्रसादात्तरिष्यसि।\nअथ चेत्वमहङ्कारान्न श्रोष्यसि विनङ्क्ष्यसि॥", Thought: "With your mind on Me, you will overcome all difficulties.", Meaning: "Trust in Me dissolves all worries and obstacles.")
        ],
        "Anxiety": [
            Shloka(number: "6.5", sanskrit: "उद्धरेदात्मनात्मानं नात्मानमवसादयेत्।\nआत्मैव ह्यात्मनो बन्धुरात्मैव रिपुरात्मनः॥", Thought: "One must elevate, not degrade oneself, for the mind is both a friend and an enemy.", Meaning: "When we allow negative thoughts, fears, and worries to take control, our mind becomes our worst enemy—keeping us trapped in overthinking, stress, and hopelessness. But if we choose to strengthen our mind with positivity, self-discipline, and faith, it becomes our greatest friend—guiding us towards peace and confidence."),
            Shloka(number: "18.66", sanskrit: "सर्वधर्मान्परित्यज्य मामेकं शरणं व्रज।\nअहं त्वां सर्वपापेभ्यो मोक्षयिष्यामि मा शुचः॥", Thought: "Take refuge in Me, and I will free you from all sins. Do not grieve.", Meaning: "Taking refuge in the Divine means surrendering our worries, fears, and guilt, trusting that we are never alone. Life can be full of challenges, but Krishna assures us that with faith, He will remove all burdens and lead us to peace."),
            Shloka(number: "2.45", sanskrit: "त्रैगुण्यविषया वेदा निस्त्रैगुण्यो भवार्जुन।\nनिर्द्वन्द्वो नित्यसत्त्वस्थो निर्योगक्षेम आत्मवान्॥", Thought: "Rise above the three gunas and be free from anxiety.", Meaning: "Transcending material influences calms the anxious mind."),
            Shloka(number: "3.9", sanskrit: "यज्ञार्थात्कर्मणोऽन्यत्र लोकोऽयं कर्मबन्धनः।\nतदर्थं कर्म कौन्तेय मुक्तसङ्गः समाचर॥", Thought: "Act for a higher purpose to be free from bondage.", Meaning: "Anxiety fades when actions are selfless and meaningful."),
            Shloka(number: "4.20", sanskrit: "त्यक्त्वा कर्मफलासङ्गं नित्यतृप्तो निराश्रयः।\nकर्मण्यभिप्रवृत्तोऽपि नैव किञ्चित्करोति सः॥", Thought: "Detached from results, one acts without anxiety.", Meaning: "Letting go of outcomes reduces mental unrest."),
            Shloka(number: "5.10", sanskrit: "ब्रह्मण्याधाय कर्माणि सङ्गं त्यक्त्वा करोति यः।\nलिप्यते न स पापेन पद्मपत्रमिवाम्भसा॥", Thought: "Offer actions to Brahman and be untouched by sin.", Meaning: "Surrendering efforts to the divine alleviates anxious guilt."),
            Shloka(number: "6.26", sanskrit: "यतो यतो निश्चरति मनश्चञ्चलमस्थिरम्।\nततस्ततो नियम्यैतदात्मन्येव वशं नयेत्॥", Thought: "Wherever the restless mind wanders, bring it back.", Meaning: "Controlling a wandering mind reduces anxiety’s hold."),
            Shloka(number: "9.34", sanskrit: "मन्मना भव मद्भक्तो मद्याजी मां नमस्कुरु।\nमामेवैष्यसि युक्त्वैवमात्मानं मत्परायणः॥", Thought: "Focus on Me, and you will reach Me.", Meaning: "A mind fixed on the divine finds relief from anxiety."),
            Shloka(number: "12.15", sanskrit: "यस्मान्नोद्विजते लोको लोकान्नोद्विजते च यः।\nहर्षामर्षभयोद्वेगैर्मुक्तो यः स च मे प्रियः॥", Thought: "He who is free from excitement and fear is dear to Me.", Meaning: "Freedom from anxiety’s extremes brings peace."),
            Shloka(number: "18.49", sanskrit: "असक्तबुद्धिः सर्वत्र जीतात्मा विगतस्पृहः।\nनैष्कर्म्यसिद्धिं परमां संन्यासेनाधिगच्छति॥", Thought: "With a detached mind, one attains perfection.", Meaning: "Detachment from desires ends anxiety’s turmoil.")
        ],
        "Anger": [
            Shloka(number: "16.21", sanskrit: "त्रिविधं नरकस्येदं द्वारं नाशनमात्मनः।\nकामः क्रोधस्तथा लोभस्तस्मादेतत्त्रयं त्यजेत्॥", Thought: "Desire, anger, and greed are the three gates to hell. Avoid them for your own well-being.", Meaning: "This verse warns us that anger, desire, and greed are destructive forces that can trap us in a cycle of suffering. Holding onto rage harms us more than the person we are angry at. It disturbs our peace, breaks relationships, and blinds us to reason."),
            Shloka(number: "2.62-63", sanskrit: "क्रोधाद्भवति सम्मोहः सम्मोहात्स्मृतिविभ्रमः।\nस्मृतिभ्रंशाद्बुद्धिनाशो बुद्धिनाशात्प्रणश्यति॥", Thought: "From anger arises delusion, which leads to memory loss and ultimately self-destruction.", Meaning: "When anger takes over, it blinds us to reality. It clouds our judgment, making us act impulsively and say things we don’t mean. Unchecked anger destroys our own peace, focus, and well-being."),
            Shloka(number: "2.56", sanskrit: "दुःखेष्वनुद्विग्नमनाः सुखेषु विगतस्पृहः।\nवीतरागभयक्रोधः स्थितधीर्मुनिरुच्यते॥", Thought: "One free from anger in misery is a sage.", Meaning: "Rising above anger brings stability and clarity."),
            Shloka(number: "3.37", sanskrit: "काम एष क्रोध एष रजोगुणसमुद्भवः।\nमहाशनो महापाप्मा विद्ध्येनमिह वैरिणम्॥", Thought: "Desire and anger, born of passion, are great enemies.", Meaning: "Recognizing anger’s source helps in overcoming it."),
            Shloka(number: "5.23", sanskrit: "शक्नोतीहैव यः सोढुं प्राक्शरीरविमोक्षणात्।\nकामक्रोधोद्भवं वेगं स युक्तः स सुखी नरः॥", Thought: "He who withstands anger’s urge is happy.", Meaning: "Controlling anger leads to inner peace."),
            Shloka(number: "6.10", sanskrit: "योगी युञ्जीत सततमात्मानं रहसि स्थितः।\nएकाकी यतचित्तात्मा निराशीरपरिग्रहः॥", Thought: "A yogi should constantly discipline the mind in solitude.", Meaning: "Self-discipline prevents anger’s rise."),
            Shloka(number: "16.1-3", sanskrit: "अहिंसा सत्यमक्रोधस्त्यागः शान्तिरपैशुनम्।\nदया भूतेष्वलोलुप्त्वं मार्दवं ह्रीरचापलम्॥", Thought: "Non-violence and freedom from anger are divine qualities.", Meaning: "Cultivating these traits dissolves anger."),
            Shloka(number: "16.4", sanskrit: "दम्भो दर्पोऽभिमानश्च क्रोधः पारुष्यमेव च।\nअज्ञानं चाभिजातस्य पार्थ सम्पदमासुरीम्॥", Thought: "Anger and harshness are demonic traits.", Meaning: "Avoiding these fosters peace over anger."),
            Shloka(number: "18.53", sanskrit: "अहङ्कारं बलं दर्पं कामं क्रोधं परिग्रहम्।\nविमुच्य निर्ममः शान्तो ब्रह्मभूयाय कल्पते॥", Thought: "Free from anger and ego, one attains peace.", Meaning: "Letting go of anger paves the way to tranquility."),
            Shloka(number: "5.26", sanskrit: "कामक्रोधवियुक्तानां यतीनां यतचेतसाम्।\nअभितो ब्रह्मनिर्वाणं वर्तते विदितात्मनाम्॥", Thought: "Those free from anger find liberation.", Meaning: "Releasing anger brings ultimate calm.")
        ],
        "Laziness": [
            Shloka(number: "6.16-17", sanskrit: "नात्यश्नतस्तु योगोऽस्ति न चैकान्तमनश्नतः।\nन चातिस्वप्नशीलस्य जाग्रतो नैव चार्जुन॥", Thought: "Yoga is not for one who eats too much or too little, nor for one who sleeps too much or too little.", Meaning: "This verse emphasizes balance in life. True well-being comes from moderation—not extremes. Oversleeping leads to laziness, while too little sleep drains energy. A balanced life leads to a focused mind."),
            Shloka(number: "18.39", sanskrit: "यदग्रे चानुबन्धे च सुखं मोहनमात्मनः।\nनिद्रालस्यप्रमादोत्थं तत्तामसं उदाहृतम्॥", Thought: "The happiness derived from laziness and ignorance is temporary and leads to misery.", Meaning: "This teaching warns us that the comfort of laziness is an illusion. At first, avoiding responsibilities may feel enjoyable, but over time, it leads to regret and suffering. True happiness comes from effort and discipline."),
            Shloka(number: "3.8", sanskrit: "नियतं कुरु कर्म त्वं कर्म ज्यायो ह्यकर्मणः।\nशरीरयात्रापि च ते न प्रसिद्ध्येदकर्मणः॥", Thought: "Perform your prescribed duty; action is better than inaction.", Meaning: "Laziness halts progress; action sustains life."),
            Shloka(number: "3.20", sanskrit: "कर्मणैव हि संसिद्धिमास्थिता जनकादयः।\nलोकसंग्रहमेवापि सम्पश्यन्कर्तुमर्हसि॥", Thought: "Even kings like Janaka attained perfection through action.", Meaning: "Overcome laziness by emulating the diligent."),
            Shloka(number: "4.15", sanskrit: "एवं ज्ञात्वा कृतं कर्म पूर्वैरपि मुमुक्षुभिः।\nकुरु कर्मैव तस्मात्त्वं पूर्वैः पूर्वतरं कृतम्॥", Thought: "The liberated performed actions; so should you.", Meaning: "Action, not laziness, leads to liberation."),
            Shloka(number: "6.1", sanskrit: "अनाश्रितः कर्मफलं कार्यं कर्म करोति यः।\nस संन्यासी च योगी च न निरग्निर्न चाक्रियः॥", Thought: "He who acts without attachment is a true yogi.", Meaning: "Laziness is not renunciation; selfless action is."),
            Shloka(number: "18.24", sanskrit: "यत्तु कामेप्सुना कर्म साहङ्कारेण वा पुनः।\nक्रियते बहुलायासं तद्राजसमुदाहृतम्॥", Thought: "Effort driven by desire is restless, not lazy.", Meaning: "Avoid laziness by channeling energy wisely."),
            Shloka(number: "18.28", sanskrit: "अयुक्तः प्राकृतः स्तब्धः शठो नैष्कृतिकोऽलसः।\nविषादी दीर्घसूत्री च कर्ता तामस उच्यते॥", Thought: "The lazy procrastinator is tamasic.", Meaning: "Recognize laziness as a flaw to overcome."),
            Shloka(number: "3.33", sanskrit: "सदृशं चेष्टते स्वस्याः प्रकृतेर्ज्ञानवानपि।\nप्रकृतिं यान्ति भूतानि निग्रहः किं करिष्यति॥", Thought: "Even the wise act according to nature.", Meaning: "Counter laziness with disciplined effort."),
            Shloka(number: "18.47", sanskrit: "स्वधर्ममपि चावेक्ष्य न विकम्पितumर्हसि।\nधर्म्याद्धि युद्धाच्छ्रेयोऽन्यत्क्षत्रियस्य न विद्यते॥", Thought: "Do not waver from your duty.", Meaning: "Laziness is overcome by embracing responsibility.")
        ],
        "Loneliness": [
            Shloka(number: "6.30", sanskrit: "यो मां पश्यति सर्वत्र सर्वं च मयि पश्यति।\nतस्याहं न प्रणश्यामि स च मे न प्रणश्यति॥", Thought: "One who sees Me everywhere and sees everything in Me is never separated from Me.", Meaning: "This verse teaches the essence of divine connection and unity. When a devotee sees God in everything and everyone, they are never truly alone. No matter the situation—joy or sorrow—God is always present within and around them."),
            Shloka(number: "9.29", sanskrit: "समोऽहं सर्वभूतेषु न मे द्वेष्योऽस्ति न प्रियः।\nये भजन्ति तु मां भक्त्या मयि ते तेषु चाप्यहम्॥", Thought: "I am equal to all beings. Those who worship Me with love dwell in Me, and I dwell in them.", Meaning: "This verse reveals God’s impartial love and universal presence. Through sincere devotion, one can feel God’s constant presence, banishing loneliness."),
            Shloka(number: "2.24", sanskrit: "अच्छेद्योऽयमदाह्योऽयमक्लेद्योऽशोष्य एव च।\nनित्यः सर्वगतः स्थाणुरचलोऽयं सनातनः॥", Thought: "The soul is eternal, all-pervading, and immovable.", Meaning: "Your eternal nature connects you to all, reducing loneliness."),
            Shloka(number: "5.18", sanskrit: "विद्याविनयसम्पन्ने ब्राह्मणे गवि हस्तिनि।\nशुनि चैव श्वपाके च पण्डिताः समदर्शिनः॥", Thought: "The wise see all beings equally.", Meaning: "Seeing unity in all counters feelings of isolation."),
            Shloka(number: "6.29", sanskrit: "सर्वभूतस्थमात्मानं सर्वभूतानि चात्मनि।\nईक्षते योगयुक्तात्मा सर्वत्र समदर्शनः॥", Thought: "The yogi sees the self in all beings and all beings in the self.", Meaning: "Realizing this oneness dispels loneliness."),
            Shloka(number: "9.32", sanskrit: "मां हि पार्थ व्यपाश्रित्य येऽपि स्युः पापयोनयः।\nस्त्रियो वैश्यास्तथा शूद्रास्तेऽपि यान्ति परां गतिम्॥", Thought: "All who take refuge in Me attain the supreme goal.", Meaning: "No one is alone when connected to the divine."),
            Shloka(number: "11.4", sanskrit: "मन्यसे यदि तच्छक्यं मया द्रष्टumिति प्रभो।\nयोगेश्वर ततो मे त्वं दर्शयात्मानमव्ययम्॥", Thought: "Show me Your imperishable self, O Lord.", Meaning: "Seeking the divine presence fills the void of loneliness."),
            Shloka(number: "12.5", sanskrit: "क्लेशोऽधिकतरस्तेषामव्यक्तासक्तचेतसाम्।\nअव्यक्ता हि गतिर्दुःखं देहभिर्जायते नृणाम्॥", Thought: "The unmanifest is harder, but devotion eases it.", Meaning: "Devotion to the divine overcomes lonely struggles."),
            Shloka(number: "13.11", sanskrit: "मयि चानन्ययोगेन भक्तिरव्यभिचारिणी।\nविविक्तदेशसेवित्वमरतिर्जनसंसदि॥", Thought: "Unwavering devotion to Me brings solace.", Meaning: "A bond with the divine cures loneliness."),
            Shloka(number: "18.61", sanskrit: "ईश्वरः सर्वभूतानां हृद्देशेऽर्जुन तिष्ठति।\nभ्रामयन्सर्वभूतानि यन्त्रारूढानि मायया॥", Thought: "The Lord dwells in the heart of all beings.", Meaning: "You are never alone with the divine within.")
        ],
        "Overwhelmed": [
            Shloka(number: "11.20", sanskrit: "द्यावापृथिव्योरिदमन्तरं हि\nव्याप्तं त्वयैकेन दिशश्च सर्वाः।", Thought: "The space between heaven and earth is filled with Your presence.", Meaning: "When overwhelmed, remember the vastness of the divine — everything is already being held and sustained."),
            Shloka(number: "2.14", sanskrit: "मात्रास्पर्शास्तु कौन्तेय शीतोष्णसुखदुःखदाः।", Thought: "Pleasure and pain are temporary.", Meaning: "Life’s ups and downs are like seasons; don’t be shaken by their passing."),
            Shloka(number: "4.7", sanskrit: "यदा यदा हि धर्मस्य ग्लानिर्भवति भारत।", Thought: "God manifests when righteousness declines.", Meaning: "Even in your lowest moments, divine help is on the way."),
            Shloka(number: "18.66", sanskrit: "सर्वधर्मान्परित्यज्य मामेकं शरणं व्रज।", Thought: "Surrender fully and find peace.", Meaning: "Letting go of control in overwhelming situations leads to liberation."),
            Shloka(number: "11.45", sanskrit: "दृष्ट्वेदं मानुषं रूपं तव सौम्यं जनार्दन।", Thought: "Seeing Your gentle form soothes the heart.", Meaning: "When chaos reigns, seek the calm and loving nature of the divine."),
            Shloka(number: "2.47", sanskrit: "कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।", Thought: "You have control over action, not results.", Meaning: "Relieve pressure by focusing only on your efforts, not the outcome."),
            Shloka(number: "6.5", sanskrit: "उद्धरेदात्मनाऽऽत्मानं नात्मानमवसादयेत्।", Thought: "Elevate yourself, don’t put yourself down.", Meaning: "In stressful times, be your own biggest supporter."),
            Shloka(number: "11.38", sanskrit: "त्वमादिदेवः पुरुषः पुराणः", Thought: "You are the original, eternal being.", Meaning: "Even when overwhelmed, there’s comfort in the presence of something timeless and unchanging."),
            Shloka(number: "6.6", sanskrit: "बन्धुरात्मात्मनस्तस्य येनात्मैवात्मना जितः।", Thought: "The self is both the friend and the enemy.", Meaning: "When your mind feels scattered, learn to befriend it."),
            Shloka(number: "18.58", sanskrit: "मच्चित्तः सर्वदुर्गाणि मत्प्रसादात्तरिष्यसि।", Thought: "With devotion, you will overcome all obstacles.", Meaning: "Overwhelm melts away with complete faith and alignment.")
        ],
        "Excited": [
            Shloka(number: "3.30", sanskrit: "मयि सर्वाणि कर्माणि संन्यस्याध्यात्मचेतसा।", Thought: "Offer all actions to Me with a focused mind.", Meaning: "Excitement becomes powerful when rooted in devotion and purpose."),
            Shloka(number: "11.12", sanskrit: "दिवि सूर्यसहस्रस्य भवेद्युगपदुत्थिता।", Thought: "If a thousand suns were to rise, it would match Your brilliance.", Meaning: "Moments of divine revelation are filled with awe and excitement."),
            Shloka(number: "2.37", sanskrit: "हतो वा प्राप्स्यसि स्वर्गं जित्वा वा भोक्ष्यसे महीम्।", Thought: "Victory or sacrifice — both lead to glory.", Meaning: "Face every challenge with zeal — there is no true loss."),
            Shloka(number: "18.46", sanskrit: "स्वकर्मणा तमभ्यर्च्य सिद्धिं विन्दति मानवः।", Thought: "One attains success by worshiping through their own work.", Meaning: "Channel your enthusiasm into your passions and purpose."),
            Shloka(number: "10.41", sanskrit: "यद् यद् विभूतिमत्सत्त्वं श्रीमदूर्जितमेव वा।", Thought: "Whatever is glorious or powerful comes from Me.", Meaning: "Your excitement is a spark of the divine at work in you."),
            Shloka(number: "3.8", sanskrit: "नियतं कुरु कर्म त्वं कर्म ज्यायो ह्यकर्मणः।", Thought: "Do your duty with enthusiasm; inaction is worse.", Meaning: "Keep moving with joyful action — that is true dharma."),
            Shloka(number: "6.28", sanskrit: "योगयुक्तो विशुद्धात्मा विजितात्मा जितेन्द्रियः।", Thought: "Through steady practice, the yogi finds joy and peace.", Meaning: "Even in excitement, grounding through discipline leads to deeper joy."),
            Shloka(number: "4.24", sanskrit: "ब्रह्मार्पणं ब्रह्म हविः ब्रह्माग्नौ ब्रह्मणा हुतम्।", Thought: "Everything is divine — the offering, the act, the doer.", Meaning: "Excitement becomes sacred when intentions are pure."),
            Shloka(number: "10.20", sanskrit: "अहमात्मा गुडाकेश सर्वभूताशयस्थितः।", Thought: "I am the soul seated in everyone’s heart.", Meaning: "Your passion is not random — it’s a divine spark within you."),
            Shloka(number: "9.22", sanskrit: "योगक्षेमं वहाम्यहम्।", Thought: "I carry the burden of those who are devoted.", Meaning: "Let your excitement rise with faith that you're being supported.")
        ],
        "Protective": [
            Shloka(number: "9.31", sanskrit: "कौन्तेय प्रतिजानीहि न मे भक्तः प्रणश्यति॥", Thought: "My devotee never perishes.", Meaning: "The Divine always protects those who surrender with love and faith. This verse radiates assurance and security."),
            Shloka(number: "18.66", sanskrit: "सर्वधर्मान्परित्यज्य मामेकं शरणं व्रज। अहं त्वां सर्वपापेभ्यो मोक्षयिष्यामि मा शुचः॥", Thought: "Surrender to Me alone, I shall liberate you from all sins.", Meaning: "When overwhelmed by duties or fear, surrendering brings divine protection."),
            Shloka(number: "4.7", sanskrit: "यदा यदा हि धर्मस्य ग्लानिर्भवति भारत।", Thought: "Whenever righteousness declines, I manifest.", Meaning: "In moments of chaos or crisis, know that the divine intervenes for protection."),
            Shloka(number: "4.8", sanskrit: "परित्राणाय साधूनां विनाशाय च दुष्कृताम्।", Thought: "To protect the righteous and destroy the wicked, I descend.", Meaning: "This shloka reveals the protective role of divinity for all beings striving toward dharma."),
            Shloka(number: "10.36", sanskrit: "धृतिः क्षमा दमः शमः सुखं दुःखं भवोऽभवः।", Thought: "I am strength, patience, and forbearance.", Meaning: "Protection is often silent — found in inner virtues bestowed by the Divine."),
            Shloka(number: "6.40", sanskrit: "न हि कल्याणकृत्कश्चिद्दुर्गतिं तात गच्छति।", Thought: "One who does good is never overcome by evil.", Meaning: "The Divine protects those with pure intentions and efforts."),
            Shloka(number: "7.14", sanskrit: "दैवी ह्येषा गुणमयी मम माया दुरत्यया।", Thought: "This divine illusion is hard to overcome—but surrendering to Me, one crosses it.", Meaning: "Even in life’s toughest storms, surrendering to the divine offers safe passage."),
            Shloka(number: "12.6–7", sanskrit: "ये तु सर्वाणि कर्माणि मयि संन्यस्य मत्पराः।", Thought: "Those who depend wholly on Me, I deliver from all troubles.", Meaning: "The Lord ensures the safety of those who dedicate their life to Him."),
            Shloka(number: "2.47", sanskrit: "कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।", Thought: "Focus on your duty, not on results.", Meaning: "This shloka reminds you that divine protection lies in right action without worry."),
            Shloka(number: "3.30", sanskrit: "मयि सर्वाणि कर्माणि संन्यस्याध्यात्मचेतसा।", Thought: "Surrender all actions to Me, and you shall be protected.", Meaning: "Act with divine consciousness, and you are never truly alone.")
        ],
        "Overjoyed": [
            Shloka(number: "11.12", sanskrit: "दिवि सूर्यसहस्रस्य भवेद्युगपदुत्थिता।", Thought: "A thousand suns rising together could barely match His glory.", Meaning: "This verse expresses the awe and ecstatic wonder of beholding the Supreme."),
            Shloka(number: "11.45", sanskrit: "दृष्ट्वेदं मानुषं रूपं तव सौम्यं जनार्दन।", Thought: "Seeing your gentle human form again fills me with joy.", Meaning: "After awe comes deep joy and comfort — a reflection of divine love."),
            Shloka(number: "10.41", sanskrit: "यद्यद्विभूतिमत्सत्त्वं श्रीमदूर्जितमेव वा।", Thought: "Wherever there's beauty, strength, or power — know it as a spark of Me.", Meaning: "Overjoy flows when we recognize divine beauty in every joy-giving moment."),
            Shloka(number: "2.70", sanskrit: "आपूर्यमाणमचलप्रतिष्ठं समुद्रमापः प्रविशन्ति यद्वत्।", Thought: "Joy is unshaken like the ocean amidst rivers flowing in.", Meaning: "True joy is calm and deep — not disturbed by outer circumstances."),
            Shloka(number: "10.9", sanskrit: "मच्चित्ता मद्गतप्राणा बोधयन्तः परस्परम्।", Thought: "My devotees find joy in discussing Me, enlightening each other.", Meaning: "Sharing divine love and wisdom multiplies inner joy."),
            Shloka(number: "6.22", sanskrit: "यं लब्ध्वा चापरं लाभं मन्यते नाधिकं ततः।", Thought: "Upon gaining this, no greater gain exists.", Meaning: "The joy of inner realization surpasses every material happiness."),
            Shloka(number: "10.18", sanskrit: "विस्तरेणात्मनो योगं विभूतिं च जनार्दन।", Thought: "Please tell me again your divine glories, I can never have enough!", Meaning: "The heart overflows with joy in learning more about the Infinite."),
            Shloka(number: "11.36", sanskrit: "एतत्त्र्यम्यं जगतः प्रहर्षति", Thought: "Hearing your name, the whole world rejoices!", Meaning: "Divine names and stories bring an unexplainable inner celebration."),
            Shloka(number: "11.14", sanskrit: "स तत्र विस्मयाविष्टो हृष्टरोमा धनञ्जयः।", Thought: "Arjuna, thrilled and awestruck, spoke with hair standing on end.", Meaning: "Real spiritual joy affects you even physically—it’s a full-body feeling."),
            Shloka(number: "6.20", sanskrit: "यत्रोपरमते चित्तं निरुद्धं योगसेवया।", Thought: "Where the mind rests completely, immersed in bliss.", Meaning: "In deep meditative joy, all else disappears—just stillness and light remain.")
        ]


    ]

    @State private var selectedShloka: Shloka?

    var body: some View {
        ZStack {
            mood.backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Text(mood.memoji)
                        .font(.system(size: 100))
                        .shadow(radius: 5)
                        .padding(.top, 40)

                    Text("Select a Shloka")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.horizontal)

                    VStack(spacing: 15) {
                        if let shlokas = moodShlokas[mood.name] {
                            ForEach(shlokas) { shloka in
                                NavigationLink(destination: ShlokaDetailView(shloka: shloka)) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Shloka \(shloka.number)")
                                            .font(.headline)
                                            .foregroundColor(.blue)
                                            .padding(.vertical, 20)
                                            .padding(.horizontal)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(
                                                RoundedRectangle(cornerRadius: 25)
                                                    .fill(Color(UIColor.systemBackground))
                                                    .shadow(radius: 5)
                                            )
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        } else {
                            Text("No shlokas available")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(mood.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ShlokaDetailView: View {
    let shloka: Shloka
    @State private var isFavorite: Bool = false
    @State private var isShowingShareSheet1 = false
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [
                Color(.systemBackground).opacity(0.8),
                Color(.systemBackground).opacity(0.5)
            ]), startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Text("Shloka \(shloka.number)")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.gray)
                        .padding(.top, 10)

                    Text(shloka.sanskrit)
                        .font(.title3.weight(.medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.ultraThinMaterial)
                                .background(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.2)))
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                        .padding(.horizontal, 20)

                    SectionView(title: "Thought", content: shloka.Thought)
                    SectionView(title: "Meaning", content: shloka.Meaning)

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
        }
        .navigationTitle("Shloka Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }

            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    isFavorite.toggle()
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .blue)
                        .imageScale(.large)
                }

                Button(action: {
                    print("Share button tapped") // Debug print
                    isShowingShareSheet1 = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.blue)
                        .imageScale(.large)
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingShareSheet1) {
            ShareSheet1(activityItems: [shareMessage])
        }

    }

    // Computed property for the share message
    private var shareMessage: String {
        """
        Hey! 🙌
        Check out this amazing shloka from the Bhagavad Gita:

        "\(shloka.sanskrit)"

        💭 \(shloka.Thought)

        \(shloka.Meaning)
        """
    }
}

struct SectionView: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundColor(.gray)

            Text(content)
                .font(.body.weight(.regular))
                .multilineTextAlignment(.leading)
                .foregroundColor(.secondary)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.ultraThinMaterial)
                        .background(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.2)))
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
        }
        .padding(.horizontal, 20)
    }
}

struct Shloka: Identifiable {
    let id = UUID()
    let number: String
    let sanskrit: String
    let Thought: String
    let Meaning: String
}

struct SharingView: View {
    @State private var isShowingContactPicker = false
    @State private var selectedPhoneNumber: String? = nil
    @State private var isShowingShareSheet = false
    @State private var isShowingMessageComposer = false
    @State private var errorMessage: String = ""


    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer()

                VStack(spacing: 10) {
                    Image(systemName: "person.2.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)

                    Text("Mood Sharing")
                        .font(.largeTitle.bold())

                    Text("Share your mood and connect with friends and family.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }

                VStack(spacing: 15) {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(alignment: .top, spacing: 15) {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)

                            VStack(alignment: .leading, spacing: 5) {
                                Text("You're in Control")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .layoutPriority(1)
                                Text("Decide how and with whom you share your mood data.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        HStack(alignment: .top, spacing: 15) {
                            Image(systemName: "bell.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)

                            VStack(alignment: .leading, spacing: 5) {
                                Text("Dashboard and Notifications")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .layoutPriority(1)
                                Text("Mood updates are shared in their app. Notifications keep them informed.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        HStack(alignment: .top, spacing: 15) {
                            Image(systemName: "lock.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)

                            VStack(alignment: .leading, spacing: 5) {
                                Text("Private and Secure")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .layoutPriority(1)
                                Text("Your data is encrypted and only shared with your consent.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(UIColor.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
                    )
                    .padding(.horizontal)
                }

                VStack(spacing: 15) {
                    Button(action: {
                        isShowingContactPicker = true
                    }) {
                        Text("Share with Someone")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 55)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(15)
                    }

                    Button(action: {
                        isShowingShareSheet = true
                    }) {
                        Text("Ask Someone to Share")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 55)
                            .foregroundColor(.blue)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(15)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $isShowingContactPicker) {
                    ContactPickerView(selectedPhoneNumber: $selectedPhoneNumber, isShowingMessageComposer: $isShowingMessageComposer)
                }
                .sheet(isPresented: $isShowingMessageComposer, onDismiss: {
                    print("Message Composer Dismissed")
                    selectedPhoneNumber = nil // Reset after dismissal
                    isShowingMessageComposer = false
                }) {
                    if let phoneNumber = selectedPhoneNumber {
                        if MessageComposer.canSendText() {
                            MessageComposer(recipients: [phoneNumber], body: "Hey! Check out this amazing app that helps you share your mood. Download it here: https://apps.apple.com/in/app/your-app-id")
                        } else {
                            Text("This device cannot send SMS.")
                                .onAppear {
                                    errorMessage = "SMS not supported on this device."
                                    isShowingMessageComposer = false
                                }
                        }
                    } else {
                        Text("No phone number selected.")
                            .onAppear {
                                errorMessage = "Failed to select a phone number."
                                isShowingMessageComposer = false
                            }
                    }
                }
            }
        }

struct ContactPickerView: UIViewControllerRepresentable {
    @Binding var selectedPhoneNumber: String?
    @Binding var isShowingMessageComposer: Bool

    class Coordinator: NSObject, CNContactPickerDelegate {
        var parent: ContactPickerView

        init(_ parent: ContactPickerView) {
            self.parent = parent
        }

        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
                print("Selected Phone Number: \(phoneNumber)")
                parent.selectedPhoneNumber = phoneNumber
                parent.isShowingMessageComposer = true
            } else {
                print("No phone number available for this contact.")
            }
            picker.dismiss(animated: true, completion: nil) // Explicitly dismiss picker
        }

        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            print("Contact Picker Cancelled")
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        picker.predicateForEnablingContact = NSPredicate(format: "phoneNumbers.@count > 0")
        return picker
    }

    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}
}

struct MessageComposer: UIViewControllerRepresentable {
    var recipients: [String]
    var body: String

    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        print("Creating Message Composer with recipients: \(recipients)")
        let composer = MFMessageComposeViewController()
        composer.recipients = recipients
        composer.body = body
        composer.messageComposeDelegate = context.coordinator
        return composer
    }

    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}

    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            print("Message Composer finished with result: \(result.rawValue)")
            controller.dismiss(animated: true, completion: nil)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    static func canSendText() -> Bool {
        let canSend = MFMessageComposeViewController.canSendText()
        print("Can send text: \(canSend)")
        return canSend
    }
}

struct SharingView_Previews: PreviewProvider {
    static var previews: some View {
        SharingView()
    }
}
