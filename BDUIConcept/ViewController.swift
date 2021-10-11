//
//  ViewController.swift
//  BDUIConcept
//
//  Created by Pablo Gonzalez on 10/10/21.
//

import UIKit

class ViewController: UIViewController {
    private var broker: AlchemistLiteBroker!
    private let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        //1 - Register Components
        AlchemistLiteManager.registerComponent(AlchemistLiteRegistration(type: "firstType", onInitialization: { component in
            return try? Component1(id: component.id, hash: component.hash, type: component.type, data: component.content)
        }))
        
        AlchemistLiteManager.registerComponent(AlchemistLiteRegistration(type: "secondType", onInitialization: { component in
            return try? Component2(id: component.id, hash: component.hash, type: component.type, data: component.content)
        }))
        
        AlchemistLiteManager.registerComponent(AlchemistLiteRegistration(type: "thirdType", onInitialization: { component in
            return try? Component3(id: component.id, hash: component.hash, type: component.type, data: component.content)
        }))
        
        
        //2 - Obtain a broker - Probably with params in order to set the endpoint to be called. TBD
        broker = AlchemistLiteManager.shared.getViewBroker()
        
        broker.onUpdatedViews = { result in
            switch result {
            case .success(let views):
                DispatchQueue.main.async { [weak self] in
                    self?.stackView.arrangedSubviews.forEach({$0.removeFromSuperview()})
                    views.forEach({ self?.stackView.addArrangedSubview($0) })
                }
            case .failure(let error):
                print(error)
            }
        }
        
        broker.load()
        
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 10) { [weak self] in
            self?.broker.load2()
        }
    }
    
    private func setupView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                                     stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor),
                                     stackView.leftAnchor.constraint(equalTo: view.leftAnchor),
                                     stackView.rightAnchor.constraint(equalTo: view.rightAnchor)])
    }
}

