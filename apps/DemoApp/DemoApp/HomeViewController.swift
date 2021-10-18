//
//  HomeViewController.swift
//  DemoApp
//
//  Created by Stephanie Zuñiga on 18/10/21.
//  Copyright © 2021 Mux, Inc. All rights reserved.
//

import Foundation
import UIKit

class HomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupLayout()
    }
    
    func setupLayout() {
        self.view.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.isHidden = true
        
        let openPlayerButton = UIButton()
        openPlayerButton.translatesAutoresizingMaskIntoConstraints = false
        openPlayerButton.backgroundColor = .secondarySystemBackground
        openPlayerButton.setTitleColor(.label, for: .normal)
        openPlayerButton.setTitle("Open Player", for: .normal)
        openPlayerButton.addTarget(self, action: #selector(self.openPlayerViewController), for: .touchUpInside)
        
        self.view.addSubview(openPlayerButton)
        
        NSLayoutConstraint.activate([
            openPlayerButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24.0),
            openPlayerButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24.0),
            openPlayerButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            openPlayerButton.heightAnchor.constraint(equalToConstant: 44.0)
        ])
    }
    
    @objc
    func openPlayerViewController() {
        self.navigationController?.pushViewController(PlayerViewController(), animated: true)
    }
}
