//
//  QuizQuestion.swift
//  Peblo-Challenge
//
//  Created by Sadiq Jatu on 14/06/26.
//

import Foundation

struct QuizQuestion: Decodable {
    let question: String
    let options: [String]
    let answer: String
}
