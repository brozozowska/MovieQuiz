//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Сергей Розов on 03.05.2025.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func disableButtons()
    func enableButtons()
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func resetImageBorder()
    func show(stepModel: QuizStepModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func show(alertModel: AlertModel)
}
