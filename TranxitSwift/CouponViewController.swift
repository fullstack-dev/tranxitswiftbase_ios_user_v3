//
//  CouponViewController.swift
//  User
//
//  Created by CSS on 24/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit
//import IQKeyboardManagerSwift
import IHKeyboardAvoiding

class CouponViewController: UIViewController {

    //MARK:- IBOutlets
    
    @IBOutlet private weak var labelMessage : UILabel!
    @IBOutlet private var textFieldCouponCode : TextField!
    @IBOutlet private weak var labelAddCouponString : UILabel!
    @IBOutlet private weak var viewCoupon : UIView!
    @IBOutlet private weak var buttonAddCoupon : UIButton!

    
    lazy var loader  : UIView = {
        return createActivityIndicator(self.view)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initalLoads()
       // KeyboardAvoiding.avoidingView = self.viewCoupon
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK:- Local Methods

extension CouponViewController {
    
    private func initalLoads() {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back-icon").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.backButtonClick))
        self.navigationItem.title = Constants.string.coupon.localize()
        self.localize()
        self.view.dismissKeyBoardonTap()
        self.setDesign()
        self.textFieldCouponCode.delegate = self
    }
    
    //  Set Designs
    
    private func setDesign () {
        
        Common.setFont(to: labelMessage)
        Common.setFont(to: labelAddCouponString)
        Common.setFont(to: textFieldCouponCode)
        buttonAddCoupon.setTitle(Constants.string.ADDCOUPON.localize(), for: .normal)

    }
    
    private func localize() {
        self.textFieldCouponCode.placeholder = Constants.string.enterCouponCode.localize()
        self.labelAddCouponString.text = Constants.string.addCouponCode.localize()
    }
    
    @IBAction private func buttonCouponAction(sender : UIButton) {
        self.view.endEditingForce()
        guard let promo = textFieldCouponCode.text, !promo.isEmpty else {
            self.view.make(toast: Constants.string.enterCouponCode.localize())
            return
        }
        
        self.loader.isHidden = false
        var promocode = Coupon()
        promocode.promocode = promo
        self.presenter?.post(api: .addPromocode, data: promocode.toData())
        
    }
}

// MARK:- UITextFieldDelegate

extension CouponViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
      //  print("begin", IQKeyboardManager.sharedManager().keyboardDistanceFromTextField)
        
    }
}

// MARK:- PostViewProtocol

extension CouponViewController : PostViewProtocol {
    
    func onError(api: Base, message: String, statusCode code: Int) {
        
        DispatchQueue.main.async {
            self.loader.isHidden = true
            //self.removeLoaderViewAndClearMapview()
            showAlert(message: message, okHandler: nil, fromView: self)
        }
    }
    
    func success(api: Base, message: String?) {
        
        DispatchQueue.main.async {
            self.loader.isHidden = true
            self.view.makeToast(message)
        }
    }
    
}
