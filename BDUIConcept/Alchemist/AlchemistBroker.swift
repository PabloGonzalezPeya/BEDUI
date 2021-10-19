//
//  AlchemistBroker.swift
//  BDUIConcept
//
//  Created by Pablo Gonzalez on 10/10/21.
//

import Foundation
import UIKit

public typealias AlchemistLiteUpdates = (Result<[AlchemistLiteModelResult], AlchemistLiteError>) -> Void

public protocol AlchemistLiteBrokerProtocol {
    func load(_ loadType: AlchemistLiteBroker.LoadType, completion: @escaping AlchemistLiteUpdates)
}

public final class AlchemistLiteBroker: AlchemistLiteBrokerProtocol {
    private var currentSessionComponents = [AlchemistLiteUIComponentProtocol]()
    private let notificationName: String = "AlchemistLiteEvent_\(UUID().uuidString)"

    public func load(_ loadType: LoadType, completion: @escaping AlchemistLiteUpdates) {
        switch loadType {
        case .fromLocalFile(let name, let bundle):
            handleLoadFromResource(name: name, bundle: bundle, completion: completion)
        case .fomUrl(let url):
            fatalError()
        case .fromProvidedComponents(let components):
            fatalError()
        }
    }

    private func handleLoadFromResource(name: String, bundle: Bundle, completion: @escaping AlchemistLiteUpdates) {
        guard let bundlePath = bundle.path(forResource: name, ofType: "json"),
              let jsonData = try? String(contentsOfFile: bundlePath).data(using: .utf8),
              let deserialized = try? JSONDecoder().decode([BEComponent].self, from: jsonData) else {
                  completion(.failure(.responseDeserialization))
                  return
              }

        handleUpdatedResults(updated: deserialized)

        DispatchQueue.main.async {
            completion(.success(self.currentSessionComponents.map({
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
            var newComponentArray = [AlchemistLiteUIComponentProtocol]()
            
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

public extension AlchemistLiteBroker {
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
                                         trackingEvents: component.trackingEvents,
                                         actions: component.actions)
    }
}

public struct AlchemistLiteModelResult {
    let id: String
    let view: UIView
}

typealias AlchemistLiteComponentable = AlchemistLiteUIComponentProtocol & AlchemistLiteContentProtocol
