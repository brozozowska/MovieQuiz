//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Сергей Розов on 02.04.2025.
//

import Foundation

// модель для результатов раунда квиза
struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: (() -> Void)?
}
