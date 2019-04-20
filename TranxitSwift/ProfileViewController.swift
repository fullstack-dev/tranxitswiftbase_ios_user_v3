//
//  ProfileViewController.swift
//  User
//
//  Created by CSS on 04/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit
import AccountKit

class ProfileViewController: UITableViewController {
    
    //MARK:- IBOutlets
    
    @IBOutlet private weak var imageViewEdit : UIImageView!
    @IBOutlet private weak var viewImageChange : UIView!
    @IBOutlet private weak var imageViewProfile : UIImageView!
    @IBOutlet private weak var textFieldFirst : HoshiTextField!
    @IBOutlet private weak var textFieldLast : HoshiTextField!
    @IBOutlet private weak var textFieldPhone : HoshiTextField!
    @IBOutlet private weak var textFieldEmail : HoshiTextField!
    @IBOutlet private weak var buttonSave : UIButton!
    @IBOutlet private weak var buttonChangePassword : UIButton!
    @IBOutlet private weak var labelBusiness : UILabel!
    @IBOutlet private weak var labelPersonal : UILabel!
    @IBOutlet private weak var labelTripType : UILabel!
    @IBOutlet private weak var imageViewBusiness : UIImageView!
    @IBOutlet private weak var imageViewPersonal : UIImageView!
    @IBOutlet private weak var viewBusiness : UIView!
    @IBOutlet private weak var viewPersonal : UIView!
    @IBOutlet weak var QRCodeBtn: UIButton!
    
    //MARK:- Local Variable
    
    var QRView : QRCodeView?
    var dialCode: String?
    var dialNumber: String?
    private var changedImage : UIImage?
    private var accountKit : AKFAccountKit?
    
    private var tripType :TripType = .Business { // Store Radio option TripType
        didSet {
            self.imageViewBusiness.image = tripType == .Business ? #imageLiteral(resourceName: "radio-on-button") : #imageLiteral(resourceName: "circle-shape-outline")
            self.imageViewPersonal.image = tripType == .Personal ? #imageLiteral(resourceName: "radio-on-button") : #imageLiteral(resourceName: "circle-shape-outline")
        }
    }
    
    private lazy var loader : UIView = {
        
        return createActivityIndicator(UIScreen.main.focusedView ?? self.view)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialLoads()
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.setLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        //self.isEnabled = IQKeyboardManager.shared.enable
        //IQKeyboardManager.shared.enable = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
}

// MARK:-  Local Methods

extension ProfileViewController {
    
