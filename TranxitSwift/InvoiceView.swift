//
//  InvoiceView.swift
//  User
//
//  Created by CSS on 24/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class InvoiceView: UIView {
    
    //MARK :- IBOutlets
    
    @IBOutlet private weak var labelBookingString : UILabel!
    @IBOutlet private weak var labelBooking : UILabel!
    @IBOutlet private weak var labelDistanceTravelledString : UILabel!
    @IBOutlet private weak var labelDistanceTravelled : UILabel!
    @IBOutlet private weak var labelTimeTakenString : UILabel!
    @IBOutlet private weak var labelTimeTaken : UILabel!
    @IBOutlet private weak var labelBaseFareString : UILabel!
    @IBOutlet private weak var labelBaseFare : UILabel!
    @IBOutlet private weak var labelDistanceFareString : UILabel!
    @IBOutlet private weak var labelDistanceFare : UILabel!
    @IBOutlet private weak var labelTimeFareString : UILabel!
    @IBOutlet private weak var labelTimeFare : UILabel!
    @IBOutlet private weak var labelTax : UILabel!
    @IBOutlet private weak var labelTaxString : UILabel!
    @IBOutlet private weak var labelTipsString : UILabel!
    @IBOutlet private weak var buttonTips : UIButton!
    @IBOutlet private weak var labelTotalString : UILabel!
    @IBOutlet private weak var labelTotal : UILabel!
    @IBOutlet private weak var labelWalletString : UILabel!
    @IBOutlet private weak var labelWallet : UILabel!
    @IBOutlet private weak var labelDiscountString : UILabel!
    @IBOutlet private weak var labelDiscount : UILabel!
    @IBOutlet private weak var labelToPayString : UILabel!
    @IBOutlet private weak var labelToPay : UILabel!
    @IBOutlet private weak var labelPaymentType : Label!
    
    @IBOutlet private weak var buttonChangePayment : UIButton!
    @IBOutlet private weak var buttonPayNow : UIButton!
    @IBOutlet private weak var labelTitle : UILabel!
    @IBOutlet private weak var labelWaitingString : UILabel!
    @IBOutlet private weak var labelWaitingTime : UILabel!
    @IBOutlet private weak var labelTollChargeString : UILabel!
    @IBOutlet private weak var labelTollCharge : UILabel!
    @IBOutlet private weak var labelRoundOff : UILabel!
    @IBOutlet private weak var labelRoundOffValue : UILabel!
    
    @IBOutlet weak var labelWaitingAlertText: Label!
    @IBOutlet private weak var viewDistanceFare : UIView!
    @IBOutlet private weak var viewTimeFare : UIView!
    @IBOutlet private weak var viewTax : UIView!
    @IBOutlet private weak var viewWallet : UIView!
    @IBOutlet private weak var viewDiscount : UIView!
    @IBOutlet private weak var viewDistance: UIView!
    @IBOutlet private weak var viewTips : UIView!
    @IBOutlet private weak var viewWaitingTime : UIView!
    @IBOutlet private weak var viewTollCharge : UIView!
    @IBOutlet private weak var viewToPay : UIView!
    @IBOutlet private weak var viewRoundOff : UIView!
    @IBOutlet weak var viewWaitingTimeAlert: UIView!
    
    //MARK:- Local Variable
    
    var request : Request?
    var isShowingRecipt = false
    private var requestId = 0
    private var viewTipsXib : ViewTips?
    var selectedCard : CardEntity?
    
    var onClickPaynow : ((Float)->Void)?
    var onDoneClick : ((Bool)->Void)?
    var onClickChangePayment : ((_ completion : @escaping ((CardEntity)->()))->Void)?
    
    var paymentType : PaymentType = .NONE { // Check Payment Type
        didSet {
            if paymentType != oldValue {
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
                    paymentString = paymentType == .CASH ? PaymentType.CASH.rawValue.localize() : (self.selectedCard?.last_four==nil) ? PaymentType.CARD.rawValue.localize() : "XXXX-\(String.removeNil(self.selectedCard?.last_four))"
                }
                
                let text = "\(Constants.string.payment.localize()): \(paymentString)"
                self.labelPaymentType.text = text
                self.labelPaymentType.attributeColor = .secondary
                self.labelPaymentType.startLocation = ((text.count)-(paymentType.rawValue.localize().count))
                self.labelPaymentType.length = paymentType.rawValue.localize().count
                if (User.main.isCardAllowed == false){
                    self.buttonChangePayment.isHidden = true
                }else {
                    self.buttonChangePayment.isHidden = (isShowingRecipt && User.main.isCardAllowed)
                }
                self.viewTips.isHidden = !(self.paymentType == .CARD || isShowingRecipt)
                self.viewTips.isUserInteractionEnabled = !isShowingRecipt // Disable userInteraction to Tips if from Past trips
            }
        }
    }
    
    private var couponId : String? = nil {
        didSet {
            
        }
    }
    
    private var serviceCalculator : ServiceCalculator = .NONE {  // Hide Distance Fare and Time fare based on Service Calculator
        didSet {
            self.viewDistanceFare.isHidden = ![ServiceCalculator.DISTANCE, .DISTANCEHOUR, .DISTANCEMIN].contains(serviceCalculator)
            self.viewTimeFare.isHidden = ![ServiceCalculator.MIN, .HOUR,.DISTANCEHOUR, .DISTANCEMIN].contains(serviceCalculator)
        }
    }
    
    private var isUsingWallet = false {
        didSet {
            self.viewWallet.isHidden = !isUsingWallet
        }
    }
    
    private var isDiscountApplied = false {
        didSet {
            self.viewDiscount.isHidden = !self.isDiscountApplied
        }
    }
    
    private var tipsAmount : Float = 0 {
        didSet {
            self.updatePayment()
        }
    }
    
    private var total : Float = 0 {
        didSet{
            self.updatePayment()
        }
    }
    
    private var payyable : Float = 0 {
        didSet{
            self.updatePayment()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.intialLoads()
    }
}

