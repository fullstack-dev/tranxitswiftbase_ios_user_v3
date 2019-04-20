//
//  CurrencyUpdateViewController.swift
//  User
//
//  Created by CSS on 19/01/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class CurrencyUpdateViewController: UIViewController {

    var presenter: PostPresenterProtocol?
    
    private lazy var loader : UIView = {
        
       return createActivityIndicator(self.view)
        
    }()
    
    @IBOutlet private var buttonDollar : Button!
    @IBOutlet private var buttonPeso : Button!
    @IBOutlet private var textFieldDollar : UITextField!
    @IBOutlet private var textFieldPeso : UITextField!
    @IBOutlet private var labelLocationName : UILabel!
    @IBOutlet private var labelStreetName : UILabel!
    
    @IBAction private func sendButtonAction(sender : UIButton){
        
        self.view.dismissKeyBoardonTap()
       
        guard  textFieldDollar.text != nil, let dollar = Float(textFieldDollar.text!) else {
            self.view.makeToast(ErrorMessage.list.enterValidAmount)
            return
        }
        
        guard  textFieldPeso.text != nil, let peso = Float(textFieldPeso.text!) else {
            self.view.makeToast(ErrorMessage.list.enterValidAmount)
            return
        }
        
        self.set(presenter: presenterObject)
        self.loader.isHidden = false
        self.presenter?.send(api: .currencyUpdate, data: MakeJson.currency(dollar: dollar, peso: peso, isUpdate: true))
        
        
    }
    
    
    @IBAction private func enableButtonAction(sender : Button){
        
        
        if sender == buttonDollar {
            
            textFieldDollar.isEnabled = !textFieldDollar.isEnabled
            Change(button: sender, isEnabled: textFieldDollar.isEnabled)
            
        } else {
            
            textFieldPeso.isEnabled = !textFieldPeso.isEnabled
            Change(button: sender, isEnabled: textFieldPeso.isEnabled)
            
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initalLoads()
    }

    
    // MARK:- Initial Loads
    
    private func initalLoads(){
        
        buttonDollar.addTarget(self, action: #selector(enableButtonAction(sender:)), for: .touchUpInside)
        buttonPeso.addTarget(self, action: #selector(enableButtonAction(sender:)), for: .touchUpInside)
        self.view.endEditingForce()
        labelStreetName.text = User.main.streetNumber
        labelLocationName.text = User.main.locationName
        self.navigationItem.title = User.main.city
    }
    
    //MARK:- button UI Change
    
    private func Change(button : Button, isEnabled : Bool){
        
        button.setTitleColor( isEnabled ? .red : .brightBlue, for: .normal)
        button.setTitle(isEnabled ? Constants.string.DISABLE : Constants.string.UPDATE, for: .normal)
        button.length = Int(isEnabled ? Constants.string.DISABLE.count : Constants.string.UPDATE.count)
        button.startLocation = 0
        print("Button Length ",button.length)
        button.attributeColor = UIColor.brightBlue
        button.isUnderLined = true
      
        
    }
    
    

    //MARK:- Disable TextFields
    
    private func disableTextFields(){
        
        if textFieldPeso.isEnabled {
            enableButtonAction(sender: buttonPeso)
        }
        if textFieldDollar.isEnabled {
            enableButtonAction(sender: buttonDollar)
        }
        
    }
    
    
    
  
}

//MARK:- Post View Protocol Implementation

extension CurrencyUpdateViewController : PostViewProtocol {
    
    
    func onSuccess(api: Base, message: String) {
       
        self.loader.isHideInMainThread(true)
        self.view.makeToast(message)
        disableTextFields()
        
    }
    
    
    func onError(api: Base, message: String) {
        
        self.present(showAlert(message: message), animated: true) {
            self.loader.isHideInMainThread(true)
        }
        
        
    }
    
}


//MARK:- TextField Delegate

extension CurrencyUpdateViewController : UITextFieldDelegate {
    
//    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
//
//        if textField.text != String.Empty,  Float(textField.text!) == nil {
//            textField.text!.removeLast(1)
//            return false
//        }
//        return true
//
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    
}


