//
//  HomeViewController.swift
//  MUXSDKStatsKalturaDemoAppSwiftPackageManager
//

import Foundation
import UIKit

class HomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupLayout()
    }

    func setupLayout() {
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = true

        let openPlayerButton = UIButton()
        openPlayerButton.translatesAutoresizingMaskIntoConstraints = false
        openPlayerButton.backgroundColor = .lightGray
        openPlayerButton.layer.cornerRadius = 4.0
        openPlayerButton.setTitleColor(.label, for: .normal)
        openPlayerButton.setTitle("Open Player", for: .normal)
        openPlayerButton.addTarget(self, action: #selector(self.openPlayerViewController), for: .primaryActionTriggered)

        self.view.addSubview(openPlayerButton)

        let padding = UIScreen.main.bounds.width * 0.10
        let buttonHeight = UIDevice.current.userInterfaceIdiom == .tv ? UIScreen.main.bounds.height * 0.1 : 44.0

        NSLayoutConstraint.activate([
            openPlayerButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: padding),
            openPlayerButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -padding),
            openPlayerButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            openPlayerButton.heightAnchor.constraint(greaterThanOrEqualToConstant: buttonHeight)
        ])
    }

    @objc func openPlayerViewController() {
        self.navigationController?.pushViewController(PlayerViewController(), animated: true)
    }
}

