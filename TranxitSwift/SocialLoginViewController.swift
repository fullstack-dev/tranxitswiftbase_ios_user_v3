//
//  SocailLoginViewController.swift
//  User
//
//  Created by CSS on 02/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit
import GoogleSignIn
import FacebookLogin
import FacebookCore
import AccountKit


class SocialLoginViewController: UITableViewController {
    
    //MARK:- Local Variable
    
    private let tableCellId = "SocialLoginCell"
    private var isfaceBook = false
    private var accessToken : String?
    
    private lazy var loader : UIView = {
        return createActivityIndicator(UIApplication.shared.keyWindow ?? self.view)
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
        self.navigationController?.isNavigationBarHidden = false
    }
}

// MARK:- Local Methods

extension SocialLoginViewController {
    
    private func initialLoads() {
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:  #imageLiteral(resourceName: "back-icon").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.backButtonClick))
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    private func localize() {
        
        self.navigationItem.title = Constants.string.chooseAnAccount.localize()
    }
    
    //  Socail Login
    
    private func didSelect(at indexPath : IndexPath) {
       
        accessToken = nil // reset access token
        switch (indexPath.section,indexPath.row) {
        case (0,0):
            self.facebookLogin()
            User.main.loginType = LoginType.facebook.rawValue
        case (0,1):
            self.googleLogin()
            User.main.loginType = LoginType.google.rawValue

        default:
            break
        }
        
    }
    
    
    // MARK:- Google Login
    
    private func googleLogin(){
        
        self.loader.isHidden = false
        self.isfaceBook = false
        
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    
    // MARK:- Facebook Login
    
    private func facebookLogin() {
        self.isfaceBook = true
        print("Facebook")
        let loginManager = LoginManager()
        loginManager.loginBehavior = .web
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self) { (loginResult) in
            switch loginResult {
            case .failed(let error):
                print(error)
                break
            case .cancelled:
                print("Cancelled")
                break
            case .success(_ , _, let accessToken):
                print(accessToken)
                self.accessToken = accessToken.authenticationToken
                self.accountKit()
                break
            }
        }
    }
    
    private func loadAPI(accessToken: String?,phoneNumber: Int?, loginBy: LoginType,country_code: String?){
        self.loader.isHidden = false
        let user = UserData()
        user.accessToken = accessToken
        user.device_id = UUID().uuidString
        user.device_token = deviceTokenString
        user.device_type = .ios
        user.login_by = loginBy
        user.mobile = phoneNumber
        user.country_code = "+\(country_code!)"
        let apiType : Base = isfaceBook ? .facebookLogin : .googleLogin
        self.presenter?.post(api: apiType, data: user.toData())
    }
    
    
    private func accountKit(){
        let accountKit = AKFAccountKit(responseType: .accessToken)
        let accountKitVC = accountKit.viewControllerForPhoneLogin()
        accountKitVC.enableSendToFacebook = true
        self.prepareLogin(viewcontroller: accountKitVC)
        self.present(accountKitVC, animated: true, completion: nil)
    }
    
    private func prepareLogin(viewcontroller : UIViewController&AKFViewController) {
        
        viewcontroller.delegate = self
        viewcontroller.uiManager = AKFSkinManager(skinType: .contemporary, primaryColor: .primary)
    }
    
}

// MARK:- AKFViewControllerDelegate
extension SocialLoginViewController : AKFViewControllerDelegate {
    
    func viewControllerDidCancel(_ viewController: (UIViewController & AKFViewController)!) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: (UIViewController & AKFViewController)!, didFailWithError error: Error!) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: (UIViewController & AKFViewController)!, didCompleteLoginWith accessToken: AKFAccessToken!, state: String!) {
        print(state)
        viewController.dismiss(animated: true) {
            //self.loader.isHidden = false
            //self.presenter?.post(api: .signUp, data: self.userSignUpInfo?.toData())
            
            AKFAccountKit(responseType: AKFResponseType.accessToken).requestAccount({ (account, error) in
                
                // self.accessToken = accessToken as! String
                guard let number = account?.phoneNumber?.phoneNumber, let code = account?.phoneNumber?.countryCode, let numberInt = Int(number) else {
                    self.onError(api: .addPromocode, message: .Empty, statusCode: 0)
                    return
                }
                
               
                let loginBy : LoginType = self.isfaceBook ? .facebook : .google
                
                self.loadAPI(accessToken: self.accessToken, phoneNumber: numberInt, loginBy: loginBy,country_code: code)
                
            })
            
        }
        
    }
}

// MARK:- TableView

extension SocialLoginViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let tableCell = tableView.dequeueReusableCell(withIdentifier: self.tableCellId, for: indexPath) as? SocialLoginCell {
            
            tableCell.labelTitle.text = (indexPath.row == 0 ? Constants.string.facebook : Constants.string.google).localize()
            tableCell.imageViewTitle.image = indexPath.row == 0 ?  #imageLiteral(resourceName: "fb_icon") :  #imageLiteral(resourceName: "google_icon")
            return tableCell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.didSelect(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}

//MARK:- Google Implementation


extension SocialLoginViewController : GIDSignInDelegate, GIDSignInUIDelegate{
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        self.loader.isHidden = true
        
        guard user != nil else {
            return
        }
        self.accessToken = user.authentication.accessToken
        print(user.profile, error)
        accountKit()
        //  UserData.main.set(name: String.removeNil(user.profile.name), email: String.removeNil(user.profile.email),image: String.removeNil(user.profile.imageURL(withDimension: 50).absoluteString))
        
    }
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        self.loader.isHidden = true
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        
        present( viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
}

extension SocialLoginViewController : PostViewProtocol {
    
    func onError(api: Base, message: String, statusCode code: Int) {
        DispatchQueue.main.async {
            self.loader.isHidden = true
            showAlert(message: message, okHandler: nil, fromView: self)
        }
    }
    func getProfile(api: Base, data: Profile?) {
        
        if api == .getProfile {
            Common.storeUserData(from: data)
            storeInUserDefaults()
            self.navigationController?.present(Common.setDrawerController(), animated: true, completion: nil)
        }
        loader.isHideInMainThread(true)
        
    }
    
    func getOath(api: Base, data: LoginRequest?) {
        if api == .facebookLogin || api == .googleLogin, let accessTokenString = data?.access_token {
            User.main.accessToken = accessTokenString
            User.main.refreshToken =  data?.refresh_token
            self.presenter?.get(api: .getProfile, parameters: nil)
        }
    }
}





class SocialLoginCell : UITableViewCell {
    
    @IBOutlet weak var imageViewTitle : UIImageView!
    @IBOutlet weak var labelTitle : UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setDesign()
    }
    
    // MARK:- Set Designs
    
    private func setDesign() {
        Common.setFont(to: self.labelTitle, isTitle: true)
    }
    
    
    
}

