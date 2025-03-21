//
//  QuizQuestionModel.swift
//  MovieQuiz
//
//  Created by Сергей Розов on 20.03.2025.
//

import UIKit

// модель для структуры вопроса
struct QuizQuestionModel {
    // строка с названием фильма, совпадает с названием картинки афиши фильма в Assets
    let image: String
    // строка с вопросом о рейтинге фильма
    let text: String
    // булевое значение, правильный ответ на вопрос
    let correctAnswer: Bool
}
