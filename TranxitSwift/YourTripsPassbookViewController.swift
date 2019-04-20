//
//  yourTripViewController.swift
//  User
//
//  Created by CSS on 09/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit
import PopupDialog

class YourTripsPassbookViewController: UIViewController {
    
    //MARK:- IBOutlets
    
    @IBOutlet var pastBtn: UIButton!
    @IBOutlet var upCommingBtn: UIButton!
    @IBOutlet private var underLineView: UIView!
    @IBOutlet private var tableViewList : UITableView!
    @IBOutlet private weak var viewUpcomming : UIView!
    
    //MARK:- Local variable
    
    var isFromTrips:Bool = false
    var isYourTripsSelected = true  // Boolean Handle Passbook and Yourtrips list
    private var datasourceYourTripsUpcoming = [Request]()
    private var datasourceYourTripsPast = [Request]()
    private var datasourceCoupon = [CouponWallet]()
    private var datasourceWallet = [WalletTransaction]()
    
    var isFirstBlockSelected = true {
        didSet {
            self.animateUnderLine()
        }
    }
    
    private lazy var loader  : UIView = {
        return createActivityIndicator(UIApplication.shared.keyWindow ?? self.view)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initalLoads()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.animateUnderLine()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    //    override func viewWillAppear(_ animated: Bool) {
    //        super.viewWillAppear(animated)
    //        switchViewAction()
    //    }
    
    //    override func viewWillDisappear(_ animated: Bool) {
    //        super.viewWillDisappear(animated)
    //        self.navigationController?.isNavigationBarHidden = true
    //    }
    
}

//MARK:- Local methods

extension YourTripsPassbookViewController {
    
    private func initalLoads() {
        self.registerCell()
        self.switchViewAction()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back-icon").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.backButtonClick))
        self.navigationItem.title = (isYourTripsSelected ? Constants.string.yourTrips : Constants.string.passbook).localize()
        self.localize()
        self.getFromApi()
        self.setDesign()
    }
    
    //  Get Data From Api
    
    private func getFromApi() {
        self.loader.isHideInMainThread(false)
        if isYourTripsSelected {
            self.presenter?.get(api: .upcomingList, parameters: nil)
            self.presenter?.get(api: .historyList, parameters: nil)
        } else {
            self.presenter?.get(api: .walletPassbook, parameters: nil)
            self.presenter?.get(api: .couponPassbook, parameters: nil)
        }
    }
    
    //  Set Design
    
    private func setDesign () {
        
        Common.setFont(to: pastBtn, isTitle: true)
        Common.setFont(to: upCommingBtn, isTitle:  true)
        self.viewUpcomming.isHidden = !isYourTripsSelected
    }
    
    private func localize(){
        
        self.pastBtn.setTitle( isYourTripsSelected ? Constants.string.past.localize() : Constants.string.walletHistory.localize(), for: .normal)
        self.upCommingBtn.setTitle(isYourTripsSelected ? Constants.string.upcoming.localize() : Constants.string.couponHistory.localize(), for: .normal)
        
    }
    
    private func registerCell(){
        
        tableViewList.register(UINib(nibName: XIB.Names.YourTripCell, bundle: nil), forCellReuseIdentifier: XIB.Names.YourTripCell)
        tableViewList.register(UINib(nibName: XIB.Names.PassbookWalletTransaction, bundle: nil), forCellReuseIdentifier: XIB.Names.PassbookWalletTransaction)
        
    }
    
    // Animate Under Line
    
    private func animateUnderLine() {
        if self.underLineView != nil {
            UIView.animate(withDuration: 0.5) {
                let viewWidth = self.isFromTrips ? self.view.bounds.width/2 : 0.0
                self.underLineView.frame.origin.x = (selectedLanguage == .arabic ? !self.isFirstBlockSelected : self.isFirstBlockSelected) ? 0 : viewWidth//(self.view.bounds.width/2)
            }
        }
    }
    
    
    //  Empty View
    
    private func checkEmptyView() {
        
        self.tableViewList.backgroundView = {
            
            if (self.isYourTripsSelected ? getData().trips.count : getData().wallet.count) == 0 {
                let label = Label(frame: UIScreen.main.bounds)
                label.numberOfLines = 0
                Common.setFont(to: label, isTitle: true)
                label.center = UIApplication.shared.keyWindow?.center ?? .zero
                label.backgroundColor = .clear
                label.textColorId = 2
                label.textAlignment = .center
                label.text = {
                    
                    if isYourTripsSelected {
                        return (isFirstBlockSelected ? Constants.string.noPastTrips : Constants.string.noUpcomingTrips).localize()
                    } else {
                        return (isFirstBlockSelected ? Constants.string.noWalletHistory : Constants.string.noCouponDetail).localize()
                    }
                }()
                return label
            } else {
                return nil
            }
        }()
    }
    
