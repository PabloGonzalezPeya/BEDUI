//
//  TipsComponent.swift
//  BDUIConcept
//
//  Created by Pablo Gonzalez on 14/10/21.
//

import Foundation
import UIKit

class TipsComponent: AlchemistLiteUIComponent {
    private(set) static var componentType = "tips"

    var id: String
    var type: String

    private(set) var content: Content
    private(set) var eventManager: AlchemistLiteEventManager
    private var currentView: TipsComponentView?

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
        let view = TipsComponentView(viewModel: TipsComponentViewModel(build: TipsComponentViewModel.Build(content: content, eventHandler: eventManager)))
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
        self.eventManager.update(eventConfiguration: component.eventConfiguration,
                                 trackingEvents: component.trackingEvents,
                                 actions: component.actions)
        self.content = updatedContent
        currentView?.update(withContent: updatedContent)
    }
}

extension TipsComponent {
    struct Content: Decodable, Equatable {
        let tips: [Tip]
    }

    struct Tip: Decodable, Equatable {
        let id: Int
        let displayValue: String
        let value: Double
    }
}
