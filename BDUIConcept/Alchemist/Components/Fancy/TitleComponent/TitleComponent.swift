//
//  TitleComponent.swift
//  BDUIConcept
//
//  Created by Pablo Gonzalez on 12/10/21.
//

import Foundation
import UIKit

class TitleComponent: AlchemistLiteComponentable {
    private(set) static var componentType = "titleSingle"
    
    private(set) var id: String
    private(set) var type: String
    private(set) var content: Content
    private(set) var eventManager: AlchemistLiteEventManager
    private(set) var currentView: UIView?
    
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
        let view = TitleComponentView(viewModel: TitleComponentViewModel(content: content,
                                                                         handler: eventManager))
        currentView = view
        return view
    }
    
    func updateView(component: BEComponent) {
        guard let data = component.content else { return }
        guard let updatedContent = try? JSONDecoder().decode(Content.self, from: data),
              updatedContent != self.content else {
                  print("No changes for \(TitleComponent.componentType)")
                  return
              }
        self.content = updatedContent
        self.eventManager.update(eventConfiguration: component.eventConfiguration,
                                 trackingEvents: component.trackingEvents,
                                 actions: component.actions)
        guard let view = currentView as? TitleComponentView else { return }
        view.update(withContent: updatedContent)
    }
}

extension TitleComponent {
    struct Content: Decodable, Equatable {
        let title: String
    }
}
