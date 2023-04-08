import UIKit

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private var indexLabel: UILabel!
    @IBOutlet private var previewImage: UIImageView!
    @IBOutlet private var questionTextLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol? = AlertPresenter()
    
    private let questionsAmount: Int = 10
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
        
    }
    
    //MARK: - Private Methods
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        
        indexLabel.text = step.questionNumber
        previewImage.image = step.image
        previewImage.layer.cornerRadius = 20
        questionTextLabel.text = step.question
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        
        blockButtons()
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        
        if isCorrect {
            previewImage.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers += 1
        } else {
            previewImage.layer.borderColor = UIColor.ypRed.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            
            guard let self = self else { return }
            self.showNextQuestionOrResults()
            self.enableButtons()
        }
    }
    
    private func showNextQuestionOrResults() {
        
        if currentQuestionIndex == questionsAmount - 1 {
            showResult()
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showResult() {
        
        let resultModel = AlertModel(
            title: "Этот раунд окончен!",
            message: "Ваш результат: \(correctAnswers)/\(questionsAmount)",
            buttonText: "Сыграть еще раз",
            completion: { [weak self] in
                guard let self = self else { return }
                self.correctAnswers = 0
                self.currentQuestionIndex = 0
                self.questionFactory?.requestNextQuestion()
            }
        )
        alertPresenter?.showAlert(quiz: resultModel, on: self)
    }
    
    private func blockButtons() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    private func enableButtons() {
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    //MARK: - Private IBActions
    
    @IBAction private func yesButtonPressed() {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = true
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer)
        
    }
    
    @IBAction private func noButtonPressed() {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = false
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer)
    }
}

extension MovieQuizViewController: QuestionFactoryDelegate {
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
        
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            
            guard let self = self else { return }
            self.previewImage.layer.borderColor = UIColor.clear.cgColor
            self.show(quiz: viewModel)
        }
    }
}


