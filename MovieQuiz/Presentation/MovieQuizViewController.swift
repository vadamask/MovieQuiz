import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var previewImage: UIImageView!
    @IBOutlet private weak var questionTextLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = MovieQuizPresenter(viewController: self)
        activityIndicator.hidesWhenStopped = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    func show(quiz step: QuizStepViewModel) {
        indexLabel.text = step.questionNumber
        previewImage.image = step.image
        previewImage.layer.cornerRadius = 20
        questionTextLabel.text = step.question
    }
    
    func showActivityIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func highlightImageBorder(isCorrect: Bool) {
        
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        
        if isCorrect {
            previewImage.layer.borderColor = UIColor.ypGreen.cgColor
        } else {
            previewImage.layer.borderColor = UIColor.ypRed.cgColor
        }
    }
    
    func clearImageBorder() {
        previewImage.layer.borderColor = UIColor.clear.cgColor
    }
    
    func enableUserInteraction() {
        view.isUserInteractionEnabled = true
    }
    
    func disableUserInteraction() {
        view.isUserInteractionEnabled = false
    }
    
    @IBAction private func yesButtonPressed() {
        presenter.yesButtonPressed()
    }
    
    @IBAction private func noButtonPressed() {
        presenter.noButtonPressed()
    }
}



