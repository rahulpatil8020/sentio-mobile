//
//  OnboardResponse.swift
//  Sentio-Mobile
//
//  Created by Rahul Patil on 7/25/25.
//

import Foundation

struct OnboardResponse: Decodable {
    let success: Bool
    let message: String
    let data: OnboardData

    struct OnboardData: Decodable {
        let user: User
    }

//    struct User: Decodable, Identifiable {
//        let id: String
//        let name: String
//        let email: String
//        let createdAt: String
//        let isOnboarded: Bool
//        let city: String?
//        let country: String?
//        let profession: String?
//        let goals: [String]?
//
//        enum CodingKeys: String, CodingKey {
//            case id = "_id"
//            case name, email, createdAt, isOnboarded, city, country, profession, goals
//        }
//    }
}
