import Foundation

struct KeychainService {
    // MARK: Types

    enum KeychainError: Error, LocalizedError {
        case noItem
        case unexpectedData
        case unhandledError

        var errorDescription: String? {
            switch self {
            case .noItem:
                return "No item"

            case .unexpectedData:
                return "Unexpected data"

            case .unhandledError:
                return "Unhandled error"
            }
        }
    }

    // MARK: Keychain access

    func readItem(
        withService service: String,
        account: String,
        accessGroup: String? = nil
    ) throws -> String {
        /*
         Build a query to find the item that matches the service, account and
         access group.
         */
        var query = keychainQuery(withService: service, account: account, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue

        // Try to fetch the existing keychain item that matches the query.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        // Check the return status and throw an error if appropriate.
        guard status != errSecItemNotFound else { throw KeychainError.noItem }
        guard status == noErr else { throw KeychainError.unhandledError }

        // Parse the password string from the query result.
        guard let existingItem = queryResult as? [String: AnyObject],
              let passwordData = existingItem[kSecValueData as String] as? Data,
              let password = String(data: passwordData, encoding: String.Encoding.utf8)
        else {
            throw KeychainError.unexpectedData
        }

        return password
    }

    func saveItem(
        _ password: String,
        withService service: String,
        account: String,
        accessGroup: String? = nil
    ) throws {
        // Encode the password into an Data object.
        let encodedPassword = password.data(using: String.Encoding.utf8)!

        do {
            // Check for an existing item in the keychain.
            try _ = readItem(withService: service, account: account, accessGroup: accessGroup)

            // Update the existing item with the new password.
            var attributesToUpdate = [String: AnyObject]()
            attributesToUpdate[kSecValueData as String] = encodedPassword as AnyObject?

            let query = keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)

            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandledError }
        } catch KeychainError.noItem {
            /*
             No password was found in the keychain. Create a dictionary to save
             as a new keychain item.
             */
            var newItem = keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            newItem[kSecValueData as String] = encodedPassword as AnyObject?

            // Add a the new item to the keychain.
            let status = SecItemAdd(newItem as CFDictionary, nil)

            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandledError }
        }
    }

    func deleteItem(
        withService service: String,
        account: String,
        accessGroup: String? = nil
    ) throws {
        // Delete the existing item from the keychain.
        let query = keychainQuery(withService: service, account: account, accessGroup: accessGroup)
        let status = SecItemDelete(query as CFDictionary)

        // Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError }
    }

    // MARK: Convenience

    private func keychainQuery(
        withService service: String,
        account: String,
        accessGroup: String? = nil
    ) -> [String: AnyObject] {
        var query = [String: AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service as AnyObject?
        query[kSecAttrAccount as String] = account as AnyObject?

        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }

        return query
    }
}
