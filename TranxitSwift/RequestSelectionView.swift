//
//  RequestSelectionView.swift
//  User
//
//  Created by CSS on 19/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class RequestSelectionView: UIView {
    
    //MARK:- IBOutlets
    
    @IBOutlet private weak var labelUseWalletString : UILabel!
    @IBOutlet private weak var imageViewWallet : UIImageView!
    @IBOutlet private weak var buttonScheduleRide : UIButton!
    @IBOutlet private weak var buttonRideNow : UIButton!
    @IBOutlet private weak var viewUseWallet : UIView!
    @IBOutlet private weak var labelEstimationFareString : UILabel!
    @IBOutlet private weak var labelEstimationFare : UILabel!
    @IBOutlet private weak var labelCouponString : UILabel!
    @IBOutlet private weak var labelPaymentMode : Label!
    @IBOutlet private weak var buttonChangePayment : UIButton!
    @IBOutlet private weak var buttonCoupon : UIButton!
    @IBOutlet private weak var imageViewModal : UIImageView!
    @IBOutlet private weak var viewImageModalBg : UIView!
    @IBOutlet private weak var labelWalletBalance : UILabel!
    
    //MARK:- Local variable
    
    private var selectedCard : CardEntity?
    private var service : Service?
    
    var scheduleAction : ((Service)->())?
    var rideNowAction : ((Service)->())?
    var paymentChangeClick : ((_ completion : @escaping ((CardEntity?)->()))->Void)?
    var onclickCoupon : ((_ couponList : [PromocodeEntity],_ selected : PromocodeEntity?, _ promo : ((PromocodeEntity?)->())?)->Void)?
    
    var selectedCoupon : PromocodeEntity? { // Selected Promocode
        didSet{
            if let percentage = selectedCoupon?.percentage, let maxAmount = selectedCoupon?.max_amount, let fare = self.service?.pricing?.estimated_fare{
                
                let discount = fare*(percentage/100)
                let discountAmount = discount > maxAmount ? maxAmount : discount
                self.setEstimationFare(amount: fare-discountAmount)
            }
            else {
                self.setEstimationFare(amount: self.service?.pricing?.estimated_fare)
            }
        }
    }
    
    private var availablePromocodes = [PromocodeEntity]() { // Entire Promocodes available for selection
        didSet {
            self.isPromocodeEnabled = availablePromocodes.count>0
        }
    }
    
    private var isWalletChecked = false {  // Handle Wallet
        didSet {
            self.imageViewWallet.image = isWalletChecked ? #imageLiteral(resourceName: "check") : #imageLiteral(resourceName: "check-box-empty")
            self.service?.pricing?.useWallet = isWalletChecked ? 1 : 0
        }
    }
    
    var paymentType : PaymentType = .NONE {
        didSet {
            var paymentString : String = .Empty
            if paymentType == .NONE {
                paymentString = Constants.string.NA.localize()
            }
            else if paymentType == .BRAINTREE {
                paymentString = PaymentType.BRAINTREE.rawValue.localize()
            }
            else if paymentType == .PAYTM {
                paymentString = PaymentType.PAYTM.rawValue.localize()
            }
            else if paymentType == .PAYUMONEY {
                paymentString = PaymentType.PAYUMONEY.rawValue.localize()
            }
            else {
                paymentString = paymentType == .CASH ? PaymentType.CASH.rawValue.localize() : (self.selectedCard == nil ? PaymentType.CARD.rawValue.localize() : "\("XXXX-"+String.removeNil(self.selectedCard?.last_four))")
            }
            let text = "\(Constants.string.payment.localize()): \(paymentString)"
            self.labelPaymentMode.text = text
            self.labelPaymentMode.attributeColor = .secondary
            self.labelPaymentMode.startLocation = ((text.count)-(paymentString.count))
            self.labelPaymentMode.length = paymentString.count
        }
    }
    
    private var isPromocodeEnabled = false {
        didSet {
            self.buttonCoupon.setTitle({
                if !isPromocodeEnabled {
                    return " \(Constants.string.NA.localize().uppercased()) "
                }
                else {
                    return self.selectedCoupon != nil ? " \(String.removeNil(self.selectedCoupon?.promo_code)) " : " \(Constants.string.viewCoupons.localize()) "
                }
            }(), for: .normal)
            UIView.animate(withDuration: 0.2) {
                self.buttonCoupon.layoutIfNeeded()
            }
            self.buttonCoupon.isEnabled = isPromocodeEnabled
            self.buttonCoupon.alpha = isPromocodeEnabled ? 1 : 0.7
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialLoads()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.viewImageModalBg.makeRoundedCorner()
    }
}

