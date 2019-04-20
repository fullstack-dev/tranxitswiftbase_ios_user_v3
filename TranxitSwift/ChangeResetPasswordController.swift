//
//  ChangeResetPasswordController.swift
//  User
//
//  Created by CSS on 29/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class ChangeResetPasswordController: UIViewController {
    
    //MARK:- IBOUtlets
    
    @IBOutlet private var viewNext: UIView!
    @IBOutlet private var textFieldOtpOrCurrentPassword : HoshiTextField!
    @IBOutlet private var textFieldNewPassword : HoshiTextField!
    @IBOutlet private var textFieldConfirmPassword : HoshiTextField!
    @IBOutlet private var scrollView : UIScrollView!
    @IBOutlet private var viewScroll : UIView!
    @IBOutlet private var buttonNext : UIButton!
    @IBOutlet private var labelDescription : UILabel!
    
    //MARK:- Local Variable
    
    private var userDataObject : UserDataResponse?
    
    private lazy var loader : UIView = {
        return createActivityIndicator(UIScreen.main.focusedView ?? self.view)
    }()
    
    var isChangePassword = true {
        didSet {
            //            self.textFieldNewPassword.isEnabled = isChangePassword
            //            self.textFieldConfirmPassword.isEnabled = isChangePassword
            self.labelDescription.isHidden = isChangePassword
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialLoads()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.viewNext.makeRoundedCorner()
        self.viewScroll.frame = self.scrollView.bounds
        self.scrollView.contentSize = self.viewScroll.bounds.size
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
}

//MARK:- Local Methods

extension ChangeResetPasswordController {
    
    private func initialLoads(){
        
        self.setDesigns()
        self.localize()
        self.view.dismissKeyBoardonTap()
        self.viewNext.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.nextAction)))
        self.buttonNext.addTarget(self, action: #selector(self.nextAction), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back-icon").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.backButtonClick))
        if #available(iOS 11.0, *), !isChangePassword {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        self.scrollView.addSubview(viewScroll)
        self.buttonNext.isHidden = !isChangePassword
        self.viewNext.isHidden = isChangePassword
        
    }
    
    func set(user : UserDataResponse){
        
        self.userDataObject = user
    }
    
    
    private func setDesigns(){
        
        //        self.textFieldEmail.borderInactiveColor = .lightGray
        //        self.textFieldEmail.placeholderColor = .gray
        //        self.textFieldEmail.textColor = .black
        self.textFieldOtpOrCurrentPassword.delegate = self
        self.textFieldNewPassword.delegate = self
        self.textFieldConfirmPassword.delegate = self
        Common.setFont(to: textFieldNewPassword)
        Common.setFont(to: textFieldConfirmPassword)
        Common.setFont(to: textFieldOtpOrCurrentPassword)
        Common.setFont(to: labelDescription)
    }
    
    
    private func localize(){
        
        self.textFieldOtpOrCurrentPassword.placeholder = (!isChangePassword ? Constants.string.enterOtp : Constants.string.enterCurrentPassword).localize()
        self.textFieldOtpOrCurrentPassword.isSecureTextEntry = (!isChangePassword ? false : true)
        self.textFieldConfirmPassword.placeholder = Constants.string.ConfirmPassword.localize()
        self.textFieldNewPassword.placeholder = Constants.string.newPassword.localize()
        self.navigationItem.title = (isChangePassword ? Constants.string.changePassword : Constants.string.resetPassword).localize()
        self.buttonNext.setTitle(Constants.string.changePassword.localize(), for: .normal)
        self.labelDescription.text = Constants.string.resetPasswordDescription.localize()
    }
    
    
    // Next View Tap Action
    
    @IBAction private func nextAction(){
        
        self.view.endEditingForce()
        
        if !self.isChangePassword { // viewNext shown only on Reset Password
            self.viewNext.addPressAnimation()
        }
        
        guard let otpCurrentPassword = self.textFieldOtpOrCurrentPassword.text, !otpCurrentPassword.isEmpty else {
            self.view.make(toast: (!isChangePassword ? Constants.string.enterOtp : Constants.string.enterCurrentPassword).localize()) {
                self.textFieldOtpOrCurrentPassword.becomeFirstResponder()
            }
            return
        }
        
        guard  let newPassword = self.textFieldNewPassword.text, !newPassword.isEmpty else {
            self.view.make(toast: Constants.string.enterNewpassword.localize()) {
                self.textFieldNewPassword.becomeFirstResponder()
            }
            return
        }
        
        guard  let confirmPassword = self.textFieldNewPassword.text, !confirmPassword.isEmpty else {
            self.view.make(toast: Constants.string.enterConfirmPassword.localize()) {
                self.textFieldConfirmPassword.becomeFirstResponder()
            }
            return
        }
        if !isChangePassword {
            guard let otpStr = self.textFieldOtpOrCurrentPassword.text,!otpStr.isEmpty else {
                self.view.make(toast: Constants.string.enterOtp.localize()) {
                    self.textFieldConfirmPassword.becomeFirstResponder()
                }
                return
            }
            if let enterOTP = textFieldOtpOrCurrentPassword.text {
                let isMatched = userDataObject?.otp == Int(enterOTP)
                if (!isMatched) {
                    self.view.make(toast: Constants.string.otpIncorrect.localize()) {
                        self.textFieldConfirmPassword.becomeFirstResponder()
                    }
                    return
                }
            }
        }
        
        
        if isChangePassword {
            self.userDataObject = UserDataResponse()
            self.userDataObject?.old_password = otpCurrentPassword
        }
        self.userDataObject?.password = newPassword
        self.userDataObject?.password_confirmation = confirmPassword
        self.loader.isHidden = false
        self.presenter?.post(api: isChangePassword ? .changePassword : .resetPassword, data: self.userDataObject?.toData())
    }
    
}

