//
//  SDUITestViewController.swift
//  BDUIConcept
//
//  Created by Pablo Gonzalez on 10/10/21.
//

import UIKit

class SDUITestViewController: UIViewController {
    private var broker: AlchemistLiteBroker!
    private let scrollView = UIScrollView()
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
        
        //2 - Obtain a broker
        broker = AlchemistLiteManager.shared.getViewBroker()

        //3 - Ask broker to process json from any source we want
        updateViews(.fromLocalFile(name: "SDUIInitialDraft", bundle: Bundle.main))

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10) { [weak self] in
            self?.updateViews(.fromLocalFile(name: "SDUISecondDraft", bundle: Bundle.main))
        }
    }

    private func updateViews(_ loadType: AlchemistLiteBroker.LoadType) {
        broker.load(loadType) { [weak self] result in
            switch result {
            case .success(let alchemistModel):
                print(alchemistModel)
                self?.handleViewAnimation(forViews: alchemistModel.map({$0.view}))
            case .failure(let error):
                print(error)
            }
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

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                                     scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
                                     scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                                     scrollView.rightAnchor.constraint(equalTo: view.rightAnchor)])

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 4
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                                     stackView.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor),
                                     stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
                                     stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
                                     stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)])

//        crollView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.alwaysBounceVertical = true
//        view.addSubview(scrollView)
//        NSLayoutConstraint.activate([scrollView.topAnchor.constraint(equalTo: view.topAnchor),
//                                     scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
//                                     scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
//                                     scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
//
//        configureRefreshControl()
//
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        stackView.axis = .vertical
//        scrollView.addSubview(stackView)
//
//        NSLayoutConstraint.activate([viewModel.viewState.build.afterOrder.isVendor
//                                        ? stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20)
//                                        : stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 14),
//                                     stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
//                                     stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
//                                     stackView.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor),
//                                     stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)])
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
