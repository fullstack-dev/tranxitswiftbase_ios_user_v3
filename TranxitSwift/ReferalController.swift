//
//  ReferalController.swift
//  Provider
//
//  Created by Ansar on 27/12/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class ReferalController: UIViewController {
    
    //MARK:- IBOutlets
    
    @IBOutlet private var viewShare : UIView!
    @IBOutlet private var lblReferMsg1 : Label!
    @IBOutlet private var lblReferMsg2 : Label!
    @IBOutlet private var lblReferralCode : UILabel!
    @IBOutlet private var lblReferHeading : UILabel!
    @IBOutlet private var imageGift : UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialLoads()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    
}

//MARK: - Local Methods

extension ReferalController {
    
    func initialLoads()  {
        SetNavigationcontroller()
        setCommonFont()
        localize()
        viewShare.makeRoundedCorner()
        self.imageGift.image = self.imageGift.image?.imageTintColor(color1: Color.valueFor(id: 2)!)
        self.lblReferralCode.text = User.main.referral_unique_id
        self.viewShare?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.shareReferal)))
    }
    
    private func setCommonFont(){
        Common.setFont(to: lblReferMsg1)
        Common.setFont(to: lblReferHeading)
        Common.setFont(to: lblReferralCode)
        
        if selectedLanguage == .arabic {
            self.lblReferMsg1.textAlignment = .right
            self.lblReferMsg2.textAlignment = .right
        }
        else {
            self.lblReferMsg1.textAlignment = .left
            self.lblReferMsg2.textAlignment = .left
        }
    }
    
    func SetNavigationcontroller(){
        
        if #available(iOS 11.0, *) {
            self.navigationController?.isNavigationBarHidden = false
            self.navigationController?.navigationBar.prefersLargeTitles = false
            self.navigationController?.navigationBar.barTintColor = UIColor.white
        } else {
            // Fallback on earlier versions
        }
        title = Constants.string.invideFriends.localize()
        
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back-icon").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.backBarButtonTapped(button:)))
    }
    
    @IBAction func backBarButtonTapped(button: UINavigationItem){
        self.popOrDismiss(animation: true)
    }
    
    //  Remove Recipt
    @IBAction private func shareReferal() {
        let  message = Constants.string.referalMessage.localize() + "\n\n" + "User: " + AppStoreUrl.user.rawValue + "\n Provider : " + AppStoreUrl.driver.rawValue + "\n\n" + Constants.string.installMessage.localize() + " \n " + User.main.referral_unique_id!
        let message1 = MessageWithSubject(subject: "Here is the subject", message: message)
        let itemsToShare:[Any] = [message1]
        //        self.share(items: [AppName,message])
        self.share(items: itemsToShare)
    }
    
    // Share Items
    
    func share(items : [Any]) {
        
        //        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        //        activityController.setValue("Test", forKey: "Subject")
        //        self.present(activityController, animated: true, completion: nil)
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = self.view
        self.present(activityController, animated: true, completion: nil)
    }
    
    func localize(){
        self.lblReferHeading.text = Constants.string.referHeading.localize()
        
        guard User.main.referral_text != nil else {
            return
        }
        guard User.main.referral_total_text != nil else {
            return
        }
        self.lblReferMsg1.attributedText = setAttributeString(htmlText: User.main.referral_text!)
        
        self.lblReferMsg2.attributedText = setAttributeString(htmlText: User.main.referral_total_text!)
        
    }
    
    func setAttributeString(htmlText:String) -> NSAttributedString {
        var attributedText = NSAttributedString()
        if let htmlData = htmlText.data(using: String.Encoding.unicode) {
            do {
                attributedText = try NSAttributedString(data: htmlData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
            } catch let e as NSError {
                print("Couldn't translate \(htmlText): \(e.localizedDescription) ")
            }
        }
        return attributedText
    }
}


//MARK:- UIActivityItemSource

class MessageWithSubject: NSObject, UIActivityItemSource {
    
    let subject:String
    let message:String
    
    init(subject: String, message: String) {
        self.subject = subject
        self.message = message
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return message
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return message
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        if activityType == UIActivity.ActivityType.mail {
            print("Mail")
        }
        return subject
    }
    
}
