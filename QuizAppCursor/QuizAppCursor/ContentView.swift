//
//  ContentView.swift
//  QuizAppCursor
//
//  Created by Berkan Aydın on 3.02.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = QuizViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.white)
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView("Loading questions...")
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 20) {
                        Text("😕")
                            .font(.system(size: 64))
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                        Button("Try Again") {
                            Task {
                                await viewModel.loadQuestions()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else if viewModel.questions.isEmpty {
                    Text("No questions available")
                } else if viewModel.quizCompleted {
                    QuizCompletedView(score: viewModel.score,
                                    totalQuestions: viewModel.questions.count,
                                    onRestart: viewModel.restartQuiz)
                } else {
                    VStack(spacing: 20) {
                        ProgressView(value: viewModel.progress)
                            .tint(.blue)
                            .padding(.horizontal)
                        
                        Text(viewModel.currentQuestion.text)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(viewModel.currentQuestion.options.indices, id: \.self) { index in
                                AnswerButton(
                                    text: viewModel.currentQuestion.options[index],
                                    isSelected: viewModel.currentQuestion.selectedAnswerIndex == index,
                                    isCorrect: index == viewModel.currentQuestion.correctAnswerIndex,
                                    isAnswered: viewModel.currentQuestion.isAnswered,
                                    action: {
                                        viewModel.answerSelected(index)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        if viewModel.currentQuestion.isAnswered {
                            Text(viewModel.currentQuestion.isCorrect ? "Correct! 🎉" : "Wrong! The correct answer is highlighted in green")
                                .foregroundColor(viewModel.currentQuestion.isCorrect ? .green : .red)
                                .font(.headline)
                                .padding(.top)
                        }
                        
                        Spacer()
                        
                        Text("Question \(viewModel.currentQuestionIndex + 1) of \(viewModel.questions.count)")
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Quiz App")
        }
    }
}

struct AnswerButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isAnswered: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            if !isAnswered {
                action()
            }
        }) {
            Text(text)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity)
                .padding()
                .background(backgroundColor)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: isAnswered ? 2 : 0)
                )
        }
        .disabled(isAnswered)
    }
    
    private var backgroundColor: Color {
        if !isAnswered {
            return isSelected ? .blue.opacity(0.2) : Color(.gray).opacity(0.1)
        } else {
            if isCorrect {
                return .green.opacity(0.2)
            } else if isSelected {
                return .red.opacity(0.2)
            }
            return Color(.gray).opacity(0.1)
        }
    }
    
    private var borderColor: Color {
        if isAnswered {
            if isCorrect {
                return .green
            } else if isSelected {
                return .red
            }
        }
        return .clear
    }
    
    private var foregroundColor: Color {
        if !isAnswered {
            return isSelected ? .blue : .primary
        } else {
            if isCorrect {
                return .green
            } else if isSelected {
                return .red
            }
            return .primary
        }
    }
}

struct QuizCompletedView: View {
    let score: Int
    let totalQuestions: Int
    let onRestart: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Quiz Completed!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Your score: \(score)/\(totalQuestions)")
                .font(.title2)
            
            Button(action: onRestart) {
                Text("Restart Quiz")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    ContentView()
}
