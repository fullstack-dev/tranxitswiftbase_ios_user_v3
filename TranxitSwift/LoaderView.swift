//
//  LoaderView.swift
//  User
//
//  Created by CSS on 17/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit
import PopupDialog

class LoaderView: UIView {
    
    @IBOutlet private weak var buttonCancelRequest : UIButton!
    @IBOutlet private weak var labelFindingDriver : UILabel!
    @IBOutlet private weak var viewLoader : UIView!
    
    private var lottieView : LottieView!
    
    var onCancel : (()->Void)?
    
    // Enable Cancel Button If only request Id available
    var isCancelButtonEnabled = false {
        didSet {
            UIView.animate(withDuration: 0.2) {
                Common.setFont(to: self.labelFindingDriver, isTitle: !self.isCancelButtonEnabled)
            }
            self.buttonCancelRequest.isHidden = !self.isCancelButtonEnabled
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialLoads()
        self.setDesign()
    }
    
}

extension LoaderView {
    
    private func initialLoads() {
        self.buttonCancelRequest.isHidden = true // Hide Cancel Button Initially
        self.buttonCancelRequest.setTitle(Constants.string.cancelRequest.localize().uppercased(), for: .normal)
        self.labelFindingDriver.text = Constants.string.findingDriver.localize()
        self.buttonCancelRequest.addTarget(self, action: #selector(cancelButtonClick), for: .touchUpInside)
        
        lottieView = LottieHelper().addLottie(file: "search", with: CGRect(origin: .zero, size: CGSize(width: self.viewLoader.frame.width/2, height: self.viewLoader.frame.width/2)))
        lottieView.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        lottieView.backgroundColor = .clear
        lottieView.loopAnimation = true
        lottieView.autoReverseAnimation = true
        self.viewLoader.addSubview(lottieView)
        self.lottieView.centerXAnchor.constraint(equalTo: self.viewLoader.centerXAnchor).isActive = true
        self.lottieView.centerYAnchor.constraint(equalTo: self.viewLoader.centerYAnchor).isActive = true
        lottieView.play()
    }
    
    // MARK:- Set Design
    
    private func setDesign() {
        
        Common.setFont(to: labelFindingDriver)
        Common.setFont(to: buttonCancelRequest, isTitle: true)
    }
    
    
    func endLoader(on completion : @escaping (()->Void)){
        
        UIView.animate(withDuration: 0.3, animations: {
            self.lottieView.transform = CGAffineTransform(scaleX: 10, y: 10)
            self.lottieView.alpha = 0
        }) { (_) in
            completion()
            self.removeFromSuperview()
        }
    }
    
    @IBAction private func cancelButtonClick(){
        self.onCancel?()
    }
}
