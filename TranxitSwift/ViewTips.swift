//
//  ViewTips.swift
//  User
//
//  Created by CSS on 11/09/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit
import IHKeyboardAvoiding

class ViewTips: UIView {

    //MARK :- Local variable
    private var labelTitle : UILabel!
    private var textFieldCustom : UITextField!
    private var buttonSubmit : UIButton!
    var total : Float = 0
    
    var onClickSubmit : ((Float)->())?
    
    var tipsAmount : Float = 0 {
        didSet {
            if tipsAmount > 0 {
                self.textFieldCustom.text = "\(User.main.currency ?? .Empty)\(Formatter.shared.limit(string: "\(tipsAmount)", maximumDecimal: 2))"
            }else {
                self.textFieldCustom.placeholder = "\(User.main.currency ?? .Empty)\(tipsAmount)"
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initializeViews()
        self.setDesign()
        self.localize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
       // fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

//MARK : - Local methods

extension ViewTips  {
    
    private func initializeViews() {
        
        self.opacityShadow = 3
        self.radiusShadow = 2
        self.colorShadow = UIColor.lightGray
        
        self.labelTitle = UILabel()
        self.labelTitle.textColor = .black
        self.labelTitle.contentMode = .center
        self.labelTitle.textAlignment = .center
        self.addSubview(self.labelTitle)
        self.labelTitle.translatesAutoresizingMaskIntoConstraints = false
        self.labelTitle.topAnchor.constraint(equalTo: self.topAnchor, constant: 4).isActive = true
        self.labelTitle.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        self.labelTitle.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9).isActive = true
        self.labelTitle.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        self.textFieldCustom = UITextField()
        self.textFieldCustom.borderStyle = .none
        self.textFieldCustom.textAlignment = .center
        self.textFieldCustom.delegate = self
        self.textFieldCustom.translatesAutoresizingMaskIntoConstraints = false
        self.textFieldCustom.keyboardType = .decimalPad
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.insertArrangedSubview(self.textFieldCustom, at: 0)
        stackView.spacing = 6
        for i in 0...2 {
            let button = UIButton()
            button.cornerRadius = 5
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = .lightGray
            button.setTitle("\(i*5+5)%", for: .normal)
            button.addTarget(self, action: #selector(self.buttonTipsAction(sender:)), for: .touchUpInside)
            stackView.insertArrangedSubview(button, at: i+1)
        }
        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: self.labelTitle.bottomAnchor, constant: 16).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        stackView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.25, constant: 0).isActive = true
        
        KeyboardAvoiding.avoidingView = self
        
        let viewTextFieldUnderLine = UIView()
        viewTextFieldUnderLine.backgroundColor = .lightGray
        viewTextFieldUnderLine.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(viewTextFieldUnderLine)
        viewTextFieldUnderLine.bottomAnchor.constraint(equalTo: self.textFieldCustom.bottomAnchor, constant: 0).isActive = true
        viewTextFieldUnderLine.leadingAnchor.constraint(equalTo: self.textFieldCustom.leadingAnchor, constant: 0).isActive = true
        viewTextFieldUnderLine.trailingAnchor.constraint(equalTo: self.textFieldCustom.trailingAnchor, constant: 0).isActive = true
        viewTextFieldUnderLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        self.buttonSubmit = UIButton()
        self.buttonSubmit.backgroundColor = .primary
        self.buttonSubmit.setTitleColor(.white, for: .normal)
        self.addSubview(self.buttonSubmit)
        self.buttonSubmit.addTarget(self, action: #selector(self.buttonSubmitAction(sender:)), for: .touchUpInside)
        self.buttonSubmit.translatesAutoresizingMaskIntoConstraints = false
        self.buttonSubmit.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 16).isActive = true
        self.buttonSubmit.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 0).isActive = true
        self.buttonSubmit.widthAnchor.constraint(equalToConstant: 100).isActive = true
        self.buttonSubmit.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
    }
    
    private func localize() {
        
        self.labelTitle.text = Constants.string.addTips.localize()
        self.buttonSubmit.setTitle(Constants.string.submit.localize(), for: .normal)
        self.tipsAmount = 0
    }
    
    private func setDesign() {
        Common.setFont(to: self.labelTitle, isTitle: true)
        Common.setFont(to: self.buttonSubmit, isTitle: true)
        Common.setFont(to: self.textFieldCustom)
    }
    
    @IBAction private func buttonTipsAction(sender : UIButton) {
        
        if let amountString = sender.title(for: .normal)?.replacingOccurrences(of: "%", with: ""), let tipsPercent = Float(amountString){
            self.tipsAmount = (total*(tipsPercent/100))
        }
    }
    
    @IBAction private func buttonSubmitAction(sender : UIButton) {
        
        let currency = User.main.currency ?? .Empty
        let str = self.textFieldCustom.text?.replacingOccurrences(of: currency, with: "")
        let value = Float(str ?? "0") ?? 0
        self.onClickSubmit?(value)
    }
}

//MARK :- UITextFieldDelegate

extension ViewTips : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var text = textField.text ?? .Empty
        text = range.length == 0 ? (text+string) : text
        let arr = text.split(separator: ".")
        if arr.count>1, arr[1].count>2{
            return false
        }
        return true
    }
    
}
