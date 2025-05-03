//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Сергей Розов on 30.04.2025.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    // MARK: - Private Properties
    private let questionsAmount = 10
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var currentQuestion: QuizQuestionModel?
    private var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticServiceProtocol
    private weak var viewController: MovieQuizViewController?

    // MARK: - Initializers
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        statisticService = StatisticService()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didLoadDataFromServer() {
        performOnMain { $0.viewController?.hideLoadingIndicator() }
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        performOnMain { $0.viewController?.hideLoadingIndicator() }
        handleNetworkError(error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestionModel?) {
        guard let question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        performOnMain { $0.viewController?.show(stepModel: viewModel) }
    }
    
    // MARK: - Public Methods
    func yesButtonClicked() {
        proceedWithAnswer(isCorrect: true)
        performOnMain { $0.viewController?.disableButtons() }
    }
    
    func noButtonClicked() {
        proceedWithAnswer(isCorrect: false)
        performOnMain { $0.viewController?.disableButtons() }
    }
    
    // MARK: - Private Methods
    private func performOnMain(_ action: @escaping (MovieQuizPresenter) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            action(self)
        }
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func convert(model: QuizQuestionModel) -> QuizStepModel {
        let image = UIImage(data: model.image) ?? UIImage()
        let question = model.text
        let questionNumber = "\(currentQuestionIndex + 1)/\(questionsAmount)"
        return QuizStepModel(
            image: image,
            question: question,
            questionNumber: questionNumber
        )
    }
    
    private func didAnswer(isCorrectAnswer: Bool) {
        guard let currentQuestion else { return }
        if isCorrectAnswer == currentQuestion.correctAnswer {
            correctAnswers += 1
        }
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        performOnMain { $0.viewController?.highlightImageBorder(isCorrectAnswer: isCorrect) }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            proceedToNextQuestionOrResults()
            viewController?.resetImageBorder()
            viewController?.enableButtons()
        }
    }

    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let bestGame = statisticService.bestGame
            let totalAccuracy = String(format: "%.2f", statisticService.totalAccuracy)
            let title = "Этот раунд окончен!"
            let text = """
                Ваш результат: \(correctAnswers)/\(questionsAmount)
                Количество сыгранных квизов: \(statisticService.gamesCount)
                Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
                Средняя точность: \(totalAccuracy)%
                """
            let buttonText = "Сыграть ещё раз"
            let model = AlertModel(
                title: title,
                message: text,
                buttonText: buttonText,
                completion: { [weak self] in
                    guard let self else { return }
                    restartGame()
                }
            )
            performOnMain { $0.viewController?.show(alertModel: model) }
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func handleNetworkError(_ message: String) {
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion: { [weak self] in
                guard let self else { return }
                restartGame()
            }
        )
        performOnMain { $0.viewController?.show(alertModel: model) }
    }
}
