import UIKit

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private var indexLabel: UILabel!
    @IBOutlet private var previewImage: UIImageView!
    @IBOutlet private var questionTextLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    
    
    private let questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    
    private let questionsAmount: Int = 10
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showCurrentQuestion()
    }
    
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
        previewImage.layer.borderColor = UIColor.clear.cgColor
        
        if currentQuestionIndex == questionsAmount - 1 {
            let resultModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/\(questionsAmount)",
                buttonText: "Сыграть еще раз"
            )
            
            show(quiz: resultModel)
            
        } else {
            currentQuestionIndex += 1
            showCurrentQuestion()
        }
    }
    
    private func showCurrentQuestion() {
        if let firstQuestion = questionFactory.requestNextQuestion() {
            currentQuestion = firstQuestion
            let viewModel = convert(model: firstQuestion)
            show(quiz: viewModel)
        }
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alertController = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(
            title: result.buttonText,
            style: .default) { [weak self] _ in
                
                guard let self = self else { return }
                self.correctAnswers = 0
                self.currentQuestionIndex = 0
                
                if let firstQuestion = questionFactory.requestNextQuestion() {
                    currentQuestion = firstQuestion
                    let viewModel = convert(model: firstQuestion)
                    show(quiz: viewModel)
                }
            }
        
        alertController.addAction(action)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func blockButtons() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    private func enableButtons() {
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    
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

