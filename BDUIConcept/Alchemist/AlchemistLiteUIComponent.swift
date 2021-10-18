//
//  AlchemistLiteUIComponent.swift
//  BDUIConcept
//
//  Created by Pablo Gonzalez on 10/10/21.
//

import Foundation
import UIKit

protocol AlchemistLiteUIComponentProtocol {
    // Component id to be used by Alchemist Lite
    static var componentType: String { get }
    
    var id: String { get }
    var type: String { get }
    var eventManager: AlchemistLiteEventManager { get }
    var currentView: UIView? { get }
    
    func getView() -> UIView
    func updateView(component: BEComponent)
    
    init(config: AlchemistLiteUIComponentConfiguration) throws
}
