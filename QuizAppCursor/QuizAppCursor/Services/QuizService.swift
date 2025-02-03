import Foundation

enum QuizError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case networkError(Error)
}

class QuizService {
    static let shared = QuizService()
    private init() {}
    
    func fetchQuestions(amount: Int = 20) async throws -> [Question] {
        let urlString = "https://opentdb.com/api.php?amount=\(amount)&type=multiple"
        
        guard let url = URL(string: urlString) else {
            throw QuizError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw QuizError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        do {
            let apiResponse = try decoder.decode(QuizAPIResponse.self, from: data)
            
            // Convert API questions to our Question model
            return apiResponse.results.map { apiQuestion in
                let allOptions = ([apiQuestion.correctAnswer] + apiQuestion.incorrectAnswers).shuffled()
                let correctAnswerIndex = allOptions.firstIndex(of: apiQuestion.correctAnswer) ?? 0
                
                // Decode HTML entities in the text
                let decodedQuestion = apiQuestion.question.removingHTMLEntities()
                let decodedOptions = allOptions.map { $0.removingHTMLEntities() }
                
                return Question(
                    text: decodedQuestion,
                    options: decodedOptions,
                    correctAnswerIndex: correctAnswerIndex
                )
            }
        } catch {
            throw QuizError.decodingError
        }
    }
} 