//
//  RateView.swift
//  User
//
//  Created by CSS on 14/06/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class RateView: UIView {
    
    //MARK:- IBOutlets
    
    @IBOutlet private weak var labelTitle : UILabel!
    @IBOutlet private weak var imageView : UIImageView!
    @IBOutlet private weak var labelServiceName : UILabel!
    @IBOutlet private weak var labelBaseFareString : UILabel!
    @IBOutlet private weak var labelBaseFare : UILabel!
    @IBOutlet private weak var labelFare : UILabel!
    @IBOutlet private weak var labelFareString : UILabel!
    @IBOutlet private weak var labelFareType : UILabel!
    @IBOutlet private weak var labelFareTypeString : UILabel!
    @IBOutlet private weak var labelCapacity : UILabel!
    @IBOutlet private weak var labelCapacityString : UILabel!
    @IBOutlet private weak var buttonDone : Button!
    
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    // Mark :- Local Variable
    
    var onCancel : (()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.localize()
        self.setDesign()
        self.buttonDone.addTarget(self, action: #selector(self.buttonDoneAction), for: .touchUpInside)
    }
    
}

//MARK :- Local methods

extension RateView {
    
    //  Set Design
    private func setDesign() {
        
        Common.setFont(to: labelTitle, isTitle: true)
        Common.setFont(to: labelServiceName, isTitle: true)
        Common.setFont(to: labelBaseFare)
        Common.setFont(to: labelBaseFareString)
        Common.setFont(to: labelFare)
        Common.setFont(to: labelFareString)
        Common.setFont(to: labelFareType)
        Common.setFont(to: labelFareTypeString)
        Common.setFont(to: labelCapacity)
        Common.setFont(to: labelCapacityString)
        Common.setFont(to: buttonDone, isTitle: true)
        self.labelFare.textAlignment = selectedLanguage == .arabic ? .left : .right
        self.labelBaseFare.textAlignment = selectedLanguage == .arabic ? .left : .right
        self.labelFareType.textAlignment = selectedLanguage == .arabic ? .left : .right
    }
    
    //  Localize
    
    private func localize() {
        
        self.labelTitle.text = Constants.string.rateCard.localize()
        self.labelBaseFareString.text = Constants.string.baseFare.localize()
        self.labelFareString.text = Constants.string.fare.localize()+"/"+String.removeNil(User.main.measurement)
        self.labelFareTypeString.text = Constants.string.fareType.localize()
        self.labelCapacityString.text = Constants.string.capacity.localize()
        self.buttonDone.setTitle(Constants.string.Done.localize(), for: .normal)
    }
    
    //  Set Values
    
    func set(values : Service?) {
        Cache.image(forUrl: values?.image) { (image) in
            if image != nil {
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }
        self.labelBaseFare.text = String.removeNil(User.main.currency)+"\(Formatter.shared.limit(string: "\(values?.pricing?.base_price ?? 0)", maximumDecimal: 2))"
        self.labelFare.text = String.removeNil(User.main.currency)+"\(Formatter.shared.limit(string: "\(values?.price ?? 0)", maximumDecimal: 2))" //"\(values?.pricing?.estimated_fare ?? 0)"
        
        self.labelFareType.text = values?.calculator?.rawValue.localize() ?? "-"
        self.labelCapacity.text = "1 - \(values?.capacity ?? 0)"
        self.labelServiceName.text = values?.name?.uppercased()
    }
    
    @IBAction private func buttonDoneAction() {
        self.onCancel?()
    }
}
