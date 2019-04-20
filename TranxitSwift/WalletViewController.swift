//
//  WalletViewController.swift
//  User
//
//  Created by CSS on 24/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit
import IHKeyboardAvoiding
import PaymentSDK
import BraintreeDropIn
import Braintree

class WalletViewController: UIViewController {
    
    //MARK:- IBOutlets
    @IBOutlet private weak var labelBalance : Label!
    @IBOutlet private weak var textFieldAmount : UITextField!
    @IBOutlet private weak var viewWallet : UIView!
    @IBOutlet private weak var buttonAddAmount : UIButton!
    @IBOutlet var labelWallet: UILabel!
    @IBOutlet var labelAddMoney: UILabel!
    @IBOutlet private var buttonsAmount : [UIButton]!
    @IBOutlet private weak var viewCard : UIView!
    @IBOutlet private weak var labelCard: UILabel!
    @IBOutlet private weak var buttonChange : UIButton!
    
    //MARK:- Local variable
    
    private var selectedCardEntity : CardEntity?
    
    private var isWalletEnabled : Bool = false {
        didSet{
            self.buttonAddAmount.isEnabled = isWalletEnabled
            self.buttonAddAmount.backgroundColor = isWalletEnabled ? .primary : .lightGray
            self.viewCard.isHidden = !isWalletEnabled
        }
    }
    
    private var isWalletAvailable : Bool = false {
        didSet {
            self.buttonAddAmount.isHidden = !isWalletAvailable
            self.viewCard.alpha = CGFloat(isWalletAvailable ? 1 : 0)
            self.viewWallet.alpha = CGFloat(isWalletAvailable ? 1 : 0)
        }
    }
    
