//
//  APIClient.swift
//  Sentio-Mobile
//
//  Created by Rahul Patil on 7/22/25.
//

import Foundation

// MARK: - API Errors
enum APIError: Error, LocalizedError {
    case invalidResponse
    case decodingError(Error)
    case serverError(String)
    case unauthorized
    case refreshFailed

    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Invalid response from server"
        case .decodingError(let err): return "Failed to decode server response: \(err.localizedDescription)"
        case .serverError(let message): return message
        case .unauthorized: return "Session expired. Please log in again."
        case .refreshFailed: return "Could not refresh session. Please log in again."
        }
    }
}

// MARK: - APIClient
final class APIClient {
    static let shared = APIClient()
    private init() {}

    private let baseURL = URL(string: Constants.baseURL)!

    /// Shared JSON decoder for all API responses
    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()

        // handle ISO8601 with fractional seconds like `2025-09-07T09:39:44.658Z`
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            if let date = isoFormatter.date(from: dateString) {
                return date
            }
            // fallback without fractional seconds
            if let date = ISO8601DateFormatter().date(from: dateString) {
                return date
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date: \(dateString)"
            )
        }

        return decoder
    }()

    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil,
        requiresAuth: Bool = false,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> T {
        // Build URL with URLComponents
        var components = URLComponents(
            url: baseURL.appendingPathComponent(endpoint),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = queryItems

        guard let url = components?.url else {
            throw APIError.invalidResponse
        }

        var urlRequest = URLRequest(url: url)
        print("➡️ Requesting:", url.absoluteString)
        urlRequest.httpMethod = method
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let timezone = TimeZone.current.identifier
        urlRequest.addValue(timezone, forHTTPHeaderField: "X-Timezone")

        if requiresAuth, let token = TokenManager.shared.accessToken {
            urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        urlRequest.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200..<300:
            do {
                let decoded = try APIClient.decoder.decode(T.self, from: data)
                return decoded
            } catch {
                throw APIError.decodingError(error)
            }

        case 401:
            if requiresAuth {
                if try await refreshAccessToken() {
                    return try await request(
                        endpoint: endpoint,
                        method: method,
                        body: body,
                        requiresAuth: requiresAuth,
                        queryItems: queryItems
                    )
                } else {
                    TokenManager.shared.clearTokens()
                    throw APIError.unauthorized
                }
            } else {
                if let serverError = try? APIClient.decoder.decode(ServerErrorResponse.self, from: data) {
                    throw APIError.serverError(serverError.error.message)
                }
                throw APIError.serverError("Unauthorized")
            }

        default:
            if let serverError = try? APIClient.decoder.decode(ServerErrorResponse.self, from: data) {
                throw APIError.serverError(serverError.error.message)
            }
            throw APIError.serverError("Unknown server error (\(httpResponse.statusCode))")
        }
    }

    // MARK: - Refresh Access Token
    private func refreshAccessToken() async throws -> Bool {
        guard let refreshToken = TokenManager.shared.refreshToken else {
            return false
        }

        var request = URLRequest(url: baseURL.appendingPathComponent("/refresh-token"))
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["refreshToken": refreshToken])

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return false
            }

            let refreshResponse = try APIClient.decoder.decode(RefreshResponse.self, from: data)
            TokenManager.shared.accessToken = refreshResponse.accessToken
            if let newRefreshToken = refreshResponse.refreshToken {
                TokenManager.shared.refreshToken = newRefreshToken
            }
            return true
        } catch {
            print("Refresh Failed", error.localizedDescription)
            return false
        }
    }
}

// MARK: - Server Error Response
struct ServerErrorResponse: Decodable, Error {
    let success: Bool
    let error: ServerErrorDetail
}

struct ServerErrorDetail: Decodable {
    let type: String
    let message: String
    let details: [String: [String]]?
}

// MARK: - Refresh Response
struct RefreshResponse: Decodable {
    let accessToken: String
    let refreshToken: String?
}
