//
//  QRCodeView.swift
//  TranxitUser
//
//  Created by Sravani on 24/01/19.
//  Copyright © 2019 Appoets. All rights reserved.
//

import UIKit

class QRCodeView: UIView {

    //IBOutlet
    @IBOutlet weak var QRImageView: UIImageView!
    @IBOutlet weak var qrInfoLabel: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
   
    override func awakeFromNib() {
       
        self.closeBtn.addTarget(self, action: #selector(buttonCloseAction), for: .touchUpInside)
    }
 
    // IBAction
    @IBAction private func buttonCloseAction() {
        self.dismissView(onCompletion: nil)
    }
}
