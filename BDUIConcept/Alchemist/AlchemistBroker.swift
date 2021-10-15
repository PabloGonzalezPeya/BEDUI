//
//  AlchemistBroker.swift
//  BDUIConcept
//
//  Created by Pablo Gonzalez on 10/10/21.
//

import Foundation
import UIKit

class AlchemistLiteBroker {
    private var currentSessionComponents = [AlchemistLiteUIComponent]()
    private let notificationName: String = "AlchemistLiteEvent_\(UUID().uuidString)"
    
    /// Notifies subscriber of the status of obtaining or refreshing views
    var onUpdatedViews: ((Result<[AlchemistLiteModelResult], AlchemistLiteError>) -> Void)?
    
    func load() {
        guard let bundlePath = Bundle.main.path(forResource: "SDUIInitialDraft", ofType: "json"),
              let jsonData = try? String(contentsOfFile: bundlePath).data(using: .utf8),
              let deserialized = try? JSONDecoder().decode([BEComponent].self, from: jsonData) else {
                  onUpdatedViews?(.failure(.responseDeserialization))
                  return
        }
        
        handleUpdatedResults(updated: deserialized)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.onUpdatedViews?(.success(self.currentSessionComponents.map({
                return AlchemistLiteModelResult(id: $0.id, view: $0.getView())
            })))
        }
    }
    
    func load2() {
        guard let bundlePath = Bundle.main.path(forResource: "SDUISecondDraft", ofType: "json"),
              let jsonData = try? String(contentsOfFile: bundlePath).data(using: .utf8),
              let deserialized = try? JSONDecoder().decode([BEComponent].self, from: jsonData) else {
                  onUpdatedViews?(.failure(.responseDeserialization))
                  return
        }
        
        handleUpdatedResults(updated: deserialized)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.onUpdatedViews?(.success(self.currentSessionComponents.map({
                return AlchemistLiteModelResult(id: $0.id, view: $0.getView())
            })))
        }
    }
    
    private func handleUpdatedResults(updated: [BEComponent]) {
        //1 - First time? just add´em up from registration
        if currentSessionComponents.isEmpty {
            for component in updated {
                guard let registration = AlchemistLiteManager.registeredComponents.first(where: {$0.type == component.type }),
                      let uiComponent = registration.onInitialization(AlchemistLiteUIComponentConfiguration(component: component, notificationHandler: AlchemistLiteNotificationHandler(name: notificationName))) else {
                          // Log this somewhere
                          continue
                      }
                currentSessionComponents.append(uiComponent)
            }
            print("No previous components. Added server ones as default")
        } else {
            //2 - We need tp update and change locations
            var newComponentArray = [AlchemistLiteUIComponent]()
            
            //1 - get the id views on both sets and remove the ones that no longer apply
            let currentIds = currentSessionComponents.map({$0.id})
            let newIds = updated.map({$0.id})
            
            var idsToRemove = [String]()
            
            for id in currentIds {
                if !newIds.contains(id) {
                    idsToRemove.append(id)
                }
            }
            
            currentSessionComponents.removeAll(where: {idsToRemove.contains($0.id)})
            
            //2 - update current set while keeping old views
            for component in updated {
                if let currentComponent = currentSessionComponents.first(where: {$0.id == component.id}) {
                    DispatchQueue.main.async {
                        currentComponent.updateView(component: component)
                    }
                    newComponentArray.append(currentComponent)
                } else {
                    guard let registration = AlchemistLiteManager.registeredComponents.first(where: {$0.type == component.type }),
                          let uiComponent = registration.onInitialization(AlchemistLiteUIComponentConfiguration(component: component,
                                                                                                                notificationHandler: AlchemistLiteNotificationHandler(name: notificationName))) else {
                              // Log this somewhere
                              continue
                          }
                    newComponentArray.append(uiComponent)
                }
            }
            
            currentSessionComponents = newComponentArray
        }
    }
}

extension AlchemistLiteBroker {
    enum LoadType {
        // To get response from local json file. Use file name without extension.
        case fromLocalFile(name: String, bundle: Bundle)
        
        // URL to make remote request for components
        case fomUrl(url: URL)
        
        // If using a mixed response, just provide those BE components for evaluation.
        case fromProvidedComponents(components: BEComponent)
    }
}

// Eventos entre componentes para modificar comportaiento/ Listener - Observer
struct AlchemistLiteNotification {
    let id: String
    let data: [String: Any]
}

struct AlchemistLiteUIComponentConfiguration {
    private let component: BEComponent
    private let notificationHandler: AlchemistLiteNotificationHandler

    init(component: BEComponent, notificationHandler: AlchemistLiteNotificationHandler) {
        self.component = component
        self.notificationHandler = notificationHandler
    }

    var componentId: String {
        return component.id
    }

    var componentType: String {
        return component.type
    }

    func parseContent<T: Decodable>() throws -> T {
        guard let componentData = component.content else { throw AlchemistLiteError.componentDataMissing(component: TitleComponent.componentType)}
        do {
            return try JSONDecoder().decode(T.self, from: componentData)
        } catch {
            throw AlchemistLiteError.componentDataParsing(component: TitleComponent.componentType)
        }
    }

    func getEventManager() -> AlchemistLiteEventManager {
        return AlchemistLiteEventManager(notificationHandler: notificationHandler,
                                         eventConfiguration: component.eventConfiguration,
                                         trackingEvents: component.trackingEvents)
    }
}

class AlchemistLiteEventManager {
    let notificationHandler: AlchemistLiteNotificationHandler
    var eventConfiguration: AlchemistLiteEventConfiguration?
    var trackingEvents: [AlchemistLiteTrackingEvent]?

    var onNotificationReceived: ((AlchemistLiteNotification) -> Void)?

    init(notificationHandler: AlchemistLiteNotificationHandler,
        eventConfiguration: AlchemistLiteEventConfiguration?,
         trackingEvents: [AlchemistLiteTrackingEvent]?) {
        self.notificationHandler = notificationHandler
        self.eventConfiguration = eventConfiguration
        self.trackingEvents = trackingEvents
        notificationHandler.onNotificationReceived = { [weak self] notification in
            self?.onNotificationReceived?(notification)
        }
    }

    func update(eventConfiguration: AlchemistLiteEventConfiguration?,
                trackingEvents: [AlchemistLiteTrackingEvent]?) {
        self.eventConfiguration = eventConfiguration
        self.trackingEvents = trackingEvents
    }

    func triggerEvent(trigger: AlchemistLiteTrigger, forId identifier: Int) {
        if let eventConfig = eventConfiguration,
           let events = eventConfig.events,
           let event = events.filter({$0.targetId == identifier && $0.trigger == trigger}).first {
            notificationHandler.broadcastNotification(notification: AlchemistLiteNotification(id: event.eventType,
                                                                                              data: event.eventBody))
        }

        // TODO: Add tracking instance
        if let trackingEvents = trackingEvents,
           let event = trackingEvents.filter({$0.trigger == trigger && $0.targetId == identifier}).first {
            print("Tracking Event \(event)")
        }

        // TODO: Handle Actions

    }
}

struct AlchemistLiteModelResult {
    let id: String
    let view: UIView
}
