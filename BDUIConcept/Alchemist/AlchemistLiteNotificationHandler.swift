//
//  AlchemistLiteNotificationHandler.swift
//  BDUIConcept
//
//  Created by Pablo Gonzalez on 15/10/21.
//

import Foundation

public class AlchemistLiteNotificationHandler {
    private let notificationCenter: NotificationCenter
    private let name: String
    var onNotificationReceived: ((AlchemistLiteNotification) -> Void)?

    public init(name: String,
         notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
        self.name = name
        setupObserver()
    }

    private func setupObserver() {
        notificationCenter.addObserver(self,
                                       selector: #selector(didReceiveNotification),
                                       name: NSNotification.Name(name),
                                       object: nil
        )
    }

    @objc
    private func didReceiveNotification(_ notification: Notification) {
        guard let item = notification.object as? AlchemistLiteNotification else {
            let object = notification.object as Any
            assertionFailure("Invalid object: \(object)")
            return
        }
        onNotificationReceived?(item)
    }

    func broadcastNotification(notification: AlchemistLiteNotification) {
        notificationCenter.post(name: NSNotification.Name(name), object: notification)
    }
}
