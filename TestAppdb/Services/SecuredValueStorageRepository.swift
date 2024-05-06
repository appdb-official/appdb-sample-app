//
//  SecuredValueStorageRepository.swift
//  TestAppdb
//
//  Created by Dmitrii Coolerov on 17.04.2024.
//

import UIKit
import Foundation

public enum SecuredValueStorageRepositoryError: Error {
    case noRandomString
}

final class SecuredValueStorageRepository {
    private let keychainService = KeychainService()

    private let fileQueue = DispatchQueue(label: "SecKeyValSyncQueue")

    private var cachedRandomString: String?

    private func generateRandomStringFile() -> Result<Void, Error> {
        do {
            let documentDirectory = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first
            let directory = documentDirectory!
            let pathWithFileName = directory.appendingPathComponent("sessionData.val")
            let randomString = UUID().uuidString + "$" + UIDevice.current.identifierForVendor!.uuidString
            let data = randomString.data(using: .utf8)!
            try data.write(
                to: pathWithFileName,
                options: [
                    .atomic,
                    .completeFileProtectionUntilFirstUserAuthentication,
                ]
            )
            return .success(())
        } catch {
            debugPrint(error)
            return .failure(error)
        }
    }

    private func getRandomString() -> Result<String, Error> {
        do {
            let documentDirectory = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first
            let directory = documentDirectory!
            let pathWithFileName = directory.appendingPathComponent("sessionData.val")
            let value = try String(contentsOf: pathWithFileName, encoding: .utf8)
            return .success(value)
        } catch {
            debugPrint(error)
            return .failure(error)
        }
    }

    private func isRandomStringFileExists() -> Result<Bool, Error> {
        let documentDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first
        let directory = documentDirectory!
        let pathWithFileName = directory.appendingPathComponent("sessionData.val", isDirectory: false)
        let value = FileManager.default.fileExists(atPath: pathWithFileName.path(percentEncoded: true))
        return .success(value)
    }

    private func getCachedString() {
        fileQueue.sync {
            if cachedRandomString != nil {
                return
            }
            switch isRandomStringFileExists() {
            case let .success(value):
                if !value {
                    switch generateRandomStringFile() {
                    case .success:
                        break

                    case .failure:
                        // TODO: Fallback?
                        break
                    }
                }
                let randomString = getRandomString()
                switch randomString {
                case let .success(success):
                    cachedRandomString = success

                case .failure:
                    // TODO: Fallback?
                    break
                }

            case .failure:
                // TODO: Fallback?
                break
            }
        }
    }
}

extension SecuredValueStorageRepository {
    func setDeveloperInformationShowed() {
        getCachedString()
        guard let cachedRandomString else { return }

        do {
            let val = String(true)
            try keychainService.saveItem(val, withService: "developerInformationShowed", account: cachedRandomString)
        } catch {
            debugPrint(error)
        }
    }

    func isDeveloperInformationShowed() throws -> Bool {
        getCachedString()
        guard let cachedRandomString else { throw SecuredValueStorageRepositoryError.noRandomString }

        let storedIdentifier = try keychainService.readItem(withService: "developerInformationShowed", account: cachedRandomString)
        return Bool(storedIdentifier)!
    }
}
