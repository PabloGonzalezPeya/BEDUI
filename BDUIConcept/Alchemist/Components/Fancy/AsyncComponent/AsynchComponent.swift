//
//  AsyncComponent.swift
//  BDUIConcept
//
//  Created by Pablo Gonzalez on 18/10/21.
//

import Foundation
import UIKit

class AsynchComponent: AlchemistLiteComponentable {
    private(set) static var componentType = "asyncDummy"

    private(set) var id: String
    private(set) var type: String
    private(set) var currentView: UIView?
    private(set) var eventManager: AlchemistLiteEventManager

    private(set) var content: Void

    required init(config: AlchemistLiteUIComponentConfiguration) throws {
        self.id = config.componentId
        self.type = config.componentType
        self.eventManager = config.getEventManager()
        self.content = ()
    }

    func getView() -> UIView {
        if let viewtoReturn = currentView {
            return viewtoReturn
        }
        let view = AsyncComponentView()
        currentView = view
        return view
    }

    func updateView(component: BEComponent) {
        self.eventManager.update(eventConfiguration: component.eventConfiguration,
                                 trackingEvents: component.trackingEvents,
                                 actions: component.actions)
        // Trigger update?
    }
}

