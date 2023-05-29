//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Вадим Шишков on 06.05.2023.
//

import Foundation

final class MovieQuizPresenter {
  
  private weak var viewController: MovieQuizViewControllerProtocol?
  private var questionFactory: QuestionFactoryProtocol?
  private var alertPresenter: AlertPresenterProtocol?
  private var statisticService: StatisticService?
  private var currentQuestion: QuizQuestion?
  private let questionsAmount: Int = 10
  private var currentQuestionIndex = 0
  private var correctAnswers = 0
  
  init(viewController: MovieQuizViewControllerProtocol) {
    self.viewController = viewController
    
    alertPresenter = AlertPresenter()
    statisticService = StatisticServiceImplementation()
    questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
    questionFactory?.loadData()
    
    viewController.showActivityIndicator()
  }
  
  func convert(model: QuizQuestion) -> QuizStepViewModel {
    let questionStep = QuizStepViewModel(
      image: model.image,
      question: model.text,
      questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
    )
    return questionStep
  }
  
  private func restartGame() {
    currentQuestionIndex = 0
    correctAnswers = 0
    questionFactory?.requestNextQuestion()
  }
  
  private var isLastQuestion: Bool {
    currentQuestionIndex == questionsAmount - 1
  }
  
  private func switchToNextQuestion() {
    currentQuestionIndex += 1
  }
  
  private func answerGived(_ givenAnswer: Bool) {
    guard let currentQuestion = currentQuestion else { return }
    proceedWithAnswer(isCorrect: currentQuestion.correctAnswer == givenAnswer)
  }
  
  private func proceedWithAnswer(isCorrect: Bool) {
    viewController?.disableUserInteraction()
    viewController?.highlightImageBorder(isCorrect: isCorrect)
    viewController?.enableFeedbackGenerator(if: isCorrect)
    
    if isCorrect {
      correctAnswers += 1
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
      guard let self = self else { return }
      self.proceedToNextQuestionOrResults()
      self.viewController?.enableUserInteraction()
    }
  }
  
  private func proceedToNextQuestionOrResults() {
    if isLastQuestion {
      showResult()
    } else {
      switchToNextQuestion()
      questionFactory?.requestNextQuestion()
    }
  }
  
  private func showResult() {
    guard let viewController = viewController as? MovieQuizViewController else { return }
    
    let resultModel = AlertModel(
      title: "Этот раунд окончен!",
      message: getResultMessage(),
      buttonText: "Сыграть еще раз",
      completion: { [weak self] in
        guard let self = self else { return }
        restartGame()
      }
    )
    alertPresenter?.showAlert(quiz: resultModel, on: viewController)
  }
  
  private func getResultMessage() -> String {
    guard let statistic = statisticService else { return "" }
    
    statistic.store(correct: correctAnswers, total: questionsAmount)
    
    let result = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
    let countGames = "Количество сыгранных квизов: \(statistic.gamesCount)"
    let record = "Рекорд: \(statistic.bestGame.correct)/\(statistic.bestGame.total) (\(statistic.bestGame.date.dateTimeString))"
    let totalAccuracy = "Cредняя точность: \(String(format: "%.2f", statistic.totalAccuracy))%"
    
    let resultMessage = [result, countGames, record, totalAccuracy].joined(separator: "\n")
    return resultMessage
  }
  
  private func showNetworkError(message: String) {
    guard let viewController = viewController as? MovieQuizViewController else { return }
    
    viewController.hideActivityIndicator()
    
    let alert = AlertModel(
      title: "Ошибка",
      message: message,
      buttonText: "Попробовать еще раз",
      completion: { [weak self] in
        guard let self = self else { return }
        restartGame()
      }
    )
    alertPresenter?.showAlert(quiz: alert, on: viewController)
  }
  
  func yesButtonPressed() {
    answerGived(true)
  }
  
  func noButtonPressed() {
    answerGived(false)
  }
}

extension MovieQuizPresenter: QuestionFactoryDelegate {
  
  func didLoadDataFromServer() {
    viewController?.hideActivityIndicator()
    questionFactory?.requestNextQuestion()
  }
  
  func didFailToLoadData(with error: Error) {
    showNetworkError(message: error.localizedDescription)
  }
  
  func didRecieveErrorMessage(_ message: String) {
    guard let viewController = viewController as? MovieQuizViewController else { return }
    
    let alert = AlertModel(
      title: "Ошибка",
      message: message,
      buttonText: "Попробовать еще раз",
      completion: { [weak self] in
        guard let self = self else { return }
        viewController.showActivityIndicator()
        self.questionFactory?.loadData()
      }
    )
    alertPresenter?.showAlert(quiz: alert, on: viewController)
  }
  
  func didRecieveNextQuestion(question: QuizQuestion?) {
    guard let question = question else { return }
    currentQuestion = question
    let viewModel = convert(model: question)
    
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      self.viewController?.clearImageBorder()
      self.viewController?.show(quiz: viewModel)
    }
  }
}
