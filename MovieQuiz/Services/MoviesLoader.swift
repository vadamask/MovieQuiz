//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Вадим Шишков on 22.04.2023.
//

import Foundation

protocol MoviesLoading {
  func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
  private let networkClient: NetworkRouting
  
  init(networkClient: NetworkRouting = NetworkClient()) {
    self.networkClient = networkClient
  }
  
  private var mostPopularMoviesURL: URL {
    guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/k_ai2ip5pa") else {
      preconditionFailure("Unable to construct mostPopularMoviesUrl")
    }
    return url
  }
  
  func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
    networkClient.fetch(url: mostPopularMoviesURL) { result in
      
      switch result {
      case .success(let data):
        do {
          let movies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
          handler(.success(movies))
        }
        catch {
          handler(.failure(error))
        }
      case .failure(let error):
        handler(.failure(error))
        return
      }
    }
  }
  
  
}
