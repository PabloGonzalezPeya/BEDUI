//
//  ImageCarrouselComponent.swift
//  BDUIConcept
//
//  Created by Pablo Gonzalez on 12/10/21.
//

import Foundation
import UIKit

class ImageCarrouselComponent: AlchemistLiteUIComponent {
    private(set) static var componentType = "imageCarrousel"
    
    var id: String
    var hash: String
    var type: String
    
    private(set) var content: Content
    private var currentView: ImageCarrouselView?
    
    required init(component: BEComponent) throws {
        self.id = component.id
        self.hash = component.hash
        self.type = component.type
        guard let componentData = component.content else { throw AlchemistLiteError.componentDataMissing(component: TitleComponent.componentType)}
        do {
            self.content = try JSONDecoder().decode(Content.self, from: componentData)
        } catch {
            throw AlchemistLiteError.componentDataParsing(component: TitleComponent.componentType)
        }
    }
    
    func getView() -> UIView {
        if let viewtoReturn = currentView {
            return viewtoReturn
        }
        let view = ImageCarrouselView(content: content)
        currentView = view
        return view
    }
    
    func updateView(data: Data) {
        guard let updatedContent = try? JSONDecoder().decode(Content.self, from: data) else { return }
        self.content = updatedContent
        currentView?.update(withContent: updatedContent)
    }
}

extension ImageCarrouselComponent {
    struct Content: Decodable {
        let title: String
        let images: [Image]
        
        struct Image: Decodable {
            let id: String
            let url: String
        }
    }
}
