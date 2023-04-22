//
//  MostPopularMovies.swift
//  MovieQuiz
//
//  Created by Вадим Шишков on 22.04.2023.
//

import Foundation
 
struct MostPopularMovies: Decodable {
    let errorMessage: String
    let items: [MostPopularMovie]
}

struct MostPopularMovie: Decodable {
    let title: String
    let rating: String
    let imageURL: URL
    
    private enum CodingKeys: String, CodingKey {
        case title = "fullTitle"
        case rating = "imDbRating"
        case imageURL = "image"
    }
}
