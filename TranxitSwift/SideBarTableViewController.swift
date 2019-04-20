//
//  SideBarTableViewController.swift
//  User
//
//  Created by CSS on 02/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class SideBarTableViewController: UITableViewController {
    
    //MARK:- IBOutlets
    
    @IBOutlet private var imageViewProfile : UIImageView!
    @IBOutlet private var labelName : UILabel!
    @IBOutlet private var labelEmail : UILabel!
    @IBOutlet private var viewShadow : UIView!
    @IBOutlet private weak var profileImageCenterContraint : NSLayoutConstraint!
    
    // private let sideBarList = [Constants.string.payment,Constants.string.yourTrips,Constants.string.coupon,Constants.string.wallet,Constants.string.passbook,Constants.string.settings,Constants.string.help,Constants.string.share,Constants.string.inviteReferral,Constants.string.faqSupport,Constants.string.termsAndConditions,Constants.string.privacyPolicy,Constants.string.logout]
    
    //MARK:- Local Variables
    
    private var sideBarList = [Constants.string.payment,
                               Constants.string.yourTrips,
                               Constants.string.offer,
                               Constants.string.wallet,
                               Constants.string.passbook,
                               Constants.string.settings,
                               Constants.string.help,
                               Constants.string.share,
                               Constants.string.becomeADriver,
                               Constants.string.notifications,
                               Constants.string.invideFriends,
                               Constants.string.logout]
    
    private let cellId = "cellId"
    private var isReferalEnable = 0
    
    private lazy var loader : UIView = {
        
        return createActivityIndicator(self.view)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialLoads()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.localize()
        self.setValues()
        self.navigationController?.isNavigationBarHidden = true
        //self.prefersStatusBarHidden = true
       // DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.presenter?.get(api: .settings, parameters: nil)
      //  })
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.setLayers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // self.prefersStatusBarHidden = false
    }
}

// MARK:-  Local Methods

extension SideBarTableViewController {
    
    private func initialLoads() {
        
        // self.drawerController?.fadeColor = UIColor
        self.drawerController?.shadowOpacity = 0.2
        let fadeWidth = self.view.frame.width*(0.2)
        //self.profileImageCenterContraint.constant = 0//-(fadeWidth/3)
        self.drawerController?.drawerWidth = Float(self.view.frame.width - fadeWidth)
        self.viewShadow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageViewAction)))
    }
    
    //  Set Designs
    
    private func setLayers(){
        
        //self.viewShadow.addShadow()
        self.imageViewProfile.makeRoundedCorner()
        
    }
    
    //  Set Designs
    
    private func setDesigns () {
        
        Common.setFont(to: labelName)
        Common.setFont(to: labelEmail, size : 12)
    }
    
    // SetValues
    
    private func setValues(){
        
        let url = (User.main.picture?.contains(WebConstants.string.http) ?? false) ? User.main.picture : Common.getImageUrl(for: User.main.picture)
        
        Cache.image(forUrl: url) { (image) in
            DispatchQueue.main.async {
                self.imageViewProfile.image = image == nil ? #imageLiteral(resourceName: "userPlaceholder") : image
            }
        }
        self.labelName.text = String.removeNil(User.main.firstName)+" "+String.removeNil(User.main.lastName)
        self.labelEmail.text = User.main.email
        self.setDesigns()
    }
    
    //  Localize
    private func localize(){
        
        self.tableView.reloadData()
    }
    
    //  ImageView Action
    
    @IBAction private func imageViewAction() {
        
        let homeVC = Router.user.instantiateViewController(withIdentifier: Storyboard.Ids.ProfileViewController)
        (self.drawerController?.getViewController(for: .none) as? UINavigationController)?.pushViewController(homeVC, animated: true)
        self.drawerController?.closeSide()
    }
    
    
    //  Selection Action For TableView
    private func select(at indexPath : IndexPath) {
        
        switch (indexPath.section,indexPath.row) {
            
        case (0,0):
            self.push(to: Storyboard.Ids.PaymentViewController)
        case (0,1):
            fallthrough
        case (0,4):
            if let vc = self.drawerController?.getViewController(for: .none)?.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.YourTripsPassbookViewController) as? YourTripsPassbookViewController {
                vc.isYourTripsSelected = indexPath.row == 1
                if indexPath.row == 1{
                    vc.isFromTrips = true
                }
                (self.drawerController?.getViewController(for: .none) as? UINavigationController)?.pushViewController(vc, animated: true)
            }
        case (0,2):
            self.push(to: CouponCollectionViewController())
        case (0,3):
            self.push(to: Storyboard.Ids.WalletViewController)
        case (0,5):
            self.push(to: Storyboard.Ids.SettingTableViewController)
        case (0,6):
            self.push(to: Storyboard.Ids.HelpViewController)
        case (0,7):
            (self.drawerController?.getViewController(for: .none)?.children.first as? HomeViewController)?.share(items: ["\(AppName)", URL.init(string: baseUrl)!])
        case (0,8):
            Common.open(url: AppStoreUrl.driver.rawValue)
        case (0,9):
            self.push(to: Storyboard.Ids.NotificationController)
        case (0,10):
            self.push(to: Storyboard.Ids.ReferalController)
        case (0,11):
            self.logout()
            
        default:
            break
        }
    }
    
    private func push(to identifier : String) {
        let viewController = self.storyboard!.instantiateViewController(withIdentifier: identifier)
        (self.drawerController?.getViewController(for: .none) as? UINavigationController)?.pushViewController(viewController, animated: true)
    }
    
    private func push(to vc : UIViewController) {
        (self.drawerController?.getViewController(for: .none) as? UINavigationController)?.pushViewController(vc, animated: true)
    }
    
    // MARK:- Logout
    
    private func logout() {
        
        let alert = UIAlertController(title: nil, message: Constants.string.areYouSureWantToLogout.localize(), preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: Constants.string.logout.localize(), style: .destructive) { (_) in
            DispatchQueue.main.async {
                self.loader.isHidden = false
                self.presenter?.post(api: .logout, data: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: Constants.string.Cancel.localize(), style: .cancel, handler: nil)
        
        alert.view.tintColor = .primary
        alert.addAction(logoutAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}


// MARK:- TableViewDelegates

extension SideBarTableViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isReferalEnable == 0 && indexPath.row == 10 {
            return 0
        }
        return 50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableCell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        tableCell.textLabel?.textColor = .secondary
        tableCell.textLabel?.text = sideBarList[indexPath.row].localize().capitalizingFirstLetter()
        tableCell.textLabel?.textAlignment = .left
        Common.setFont(to: tableCell.textLabel!, isTitle: true)
        return tableCell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sideBarList.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.select(at: indexPath)
        self.drawerController?.closeSide()
    }
}


// MARK:- PostViewProtocol

extension SideBarTableViewController : PostViewProtocol {
    
    func onError(api: Base, message: String, statusCode code: Int) {
        
        DispatchQueue.main.async {
            self.loader.isHidden = true
            showAlert(message: message, okHandler: nil, fromView: self)
        }
    }
    
    func success(api: Base, message: String?) {
        DispatchQueue.main.async {
            self.loader.isHidden = true
            forceLogout()
        }
    }
    
    func getSettings(api: Base, data: SettingsEntity) {
        self.isReferalEnable = Int((data.referral?.referral)!)!
        self.tableView.reloadInMainThread()
    }
}

