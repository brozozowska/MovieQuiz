//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Сергей Розов on 01.04.2025.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestionModel?)
}
