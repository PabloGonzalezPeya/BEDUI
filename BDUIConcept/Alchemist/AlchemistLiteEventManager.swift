//
//  AlchemistLiteEventManager.swift
//  BDUIConcept
//
//  Created by Pablo Gonzalez on 15/10/21.
//

import Foundation

class AlchemistLiteEventManager {
    let notificationHandler: AlchemistLiteNotificationHandler
    var eventConfiguration: AlchemistLiteEventConfiguration?
    var trackingEvents: [AlchemistLiteTrackingEvent]?
    var actions: [AlchemistLiteAction]?

    var onNotificationReceived: ((AlchemistLiteNotification) -> Void)?

    init(notificationHandler: AlchemistLiteNotificationHandler,
        eventConfiguration: AlchemistLiteEventConfiguration?,
         trackingEvents: [AlchemistLiteTrackingEvent]?,
         actions: [AlchemistLiteAction]?) {
        self.notificationHandler = notificationHandler
        self.eventConfiguration = eventConfiguration
        self.trackingEvents = trackingEvents
        self.actions = actions
        notificationHandler.onNotificationReceived = { [weak self] notification in
            self?.onNotificationReceived?(notification)
        }
    }

    func update(eventConfiguration: AlchemistLiteEventConfiguration?,
                trackingEvents: [AlchemistLiteTrackingEvent]?,
                actions: [AlchemistLiteAction]?) {
        self.eventConfiguration = eventConfiguration
        self.trackingEvents = trackingEvents
        self.actions = actions
    }

    func triggerEvent(trigger: AlchemistLiteTrigger, forId identifier: Int) {
        // TODO: Add tracking instance
        if let trackingEvents = trackingEvents,
           let event = trackingEvents.filter({$0.trigger == trigger && $0.targetId == identifier}).first {
            print("Tracking Event \(event)")
        }

        if let eventConfig = eventConfiguration,
           let events = eventConfig.events,
           let event = events.filter({$0.targetId == identifier && $0.trigger == trigger}).first {
            notificationHandler.broadcastNotification(notification: AlchemistLiteNotification(id: event.eventType,
                                                                                              data: event.eventBody))
        }

        // TODO: Handle Actions
        if let actions = actions,
           let action = actions.filter({$0.trigger == trigger && $0.targetId == identifier}).first {
            print("Executing action \(action)")
        }
    }
}
