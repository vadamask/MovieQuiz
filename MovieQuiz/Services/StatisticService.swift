//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Вадим Шишков on 11.04.2023.
//

import UIKit

protocol StatisticService {
  var totalAccuracy: Double { get }
  var gamesCount: Int { get }
  var bestGame: GameRecord { get }
  func store(correct count: Int, total amount: Int)
}

final class StatisticServiceImplementation: StatisticService {
  
  private enum Keys: String {
    case correct, total, bestGame, gamesCount
  }
  
  private let userDefaults = UserDefaults.standard
  
  var totalAccuracy: Double {
    let correct = userDefaults.integer(forKey: Keys.correct.rawValue)
    let total = userDefaults.integer(forKey: Keys.total.rawValue)
    return Double(correct) / Double(total) * 100
  }
  
  var gamesCount: Int {
    get {
      userDefaults.integer(forKey: Keys.gamesCount.rawValue)
    }
    set {
      userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
    }
  }
  
  var bestGame: GameRecord {
    get {
      guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
            let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
        return .init(correct: 0, total: 0, date: Date())
      }
      return record
    }
    set {
      guard let data = try? JSONEncoder().encode(newValue) else {
        print("Невозможно сохранить результат")
        return
      }
      userDefaults.set(data, forKey: Keys.bestGame.rawValue)
    }
  }
  
  func store(correct count: Int, total amount: Int) {
    updateData(with: count, and: amount)
    
    let currentGame = GameRecord(correct: count, total: amount, date: Date())
    
    if currentGame > bestGame {
      bestGame = currentGame
    }
  }
  
  private func updateData(with correct: Int, and total: Int) {
    let oldCorrect = userDefaults.integer(forKey: Keys.correct.rawValue)
    let oldTotal = userDefaults.integer(forKey: Keys.total.rawValue)
    userDefaults.set(correct + oldCorrect, forKey: Keys.correct.rawValue)
    userDefaults.set(total + oldTotal, forKey: Keys.total.rawValue)
    let oldGamesCount = gamesCount
    gamesCount = oldGamesCount + 1
  }
}

struct GameRecord: Codable, Comparable {
  let correct: Int
  let total: Int
  let date: Date
  
  static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
    lhs.correct < rhs.correct
  }
}

