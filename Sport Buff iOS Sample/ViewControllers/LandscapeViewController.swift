//
//  LandscapeViewController.swift
//  buffup-ios
//
//  Created by Eleftherios Charitou on 14/01/2020.
//  Copyright © 2020 BuffUp. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
