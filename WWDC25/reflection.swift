import Foundation
struct Reflection: Identifiable, Codable , Equatable {
    let id: UUID
    let mood: String
    let emoji: String
    let text: String
    let date: Date
    
    
    // Regular initializer for creating new reflections
    init(mood: String, emoji: String, text: String, date: Date = Date()) {
        self.id = UUID()
        self.mood = mood
        self.emoji = emoji
        self.text = text
        self.date = date
    }
    
    // Decoder initializer for loading from storage
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        mood = try container.decode(String.self, forKey: .mood)
        emoji = try container.decode(String.self, forKey: .emoji)
        text = try container.decode(String.self, forKey: .text)
        date = try container.decode(Date.self, forKey: .date)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, mood, emoji, text, date
    }
}
class ReflectionManager: ObservableObject {
    @Published var reflections: [Reflection] = [] {
        didSet {
            saveReflections() // Auto-save when array changes
        }
    }
    
    private let key = "savedReflections"
    
    init() {
        loadReflections()
    }
    
    func addReflection(mood: String, emoji: String, text: String) {
        let newReflection = Reflection(mood: mood, emoji: emoji, text: text)
        reflections.insert(newReflection, at: 0) // Add to top
    }
    
    func deleteReflection(_ reflection: Reflection) {
            reflections.removeAll { $0.id == reflection.id }
        }

    
    private func saveReflections() {
        if let encoded = try? JSONEncoder().encode(reflections) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    private func loadReflections() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Reflection].self, from: data) {
            reflections = decoded.sorted { $0.date > $1.date } // Newest first
        }
    }
}
