//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Вадим Шишков on 06.05.2023.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showActivityIndicator()
    func hideActivityIndicator()
    func highlightImageBorder(isCorrect: Bool)
    func clearImageBorder()
    func enableUserInteraction()
    func disableUserInteraction()
}
