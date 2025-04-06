//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Сергей Розов on 02.04.2025.
//

import Foundation

final class AlertPresenter {
    weak var delegate: AlertPresenterDelegate?
    
    init(delegate: AlertPresenterDelegate) {
        self.delegate = delegate
    }
    
    func showAlert(title: String, message: String, buttonText: String, completion: (() -> Void)?) {
        let alertModel = AlertModel(title: title, message: message, buttonText: buttonText, completion: completion)
        delegate?.presentAlert(model: alertModel)
    }
}
