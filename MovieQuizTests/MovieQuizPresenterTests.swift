//
//  MovieQuizPresenterTests.swift
//  MovieQuizTests
//
//  Created by Сергей Розов on 03.05.2025.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func disableButtons() { }
    func enableButtons() {  }
    func showLoadingIndicator() { }
    func hideLoadingIndicator() { }
    func resetImageBorder() { }
    func show(stepModel: QuizStepModel) { }
    func highlightImageBorder(isCorrectAnswer: Bool) { }
    func show(alertModel: AlertModel) { }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        // Given
        let viewControllerMock = MovieQuizViewControllerMock()
        let presenter = MovieQuizPresenter(viewController: viewControllerMock)
        let emptyData = Data()
        let question = QuizQuestionModel(
            image: emptyData,
            text: "Question Text",
            correctAnswer: true
        )
        
        // When
        let viewModel = presenter.convert(model: question)
        
        // Then
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