    private lazy var loader  : UIView = {
        return createActivityIndicator(self.view)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setDesign()
        self.initalLoads()
        self.presenter?.get(api: .getCards, parameters: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.isWalletAvailable = User.main.isCardAllowed
        self.setWalletBalance()
        self.presenter?.get(api: .getProfile, parameters: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       // IQKeyboardManager.sharedManager().enable = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

// Mark:- Local methods

extension WalletViewController {
    
    private func initalLoads() {
        
        self.view.dismissKeyBoardonTap()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back-icon").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.backButtonClick))
        self.navigationItem.title = Constants.string.wallet.localize()
        self.textFieldAmount.placeholder = String.removeNil(User.main.currency)+" "+"\(0)"
        self.textFieldAmount.delegate = self
        for (index,button) in buttonsAmount.enumerated() {
            button.tag = (index*100)+99
            button.setTitle(String.removeNil(String.removeNil(User.main.currency)+" \(button.tag)"), for: .normal)
        }
        self.buttonChange.addTarget(self, action: #selector(self.buttonChangeCardAction), for: .touchUpInside)
        self.isWalletEnabled = false
        KeyboardAvoiding.avoidingView = self.view
    }
    
    // Set Designs
    
    private func setDesign() {
        
        Common.setFont(to: labelBalance, isTitle: true)
        Common.setFont(to: textFieldAmount)
        Common.setFont(to: labelCard)
        Common.setFont(to: buttonChange)
        buttonChange.setTitle(Constants.string.change.localize(), for: .normal)
        labelAddMoney.text = Constants.string.addAmount.localize()
        labelWallet.text = Constants.string.yourWalletAmnt.localize()
        buttonAddAmount.setTitle(Constants.string.ADDAMT, for: .normal)
    }
    
    @IBAction private func buttonAmountAction(sender : UIButton) {
        
        textFieldAmount.text = "\(sender.tag)"
    }
    
    private func setCardDetails() {
        if let lastFour = self.selectedCardEntity?.last_four {
           self.labelCard.text = "XXXX-XXXX-XXXX-"+lastFour
        }
    }
    
    @IBAction private func buttonAddAmountClick() {
        self.view.endEditingForce()
        guard let text = textFieldAmount.text?.replacingOccurrences(of: String.removeNil(User.main.currency), with: "").removingWhitespaces(),  text.isNumber, Float(text)! > 0  else {
            self.view.make(toast: Constants.string.enterValidAmount.localize())
            return
        }
        guard self.selectedCardEntity != nil else{
            return
        }
        self.loader.isHidden = false
        
        if self.labelCard.text == PaymentType.BRAINTREE.rawValue ||  self.labelCard.text == PaymentType.PAYTM.rawValue || self.labelCard.text == PaymentType.PAYUMONEY.rawValue {
            var requestObj = AddMoneyEntity()
            requestObj.amount = self.textFieldAmount.text
            requestObj.payment_mode = self.labelCard.text
            requestObj.type = UserType.user.rawValue
            self.presenter?.post(api: Base.addMoney, data: requestObj.toData())
        }
        else {
            let cardId = self.selectedCardEntity?.card_id
            self.selectedCardEntity?.strCardID = cardId
            self.selectedCardEntity?.payment_mode = PaymentType.CARD.rawValue
            self.selectedCardEntity?.user_type = UserType.user.rawValue
            self.selectedCardEntity?.amount = text
            self.presenter?.post(api: Base.addMoney, data: self.selectedCardEntity?.toData())
        }
    }
    
    //  Change Card Action
    
    @IBAction private func buttonChangeCardAction() {
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.PaymentViewController) as? PaymentViewController{
            vc.isChangingPayment = true
            vc.isShowCash = false
            vc.onclickPayment = { type, cardEntity in
                if type == PaymentType.BRAINTREE {
                    self.labelCard.text = PaymentType.BRAINTREE.rawValue
                }
                else if type == PaymentType.PAYTM {
                    self.labelCard.text = PaymentType.PAYTM.rawValue
                }
                else if type == PaymentType.PAYUMONEY {
                    self.labelCard.text = PaymentType.PAYUMONEY.rawValue
                }
                else {
                    self.selectedCardEntity = cardEntity
                    self.setCardDetails()
                }
                vc.navigationController?.dismiss(animated: true, completion: nil)
            }
            let navigation = UINavigationController(rootViewController: vc)
            self.present(navigation, animated: true, completion: nil)
        }
        
    }
    
    
    private func setWalletBalance() {
        DispatchQueue.main.async {
            self.labelBalance.text = String.removeNil(User.main.currency)+" \(User.main.wallet_balance ?? 0)"
        }
    }
}


extension WalletViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
     //   print(IQKeyboardManager.sharedManager().keyboardDistanceFromTextField)
    }
}

// MARK:- PostViewProtocol

extension WalletViewController : PostViewProtocol {
    
    func onError(api: Base, message: String, statusCode code: Int) {
        DispatchQueue.main.async {
            self.loader.isHidden = true
            showAlert(message: message, okHandler: nil, fromView: self)
        }
    }
    
    func getProfile(api: Base, data: Profile?) {
        Common.storeUserData(from: data)
        storeInUserDefaults()
        self.setWalletBalance()
    }
    
    func getCardEnities(api: Base, data: [CardEntity]) {
        self.selectedCardEntity = data.first
        DispatchQueue.main.async {
            self.setCardDetails()
            self.isWalletEnabled = !data.isEmpty
            if data.isEmpty && User.main.isCardAllowed {
                showAlert(message: Constants.string.addCard.localize(), okHandler: {
                   self.push(id: Storyboard.Ids.AddCardViewController, animation: true)
                }, cancelHandler: nil, fromView: self)
            }
        }
    }
   
    func getWalletEntity(api: Base, data: WalletEntity?) {
        
        DispatchQueue.main.async {
            self.loader.isHidden = true
            self.textFieldAmount.text = nil
        }
        switch self.labelCard.text {
        case PaymentType.BRAINTREE.rawValue:
            break
        case PaymentType.PAYTM.rawValue:
            break
        case PaymentType.PAYUMONEY.rawValue:
            break
        default:
            if let tempBalance = data?.wallet_balance {
                User.main.wallet_balance = tempBalance
                storeInUserDefaults()
                self.setWalletBalance()
            }
            UIApplication.shared.keyWindow?.makeToast(data?.message)
            break
        }
    }
}

//MARK:- PayTM Payment Gateway
extension WalletViewController {
    func makePaymentWithPaytm(paymentEntity: PayTmEntity?) {
        
        PGServerEnvironment().selectServerDialog(self.view, completionHandler: {(type: ServerType) -> Void in
            
            let tempAmount: String = "\((paymentEntity?.TXN_AMOUNT)!)"
            let tempCustomerId: String = "\((paymentEntity?.CUST_ID)!)"
            let tempOrderId: String = "\((paymentEntity?.ORDER_ID)!)"
            let tempemailId: String = "\((paymentEntity?.EMAIL)!)"
            let tempMobileNumber: String = "\((paymentEntity?.MOBILE_NO)!)"
            let tempMid: String = "\((paymentEntity?.MID)!)"
            let tempChannelId: String = "\((paymentEntity?.CHANNEL_ID)!)"
            let tempWebsite: String = "\((paymentEntity?.WEBSITE)!)"
            let tempIndustruyType: String = "\((paymentEntity?.INDUSTRY_TYPE_ID)!)"
            let tempChecksumhash: String = "\((paymentEntity?.CHECKSUMHASH)!)"
            let tempCallbackUrl: String = "\((paymentEntity?.CALLBACK_URL)!)"
            
            let type :ServerType = .eServerTypeStaging
//            let order = PGOrder(orderID: tempOrderId,
//                                customerID: tempCustomerId,
//                                amount: tempAmount,
//                                eMail: tempemailId,
//                                mobile: tempMobileNumber)
            
            var orderDic = [String: String]()
            orderDic[Constants().mid] = tempMid
            orderDic[Constants().orderId] = tempOrderId
            orderDic[Constants().custId] = tempCustomerId
            orderDic[Constants().mobileNo] = tempMobileNumber
            orderDic[Constants().emailId] =  tempemailId
            orderDic[Constants().channelId] = tempChannelId
            orderDic[Constants().website] = tempWebsite
            orderDic[Constants().txnAmount] = tempAmount
            orderDic[Constants().industryType] = tempIndustruyType
            orderDic[Constants().checksumhash] = tempChecksumhash
            orderDic[Constants().callbackUrl] = tempCallbackUrl
            
            let order = PGOrder()
            order.params = orderDic
            
            let txnController = PGTransactionViewController().initTransaction(for: order) as! PGTransactionViewController
            //                self.txnController = self.txnController?.initTransaction(for: order) as? PGTransactionViewController
            txnController.title = "Paytm Payments"
            txnController.setLoggingEnabled(true)
            if(type != ServerType.eServerTypeNone) {
                txnController.serverType = type
            } else {
                return
            }
            txnController.merchant = PGMerchantConfiguration.defaultConfiguration()
            txnController.delegate = self
            self.navigationController?.pushViewController(txnController, animated: true)
        })
    }
}

//MARK:- PGTransactionDelegate
extension WalletViewController: PGTransactionDelegate {
    //this function triggers when transaction gets finished
    func didFinishedResponse(_ controller: PGTransactionViewController, response responseString: String) {
        let msg : String = responseString
        var titlemsg : String = ""
        if let data = responseString.data(using: String.Encoding.utf8) {
            do {
                if let jsonresponse = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] , jsonresponse.count > 0{
                    titlemsg = jsonresponse["STATUS"] as? String ?? ""
                }
            } catch {
                print("Something went wrong")
            }
        }
        let actionSheetController: UIAlertController = UIAlertController(title: titlemsg , message: msg, preferredStyle: .alert)
        let cancelAction : UIAlertAction = UIAlertAction(title: "OK", style: .cancel) {
            action -> Void in
            controller.navigationController?.popViewController(animated: true)
        }
        actionSheetController.addAction(cancelAction)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    //this function triggers when transaction gets cancelled
    func didCancelTrasaction(_ controller : PGTransactionViewController) {
        controller.navigationController?.popViewController(animated: true)
    }
    //Called when a required parameter is missing.
    func errorMisssingParameter(_ controller : PGTransactionViewController, error : NSError?) {
        controller.navigationController?.popViewController(animated: true)
    }
}

//MARK:- BrainTree Payment
extension WalletViewController {
    
    func getBrainTreeToken(api: Base, data: TokenEntity) {
        guard let token: String = data.token else {
            return
        }
        self.showDropIn(newToken: token)
    }
    
    
    func showDropIn(newToken: String) {
        let newRequest =  BTDropInRequest()
        let dropIn = BTDropInController(authorization: newToken, request: newRequest)
        { (controller, result, error) in
            if (error != nil) {
                print("ERROR")
            } else if (result?.isCancelled == true) {
                print("CANCELLED")
            } else if let result = result {
                // Use the BTDropInResult properties to update your UI
                // result.paymentOptionType
                // result.paymentMethod
                // result.paymentIcon
                // result.paymentDescription
                print(result)
            }
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true, completion: nil)
    }
}

