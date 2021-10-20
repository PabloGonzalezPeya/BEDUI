//
//  ViewController.swift
//  BDUIConcept
//
//  Created by Pablo Gonzalez on 10/10/21.
//

import UIKit

class ViewController: UIViewController {
    var presented = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !presented {
            let vc = SDUITestViewController()
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
            presented = true
        }

    }
}

