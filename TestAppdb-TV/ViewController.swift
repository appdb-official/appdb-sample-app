//
//  ViewController.swift
//  TestAppdb-TV
//
//  Created by Dmitrii Coolerov on 06.05.2024.
//

import UIKit
import AppdbSDK

class ViewController: UIViewController {

    @IBOutlet var textLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        var text = ""

        let isInstalledViaAppdb = Appdb.shared.isInstalledViaAppdb()
        if isInstalledViaAppdb {
            text += "isInstalledViaAppdb: \(isInstalledViaAppdb)"

            guard case let .success(persistentCustomerIdentifier) = Appdb.shared.getPersistentCustomerIdentifier() else {
                fatalError()
            }
            text += "\npersistentCustomerIdentifier: \(persistentCustomerIdentifier)"
            guard case let .success(persistentDeviceIdentifier) = Appdb.shared.getPersistentDeviceIdentifier() else {
                fatalError()
            }
            text += "\npersistentDeviceIdentifier: \(persistentDeviceIdentifier)"
        } else {
            text += "isInstalledViaAppdb: \(isInstalledViaAppdb)"
        }

        textLabel.text = text
    }
}

