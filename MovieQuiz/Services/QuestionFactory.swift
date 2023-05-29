//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Вадим Шишков on 07.04.2023.
//

import UIKit

final class QuestionFactory: QuestionFactoryProtocol {
  
  private let moviesLoader: MoviesLoading
  private weak var delegate: QuestionFactoryDelegate?
  private var movies: [MostPopularMovie] = []
  
  init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
    self.moviesLoader = moviesLoader
    self.delegate = delegate
  }
  
  func loadData() {
    moviesLoader.loadMovies { [weak self] result in
      DispatchQueue.main.async {
        guard let self = self else { return }
        
        switch result {
        case .success(let mostPopularMovies):
          if mostPopularMovies.errorMessage.isEmpty {
            self.movies = mostPopularMovies.items
            self.delegate?.didLoadDataFromServer()
          } else {
            self.delegate?.didRecieveErrorMessage(mostPopularMovies.errorMessage)
          }
        case .failure(let error):
          self.delegate?.didFailToLoadData(with: error)
        }
      }
    }
    
  }
  
  func requestNextQuestion() {
    DispatchQueue.global().async { [weak self] in
      guard let self = self else { return }
      let index = (0..<movies.count).randomElement() ?? 0
      
      guard let movie = movies[safe: index] else { return }
      
      var imageData = Data()
      
      do {
        imageData = try Data(contentsOf: movie.resizedImageURL) // не использовать так! пока для удобства
      }
      catch {
        DispatchQueue.main.async {
          self.delegate?.didFailToLoadData(with: error)
          return
        }
      }
      
      let rating = Float(movie.rating) ?? 0
      let randomQuestion = generateRandomQuestion()
      
      var correctAnswer: Bool {
        if randomQuestion.randomWord == "больше чем " {
          return rating > Float(randomQuestion.randomNumber)
        } else {
          return rating < Float(randomQuestion.randomNumber)
        }
      }
      
      let question = QuizQuestion(image: imageData, text: randomQuestion.question, correctAnswer: correctAnswer)
      
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        self.delegate?.didRecieveNextQuestion(question: question)
      }
    }
  }
  
  private func generateRandomQuestion() -> (question: String, randomNumber: Int, randomWord: String) {
    let result = "Рейтинг этого фильма "
    
    guard let randomNumber = (7...9).randomElement(),
          let randomWord = ["больше чем ", "меньше чем "].randomElement() else {
      return ("Ошибка генерации вопроса", 0, "")
    }
    
    return (result + randomWord + String(randomNumber) + "?", randomNumber, randomWord)
  }
}
