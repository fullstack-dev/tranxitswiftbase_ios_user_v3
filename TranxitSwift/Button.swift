//
//  Button.swift
//  User
//
//  Created by imac on 12/22/17.
//  Copyright © 2017 Appoets. All rights reserved.
//

import UIKit

//MARK:- Designable class UIButton


class Button : UIButton {
 
    
    //MARK:- Setting Background color
    
    @IBInspectable var isBackgroundColorPrimary : Bool = false {
        didSet {
            self.backgroundColor = isBackgroundColorPrimary ? .primary : .white
        }
    }
    
    
    
    //MARK:- Setting Corner Radius to Round
    
    @IBInspectable var isRoundedCorner : Bool = false {
        didSet {
            self.layer.masksToBounds = isRoundedCorner
            if isRoundedCorner{
                self.layer.cornerRadius = self.frame.height/2
            }
        }
    }
    
//
//    //MARK:- Button Text Color
//
//    @IBInspectable var textColorIsPrimary : Bool = false {
//
//        didSet {
//
//            if textColorIsPrimary {
//                self.titleLabel?.textColor = .primary
//            }
//
//        }
//
//    }
    
    
    //MARK:- Border Width
    
    @IBInspectable var borderWidth : CGFloat = 0{
        
        didSet{
            self.layer.borderWidth = borderWidth
        }
        
    }
    
    
    //MARK:- Primary Button
    
    @IBInspectable var isPrimaryButton : Bool = false {
        didSet{
            if isPrimaryButton{
                primaryButton()
            }
        }
        
    }
    
    //MARK:- Primary Color
    
    @IBInspectable var primaryButtonColor : UIColor =  .primary{
        
        didSet{
            primaryButton()
        }
        
    }
    
    //MARK:- Button Text Color
    
    @IBInspectable
    var buttonTextColorId : Int = 0{
        
        didSet {
            self.setTitleColor({
                
                if let color = Color.valueFor(id: buttonTextColorId){
                    return color
                } else {
                    return self.titleColor(for: .normal)
                    
                }
                
            }(), for: .normal)
        }
        
    }
    
    
    
    private func primaryButton(){
        self.layer.borderWidth = 0.5
        self.layer.cornerRadius = 4
        self.setTitleColor(primaryButtonColor, for: .normal)
        self.layer.borderColor = primaryButtonColor.cgColor
    }
    
//    //MARK:- Border Color
//
//    @IBInspectable var borderColor : UIColor = .black {
//
//        didSet{
//
//            self.layer.borderColor = borderColor.cgColor
//
//        }
//
//    }
//
//    //MARK:- Corner Radius
//
//    @IBInspectable var cornerRadius : CGFloat = 0 {
//
//        didSet{
//
//            self.layer.cornerRadius = cornerRadius
//
//        }
//    }
    
    
    
//    //MARK:- Add Image Background
//    
//    @IBInspectable var setBackroungImage : UIImage? = nil {
//        
//        didSet {
//            
//            if setBackroungImage != nil {
//                
//                let imageView = UIImageView(frame: CGRect(x: frame.origin.x-5, y: frame.origin.y-5, width: frame.width-10, height: frame.height-10))
//                imageView.image = setBackroungImage
//                imageView.contentMode = .scaleAspectFit
//                imageView.backgroundColor = .white
//                self.insertSubview(imageView, belowSubview: self)
//                self.backgroundColor = .clear
//                
//            }
//            
//        }
//        
//    }
    
    
    
    
  
    //MARK:- UnderLined
    
    @IBInspectable var isUnderLined : Bool = false {
        
        didSet {
            updateAttributedText()
            
        }
    }
    
    //MARK:- Attributed String
    
    @IBInspectable var startLocation : Int = 0 {
        didSet{
            updateAttributedText()
        }
    }
    
    @IBInspectable var length : Int = 0 {
        didSet {
            updateAttributedText()
        }
    }
    
    @IBInspectable var attributeColor : UIColor = .black {
        didSet{
            updateAttributedText()
        }
    }
    
    
    private func updateAttributedText(){
        
        let mutableString = NSMutableAttributedString(string: String.removeNil(self.title(for: .normal)), attributes: [NSAttributedString.Key.font: self.titleLabel?.font ?? (UIFont(name: "Lato-Regular", size: 14.0))!])
        
        var attributes = [NSAttributedString.Key : Any]()
        
        if isUnderLined{
            attributes.updateValue(NSUnderlineStyle.single.rawValue, forKey: .underlineStyle)
        }
        attributes.updateValue(attributeColor, forKey: .foregroundColor)
     //   attributes.updateValue(UIFont(name: "Lato-Heavy", size: 20.0)!, forKey : NSAttributedStringKey.font)
        
        //        let underlineAttribute = (NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue)
        //        let colorAttribute = (NSAttributedStringKey.foregroundColor: attributeColor)
        // mutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: attributeColor, range: NSRange(location:startLocation,length:length))
        mutableString.addAttributes(attributes, range: NSRange(location:startLocation,length:length))
        self.titleLabel?.attributedText = mutableString
    }
    
  }


extension UIButton {
    func imageWith(color:UIColor, for: UIControl.State) {
        if let imageForState = self.image(for: state) {
            self.image(for: .normal)?.withRenderingMode(.alwaysTemplate)
            let colorizedImage = imageForState.imageTintColor(color1: color)
            self.setImage(colorizedImage, for: state)
        }
    }
}
