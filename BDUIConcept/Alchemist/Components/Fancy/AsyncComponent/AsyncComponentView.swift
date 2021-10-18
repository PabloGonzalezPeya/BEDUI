//
//  AsyncComponentView.swift
//  BDUIConcept
//
//  Created by Pablo Gonzalez on 18/10/21.
//

import UIKit

class AsyncComponentView: UIView {
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    init() {
        super.init(frame: .zero)
        setupView()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 12) { [weak self] in
            self?.backgroundColor = .yellow
            self?.activityIndicator.stopAnimating()
            self?.activityIndicator.isHidden = true
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)
        NSLayoutConstraint.activate([activityIndicator.heightAnchor.constraint(equalToConstant: 100),
                                     activityIndicator.topAnchor.constraint(equalTo: topAnchor),
                                     activityIndicator.leftAnchor.constraint(equalTo: leftAnchor),
                                     activityIndicator.rightAnchor.constraint(equalTo: rightAnchor),
                                     activityIndicator.bottomAnchor.constraint(equalTo: bottomAnchor)])
        activityIndicator.startAnimating()
    }
}
