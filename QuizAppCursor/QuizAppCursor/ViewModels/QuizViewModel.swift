import SwiftUI

@MainActor
class QuizViewModel: ObservableObject {
    @Published var questions: [Question]
    @Published var currentQuestionIndex = 0
    @Published var score = 0
    @Published var quizCompleted = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var currentQuestion: Question {
        questions[currentQuestionIndex]
    }
    
    var progress: Float {
        Float(currentQuestionIndex + 1) / Float(questions.count)
    }
    
    init() {
        self.questions = []
        Task {
            await loadQuestions()
        }
    }
    
    func loadQuestions() async {
        isLoading = true
        errorMessage = nil
        
        do {
            questions = try await QuizService.shared.fetchQuestions()
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to load questions. Please try again."
            questions = [] // Clear any existing questions
        }
    }
    
    func answerSelected(_ answerIndex: Int) {
        var question = questions[currentQuestionIndex]
        question.isAnswered = true
        question.selectedAnswerIndex = answerIndex
        questions[currentQuestionIndex] = question
        
        if question.isCorrect {
            score += 1
        }
        
        // Wait for 2 seconds before moving to the next question
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if self.currentQuestionIndex < self.questions.count - 1 {
                self.currentQuestionIndex += 1
            } else {
                self.quizCompleted = true
            }
        }
    }
    
    func restartQuiz() {
        currentQuestionIndex = 0
        score = 0
        quizCompleted = false
        Task {
            await loadQuestions() // Load new questions for the next round
        }
    }
} 