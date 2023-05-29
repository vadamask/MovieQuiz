//
//  AlertPresenterProtocol.swift
//  MovieQuiz
//
//  Created by Вадим Шишков on 08.04.2023.
//

import UIKit

protocol AlertPresenterProtocol {
  func showAlert(quiz result: AlertModel, on vc: UIViewController)
}
