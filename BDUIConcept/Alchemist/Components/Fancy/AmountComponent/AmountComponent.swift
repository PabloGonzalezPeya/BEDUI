//
//  AmountComponent.swift
//  BDUIConcept
//
//  Created by Pablo Gonzalez on 14/10/21.
//

import Foundation
import UIKit

class AmountComponent: AlchemistLiteComponentable {
    private(set) static var componentType = "amount"

    var id: String
    var type: String

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
        let view = AmountComponentView(viewModel: AmountComponentViewModel(build: AmountComponentViewModel.Build(content: content, eventManager: eventManager)))
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
        eventManager.update(eventConfiguration: component.eventConfiguration,
                            trackingEvents: component.trackingEvents,
                            actions: component.actions)
        guard let view = currentView as? AmountComponentView else { return }
        view.update(withContent: updatedContent)
    }
}

extension AmountComponent {
    struct Content: Decodable, Equatable {
        let amountDisplayValue: String
        let amount: Double
        let currencySymbol: String
        let cardImage: String
        let cardType: String
    }
}
