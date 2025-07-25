import Foundation
import Security

final class TokenManager {
    static let shared = TokenManager()
    private init() {}

    private let accessTokenKey = "SentioAccessToken"
    private let refreshTokenKey = "SentioRefreshToken"

    // MARK: - Access Token
    var accessToken: String? {
        get { KeychainHelper.get(key: accessTokenKey) }
        set {
            if let token = newValue {
                KeychainHelper.set(token, key: accessTokenKey)
            } else {
                KeychainHelper.delete(key: accessTokenKey)
            }
        }
    }

    // MARK: - Refresh Token
    var refreshToken: String? {
        get { KeychainHelper.get(key: refreshTokenKey) }
        set {
            if let token = newValue {
                KeychainHelper.set(token, key: refreshTokenKey)
            } else {
                KeychainHelper.delete(key: refreshTokenKey)
            }
        }
    }

    // MARK: - Clear All Tokens
    func clearTokens() {
        KeychainHelper.delete(key: accessTokenKey)
        KeychainHelper.delete(key: refreshTokenKey)
    }
}

struct KeychainHelper {
    static func set(_ value: String, key: String) {
        guard let data = value.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        // Remove old item if exists
        SecItemDelete(query as CFDictionary)
        // Add new
        SecItemAdd(query as CFDictionary, nil)
    }

    static func get(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    static func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
