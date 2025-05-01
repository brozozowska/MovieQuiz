//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Сергей Розов on 30.04.2025.
//

import UIKit

final class MovieQuizPresenter {
    let questionsAmount = 10
    private var currentQuestionIndex = 0
    var currentQuestion: QuizQuestionModel?
    weak var viewController: MovieQuizViewController?

    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestionModel) -> QuizStepModel {
        let image = UIImage(data: model.image) ?? UIImage()
        let question = model.text
        let questionNumber = "\(currentQuestionIndex + 1)/\(questionsAmount)"
        return QuizStepModel(image: image, question: question, questionNumber: questionNumber)
    }
    
    func yesButtonClicked() {
        guard let currentQuestion else { return }
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
    }
    
    func noButtonClicked() {
        guard let currentQuestion else { return }
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
    }
    
}
