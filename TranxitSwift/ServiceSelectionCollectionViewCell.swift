//
//  ServiceSelectionCollectionViewCell.swift
//  User
//
//  Created by CSS on 11/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class ServiceSelectionCollectionViewCell: UICollectionViewCell {
    
    // @IBOutlet private var imageViewHeightConstant : NSLayoutConstraint!
    // @IBOutlet private var imageViewWidthConstant : NSLayoutConstraint!
    @IBOutlet private weak var imageViewService : UIImageView!
    @IBOutlet private weak var labelService : UILabel!
    @IBOutlet private weak var labelPricing : UILabel!
    @IBOutlet private weak var viewImageView : UIView!
    @IBOutlet private weak var viewBackground : UIView!
    @IBOutlet private weak var labelETA : UILabel!
    // private var initialFrame = CGSize.init()
    private var service : Service?
    
    override var isSelected: Bool {
        
        didSet{
            self.viewBackground.layer.masksToBounds = self.isSelected
            self.imageViewService.layer.masksToBounds = self.isSelected
            self.transform = isSelected ? .init(scaleX: 1.2, y: 1.2) : .identity
            self.labelService.textColor = !self.isSelected ? .black : .secondary
            self.viewBackground.borderLineWidth = self.isSelected ? 2 : 0
            self.setLabelPricing()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialLoads()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.viewImageView.cornerRadius = self.viewImageView.frame.width/2
        self.viewBackground.cornerRadius = self.viewBackground.frame.width/2
    }
}

//MARK:- Local Methods

extension ServiceSelectionCollectionViewCell {
    
    //  Set Designs
    
    private func setDesign() {
        
        Common.setFont(to: labelService, size : 12)
        Common.setFont(to: labelPricing, size : 10)
        Common.setFont(to: labelETA, size : 10)
    }
    
    private func initialLoads(){
        
        self.imageViewService.image = #imageLiteral(resourceName: "sedan-car-model")
        self.labelService.textColor = .black
        self.viewImageView.borderColor = .secondary
        self.viewBackground.borderColor = .secondary
        self.setDesign()
        // self.initialFrame = self.imageViewService.frame.size
    }
    
    func set(value : Service) {
        
        self.service = value
        labelService.text = value.name
        //self.imageViewService.image = #imageLiteral(resourceName: "sedan-car-model")
        self.imageViewService.setImage(with: value.image, placeHolder: #imageLiteral(resourceName: "sedan-car-model"))
        //        Cache.image(forUrl: value.image) { (image) in
        //            DispatchQueue.main.async {
        //                self.imageViewService.image = image == nil ? #imageLiteral(resourceName: "sedan-car-model") : image
        //            }
        //        }
        self.setLabelPricing()
        
    }
    
    func setLabelPricing() {
        self.labelPricing.text =  isSelected ? {
            if let distance = self.service?.pricing?.distance {
                return "\(distance) \(String.removeNil(User.main.measurement))"
            }
            return nil
            }() : nil
        self.labelETA.text =  isSelected ? {
            if let fare = self.service?.pricing?.estimated_fare {
                return "\(String.removeNil(User.main.currency))\(Formatter.shared.limit(string: "\(fare)", maximumDecimal: 2))"
            }
            return nil
            }() : nil
    }
}
