//
//  BEComponent.swift
//  BDUIConcept
//
//  Created by Pablo Gonzalez on 10/10/21.
//

import Foundation
import UIKit

public struct BEComponent: Decodable {
    
    /// What identifies the component. Ir may have the same type as others. Ex: Collection for X thing, Collection for Y thing
    let id: String
    
    /// Identifies the component to be instantiated in the cliend
    let type: String
    
    /// Payload with relevant view data. To be decoded when needed to the appropriate entity.
    let content: Data?

    // Events to bind
    let eventConfiguration: AlchemistLiteEventConfiguration?

    // All tracking events
    let trackingEvents: [AlchemistLiteTrackingEvent]?

    let actions: [AlchemistLiteAction]?
    
    private enum CodingKeys : String, CodingKey {
        case id, type, hash, content, eventConfiguration, trackingEvents, actions
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.type = try container.decode(String.self, forKey: .type)
        self.eventConfiguration = try container.decodeIfPresent(AlchemistLiteEventConfiguration.self, forKey: .eventConfiguration)
        self.trackingEvents = try container.decodeIfPresent([AlchemistLiteTrackingEvent].self, forKey: .trackingEvents)
        self.actions = try container.decodeIfPresent([AlchemistLiteAction].self, forKey: .actions)
        guard let contentDictionary = try container.decodeIfPresent([String: Any].self, forKey: .content) else {
            self.content = nil
            return
        }
        let data = try JSONSerialization.data(withJSONObject: contentDictionary, options: .prettyPrinted)
        content = data
    }
}

struct AlchemistLiteEventConfiguration: Decodable {
    let events: [AlchemistLiteEvent]?
    let origins: [String]?
}

struct AlchemistLiteEvent: Decodable {
    let eventType: String
    let targetId: Int
    let eventBody: [String: Any]
    let trigger: AlchemistLiteTrigger

    private enum CodingKeys : String, CodingKey {
        case eventType, targetId, eventBody, trigger
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.eventType = try container.decode(String.self, forKey: .eventType)
        self.targetId = try container.decode(Int.self, forKey: .targetId)
        self.trigger = try container.decode(AlchemistLiteTrigger.self, forKey: .trigger)
        guard let eventBodyDictionary = try container.decodeIfPresent([String: Any].self, forKey: .eventBody) else {
            self.eventBody = [String:Any]()
            return
        }
        self.eventBody = eventBodyDictionary
    }
}

struct AlchemistLiteTrackingEvent: Decodable {
    let id: String
    let targetId: Int
    let properties: [String: Any]?
    let trigger: AlchemistLiteTrigger

    private enum CodingKeys : String, CodingKey {
        case id, targetId, properties, trigger
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.targetId = try container.decode(Int.self, forKey: .targetId)
        self.trigger = try container.decode(AlchemistLiteTrigger.self, forKey: .trigger)
        guard let propertiesDictionary = try container.decodeIfPresent([String: Any].self, forKey: .properties) else {
            self.properties = nil
            return
        }
        self.properties = propertiesDictionary
    }
}

struct AlchemistLiteAction: Decodable {
    let type: String
    let data: [String: Any]?
    let targetId: Int
    let trigger: AlchemistLiteTrigger

    private enum CodingKeys : String, CodingKey {
        case type, data, targetId, trigger
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(String.self, forKey: .type)
        self.targetId = try container.decode(Int.self, forKey: .targetId)
        self.trigger = try container.decode(AlchemistLiteTrigger.self, forKey: .trigger)
        guard let dataDictionary = try container.decodeIfPresent([String: Any].self, forKey: .data) else {
            data = nil
            return
        }
        self.data = dataDictionary
    }
}

//"actions": [{
//        "type": "navigate",
//        "data": {
//            "targetUrl": "pedidosya://lptm"
//        },
//        "targetId": 1,
//        "trigger": "CLICKED"
//    },
//    {
//        "type": "modal",
//        "data": {
//            "title": "Cancelar orden",
//            "subtitle": "?Desea usted cancelar la orden",
//            "actionTitle": "aceptar"
//        },
//        "targetId": 2,
//        "trigger": "CLICKED"
//    },
//    {
//        "type": "link",
//        "data": {
//            "targetUrl": "pedidosya://lptm"
//        },
//        "targetId": 3,
//        "trigger": "CLICKED"
//    }
//]

enum AlchemistLiteTrigger: String, Decodable {
    case clicked = "CLICKED"
    case loaded = "LOADED"

    case unknown = "UNKNOWN"
}
