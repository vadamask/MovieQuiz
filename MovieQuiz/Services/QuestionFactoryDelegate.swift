//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Вадим Шишков on 07.04.2023.
//

import UIKit

protocol QuestionFactoryDelegate: AnyObject {
    func didRecieveNextQuestion(question: QuizQuestion?)
}