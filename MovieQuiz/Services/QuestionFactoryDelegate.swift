//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Вадим Шишков on 07.04.2023.
//

import UIKit

protocol QuestionFactoryDelegate: AnyObject {
  func didRecieveNextQuestion(question: QuizQuestion?)
  func didLoadDataFromServer()
  func didFailToLoadData(with error: Error)
  func didRecieveErrorMessage(_ message: String)
}