    private func initialLoads() {
        
        self.viewPersonal.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.setTripTypeAction(sender:))))
        self.viewBusiness.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.setTripTypeAction(sender:))))
        self.imageViewProfile.isUserInteractionEnabled = true
        [self.imageViewEdit, self.viewImageChange].forEach({$0?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.changeImage)))}) 
        self.buttonSave.addTarget(self, action: #selector(self.buttonSaveAction), for: .touchUpInside)
        self.buttonChangePassword.addTarget(self, action: #selector(self.changePasswordAction), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back-icon").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.backButtonClick))
        self.navigationItem.title = Constants.string.profile.localize()
        self.localize()
        self.setDesign()
        self.setProfile()
        self.view.dismissKeyBoardonTap()
        self.presenter?.get(api: .getProfile, parameters: nil)
        self.tableView.tableHeaderView?.bounds.size = CGSize(width: self.tableView.bounds.width, height: 200)
        self.buttonChangePassword.isHidden = (User.main.loginType != LoginType.manual.rawValue)
        self.navigationController?.isNavigationBarHidden = false
        self.textFieldPhone.isEnabled = false
        self.QRCodeBtn.addTarget(self, action: #selector(self.QRCodeBtnTapped(sender:)), for: .touchUpInside)
    }
    
    //  Set Profile Details
    
    private func setProfile(){
        
        let url = (User.main.picture?.contains(WebConstants.string.http) ?? false) ? User.main.picture : Common.getImageUrl(for: User.main.picture)
        
        Cache.image(forUrl: url) { (image) in
            DispatchQueue.main.async {
                self.imageViewProfile.image = image == nil ? #imageLiteral(resourceName: "userPlaceholder") : image
            }
        }
        
        //        Cache.image(forUrl: Common.getImageUrl(for: User.main.picture)) { (image) in
        //            DispatchQueue.main.async {
        //                self.imageViewProfile.image = image == nil ? #imageLiteral(resourceName: "userPlaceholder") : image
        //            }
        //        }
        self.textFieldFirst.text = User.main.firstName
        self.textFieldLast.text = User.main.lastName
        self.textFieldEmail.text = User.main.email
        self.textFieldPhone.text = "\(User.main.country_code ?? "")\(User.main.mobile ?? "")"
        self.dialNumber = User.main.mobile
        self.dialCode = User.main.country_code
    }
    
    // Set Designs
    
    private func setDesign() {
        
        var attributes : [ NSAttributedString.Key : Any ] = [.font : UIFont.systemFont(ofSize: 18, weight: .bold)]
        attributes.updateValue(UIColor.white, forKey: NSAttributedString.Key.foregroundColor)
        self.buttonSave.setAttributedTitle(NSAttributedString(string: Constants.string.save.localize().uppercased(), attributes: attributes), for: .normal)
        [textFieldFirst, textFieldLast, textFieldEmail, textFieldPhone].forEach({
            $0?.borderInactiveColor = nil
            $0?.borderActiveColor = nil
        })
        self.textFieldEmail.isEnabled = false
        
        Common.setFont(to: textFieldEmail)
        Common.setFont(to: textFieldFirst)
        Common.setFont(to: textFieldLast)
        Common.setFont(to: textFieldPhone)
        Common.setFont(to: buttonSave)
        Common.setFont(to: buttonChangePassword)
        Common.setFont(to: labelBusiness)
        Common.setFont(to: labelPersonal)
        Common.setFont(to: labelTripType)
    }
    
    //  Show Image
    
    @IBAction private func changeImage(){
        
        self.showImage { (image) in
            if image != nil {
                self.imageViewProfile.image = image?.resizeImage(newWidth: 200)
                self.changedImage = self.imageViewProfile.image
            }
        }
    }
    
    //  Trip Type Action
    
    @IBAction private func setTripTypeAction(sender : UITapGestureRecognizer) {
        
        guard let senderView = sender.view else { return }
        
        self.tripType = senderView == viewPersonal ? .Personal : .Business
    }
    
    //  Update Profile Details
    
    @IBAction private func buttonSaveAction(){
        
        self.view.endEditingForce()
        
        guard let firstName = self.textFieldFirst.text, firstName.count>0 else {
            UIScreen.main.focusedView?.make(toast: ErrorMessage.list.enterFirstName.localize())
            return
        }
        
        guard let lastName = self.textFieldLast.text, lastName.count>0 else {
            UIScreen.main.focusedView?.make(toast: ErrorMessage.list.enterLastName.localize())
            return
        }
        
        guard let mobile = self.textFieldPhone.text, mobile.count>0 else {
            UIScreen.main.focusedView?.make(toast: ErrorMessage.list.enterMobileNumber.localize())
            return
        }
        
        //        if self.textFieldPhone.text != User.main.mobile {
        //
        //            let user = User()
        //            user.mobile = self.textFieldPhone.text
        //            presenter?.post(api: .phoneNubVerify, data: user.toData())
        //
        //            self.accountKit = AKFAccountKit(responseType: .accessToken)
        //            let akPhone = AKFPhoneNumber(countryCode: "in", phoneNumber: "")
        //            let accountKitVC = accountKit?.viewControllerForPhoneLogin(with: akPhone, state: UUID().uuidString)
        //            accountKitVC!.enableSendToFacebook = true
        //            self.prepareLogin(viewcontroller: accountKitVC!)
        //            self.present(accountKitVC!, animated: true, completion: nil)
        //        }
        if self.textFieldPhone.text != User.main.mobile {
            
            let user = User()
            user.mobile = self.textFieldPhone.text
            presenter?.post(api: .phoneNubVerify, data: user.toData())
        }
        
        //        guard let email = self.textFieldEmail.text, email.count>0 else {
        //            UIScreen.main.focusedView?.make(toast: ErrorMessage.list.enterEmail.localize())
        //            return
        //        }
        
        //        guard Common.isValid(email: email) else {
        //            UIScreen.main.focusedView?.make(toast: ErrorMessage.list.enterValidEmail.localize())
        //            return
        //        }
        
        self.loader.isHidden = false
        let profile = Profile()
        profile.device_token = deviceTokenString
        profile.email = User.main.email
        profile.first_name = firstName
        profile.last_name = lastName
        profile.mobile = dialNumber
        profile.country_code = dialCode
        
        var json = profile.JSONRepresentation
        json.removeValue(forKey: "id")
        json.removeValue(forKey: "picture")
        json.removeValue(forKey: "access_token")
        json.removeValue(forKey: "currency")
        json.removeValue(forKey: "wallet_balance")
        json.removeValue(forKey: "sos")
        
        if self.changedImage != nil, let dataImg = self.changedImage!.pngData() {
            self.presenter?.post(api: .updateProfile, imageData: [WebConstants.string.picture : dataImg], parameters: json)
        } else {
            self.presenter?.post(api: .updateProfile, data: profile.toData())
        }
    }
    
    private func setLayout(){
        
        self.imageViewProfile.makeRoundedCorner()
        self.viewImageChange.frame.origin.y = self.imageViewProfile.frame.origin.y + ((self.imageViewProfile.frame.height/3)*2)
        self.imageViewEdit.frame.origin.y = self.viewImageChange.frame.origin.y+(self.viewImageChange.frame.height/6)
    }
    
    //  Localize
    
    private func localize() {
        
        self.textFieldFirst.placeholder = Constants.string.first.localize()
        self.textFieldLast.placeholder = Constants.string.last.localize()
        self.textFieldPhone.placeholder = Constants.string.phoneNumber.localize()
        self.textFieldEmail.placeholder = Constants.string.email.localize()
        self.labelTripType.text = Constants.string.tripType.localize()
        self.labelBusiness.text = Constants.string.business.localize()
        self.labelPersonal.text = Constants.string.personal.localize()
        self.buttonChangePassword.setTitle(Constants.string.lookingToChangePassword.localize(), for: .normal)
    }
    
    // Button Change Password Action
    
    @IBAction private func changePasswordAction() {
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.ChangeResetPasswordController) as? ChangeResetPasswordController {
            vc.isChangePassword = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func prepareLogin(viewcontroller : UIViewController&AKFViewController) {
        
        viewcontroller.delegate = self
        viewcontroller.uiManager = AKFSkinManager(skinType: .contemporary, primaryColor: .primary)
        viewcontroller.uiManager.theme?()?.buttonTextColor = .secondary
    }
    
    @IBAction private func editBtnAction(sender: UIButton) {
        
        self.accountKit = AKFAccountKit(responseType: .accessToken)
        let akPhone = AKFPhoneNumber(countryCode: "in", phoneNumber: "")
        let accountKitVC = accountKit?.viewControllerForPhoneLogin(with: akPhone, state: UUID().uuidString)
        accountKitVC!.enableSendToFacebook = true
        self.prepareLogin(viewcontroller: accountKitVC!)
        self.present(accountKitVC!, animated: true, completion: nil)
    }
    
    
    @IBAction private func QRCodeBtnTapped(sender : UIButton) {
        
        if let qrcodeUrl = User.main.qrcode_url {
            self.QRView = Bundle.main.loadNibNamed(XIB.Names.QRCodeView, owner: self, options: [:])?.first as? QRCodeView
            self.QRView?.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y-60, width: self.view.frame.width, height: self.view.frame.height)
            self.QRView?.QRImageView.setImage(url: URL(string: baseUrl+qrcodeUrl)!)
            self.view.addSubview(QRView!)
        }
    }
}

// MARK :- AKFViewControllerDelegate

extension ProfileViewController : AKFViewControllerDelegate {
    
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
                guard let number = account?.phoneNumber?.phoneNumber, let code = account?.phoneNumber?.countryCode, let numberInt = Int(code+number) else {
                    self.onError(api: .addPromocode, message: .Empty, statusCode: 0)
                    return
                }
                
                if let tempDialCode = account?.phoneNumber?.countryCode, let tempDialNumer = account?.phoneNumber?.phoneNumber {
                    self.dialNumber = tempDialNumer
                    self.dialCode = "+\(tempDialCode)"
                }
                
                print(numberInt)
                
                //                self.textFieldPhone.text = "\("+")\(String(numberInt))"
                
                self.textFieldPhone.text = "+\(numberInt)"
            })
        }
    }
}


