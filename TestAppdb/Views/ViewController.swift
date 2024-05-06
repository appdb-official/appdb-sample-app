//
//  ViewController.swift
//  TestAppdb
//
//  Created by Dmitrii Coolerov on 19.03.2024.
//

import UIKit
import AppdbSDK
import CryptoKit

class ViewController: UIViewController {

    private let securedValueStorageRepository: SecuredValueStorageRepository

    required init?(coder: NSCoder) {
        self.securedValueStorageRepository = SecuredValueStorageRepository()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self else { return }
            
            let showBlock: () -> Void = { [weak self] in
                guard let self else { return }

                let developerInformation = Appdb.shared.showDeveloperInformation()
                switch developerInformation {
                case .success:
                    self.securedValueStorageRepository.setDeveloperInformationShowed()

                case .failure(let error):
                    self.showAlert(
                        title: "showDeveloperInformation",
                        message: error.localizedDescription,
                        completion: {}
                    )
                }
            }

            do {
                if try !self.securedValueStorageRepository.isDeveloperInformationShowed() {
                    showBlock()
                }
            } catch let error as KeychainService.KeychainError {
                if case .noItem = error {
                    showBlock()
                }
                debugPrint(error)
            } catch {
                debugPrint(error)
            }
        }
    }

    @IBAction private func isInstalledViaAppdb() {
        let isInstalledViaAppdb = Appdb.shared.isInstalledViaAppdb()
        showAlert(
            title: "isInstalledViaAppdb",
            message: isInstalledViaAppdb ? "True" : "False",
            completion: {}
        )
    }

    @IBAction private func getPersistentCustomerIdentifier() {
        let persistentCustomerIdentifier = Appdb.shared.getPersistentCustomerIdentifier()
        switch persistentCustomerIdentifier {
        case let .success(value):
            showAlert(
                title: "getPersistentCustomerIdentifier",
                message: value,
                completion: {}
            )

        case let .failure(error):
            showAlert(
                title: "getPersistentCustomerIdentifier",
                message: error.localizedDescription,
                completion: {}
            )
        }
    }

    @IBAction private func getPersistentDeviceIdentifier() {
        let persistentDeviceIdentifier = Appdb.shared.getPersistentDeviceIdentifier()
        switch persistentDeviceIdentifier {
        case let .success(value):
            showAlert(
                title: "getPersistentDeviceIdentifier",
                message: value,
                completion: {}
            )

        case let .failure(error):
            showAlert(
                title: "getPersistentDeviceIdentifier",
                message: error.localizedDescription,
                completion: {}
            )
        }
    }

    @IBAction private func getAppleBundleIdentifier() {
        let appleBundleIdentifier = Appdb.shared.getAppleBundleIdentifier()
        switch appleBundleIdentifier {
        case let .success(value):
            showAlert(
                title: "getAppleBundleIdentifier",
                message: value,
                completion: {}
            )

        case let .failure(error):
            showAlert(
                title: "getAppleBundleIdentifier",
                message: error.localizedDescription,
                completion: {}
            )
        }
    }

    @IBAction private func getAppleAppGroupIdentifier() {
        let appleAppGroupIdentifier = Appdb.shared.getAppleAppGroupIdentifier()
        switch appleAppGroupIdentifier {
        case let .success(value):
            showAlert(
                title: "getAppleAppGroupIdentifier",
                message: value,
                completion: {}
            )

        case let .failure(error):
            showAlert(
                title: "getAppleAppGroupIdentifier",
                message: error.localizedDescription,
                completion: {}
            )
        }
    }

    @IBAction private func getAppdbAppIdentifier() {
        let appdbAppIdentifier = Appdb.shared.getAppdbAppIdentifier()
        switch appdbAppIdentifier {
        case let .success(value):
            showAlert(
                title: "getAppdbAppIdentifier",
                message: value,
                completion: {}
            )

        case let .failure(error):
            showAlert(
                title: "getAppdbAppIdentifier",
                message: error.localizedDescription,
                completion: {}
            )
        }
    }

    @IBAction private func getAlongsideIdentifier() {
        let alongsideIdentifier = Appdb.shared.getAlongsideIdentifier()
        switch alongsideIdentifier {
        case let .success(value):
            showAlert(
                title: "getAlongsideIdentifier",
                message: value,
                completion: {}
            )

        case let .failure(error):
            showAlert(
                title: "getAlongsideIdentifier",
                message: error.localizedDescription,
                completion: {}
            )
        }
    }

    @IBAction private func getInstallationUUID() {
        let installationUUID = Appdb.shared.getInstallationUUID()
        switch installationUUID {
        case let .success(value):
            showAlert(
                title: "getInstallationUUID",
                message: value,
                completion: {}
            )

        case let .failure(error):
            showAlert(
                title: "getInstallationUUID",
                message: error.localizedDescription,
                completion: {}
            )
        }
    }

    @IBAction private func getSupportedServicesIdentifiers() {
        let supportedServicesIdentifiers = Appdb.shared.getSupportedServicesIdentifiers()
        switch supportedServicesIdentifiers {
        case let .success(value):
            showAlert(
                title: "supportedServicesIdentifiers",
                message: value.joined(separator: ", "),
                completion: {}
            )

        case let .failure(error):
            showAlert(
                title: "supportedServicesIdentifiers",
                message: error.localizedDescription,
                completion: {}
            )
        }
    }

    @IBAction private func askCustomerToEnableOpenIn() {
        let result = Appdb.shared.askCustomerToEnableOpenIn()
        switch result {
        case .success:
            break

        case let .failure(error):
            DispatchQueue.main.async { [unowned self] in
                self.showAlert(
                    title: "askCustomerToEnableOpenIn",
                    message: error.localizedDescription,
                    completion: {}
                )
            }
        }
    }

    @IBAction private func registerPushNotifications() {
        UIApplication.shared.registerForRemoteNotifications()

        UNUserNotificationCenter.current()
            .requestAuthorization(
                options: [.alert, .sound, .badge]
            ) { [weak self] granted, _ in
                print("Permission granted: \(granted)")
                DispatchQueue.main.async { [unowned self] in
                    self?.showAlert(
                        title: "registerPushNotifications",
                        message: granted ? "Permission granted" : "Permission NOT granted",
                        completion: {}
                    )
                }
            }
    }

    @IBAction private func validateAppAttest() {
        let randomWords = self.generateRandomWords()
        let clientData = randomWords.data(using: .utf8)!

        Appdb.shared.generateDataAssertion(
            clientData: clientData
        ) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                switch result {
                case let .success(value):
                    let pasteboard = UIPasteboard.general
                    pasteboard.string = randomWords
                    self.showAlert(
                        title: "validateAppAttest",
                        message: "(copied to clipboard) \(randomWords)",
                        completion: { [weak self] in
                            guard let self else { return }


                            let pasteboard = UIPasteboard.general
                            pasteboard.string = value
                            self.showAlert(
                                title: "validateAppAttest",
                                message: "(copied to clipboard) \(value)",
                                completion: {}
                            )
                        }
                    )

                case let .failure(error):
                    self.showAlert(
                        title: "validateAppAttest",
                        message: error.localizedDescription,
                        completion: {}
                    )
                }
            }
        }
    }

    @IBAction private func appAttest() {
        let challenge = "qwerty"
        Appdb.shared.registerAppAttestation(
            challenge: challenge
        ) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                switch result {
                case .success:
                    self.showAlert(
                        title: "appAttest",
                        message: "valid",
                        completion: {}
                    )

                case let .failure(error):
                    self.showAlert(
                        title: "appAttest",
                        message: error.localizedDescription,
                        completion: {}
                    )
                }
            }
        }
    }

    @IBAction private func isAppUpdateAvailable() {
        Appdb.shared.isAppUpdateAvailable { [weak self] result in
            switch result {
            case let .success(value):
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    if value {
                        self.showAlert(
                            title: "isAppUpdateAvailable",
                            message: String(value),
                            completion: { [weak self] in
                                guard self != nil else { return }
                                if case let .success(value) = Appdb.shared.getAppdbStoreURL() {
                                    UIApplication.shared.open(value)
                                }
                            }
                        )
                    } else {
                        self.showAlert(
                            title: "isAppUpdateAvailable",
                            message: String(value),
                            completion: {}
                        )
                    }
                }

            case let .failure(error):
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.showAlert(
                        title: "isAppUpdateAvailable",
                        message: error.localizedDescription,
                        completion: {}
                    )
                }
            }
        }
    }

    @IBAction private func backupData() {
        guard let hash = generateBackupKey() else {
            showAlert(
                title: "backupData",
                message: "Hash unavailiable",
                completion: {}
            )
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium

        let value: [String: Any] = [
            "random_string": generateRandomWords(),
            "backup_date": dateFormatter.string(from: Date.now)
        ]
        showAlert(
            title: "backupData",
            message: "Backuped data: \(value)"
        ) {
            Appdb.shared.storeBackup(
                backupIDKey: hash,
                value: value
            ) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success:
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        showAlert(
                            title: "backupData",
                            message: "(\(hash)) now you can reinstall this app and then use \"restore backup\" button to restore backup.",
                            completion: {}
                        )
                    }

                case .failure(let error):
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        showAlert(
                            title: "backupData",
                            message: error.localizedDescription,
                            completion: {}
                        )
                    }
                }
            }
        }
    }

    @IBAction private func restoreBackup() {
        guard let hash = generateBackupKey() else {
            showAlert(
                title: "restoreBackup",
                message: "Hash unavailiable",
                completion: {}
            )
            return
        }

        Appdb.shared.getBackup(
            backupIDKey: hash
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let value):
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    showAlert(
                        title: "restoreBackup",
                        message: "(\(hash)) Restored: \(value)",
                        completion: {}
                    )
                }

            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    showAlert(
                        title: "restoreBackup",
                        message: error.localizedDescription,
                        completion: {}
                    )
                }
            }
        }
    }

    @IBAction private func purgeBackup() {
        guard let hash = generateBackupKey() else {
            showAlert(
                title: "purgeBackup",
                message: "Hash unavailiable",
                completion: {}
            )
            return
        }

        Appdb.shared.purgeBackup(
            backupIDKey: hash
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    showAlert(
                        title: "purgeBackup",
                        message: "(\(hash)) Purged",
                        completion: {}
                    )
                }

            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    showAlert(
                        title: "purgeBackup",
                        message: error.localizedDescription,
                        completion: {}
                    )
                }
            }
        }
    }

    private func generateRandomWords() -> String {
        let sentence = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        let words = sentence.components(separatedBy: " ")
        var randomWords: [String] = []
        for _ in 0..<10 {
            let index: Int = Int(arc4random_uniform(UInt32(words.count - 1)))
            randomWords.append(words[index])
        }
        return randomWords.joined(separator: " ")
    }

    private func showAlert(
        title: String,
        message: String,
        completion: @escaping () -> Void
    ) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(.init(title: "Okay", style: .default, handler: { _ in
            completion()
        }))
        present(alertVC, animated: true)
    }

    private func generateBackupKey() -> String? {
        let salt = "lorem ipsum"
        
        guard case let .success(userID) = Appdb.shared.getPersistentCustomerIdentifier() else {
            return nil
        }
        guard case let .success(deviceID) = Appdb.shared.getPersistentDeviceIdentifier() else {
            return nil
        }

        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"]! as! String
        let value = "\(salt)+\(userID)+\(deviceID)+\(appVersion)"
        let hashed = SHA256.hash(data: Data(value.utf8))
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }

    @IBAction private func getPushNotification() {
        showAlert(
            title: "getPushNotification",
            message: "You may close this app, push will arrive in 10 seconds",
            completion: {}
        )

        sendPushNotificationRequest { [weak self] result in
            guard let self else { return }
            if case let .failure(error) = result {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    showAlert(
                        title: "getPushNotification",
                        message: error.localizedDescription,
                        completion: {}
                    )
                }
            }
        }
    }

    private func sendPushNotificationRequest(completion: @escaping (Result<Void, Error>) -> Void) {
        let customerID = Appdb.shared.getPersistentCustomerIdentifier()
        switch customerID {
        case .success(let value):
            let url = URL(string: "https://dbservices.to/delayed_push_for_sample_app/?customer_id=\(value)")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                if let error {
                    debugPrint(error)
                    completion(.failure(error))
                    return
                }
                completion(.success(()))
                return
            }
            task.resume()

        case .failure(let error):
            completion(.failure(error))
        }
    }

    @IBAction private func getDeveloperInformation() {
        let developerInformation = Appdb.shared.getDeveloperInformation()
        switch developerInformation {
        case .success(let value):
            showAlert(
                title: "getDeveloperInformation",
                message: "\(value)",
                completion: {}
            )

        case .failure(let error):
            showAlert(
                title: "getDeveloperInformation",
                message: error.localizedDescription,
                completion: {}
            )
        }
    }

    @IBAction private func showDeveloperInformation() {
        let developerInformation = Appdb.shared.showDeveloperInformation()
        switch developerInformation {
        case .success:
            break

        case .failure(let error):
            showAlert(
                title: "showDeveloperInformation",
                message: error.localizedDescription,
                completion: {}
            )
        }
    }
}

