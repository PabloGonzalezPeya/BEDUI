//
//  AmountComponentViewModel.swift
//  BDUIConcept
//
//  Created by Pablo Gonzalez on 14/10/21.
//

import Foundation

class AmountComponentViewModel: ViewModellable {
    let viewState = ViewState()
    let modelState: ModelState

    init(build: Build) {
        modelState = ModelState(notificationHandler: build.notificationHandler,
                                content: build.content)
        listenEventBusEvents()
    }

    func dispatchInputAction(_ action: InputAction) {
        switch action {
        case .didSetupView:
            handleDidSetupView()
        case .didUpdate(let content):
            handleDidUpdateContent(content)
        }
    }

    private func listenEventBusEvents() {
        modelState.notificationHandler.onNotificationReceived = { [weak self] notification in
            self?.handleNotificationIfNeeded(notification)
        }
    }

    private func handleNotificationIfNeeded(_ notification: AlchemistLiteNotification) {
        switch notification.id {
        case "amountUpdated":
            print("Received amount updated in Detail component with payload \(notification.data)")
        default:
            print("Nada!")
        }
    }

    private func handleDidUpdateContent(_ content: AmountComponent.Content) {
        modelState.content = content
        handleDidSetupView()
    }

    private func handleDidSetupView() {
        viewState.amount.value = modelState.content.amountDisplayValue
        viewState.cardLink.value = modelState.content.cardImage
        viewState.paymentType.value = modelState.content.cardType
        modelState.currentValue = modelState.content.amount
    }
}

extension AmountComponentViewModel {
    class ViewState {
        let paymentType = StateObservable<String>(nil)
        let cardLink = StateObservable<String>(nil)
        let amount = StateObservable<String>(nil)
    }

    class ModelState {
        let notificationHandler: AlchemistLiteNotificationHandler
        var content: AmountComponent.Content
        var currentValue: Double = 0

        init(notificationHandler: AlchemistLiteNotificationHandler,
             content: AmountComponent.Content) {
            self.notificationHandler = notificationHandler
            self.content = content
        }
    }

    enum InputAction: Equatable {
        case didSetupView
        case didUpdate(content: AmountComponent.Content)
    }
}

extension AmountComponentViewModel {
    struct Build {
        let content: AmountComponent.Content
        let notificationHandler: AlchemistLiteNotificationHandler
    }
}
