//
//  PassbookWalletTableViewCell.swift
//  TranxitUser
//
//  Created by CSS on 01/10/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class PassbookWalletTableViewCell: UITableViewCell {
    
    //MARK:- IBOutlets
    @IBOutlet private weak var labelTransactionId : UILabel!
    @IBOutlet private weak var labelAmount : Label!
    @IBOutlet private weak var labelBalance : Label!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialLoads()
    }
    
    private func initialLoads() {
        self.setDesign()
    }
    
}

//MARK:- Local methods

extension PassbookWalletTableViewCell {
    
    private func setDesign() {
        Common.setFont(to: labelTransactionId)
        Common.setFont(to: labelAmount)
        Common.setFont(to: labelBalance)
        self.labelAmount.attributeColor = .gray
        self.labelBalance.attributeColor = .gray
    }
    
    // Set values to Transaction list 
    func set(value : WalletTransaction) {
        
        self.labelTransactionId.text = value.transaction_alias
        self.labelAmount.text = Constants.string.amount.localize()+" : "+"\(User.main.currency ?? .Empty) \(Formatter.shared.limit(string: "\(value.amount ?? 0)", maximumDecimal: 2))"
        self.labelAmount.startLocation = 0
        self.labelAmount.length = Constants.string.amount.localize().count-1
        self.labelBalance.text = Constants.string.balance.localize()+" : "+"\(User.main.currency ?? .Empty) \(Formatter.shared.limit(string: "\(value.close_balance ?? 0)", maximumDecimal: 2))"
        self.labelBalance.startLocation = 0
        self.labelBalance.length = Constants.string.balance.localize().count
        
    }
}
