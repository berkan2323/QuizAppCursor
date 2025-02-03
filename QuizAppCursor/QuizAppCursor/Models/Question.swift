import Foundation

struct Question: Identifiable {
    let id = UUID()
    let text: String
    let options: [String]
    let correctAnswerIndex: Int
    
    var isAnswered = false
    var selectedAnswerIndex: Int?
    
    var isCorrect: Bool {
        guard let selectedAnswerIndex = selectedAnswerIndex else { return false }
        return selectedAnswerIndex == correctAnswerIndex
    }
} 