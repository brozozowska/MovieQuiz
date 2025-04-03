//
//  AlertPresenterDelegate.swift
//  MovieQuiz
//
//  Created by Сергей Розов on 02.04.2025.
//

import Foundation

protocol AlertPresenterDelegate: AnyObject {
    func presentAlert(model: AlertModel)
}
