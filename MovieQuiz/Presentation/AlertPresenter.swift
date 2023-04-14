//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Вадим Шишков on 07.04.2023.
//

import UIKit

class AlertPresenter: AlertPresenterProtocol {
    
    func showAlert(quiz result: AlertModel, on vc: UIViewController) {
        
        let alertController = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(
            title: result.buttonText,
            style: .default) { _ in
                result.completion()
            }
        
        alertController.addAction(action)
        vc.present(alertController, animated: true)
    }
}
