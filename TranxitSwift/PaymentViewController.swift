//
//  PaymentViewController.swift
//  User
//
//  Created by CSS on 24/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit
import Stripe

class PaymentViewController: UITableViewController {
    
    //MARK:- IBOutlet Variable
    @IBOutlet private var buttonAddPayments : UIButton!
    
    //MARK:- Local Variable
    private let tableCellId = "tableCellId"
    private var headers = [Constants.string.paymentMethods]
    private var totalCount = [Int:Int]()
    
    // Boolean for Card selection whether to show or not
    var isShowCash = true
    var isChangingPayment = false
    var paymentTypeStr = ""
    var onclickPayment : ((PaymentType ,CardEntity?)->Void)? // Change payment Mode from Request
    private var cardsList = [CardEntity]()
    private lazy var loader  : UIView = {
        return createActivityIndicator(self.view)
    }()
    
    private let cashSection = 0
    private let cardSection = 4
    private let brainTreeSection = 1
    private let paytmSection = 2
    private let payumoneySection = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initalLoads()
        self.localize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.validatePaymentModes()
        //self.isEnabled = IQKeyboardManager.shared.enable
        //IQKeyboardManager.shared.enable = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
}

//MARK:- Local Methods
extension PaymentViewController {
    
    private func initalLoads() {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: (self.isChangingPayment ? #imageLiteral(resourceName: "close-1") : #imageLiteral(resourceName: "back-icon")).withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.backButtonAction))
        self.navigationItem.title = Constants.string.payment.localize()
        self.setDesign()
        self.buttonAddPayments.addTarget(self, action: #selector(self.buttonPaymentAction), for: .touchUpInside)
    }
    
    @IBAction private func backButtonAction() {
        
        if isChangingPayment {
            self.navigationController?.popOrDismiss(animation: true)
        } else {
            self.popOrDismiss(animation: true)
        }
        
    }
    
    // Validate Payment Types
    private func validatePaymentModes() {
        
        if User.main.isCardAllowed {
            self.presenter?.get(api: .getCards, parameters: nil)
        }
        self.buttonAddPayments.isHidden = !User.main.isCardAllowed
        self.isShowCash = (User.main.isCashAllowed && isShowCash)
        if !User.main.isCardAllowed && !User.main.isCashAllowed {
            self.headers = [Constants.string.allPaymentMethodsBlocked]
        }
        let isShowCashRow = (!User.main.isCashAllowed || !isShowCash) ? 0 : 1
        totalCount.updateValue(isShowCashRow, forKey: cashSection) // Cash rows
        
        let isBrainTreehRow = (!User.main.isBrainTreeAllowed) ? 0 : 1
        totalCount.updateValue(isBrainTreehRow, forKey: brainTreeSection) // BrainTreeh rows
        
        let isPayTmRow = (!User.main.isPaytmAllowed) ? 0 : 1
        totalCount.updateValue(isPayTmRow, forKey: paytmSection) // PayTM rows
        
        let isPayUMoney = (!User.main.isPayumoneyAllowed) ? 0 : 1
        totalCount.updateValue(isPayUMoney, forKey: payumoneySection) // PayU Money rows
        
        totalCount.updateValue(0, forKey: cardSection) // Card Row
        
    }
    
    //  Set Design
    private func setDesign () {
        
        Common.setFont(to: buttonAddPayments)
    }
    
    
    private func localize() {
        
        buttonAddPayments.setTitle(Constants.string.addCardPayments.localize(), for: .normal)
        
    }
    
    // Payment Button Action
    
    @IBAction private func buttonPaymentAction() {
        self.push(id: Storyboard.Ids.AddCardViewController, animation: true)
        
        //        let theme = STPTheme.default()
        //        theme.primaryForegroundColor = .primary
        //
        //        let config = STPPaymentConfiguration()
        //        config.requiredBillingAddressFields = .none
        //
        //        let cardController = STPAddCardViewController(configuration: config, theme: theme)
        //        cardController.delegate = self
        //        cardController.navigationItem.title = cardController.navigationItem.title?.localize()
        //        self.navigationController?.pushViewController(cardController, animated: true)
    }
    
    //  Swipe Action
    @available(iOS 11.0, *)
    private func swipeAction(at indexPath : IndexPath) -> UISwipeActionsConfiguration?{
        
        guard indexPath.section == 4 else { return nil}
        let entity = self.cardsList[indexPath.row]
        let contextAction = UIContextualAction(style: .normal, title: Constants.string.delete.localize()) { (action, view, bool) in
            let alert = UIAlertController(title: "XXXX-XXXX-XXXX-"+String.removeNil(self.cardsList[indexPath.row].last_four), message: Constants.string.areYouSureCard.localize(), preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: Constants.string.remove.localize(), style: .destructive, handler: { (_) in
                self.loader.isHidden = false
                var cardEntity = CardEntity()
                cardEntity.card_id = entity.card_id
                cardEntity._method = Constants.string.delete.uppercased()
                self.presenter?.post(api: .deleteCard, data: cardEntity.toData())
                bool(true)
            }))
            alert.addAction(UIAlertAction(title: Constants.string.Cancel.localize(), style: .cancel, handler: { _ in
                bool(true)
            }))
            alert.view.tintColor = .primary
            self.present(alert, animated: true, completion: nil)
        }
        contextAction.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [contextAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
        
    }
    
}

//MARK:- TableView

extension PaymentViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return totalCount.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let tableCell = tableView.dequeueReusableCell(withIdentifier: self.tableCellId, for: indexPath) as? PaymentCell {
            
            if indexPath.section == 0  {
                tableCell.imageViewPayment.image =  UIImage.init(named: "money_icon")
                tableCell.labelPayment.text = Constants.string.cash.localize()
                if paymentTypeStr == PaymentType.CASH.rawValue {
                    tableCell.accessoryType = .checkmark 
                }
            }else if indexPath.section == 1  {
                tableCell.imageViewPayment.image =  UIImage.init(named: "Braintree-logo")
                tableCell.labelPayment.text = Constants.string.braintree.localize()
                if paymentTypeStr == PaymentType.BRAINTREE.rawValue {
                    tableCell.accessoryType = .checkmark
                }
            }else if indexPath.section == 2  {
                tableCell.imageViewPayment.image =  UIImage.init(named: "Paytm_logo")
                tableCell.labelPayment.text = Constants.string.paytm.localize()
                if paymentTypeStr == PaymentType.PAYTM.rawValue {
                    tableCell.accessoryType = .checkmark
                }
            }else if indexPath.section == 3  {
                tableCell.imageViewPayment.image =  UIImage.init(named: "payumoney-logo")
                tableCell.labelPayment.text = Constants.string.Payumoney.localize()
                if paymentTypeStr == PaymentType.PAYUMONEY.rawValue {
                    tableCell.accessoryType = .checkmark
                }
            } else if self.cardsList.count > indexPath.row {
                tableCell.imageViewPayment.image =  UIImage.init(named: "visa")
                tableCell.labelPayment.text = "XXXX-XXXX-XXXX-"+String.removeNil(cardsList[indexPath.row].last_four)
                if paymentTypeStr == PaymentType.CARD.rawValue {
                    tableCell.accessoryType = cardsList[indexPath.row].is_default == 1 ? .checkmark : .none
                }
                
            }
            return tableCell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.totalCount[section] ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? headers[section].localize() : nil
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tempVal = self.totalCount[indexPath.section]
        return (tempVal == 0) ? 0 : 60
    }
    
    //    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    //        let tempVal = self.totalCount[section]
    //        return (tempVal == 0) ? 0 : 10
    //    }
    //
    //    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    //        let tempVal = self.totalCount[section]
    //        return (tempVal == 0) ? 0 : UITableView.automaticDimension
    //    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.5) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        guard self.isChangingPayment else { return }
        self.dismiss(animated: true) {
            if indexPath.section == 1 {
                self.onclickPayment?(.BRAINTREE, nil)
            }
            else if indexPath.section == 2 {
                self.onclickPayment?(.PAYTM, nil)
            }
            else if indexPath.section == 3 {
                self.onclickPayment?(.PAYUMONEY, nil)
            }
            else if indexPath.section == 4, self.cardsList.count > indexPath.row {
                self.onclickPayment?(.CARD ,self.cardsList[indexPath.row])
            }
            else {
                self.onclickPayment?(.CASH, nil)
            }
        }
    }
    