//MARK:- UITextFieldDelegate

extension ChangeResetPasswordController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if !isChangePassword, textField == textFieldOtpOrCurrentPassword, let enteredOtp = textField.text {
            
            let isMatched = userDataObject?.otp == Int(enteredOtp)
            
            if !isMatched {
                self.view.makeToast(Constants.string.otpIncorrect.localize(), point: CGPoint(x: self.view.frame.width/2, y: 100), title: nil, image: nil, completion: nil)
            }
            
            //            self.textFieldNewPassword.isEnabled = isMatched
            //            self.textFieldConfirmPassword.isEnabled = isMatched
        }
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
}

//MARK:- PostViewProtocol

extension ChangeResetPasswordController : PostViewProtocol {
    
    func onError(api: Base, message: String, statusCode code: Int) {
        DispatchQueue.main.async {
            self.view.make(toast: message)
            self.loader.isHidden = true
        }
    }
    
    func success(api: Base, message: String?) {
        
        if message != nil {
            DispatchQueue.main.async {
                showAlert(message: Constants.string.changePasswordMsg.localize(), okHandler: {
                    
                    if self.isChangePassword {
                        //                        if let loginVC = Router.user.instantiateViewController(withIdentifier: Storyboard.Ids.EmailViewController) as? EmailViewController {
                        //                            loginVC.isHideLeftBarButton = true
                        //                            let navigationControllerVC = UINavigationController(rootViewController: loginVC)
                        //                            self.navigationController?.present(navigationControllerVC, animated: true, completion: nil)
                        //                        }
                        self.forceLogout()
                    } else {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                    
                }, fromView: self)
            }
        }
    }
    
    func forceLogout(with message : String? = nil) {
        let user = User()
        user.id = User.main.id
        Webservice().retrieve(api: .logout, url: nil, data: user.toData(), imageData: nil, paramters: nil, type: .POST, completion: nil)
        DispatchQueue.main.async { // stopping timer on unauthorized status
            HomePageHelper.shared.stopListening()
        }
        clearUserDefaults()
        UIApplication.shared.windows.last?.rootViewController?.popOrDismiss(animation: true)
        let navigationController = UINavigationController(rootViewController: Router.user.instantiateViewController(withIdentifier: Storyboard.Ids.LaunchViewController))
        navigationController.isNavigationBarHidden = true
        
        UIApplication.shared.windows.first?.rootViewController = navigationController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
        if message != nil {
            UIApplication.shared.keyWindow?.makeToast(message)
        }
    }
}


