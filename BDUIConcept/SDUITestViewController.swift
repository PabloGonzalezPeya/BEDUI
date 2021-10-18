//
//  SDUITestViewController.swift
//  BDUIConcept
//
//  Created by Pablo Gonzalez on 10/10/21.
//

import UIKit

class SDUITestViewController: UIViewController {
    private var broker: AlchemistLiteBroker!
    private let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        //1 - Register Components
        AlchemistLiteManager.registerComponent(AlchemistLiteRegistration(type: TitleComponent.componentType, onInitialization: { config in
            return try? TitleComponent(config: config)
        }))
        
        AlchemistLiteManager.registerComponent(AlchemistLiteRegistration(type: ImageCarrouselComponent.componentType, onInitialization: { config in
            return try? ImageCarrouselComponent(config: config)
        }))
        
        AlchemistLiteManager.registerComponent(AlchemistLiteRegistration(type: MultiLineTextComponent.componentType, onInitialization: { config in
            return try? MultiLineTextComponent(config: config)
        }))

        AlchemistLiteManager.registerComponent(AlchemistLiteRegistration(type: AmountComponent.componentType, onInitialization: { config in
            return try? AmountComponent(config: config)
        }))

        AlchemistLiteManager.registerComponent(AlchemistLiteRegistration(type: TipsComponent.componentType, onInitialization: { config in
            return try? TipsComponent(config: config)
        }))

        AlchemistLiteManager.registerComponent(AlchemistLiteRegistration(type: AsynchComponent.componentType, onInitialization: { config in
            return try? AsynchComponent(config: config)
        }))


        //asyncDummy
        
        
        //2 - Obtain a broker
        broker = AlchemistLiteManager.shared.getViewBroker()

        //3 - Subscribe to updates
        broker.onUpdatedViews = { [weak self] result in
            switch result {
            case .success(let alchemistModel):
                print(alchemistModel)
                self?.handleViewAnimation(forViews: alchemistModel.map({$0.view}))
            case .failure(let error):
                print(error)
            }
        }

        //4 - Ask broker to process json from any source we want
        broker.load(.fromLocalFile(name: "SDUIInitialDraft", bundle: Bundle.main))
        
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 10) { [weak self] in
            self?.broker.load(.fromLocalFile(name: "SDUISecondDraft", bundle: Bundle.main))
        }
    }
    
    func handleViewAnimation(forViews views: [UIView]) {
        DispatchQueue.main.async { [weak self] in
            self?.stackView.arrangedSubviews.forEach({$0.removeFromSuperview()})
            views.forEach({ self?.stackView.addArrangedSubview($0) })
        }
    }
    
    private func setupView() {
        view.backgroundColor = .white
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 4
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                                     stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor),
                                     stackView.leftAnchor.constraint(equalTo: view.leftAnchor),
                                     stackView.rightAnchor.constraint(equalTo: view.rightAnchor)])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 20) { [weak self] in
//            self?.dismiss(animated: true, completion: nil)
//        }
    }
    
    deinit {
        print("WE HAVE NO LEAKS!!!")
    }

}
