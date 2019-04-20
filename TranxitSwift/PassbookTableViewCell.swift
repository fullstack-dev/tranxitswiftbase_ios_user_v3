//
//  PassbookTableViewCell.swift
//  User
//
//  Created by CSS on 25/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class PassbookTableViewCell: UITableViewCell {
    
    // Mark:- IBOutlets
    @IBOutlet private weak var labelDate :UILabel!
    @IBOutlet private weak var labelAmountString :UILabel!
    @IBOutlet private weak var labelOffer :UILabel!
    @IBOutlet private weak var labelCredit :UILabel!
    @IBOutlet private weak var labelPaymentType :UILabel!
    @IBOutlet private weak var labelCouponStatus : UILabel!
    

    var isWalletSelected = true {
        didSet {
            self.labelCouponStatus.isHidden = isWalletSelected
            self.labelAmountString.text = (isWalletSelected ? Constants.string.amount : Constants.string.offer).localize()
            self.labelCredit.text = (isWalletSelected ? Constants.string.creditedBy : Constants.string.CouponCode).localize()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setDesign()
    }
    
    // MARK:- Set Designs
    private func setDesign () {
        
        Common.setFont(to: labelDate)
        Common.setFont(to: labelAmountString)
        Common.setFont(to: labelOffer)
        Common.setFont(to: labelCredit)
        Common.setFont(to: labelPaymentType)
        Common.setFont(to: labelCouponStatus)
    }
    
    func set(values : CouponWallet) {
        
        if let dateObject = Formatter.shared.getDate(from: values.created_at, format: DateFormat.list.yyyy_mm_dd_HH_MM_ss) {
            self.labelDate.text = Formatter.shared.getString(from: dateObject, format: DateFormat.list.ddMMMyyyy)
        }
        self.labelCouponStatus.text = values.promocode?.status?.localize()
        self.labelPaymentType.text =  values.promocode?.promo_code
        let discountValue = values.promocode?.discount_type == Constants.string.amount.lowercased() ? "\(User.main.currency ?? .Empty) \(values.promocode?.discount ?? 0)" : "\(values.promocode?.discount ?? 0) % \(Constants.string.OFF.localize())"
        self.labelOffer.text =  "\(discountValue)"
        
    }
    
    func set(values : WalletTransaction) {
        
        if let dateObject = Formatter.shared.getDate(from:  values.created_at, format: DateFormat.list.yyyy_mm_dd_HH_MM_ss) {
            self.labelDate.text = Formatter.shared.getString(from: dateObject, format: DateFormat.list.ddMMMyyyy)
        }
        self.labelPaymentType.text = values.transaction_desc
       // let discountValue = values.promocode?.discount_type == Constants.string.amount.lowercased() ? "\(User.main.currency ?? .Empty) \(values.promocode?.discount ?? 0)" : "\(values.promocode?.discount ?? 0) % \(Constants.string.OFF.localize())"
        self.labelOffer.text =  "\(User.main.currency ?? .Empty) \(Formatter.shared.limit(string: "\(values.amount ?? 0)", maximumDecimal: 2))"
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
