//
//  FirebaseHelper.swift
//  User
//
//  Created by CSS on 01/03/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation
import FirebaseAuth

class FirebaseAuth {
    
    static let main = FirebaseAuth()
    
    private var verifiedId : String = .Empty
    
    //MARK:- Get Verification Id
    
    func getVerificationId(with number : String, verificationId : @escaping (Bool)->()){
        
        PhoneAuthProvider.provider().verifyPhoneNumber(number, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                print("Error on Firebase -  ", error.localizedDescription)
                
            }
            
            self.verifiedId = verificationID ?? .Empty
            
            verificationId(verificationID != nil)
            
        }
        
    }
    
    //MARK:- Authenticate
    
    func Authenticate(with verificationCode : String, isValid : @escaping (Bool)->()) {
        
        print("Otp Entered ",verificationCode)
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: self.verifiedId,
            verificationCode: verificationCode)
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        firebaseAuth.signIn(with: credential) { (user, error) in
            
            if error != nil {
                print("Error in Authenticating ", error?.localizedDescription ?? "")
            }
            
            isValid(user != nil)
            
            print("User  ", user ?? "" )
            
        }
        
    }
    
}