// MARK:- TextField Delegate

extension ProfileViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return textField.resignFirstResponder()
    }
}

// MARK:- ScrollView Delegate

extension ProfileViewController {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard scrollView.contentOffset.y<0 else { return }
        
        print(scrollView.contentOffset)
        
        let inset = abs(scrollView.contentOffset.y/imageViewProfile.frame.height)
        
        self.imageViewProfile.transform = CGAffineTransform(scaleX: 1+inset, y: 1+inset)
        self.viewImageChange.transform = CGAffineTransform(scaleX: 1+inset, y: 1+inset)
        self.imageViewEdit.transform = CGAffineTransform(scaleX: 1+inset, y: 1+inset)
    }
}


// MARK:- PostviewProtocol

extension ProfileViewController : PostViewProtocol {
    
    func onError(api: Base, message: String, statusCode code: Int) {
        
        if api == .phoneNubVerify {
            self.textFieldPhone.shake()
            vibrate(with: .weak)
            DispatchQueue.main.async {
                self.textFieldPhone.resignFirstResponder()
            }
        }
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.make(toast: message)
            self.loader.isHidden = true
        }
    }
    
    func getProfile(api: Base, data: Profile?) {
        Common.storeUserData(from: data)
        storeInUserDefaults()
        DispatchQueue.main.async {
            self.loader.isHidden = true
            self.setProfile()
            if api == .updateProfile {
                UIApplication.shared.keyWindow?.make(toast: Constants.string.profileUpdated.localize())
            }
        }
    }
}
