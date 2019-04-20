//
//  CouponCollectionViewCell.swift
//  User
//
//  Created by CSS on 17/09/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class CouponCollectionViewCell: UICollectionViewCell {
    
    //MARK:- IBOulets
    
    @IBOutlet private weak var labelCouponCode : UILabel!
    @IBOutlet private weak var labelCouponDescription : UILabel!
    @IBOutlet private weak var labelValidity : UILabel!
    @IBOutlet private weak var buttonApply : UIButton!
    
    //MARK:- local variable
    
    private var values : PromocodeEntity?
    var isHideApplyButton = false
    
    var onClickApply : ((PromocodeEntity)->Void)?
    
    override var isSelected: Bool {
        didSet{
            self.buttonApply.setTitle({
                return (isSelected ? Constants.string.remove : Constants.string.apply).localize().uppercased()
            }(), for: .normal)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialLoads()
    }
}

// Mark:- Local methods

extension CouponCollectionViewCell {
    
    private func initialLoads() {
        self.localize()
        self.setDesign()
    }
    
    private func localize() {
        self.buttonApply.addTarget(self, action: #selector(self.buttonApplyAction), for: .touchUpInside)
        self.labelCouponCode.textColor = .black
        self.labelValidity.textColor = .lightGray
        self.labelCouponDescription.textColor = .gray
        self.buttonApply.setTitleColor(.secondary, for: .normal)
    }
    
    private func setDesign() {
        
        Common.setFont(to: labelCouponCode, isTitle: true)
        Common.setFont(to: labelCouponDescription, isTitle: true)
        Common.setFont(to: labelValidity)
        Common.setFont(to: buttonApply, isTitle: true)
    }
    
    // Set values for CollectionCell
    
    func set(values : PromocodeEntity) {
        self.values = values
        self.labelCouponCode.text = self.values?.promo_code
        self.labelCouponDescription.text = self.values?.promo_description
        if let dateObject = Formatter.shared.getDate(from: self.values?.expiration, format: DateFormat.list.yyyy_mm_dd_HH_MM_ss){
            self.labelValidity.text =  Constants.string.validity.localize()+" : "+"\(Formatter.shared.getString(from: dateObject, format: DateFormat.list.dd_MM_yyyy) ?? .Empty)"
        }
        self.buttonApply.isHidden = isHideApplyButton
    }
    
    // Button Apply action
    @IBAction private func buttonApplyAction() {
        if self.values != nil {
            self.onClickApply?(self.values!)
        }
    }
}
