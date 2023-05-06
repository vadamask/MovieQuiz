import UIKit

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var previewImage: UIImageView!
    @IBOutlet private weak var questionTextLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private let presenter = MovieQuizPresenter()
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticService?
    
    private var correctAnswers = 0
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        alertPresenter = AlertPresenter()
        statisticService = StatisticServiceImplementation()
        activityIndicator.hidesWhenStopped = true
        
        questionFactory?.loadData()
        activityIndicator.startAnimating()
    }
    
    
    
    private func showNetworkError(message: String) {
        activityIndicator.stopAnimating()
        
        let alert = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз",
            completion: { [weak self] in
                guard let self = self else { return }
                self.correctAnswers = 0
                self.presenter.resetQuestionIndex()
                self.questionFactory?.requestNextQuestion()
            }
        )
        alertPresenter?.showAlert(quiz: alert, on: self)
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
        
        let feedbackGenertor = UINotificationFeedbackGenerator()
        
        if isCorrect {
            feedbackGenertor.notificationOccurred(.success)
            previewImage.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers += 1
        } else {
            feedbackGenertor.notificationOccurred(.error)
            previewImage.layer.borderColor = UIColor.ypRed.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            
            guard let self = self else { return }
            self.showNextQuestionOrResults()
            self.enableButtons()
        }
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            showResult()
        } else {
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showResult() {
        guard let statistic = statisticService else {
            print("Сервис статистики не доступен")
            return
        }
        
        statistic.store(correct: correctAnswers, total: presenter.questionsAmount)
        
        let resultModel = AlertModel(
            title: "Этот раунд окончен!",
            message: """
                        Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
                        Количество сыгранных квизов: \(statistic.gamesCount)
                        Рекорд: \(statistic.bestGame.correct)/\(statistic.bestGame.total) (\(statistic.bestGame.date.dateTimeString))
                        Cредняя точность: \(String(format: "%.2f", statistic.totalAccuracy))%
                     """,
            buttonText: "Сыграть еще раз",
            completion: { [weak self] in
                guard let self = self else { return }
                self.correctAnswers = 0
                self.presenter.resetQuestionIndex()
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
    
    private func answerGived(_ givenAnswer: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer)
    }
    
    @IBAction private func yesButtonPressed() {
        answerGived(true)
    }
    
    @IBAction private func noButtonPressed() {
        answerGived(false)
    }
}

extension MovieQuizViewController: QuestionFactoryDelegate {
    
    func didRecieveErrorMessage(_ message: String) {
        let alert = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз",
            completion: { [weak self] in
                guard let self = self else { return }
                self.activityIndicator.startAnimating()
                self.questionFactory?.loadData()
            }
        )
        alertPresenter?.showAlert(quiz: alert, on: self)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.stopAnimating()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.previewImage.layer.borderColor = UIColor.clear.cgColor
            self.show(quiz: viewModel)
        }
    }
}


