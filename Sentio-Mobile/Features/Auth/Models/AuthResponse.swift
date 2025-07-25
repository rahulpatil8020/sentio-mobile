//
//  AuthResponse.swift
//  Sentio-Mobile
//
//  Created by Rahul Patil on 7/22/25.
//

import Foundation

struct AuthResponse: Decodable {
    let success: Bool
    let message: String
    let data: AuthData

    struct AuthData: Decodable {
        let accessToken: String
        let refreshToken: String
        let user: User
    }

    struct User: Decodable, Identifiable {
        let id: String
        let name: String
        let email: String
        let profileType: String
        let createdAt: String

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case name, email, profileType, createdAt
        }
    }
}
