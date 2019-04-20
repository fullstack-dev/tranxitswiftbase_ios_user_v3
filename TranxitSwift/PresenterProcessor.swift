//
//  PresenterProcessor.swift
//  User
//
//  Created by imac on 1/1/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation

class PresenterProcessor {

    static let shared = PresenterProcessor()

    func success(api : Base, response : Data)->String? {
        return response.getDecodedObject(from: DefaultMessage.self)?.message
    }
    
    //  Send Oath
    
    func loginRequest(data : Data)->LoginRequest? {
        return data.getDecodedObject(from: LoginRequest.self)
    }
    
    // Send Profile
    
    func profile(data : Data)->Profile? {
        return data.getDecodedObject(from: Profile.self)
    }
    
    //  UserData
    
    func userData(data : Data)->UserDataResponse? {
        return data.getDecodedObject(from: ForgotResponse.self)?.user
    }
    
    // Service List
    
    func serviceList(data : Data)->[Service] {
        return data.getDecodedObject(from: [Service].self) ?? []
    }
    
    // Provider List
    
    func providerList(data : Data)->[Provider] {
        return data.getDecodedObject(from: [Provider].self) ?? []
    }
    
    //  Estimate Fare
    
    func estimateFare(data : Data)->EstimateFare? {
        return data.getDecodedObject(from: EstimateFare.self)
    }
    
    // Send Request
    
    func request(data : Data)->Request?{
        return data.getDecodedObject(from: Request.self)
    }
    
    //  Your Trips Modal
    
    func requestArray (data : Data)->[Request] {
        return data.getDecodedObject(from: [Request].self) ?? []
    }
    
    //  Location Service
    
    func locationService(data : Data)->LocationService? {
        return data.getDecodedObject(from: LocationService.self)
    }
    
    //  Coupon Wallet
    
    func couponWallet(data : Data)->[CouponWallet]{
        return data.getDecodedObject(from: [CouponWallet].self) ?? []
    }
    
    //  Get Card
    
    func getCards(data : Data)->[CardEntity] {
        return data.getDecodedObject(from: [CardEntity].self) ?? []
    }
    
    //  Send Wallet Entity
    
    func getWalletEntity(data : Data)->WalletEntity? {
        return data.getDecodedObject(from: WalletEntity.self)
    }
    
    //  Send Promocodes
    
    func getPromocodes(data : Data)->[PromocodeEntity] {
        return data.getDecodedObject(from: PromoCodeList.self)?.promo_list ?? []
    }
    
    //  Help
    
    func getHelpAPI(data : Data)->HelpEntity? {
        return data.getDecodedObject(from: HelpEntity.self)
    }
    
    //  Settings
    
    func getSettings(data : Data)->SettingsEntity? {
        return data.getDecodedObject(from: SettingsEntity.self)
    }
    
    //  Reason
    
    func getReasonData(data : Data)->[ReasonEntity]? {
        return data.getDecodedObject(from: [ReasonEntity].self) ?? []
    }
    
    //  Get DisputeList
    
    func getDisputeList(data : Data)->[DisputeList]? {
        return data.getDecodedObject(from: [DisputeList].self) ?? []
    }
    
    //  Send Dispute
    
    func getPostDispute(data : Data)->DisputeList? {
        return data.getDecodedObject(from: DisputeList.self)
    }
    
    //  Lost Item
    
    func getLostItem(data : Data)->DisputeList? {
        return data.getDecodedObject(from: DisputeList.self)
    }
    
    //  Extend Trip
    
    func getExtendTrip(data : Data)->ExtendTrip? {
        return data.getDecodedObject(from: ExtendTrip.self)
    }
    
    //  Notification
    
    func notifications(data : Data)->[NotificationManagerModel]? {
        
        return data.getDecodedObject(from: [NotificationManagerModel].self)
    }
    
    func brainTreeToken(data : Data)->TokenEntity? {
        
        return data.getDecodedObject(from: TokenEntity.self)
    }
}






