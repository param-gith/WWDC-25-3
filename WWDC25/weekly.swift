import SwiftUI
import Charts

struct WeeklySummaryView: View {
    let summary: MoodSummary
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    moodBreakdownSection
                    adviceSection
                    Spacer()
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Weekly Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weekly Mood Story")
                .font(.title)
                .fontWeight(.semibold)

            let dominantMood = summary.dominantMood
            HStack {
                Text("Dominant Mood: \(emojiForMood(dominantMood)) \(dominantMood)")
                    .font(.headline)
                    .padding(8)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(10)
            }
        }
    }

    private var moodBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Mood Breakdown")
                .font(.headline)

            VStack {
                HStack(alignment: .bottom, spacing: 20) {
                    ForEach(summary.moodFrequency.sorted(by: { $0.value > $1.value }), id: \.key) { mood, count in
                        VStack {
                            Text(emojiForMood(mood))
                                .font(.title2)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(colorForMood(mood))
                                .frame(width: 24, height: CGFloat(count) / CGFloat(maxCount()) * 120)
                            
                            Text("\(count)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.15), Color.cyan.opacity(0.2)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(20)
            .shadow(color: Color.blue.opacity(0.1), radius: 8, x: 0, y: 4)
        }
    }

    private var adviceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Advice for You")
                .font(.headline)

            Text(summary.advice)
                .font(.body)
                .padding(10)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
                
        }
    }

    private func maxCount() -> Int {
        summary.moodFrequency.values.max() ?? 1
    }

    private func emojiForMood(_ mood: String) -> String {
        switch mood {
        case "Happy": return "😊"
        case "Sad": return "😢"
        case "Angry": return "😡"
        case "Peaceful": return "😌"
        case "Anxious": return "😟"
        case "Tired": return "😴"
        case "Lonely": return "😞"
        case "Excited": return "🤩"
        case "Overwhelmed": return "🤯"
        case "Protective": return "🛡️"
        case "Overjoyed": return "🥳"
        default: return "🙂"
        }
    }


    private func colorForMood(_ mood: String) -> Color {
        switch mood {
        case "Happy": return .yellow
        case "Sad": return .blue
        case "Peaceful": return .green
        case "Protective": return .purple
        case "Anxious": return .orange
        case "Angry": return .red
        case "Lazy": return .gray
        case "Lonely": return .mint
        case "Excited": return .pink
        case "Overwhelmed": return .indigo
        case "Overjoyed": return .teal
        default: return .primary
        }
    }
}