    @available(iOS 11.0, *)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 4 {
            return self.swipeAction(at: indexPath)
        }
        else {
            return UISwipeActionsConfiguration(actions: [])
        }
    }
}

//Mark:- PostViewProtocol

extension PaymentViewController : PostViewProtocol {
    
    func onError(api: Base, message: String, statusCode code: Int) {
        DispatchQueue.main.async {
            self.loader.isHidden = true
            showAlert(message: message, okHandler: nil, fromView: self)
        }
    }
    
    func getCardEnities(api: Base, data: [CardEntity]) {
        
        self.cardsList = data
        if User.main.isCardAllowed {
            self.totalCount.updateValue(self.cardsList.count, forKey: cardSection)
        }
        self.loader.isHideInMainThread(true)
        self.tableView.reloadInMainThread()
        
    }
    
    func success(api: Base, message: String?) {
        self.loader.isHideInMainThread(true)
        if api == .deleteCard {
            UIApplication.shared.keyWindow?.makeToast(message)
            self.presenter?.get(api: .getCards, parameters: nil)
        }
    }
}

//// MARK:- STPAddCardViewControllerDelegate
//
//extension PaymentViewController : STPAddCardViewControllerDelegate {
//
//    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
//
//        print("Stripe Token :: -> ",token);
//        addCardViewController.popOrDismiss(animation: true)
//
//    }
//
//
//    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
//
//        DispatchQueue.main.async {
//
//           addCardViewController.popOrDismiss(animation: true)
//
//        }
//
//    }
//}
//
//
//

// Mark:- UITableViewCell

class PaymentCell : UITableViewCell {
    
    @IBOutlet var imageViewPayment : UIImageView!
    @IBOutlet var labelPayment : UILabel!
}