    private func switchViewAction(){
        // self.pastUnderLineView.isHidden = false
        // self.isFirstBlockSelected = true
        self.pastBtn.tag = 1
        self.upCommingBtn.tag = 2
        self.pastBtn.addTarget(self, action: #selector(ButtonTapped(sender:)), for: .touchUpInside)
        self.upCommingBtn.addTarget(self, action: #selector(ButtonTapped(sender:)), for: .touchUpInside)
    }
    
    @IBAction func ButtonTapped(sender: UIButton){
        
        self.isFirstBlockSelected = sender.tag == 1
        self.reloadTable()
    }
    
    private func reloadTable() {
        DispatchQueue.main.async {
            self.loader.isHidden = true
            self.checkEmptyView()
            self.tableViewList.reloadInMainThread()
        }
    }
    
    //  Cancel Request
    
    private func cancelRequest(with requestId : Int) {
        
        let alert = PopupDialog(title: Constants.string.cancelRequest.localize(), message: Constants.string.cancelRequestDescription.localize())
        let cancelButton =  PopupDialogButton(title: Constants.string.no.localize(), action: {
            alert.dismiss()
        })
        cancelButton.titleColor = .primary
        let sureButton = PopupDialogButton(title: Constants.string.yes.localize()) {
            self.loader.isHidden = false
            let request = Request()
            request.request_id = requestId
            self.presenter?.post(api: .cancelRequest, data: request.toData())
        }
        sureButton.titleColor = .red
        alert.addButtons([cancelButton,sureButton])
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK:- UITableViewDelegate

extension YourTripsPassbookViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (isYourTripsSelected ? (215.0-(isFirstBlockSelected ? 20 : 0)) : 120)//*(UIScreen.main.bounds.height/568)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        UIView.animate(withDuration: 0.5) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        guard isYourTripsSelected else { return }
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.YourTripsDetailViewController) as? YourTripsDetailViewController, self.getData().trips.count>indexPath.row, let idValue = self.getData().trips[indexPath.row].id {
            vc.isUpcomingTrips = !isFirstBlockSelected
            vc.setId(id: idValue)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK:- UITableViewDataSource

extension YourTripsPassbookViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isYourTripsSelected ? getData().trips.count : getData().wallet.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.getCell(for: indexPath, in: tableView)
        cell.selectionStyle = .none
        return cell
    }
    
    private func getCell(for indexPath : IndexPath, in tableView : UITableView)->UITableViewCell {
        
        if isYourTripsSelected {
            if let cell = tableView.dequeueReusableCell(withIdentifier: XIB.Names.YourTripCell, for: indexPath) as? YourTripCell {
                cell.isPastButton = isFirstBlockSelected
                let datasource = (self.isFirstBlockSelected ? self.datasourceYourTripsPast : self.datasourceYourTripsUpcoming)
                if datasource.count>indexPath.row{
                    cell.set(values: datasource[indexPath.row])
                }
                cell.onClickCancel = { requestId in
                    self.cancelRequest(with: requestId)
                }
                return cell
            }
        } else {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: XIB.Names.PassbookWalletTransaction, for: indexPath) as? PassbookWalletTableViewCell {
                // cell.isWalletSelected = isFirstBlockSelected
                if isFirstBlockSelected {
                    if datasourceWallet.count>indexPath.row{
                        cell.set(value: datasourceWallet[indexPath.row])
                    }
                }
                //                else {
                //                    if datasourceCoupon.count>indexPath.row{
                //                        cell.set(values: datasourceCoupon[indexPath.row])
                //                    }
                //                }
                return cell
            }
            
        }
        return UITableViewCell()
    }
    
    private func getData()->(trips :[Request],wallet : [WalletTransaction], coupon :[CouponWallet]) {
        
        if isYourTripsSelected {
            return ((isFirstBlockSelected ? self.datasourceYourTripsPast : self.datasourceYourTripsUpcoming),[],[])
        } else {
            return ([],self.datasourceWallet,self.datasourceCoupon)
        }
    }
}

// MARK:- PostviewProtocol

extension YourTripsPassbookViewController : PostViewProtocol  {
    
    func onError(api: Base, message: String, statusCode code: Int) {
        print("Called", #function)
        DispatchQueue.main.async {
            self.loader.isHidden = true
            showAlert(message: message, okHandler: nil, fromView: self)
        }
    }
    
    func getRequestArray(api: Base, data: [Request]) {
        print("Called", #function,data)
        
        if api == .historyList {
            self.datasourceYourTripsPast = data
        } else if api == .upcomingList {
            self.datasourceYourTripsUpcoming = data
        }
        reloadTable()
    }
    
    func getCouponWallet(api: Base, data: [CouponWallet]) {
        
        if api == .couponPassbook {
            self.datasourceCoupon = data
        }
        reloadTable()
    }
    
    func success(api: Base, message: String?) {
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.makeToast(message)
        }
        self.getFromApi()
    }
    
    func getWalletEntity(api: Base, data: WalletEntity?) {
        if api == .walletPassbook {
            DispatchQueue.main.async {
                User.main.wallet_balance = data?.balance
                storeInUserDefaults()
            }
            self.datasourceWallet = data?.wallet_transation ?? []
            self.reloadTable()
        }
    }
    
}


