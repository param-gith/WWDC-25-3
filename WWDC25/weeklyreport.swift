//
//  weeklyreport.swift
//  WWDC25
//
//  Created by User@Param on 11/04/25.
//
// WeeklyMoodAnalyzer.swift
import Foundation



struct MoodSummary {
    let dominantMood: String
    let moodFrequency: [String: Int]
    let positiveDays: Int
    let negativeDays: Int
    let neutralDays: Int
    let advice: String
    let startDate: Date
    let endDate: Date
}

class WeeklyMoodAnalyzer {
    
    static func analyzeWeek(reflections: [Reflection]) -> MoodSummary? {
        guard !reflections.isEmpty else { return nil }
        
        let calendar = Calendar.current
        let now = Date()
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else { return nil }
        
        let weeklyReflections = reflections.filter { $0.date >= startOfWeek }
        
        // Mood frequency analysis
        var moodFrequency = [String: Int]()
        var positiveDays = 0
        var negativeDays = 0
        var neutralDays = 0
        
        for reflection in weeklyReflections {
            moodFrequency[reflection.mood, default: 0] += 1
            
            // Categorize moods
            switch reflection.mood.lowercased() {
            case "happy", "peaceful", "excited", "overjoyed":
                positiveDays += 1
            case "sad", "angry", "anxious", "lonely", "overwhelmed":
                negativeDays += 1
            default:
                neutralDays += 1
            }
        }
        
        // Determine dominant mood
        let dominantMood = moodFrequency.max { $0.value < $1.value }?.key ?? "neutral"
        
        // Generate advice
        let advice = generateAdvice(
            dominantMood: dominantMood,
            positiveDays: positiveDays,
            negativeDays: negativeDays,
            moodFrequency: moodFrequency
        )
        
        return MoodSummary(
            dominantMood: dominantMood,
            moodFrequency: moodFrequency,
            positiveDays: positiveDays,
            negativeDays: negativeDays,
            neutralDays: neutralDays,
            advice: advice,
            startDate: startOfWeek,
            endDate: now
        )
    }
    
    private static func generateAdvice(
        dominantMood: String,
        positiveDays: Int,
        negativeDays: Int,
        moodFrequency: [String: Int]
    ) -> String {
        let totalDays = positiveDays + negativeDays + (moodFrequency["tired"] ?? 0)
        
        // General assessment
        let moodRatio = Double(positiveDays) / Double(totalDays)
        
        var advice = ""
        
        // Overall assessment
        switch moodRatio {
        case 0.7...1.0:
            advice += "You've had a great week! Keep doing what makes you happy. "
        case 0.4..<0.7:
            advice += "Your week had more ups than downs. "
        case 0.0..<0.4:
            advice += "You've had a challenging week. "
        default:
            advice += "Your week had a mix of emotions. "
        }
        
        // Specific mood advice
        switch dominantMood.lowercased() {
        case "happy", "excited", "overjoyed":
            advice += """
            Your heart felt light and joyful this week. Enjoy this fully, but also remember—lasting peace comes from within, not just from external highs. Reflect on what truly nourished your spirit, and carry that warmth forward without getting attached to outcomes.
            """

        case "sad", "lonely":
            advice += """
            This week may have felt heavy or isolating. Emotions pass like clouds in the sky. You're not alone, even when it feels that way. Sometimes, sitting with your feelings gently and reaching out—just a little—can open up space for light to enter again.
            """

        case "angry":
            advice += """
            Anger often arises when expectations collide with reality. Take a moment to pause, breathe, and look inward. It's okay to feel it—but you don’t have to act on it. Responding from calm awareness helps you protect your energy and choose your next step wisely.
            """

        case "anxious", "overwhelmed":
            advice += """
            When life feels like too much, slow down. You don’t have to do everything at once. Break things into small steps, and bring your focus gently back to what you can control right now. Peace grows when you create space between stimulus and response.
            """

        case "tired":
            advice += """
            Tiredness is your body and mind asking for rest. You don’t have to earn rest—it’s a basic need. This week, allow yourself to step back, restore, and simply be. Moving gently and mindfully often brings you closer to clarity than constant pushing ever could.
            """

        default:
            advice += """
            However you're feeling, it's okay. Emotions are like waves—they rise, they fall, they pass. Try to observe what your heart needs right now. A little space, a little kindness, and a few quiet moments can bring surprising clarity.
            """
        }

        
        // Additional suggestions
        if negativeDays > 3 {
            advice += """

            \n\nThis week had more than a few hard days. That’s okay. Sometimes, the path forward begins with simply noticing what’s hurting and allowing yourself to feel it. Writing it down or sharing with someone can help lighten the weight you've been carrying.
            """
        }

        if let happyCount = moodFrequency["happy"], happyCount >= 3 {
            advice += """

            \n\nThere were several happy moments this week. That’s a beautiful thing. Pause and remember what brought you those smiles—people, places, or even small things. Try to hold on to those habits or spaces that bring you closer to yourself.
            """
        }

        return advice

    }
    
    static func formattedDateRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
}
