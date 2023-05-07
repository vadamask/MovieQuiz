//
//  MovieQuizPresenterTests.swift
//  MovieQuizTests
//
//  Created by Вадим Шишков on 06.05.2023.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func enableUserInteraction() {}
    func disableUserInteraction() {}
    func show(quiz step: MovieQuiz.QuizStepViewModel) {}
    func showActivityIndicator() {}
    func hideActivityIndicator() {}
    func highlightImageBorder(isCorrect: Bool) {}
    func clearImageBorder() {}
}

final class MovieQuizPresenterTests: XCTestCase {
    
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let presenter = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Test", correctAnswer: true)
        let viewModel = presenter.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Test")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
