//
//  MultiLineTextComponent.swift
//  BDUIConcept
//
//  Created by Pablo Gonzalez on 12/10/21.
//

import Foundation
import UIKit

class MultiLineTextComponent: AlchemistLiteUIComponent {
    private(set) static var componentType = "multilineText"
    
    var id: String
    var type: String
    
    private(set) var content: Content
    private(set) var eventManager: AlchemistLiteEventManager
    private var currentView: MultiLineTextComponentView?
    
    required init(config: AlchemistLiteUIComponentConfiguration) throws {
        self.id = config.componentId
        self.type = config.componentType
        self.content = try config.parseContent()
        self.eventManager = config.getEventManager()
    }
    
    func getView() -> UIView {
        if let viewtoReturn = currentView {
            return viewtoReturn
        }
        let view = MultiLineTextComponentView(viewModel: content, handler: eventManager)
        currentView = view
        return view
    }
    
    func updateView(component: BEComponent) {
        guard let data = component.content else { return }
        guard let updatedContent = try? JSONDecoder().decode(Content.self, from: data),
        updatedContent != self.content else {
            print("No changes for \(MultiLineTextComponent.componentType)")
            return
        }
        self.content = updatedContent
        eventManager.update(eventConfiguration: component.eventConfiguration, trackingEvents: component.trackingEvents)
        currentView?.update(withContent: updatedContent)
    }
}

extension MultiLineTextComponent {
    struct Content: Decodable, Equatable {
        let body: String
    }
}
