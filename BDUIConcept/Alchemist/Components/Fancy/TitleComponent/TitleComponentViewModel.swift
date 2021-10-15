//
//  TitleComponentViewModel.swift
//  BDUIConcept
//
//  Created by Pablo Gonzalez on 12/10/21.
//

import Foundation

class TitleComponentViewModel {
    private(set) var title: String
    private(set) var notificationHandler: AlchemistLiteEventManager
    
    var onTitleUpdated: (() -> Void)?
    
    init(content: TitleComponent.Content,
         handler: AlchemistLiteEventManager) {
        self.title = content.title
        self.notificationHandler = handler
    }
    
    func update(_ content: TitleComponent.Content) {
        title = content.title
        onTitleUpdated?()
    }
    
    func sendNotification() {
        //notificationHandler.broadcastNotification(notification: AlchemistLiteNotification(id: "123", data: ["d": 1]))
    }
}