// MARK:-  Local Methods

extension RequestSelectionView {
    
    //  Initial Loads
    
    private func initialLoads() {
        self.backgroundColor = .clear
        self.isWalletChecked = false
        self.localize()
        self.setDesign()
        self.viewUseWallet.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.useWalletAction)))
        self.paymentType = .NONE
        if (User.main.isCardAllowed == false){
            self.buttonChangePayment.isHidden = true
        }
        else {
            self.buttonChangePayment.isHidden = !(User.main.isCashAllowed || User.main.isCardAllowed)
        }
        //        self.buttonChangePayment.isHidden = !(User.main.isCashAllowed && User.main.isCardAllowed) // Change button enabled only if both payment modes are enabled
        self.buttonChangePayment.addTarget(self, action: #selector(self.buttonChangePaymentAction), for: .touchUpInside)
        self.buttonCoupon.addTarget(self, action: #selector(self.buttonCouponAction), for: .touchUpInside)
        self.isPromocodeEnabled = false
        self.presenter?.get(api: .promocodes, parameters: nil)
    }
    
    //  Set Designs
    
    private func setDesign() {
        
        Common.setFont(to: buttonRideNow, isTitle: true)
        Common.setFont(to: buttonScheduleRide, isTitle:  true)
        Common.setFont(to: labelUseWalletString)
        Common.setFont(to: labelEstimationFareString, isTitle: true)
        Common.setFont(to: labelEstimationFare, isTitle: true)
        Common.setFont(to: labelCouponString)
        Common.setFont(to: labelPaymentMode)
        Common.setFont(to: buttonChangePayment)
        Common.setFont(to: buttonCoupon)
        Common.setFont(to: labelWalletBalance, isTitle: true)
    }
    
    //  Localize
    
    private func localize() {
        
        self.labelUseWalletString.text = Constants.string.useWalletAmount.localize()
        self.buttonScheduleRide.setTitle(Constants.string.scheduleRide.localize().uppercased(), for: .normal)
        self.buttonRideNow.setTitle(Constants.string.rideNow.localize().uppercased(), for: .normal)
        self.labelEstimationFareString.text = Constants.string.estimatedFare.localize()
        self.labelCouponString.text = Constants.string.coupon.localize()
        self.buttonChangePayment.setTitle(Constants.string.change.localize().uppercased(), for: .normal)
    }
    
    func setValues(values : Service) {
        self.service = values
        self.viewUseWallet.isHidden = !(Float.removeNil(self.service?.pricing?.wallet_balance)>0)
        self.setEstimationFare(amount: self.service?.pricing?.estimated_fare)
        self.paymentType = User.main.isCashAllowed ? .CASH :( User.main.isCardAllowed ? .CARD : .NONE)
        self.imageViewModal.setImage(with: values.image, placeHolder: #imageLiteral(resourceName: "CarplaceHolder"))
        self.labelWalletBalance.text = "\(String.removeNil(User.main.currency)) \(Formatter.shared.limit(string: "\(Float.removeNil(self.service?.pricing?.wallet_balance))", maximumDecimal: 2))"
    }
    
    func setEstimationFare(amount : Float?) {
        self.labelEstimationFare.text = "\(User.main.currency ?? .Empty) \(Formatter.shared.limit(string: "\(amount ?? 0)", maximumDecimal: 2))"
    }
    
    @IBAction private func buttonScheduleAction(){
        self.service?.promocode = self.selectedCoupon
        self.scheduleAction?(self.service!)
    }
    
    @IBAction private func buttonRideNowAction(){
        self.service?.promocode = self.selectedCoupon
        self.rideNowAction?(self.service!)
    }
    
    @IBAction private func useWalletAction(){
        self.isWalletChecked = !isWalletChecked
        
    }
    @IBAction private func buttonCouponAction() {
        self.onclickCoupon?( self.availablePromocodes,self.selectedCoupon, { [weak self] selectedCouponCode in  // send Available couponlist and get the selected coupon entity
            self?.selectedCoupon = selectedCouponCode
            self?.isPromocodeEnabled = true
        })
    }
    @IBAction private func buttonChangePaymentAction() {
        self.paymentChangeClick?({ [weak self] selectedCard in
            self?.selectedCard = selectedCard
        })
    }
}

// MARK:- PostViewProtocol

extension RequestSelectionView : PostViewProtocol {
    func onError(api: Base, message: String, statusCode code: Int) {
        print(message)
    }
    
    func getPromocodeList(api: Base, data: [PromocodeEntity]) {
        self.availablePromocodes = data
    }
}

