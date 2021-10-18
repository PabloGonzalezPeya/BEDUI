//
//  ImageCarrouselComponent.swift
//  BDUIConcept
//
//  Created by Pablo Gonzalez on 12/10/21.
//

import Foundation
import UIKit

class ImageCarrouselComponent: AlchemistLiteComponentable {
    private(set) static var componentType = "imageCarrousel"
    
    private(set) var id: String
    private(set) var type: String
    private(set) var content: Content
    private(set) var eventManager: AlchemistLiteEventManager
    private(set) var currentView: UIView?
    
    required init(config: AlchemistLiteUIComponentConfiguration) throws {
        self.id = config.componentId
        self.type = config.componentType
        self.eventManager = config.getEventManager()
        self.content = try config.parseContent()
    }
    
    func getView() -> UIView {
        if let viewtoReturn = currentView {
            return viewtoReturn
        }
        let view = ImageCarrouselView(content: content, eventManager: eventManager)
        currentView = view
        return view
    }
    
    func updateView(component: BEComponent) {
        guard let data = component.content else { return }
        guard let updatedContent = try? JSONDecoder().decode(Content.self, from: data),
        updatedContent != self.content else {
            print("No changes for \(ImageCarrouselComponent.componentType)")
            return
        }
        self.eventManager.update(eventConfiguration: component.eventConfiguration,
                                 trackingEvents: component.trackingEvents,
                                 actions: component.actions)
        self.content = updatedContent
        guard let view = currentView as? ImageCarrouselView else { return }
        view.update(withContent: updatedContent)
    }
}

extension ImageCarrouselComponent {
    struct Content: Decodable, Equatable {
        let title: String
        let images: [Image]
        
        struct Image: Decodable, Equatable {
            let id: String
            let url: String
        }
    }
}
