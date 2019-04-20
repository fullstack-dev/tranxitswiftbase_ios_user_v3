//
//  OfflineBookingViewController.swift
//  User
//
//  Created by CSS on 18/06/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit
import MessageUI

class OfflineBookingViewController: UIViewController {
    
    //MARK:- IBOutlets
    
    @IBOutlet private weak var viewCancel : UIView!
    @IBOutlet private weak var labelNoInternet : UILabel!
    @IBOutlet private weak var labelBookSMS : UILabel!
    @IBOutlet private weak var labelsmsCharge : UILabel!
    @IBOutlet private weak var labelDescription : UILabel!
    @IBOutlet private weak var buttonSend:Button!
    @IBOutlet private weak var buttonNoThanks : UIButton!
    
    //MARK:- Local Variable
    
    private var currentLocation : LocationCoordinate?
    private var mapHelper : GoogleMapsHelper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .popover// = true
        self.modalTransitionStyle = .coverVertical
        self.localize()
        self.setDesign()
        self.viewCancel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backButtonClick)))
        self.buttonSend.addTarget(self, action: #selector(self.buttonSendAction), for: .touchUpInside)
        self.buttonNoThanks.addTarget(self, action: #selector(self.buttonNoThanksAction), for: .touchUpInside)
        self.mapHelper = GoogleMapsHelper()
        self.buttonSend.isEnabled = false
        self.mapHelper?.getCurrentLocation(onReceivingLocation: { (location) in
            self.currentLocation = location.coordinate
            self.buttonSend.isEnabled = true
        })
        self.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.panAction(sender:))))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK:- Local Methods

extension OfflineBookingViewController  {
    
    //  Localize
    private func localize () {
        
        self.labelNoInternet.text = Constants.string.noInternet.localize()
        self.labelBookSMS.text = Constants.string.bookNowOffline.localize()
        self.labelsmsCharge.text = Constants.string.standardChargesApply.localize()
        self.buttonSend.setTitle(Constants.string.sendMyLocation.localize().uppercased(), for: .normal)
        self.buttonNoThanks.setTitle(Constants.string.noThanks.localize(), for: .normal)
        self.labelDescription.text = Constants.string.tapForCurrentLocation.localize()
    }
    
    //  Set Design
    private func setDesign() {
        Common.setFont(to: buttonNoThanks, size : 12)
        Common.setFont(to: buttonSend, size : 16)
        Common.setFont(to: labelDescription, size : 16)
        Common.setFont(to: labelsmsCharge, size : 10)
        Common.setFont(to: labelBookSMS, size : 20)
        Common.setFont(to: labelNoInternet, size : 20)
    }
    
    @IBAction private func buttonSendAction() {
        
        if self.currentLocation != nil {
            let text = Constants.string.iNeedCab.localize()+" \(self.currentLocation!.latitude),\(self.currentLocation!.longitude)"+Constants.string.donotEditMessage.localize()
            Common.sendMessage(to: [User.main.dispatcherNumber ?? offlineNumber], text: text, from: self)
        }
    }
    
    @IBAction private func buttonNoThanksAction() {
        AppDelegate.shared.stopReachability()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func panAction(sender : UIPanGestureRecognizer) {
        
        if sender.state == .began || sender.state == .changed {
            let point = sender.translation(in: self.view)
            guard point.y > 0 else { return }
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y = point.y
            }
            print(point)
            if point.y > (UIScreen.main.bounds.height/4) {
                self.backButtonClick()
            }
        }
        else {
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin = .zero
            }
        }
    }
}

//MARK:- MFMessageComposeViewControllerDelegate

extension OfflineBookingViewController : MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
