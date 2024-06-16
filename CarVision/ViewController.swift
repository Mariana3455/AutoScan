//
//  ViewController.swift
//  CarVision
//
//  Created by Mariana Dekhtiarenko on 16.06.2024.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var squareView: UIView!
    
    @IBOutlet private weak var squareWhiteView: UIView!
    
    @IBOutlet private weak var getStartedButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        squareView.layer.cornerRadius = 30
        squareView.layer.masksToBounds = true
        let path = UIBezierPath(roundedRect: squareWhiteView.bounds,
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: CGSize(width: 30, height: 30))
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        squareWhiteView.layer.mask = mask
        getStartedButton.layer.cornerRadius = 15
        getStartedButton.layer.masksToBounds = true
        
    }
    
}