// MARK:-  Local Methods

extension InvoiceView {
    
    func intialLoads() {
        self.buttonPayNow.addTarget(self, action: #selector(self.buttonPaynowAction), for: .touchUpInside)
        self.buttonChangePayment.addTarget(self, action: #selector(self.buttonChangePaymentAction), for: .touchUpInside)
        self.buttonChangePayment.setTitle(Constants.string.change.localize(), for: .normal)
        self.buttonTips.addTarget(self, action: #selector(self.buttonTipsAction(sender:)), for: .touchUpInside)
        self.tipsAmount = 0
        self.localize()
        self.setDesign()
        self.viewDistance.isHidden = true 
    }
    
    //  Set Designs
    
    private func setDesign() {
        
        Common.setFont(to: labelTitle, isTitle: true)
        Common.setFont(to: buttonPayNow, isTitle: true)
        Common.setFont(to: labelTotal, isTitle: true, size: 20)
        Common.setFont(to: labelTotalString, isTitle: true, size: 20)
        Common.setFont(to: labelToPay, isTitle: true, size: 20)
        Common.setFont(to: labelToPayString, isTitle: true, size: 20)
        Common.setFont(to: labelDiscount)
        Common.setFont(to: labelDiscountString)
        Common.setFont(to: labelBooking)
        Common.setFont(to: labelBookingString)
        Common.setFont(to: labelBaseFare)
        Common.setFont(to: labelBaseFareString)
        Common.setFont(to: labelDistanceFare)
        Common.setFont(to: labelDistanceFareString)
        Common.setFont(to: labelTimeFare)
        Common.setFont(to: labelTimeFareString)
        Common.setFont(to: labelTimeTaken)
        Common.setFont(to: labelTimeTakenString)
        Common.setFont(to: labelDistanceTravelled)
        Common.setFont(to: labelDistanceTravelledString)
        Common.setFont(to: labelTax)
        Common.setFont(to: labelTaxString)
        Common.setFont(to: labelTipsString)
        Common.setFont(to: labelWallet)
        Common.setFont(to: labelWalletString)
        Common.setFont(to: labelPaymentType)
        Common.setFont(to: buttonChangePayment)
        Common.setFont(to: labelWaitingTime)
        Common.setFont(to: labelWaitingString)
        Common.setFont(to: labelTollCharge)
        Common.setFont(to: labelTollChargeString)
        Common.setFont(to: labelRoundOff)
        Common.setFont(to: labelRoundOffValue)
        Common.setFont(to: labelWaitingAlertText)
    }
    
    
    
    //  Localize
    
    private func localize() {
        
        self.labelBookingString.text = Constants.string.bookingId.localize()
        self.labelDistanceTravelledString.text = Constants.string.distanceTravelled.localize()
        self.labelTimeTakenString.text = Constants.string.timeTaken.localize()
        self.labelBaseFareString.text = Constants.string.baseFare.localize()
        self.labelDistanceFareString.text = Constants.string.distanceFare.localize()
        self.labelTimeFareString.text = Constants.string.timeFare.localize()
        self.labelTaxString.text = Constants.string.tax.localize()
        self.labelTipsString.text = Constants.string.tips.localize()
        self.buttonTips.setTitle(Constants.string.addTips.localize(), for: .normal)
        self.labelTotalString.text = Constants.string.total.localize()
        self.labelWalletString.text = Constants.string.walletDeduction.localize()
        self.labelDiscountString.text = Constants.string.discount.localize()
        self.labelTitle.text = Constants.string.invoice.localize()
        self.labelWaitingString.text = Constants.string.WaitingTime.localize()
        self.labelTollChargeString.text = Constants.string.tollCharge.localize()
        self.labelRoundOff.text = Constants.string.roundOff.localize()
        self.labelWaitingAlertText.text = Constants.string.waitingAlertText.localize()
    }
    
    func set(request : Request) {
        self.request = request
        if (isShowingRecipt || request.paid == 1 || request.payment_mode == .CASH) {
            self.buttonPayNow.setTitle(Constants.string.Done.localize(), for: .normal)
        }
        else {
            self.buttonPayNow.setTitle(Constants.string.paynow.localize(), for: .normal)
        }
        self.labelToPayString.text = (isShowingRecipt ? Constants.string.paid : Constants.string.toPay).localize()
        self.labelBooking.text = request.booking_id
        
        self.labelDistanceTravelled.text = "\(Formatter.shared.limit(string: "\(request.distanceInt ?? 0)", maximumDecimal: 1)) \(String.removeNil(request.unit))"
        
        self.labelTimeTaken.text = "\(String.removeNil(request.travel_time)) \(Constants.string.mins.localize())"
        self.paymentType = request.payment_mode ?? .NONE
        self.serviceCalculator = request.service?.calculator ?? .NONE
        self.isUsingWallet = (request.payment?.wallet ?? 0)>0
        self.isDiscountApplied = (request.payment?.discount ?? 0)>0
        // Set Amount to Label
        func setAmount(to label : UILabel, with amount : Float?) {
            label.text = "\(String.removeNil(User.main.currency)) \(Formatter.shared.limit(string: "\(Float.removeNil(amount))", maximumDecimal: 2))"
        }
        setAmount(to: self.labelBaseFare, with: request.payment?.fixed)
        
        let distanceFare : Float = {
            if[ServiceCalculator.DISTANCE, .DISTANCEMIN, .DISTANCEHOUR].contains(self.serviceCalculator) {
                return request.payment?.distance ?? 0
            }
            return 0
        }()
        
        let timeFare : Float = {
            if [ServiceCalculator.MIN, .DISTANCEMIN].contains(self.serviceCalculator) {
                return request.payment?.minute ?? 0
            } else if [ServiceCalculator.HOUR, .DISTANCEHOUR].contains(self.serviceCalculator) {
                return request.payment?.minute ?? 0
            }
            return 0
        }()
        
        setAmount(to: self.labelDistanceFare, with: distanceFare)
        setAmount(to: self.labelTimeFare, with: timeFare)
        setAmount(to: self.labelTax, with: request.payment?.tax)
        setAmount(to: self.labelWallet, with: request.payment?.wallet)
        setAmount(to: self.labelDiscount, with: request.payment?.discount)
        setAmount(to: self.labelWaitingTime, with: request.payment?.waiting_amount)
        setAmount(to: self.labelTollCharge, with: request.payment?.toll_charge)
        setAmount(to: self.labelRoundOffValue, with: request.payment?.round_of)
        self.total = request.payment?.total ?? 0
        if self.tipsAmount == 0 {
            self.tipsAmount = request.payment?.tips ?? 0
        }
        if self.isShowingRecipt { // On recipt page
            self.payyable = self.total-((request.payment?.discount ?? 0)+(request.payment?.wallet ?? 0))
        }
        else { // On Invoice page
            self.payyable = request.payment?.payable ?? 0
        }
        if (request.payment_mode == .CASH && !isShowingRecipt) && (request.paid == 0){
            self.labelPaymentType.isHidden = false
            self.buttonPayNow.isHidden = false //true
        }
        else{
            self.buttonPayNow.isHidden = false
        }
        if (request.paid == 1){
            self.labelPaymentType.isHidden = true
            self.buttonChangePayment.isHidden = true
            self.buttonPayNow.isHidden = false
        }
        self.viewTips.isHidden = request.payment_mode == .CASH
        self.viewTimeFare.isHidden = timeFare == 0
        self.viewWaitingTime.isHidden = request.payment?.waiting_amount == 0
        self.viewTollCharge.isHidden = request.payment?.toll_charge == 0
        self.viewToPay.isHidden = request.payment?.payable == 0
        self.viewRoundOff.isHidden = request.payment?.round_of == 0
        
        if  request.payment?.waiting_amount == 0  ||  request.payment?.waiting_min_charge == 0 {
           
            self.viewWaitingTimeAlert.isHidden = false
        }
        else {
            self.viewWaitingTimeAlert.isHidden = true
        }
        self.viewWaitingTimeAlert.isHidden = request.payment?.waiting_amount != 0
    }
    
    private func updatePayment() {
        self.buttonTips.setTitle((tipsAmount>0 || self.isShowingRecipt) ? " \(String.removeNil(User.main.currency)) \(Formatter.shared.limit(string: "\(tipsAmount)", maximumDecimal: 2)) " : " \(Constants.string.addTips.localize()) ", for: .normal)
        self.labelTotal.text = "\(String.removeNil(User.main.currency)) \(Formatter.shared.limit(string: "\(tipsAmount+total)", maximumDecimal: 2))"
        self.labelToPay.text = "\(String.removeNil(User.main.currency)) \(Formatter.shared.limit(string: "\(tipsAmount+payyable)", maximumDecimal: 2))"
    }
    
    @IBAction private func buttonPaynowAction() {
        if buttonPayNow.titleLabel?.text == Constants.string.Done{
            if request?.paid == 0 {
                self.makeToast(Constants.string.confirmPayment.localize(), duration: 1.0, position: .center)
                return
            }
            self.onDoneClick?(true)
        }else{
            self.onClickPaynow?(self.tipsAmount)
        }
    }
    
    //  Change Payment Type
    @IBAction private func buttonChangePaymentAction() {
        self.onClickChangePayment?({ [weak self] card in
            self?.selectedCard = card
        })
    }
    
    @IBAction private func buttonTipsAction(sender : UIButton){
        
        if self.viewTipsXib == nil {
            self.viewTipsXib = ViewTips(frame: .zero)
            self.viewTipsXib?.alpha = 0
            self.viewTipsXib?.backgroundColor = .white
            self.viewTipsXib?.addBackgroundView(in: self, gesture: UITapGestureRecognizer(target: self, action: #selector(self.dismissTipsView)))
            self.addSubview(self.viewTipsXib!)
            UIView.animate(withDuration: 0.5) {
                self.viewTipsXib?.alpha = 1
            }
            self.viewTipsXib?.translatesAutoresizingMaskIntoConstraints = false
            self.viewTipsXib?.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0 ).isActive = true
            self.viewTipsXib?.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0 ).isActive = true
            self.viewTipsXib?.heightAnchor.constraint(equalToConstant: 150).isActive = true
            self.viewTipsXib?.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8).isActive = true
            self.viewTipsXib?.tipsAmount = tipsAmount
            self.viewTipsXib?.onClickSubmit = { value in
                self.tipsAmount = value
                self.dismissTipsView()
            }
        }
        self.viewTipsXib?.total = self.total
    }
    
    @IBAction private func dismissTipsView() {
        self.removeBackgroundView()
        UIView.animate(withDuration: 0.5, animations: {
            self.viewTipsXib?.alpha = 0
        }) { (_) in
            self.viewTipsXib?.removeFromSuperview()
            self.viewTipsXib = nil
        }
    }
}
