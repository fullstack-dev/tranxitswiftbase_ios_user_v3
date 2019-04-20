//
//  Presenter.swift
//  User
//
//  Created by imac on 12/19/17.
//  Copyright © 2017 Appoets. All rights reserved.
//

import Foundation


class Presenter  {
    
    var interactor: PostInteractorInputProtocol?
    var controller: PostViewProtocol?
}

//MARK:- Implementation PostPresenterInputProtocol

extension Presenter : PostPresenterInputProtocol {

    func put(api: Base, url: String, data: Data?) {
        interactor?.send(api: api, url: url, data: data, type: .PUT)
    }
    
    func delete(api: Base, url: String, data: Data?) {
        interactor?.send(api: api, url: url, data: data, type: .DELETE)
    }
    
    func patch(api: Base, url: String, data: Data?) {
        interactor?.send(api: api, url: url, data: data,type: .PATCH)
    }
    
    func post(api: Base, data: Data?) {
        interactor?.send(api: api, data: data, paramters: nil, type: .POST)
    }
    
    func get(api: Base, parameters: [String : Any]?) {
        interactor?.send(api: api, data: nil, paramters: parameters, type: .GET)
    }
    
    func get(api : Base, url : String){
        interactor?.send(api: api, url: url, data: nil, type: .GET)
    }
    
    func post(api: Base, imageData: [String : Data]?, parameters: [String : Any]?) {
        interactor?.send(api: api, imageData: imageData, parameters: parameters)
    }
    
    func post(api: Base, url: String, data: Data?) {
        interactor?.send(api: api, url: url, data: data,type: .POST)
    }
    
}


//MARK:- Implementation PostPresenterOutputProtocol

extension Presenter : PostPresenterOutputProtocol {
    func sendBrainTreeToken(api: Base, data: Data) {
        controller?.getBrainTreeToken(api: api, data: PresenterProcessor.shared.brainTreeToken(data: data)!)
    }
    
    func sendNotificationList(api: Base, data: Data) {
        controller?.getNotificationsMangerList(api: api, data: PresenterProcessor.shared.notifications(data: data))
    }
    
    func sendExtendTrip(api: Base, data: Data) {
        controller?.getExtendTrip(api: api, data: PresenterProcessor.shared.getExtendTrip(data: data)!)
    }
    
    func sendLostItem(api: Base, data: Data) {
        controller?.getDispute(api: api, data: PresenterProcessor.shared.getLostItem(data: data)!)
    }
    
    func sendDispute(api: Base, data: Data) {
        controller?.getDispute(api: api, data: PresenterProcessor.shared.getPostDispute(data: data)!)
    }
    
    func sendDisputeList(api: Base, data: Data) {
        controller?.getDisputeList(api: api, data: PresenterProcessor.shared.getDisputeList(data: data)!)
    }
    
    func sendReason(api: Base, data: Data) {
        controller?.getReason(api: api, data: PresenterProcessor.shared.getReasonData(data: data)!)
    }
    
    func sendSetting(api: Base, data: Data) {
        controller?.getSettings(api: api, data: PresenterProcessor.shared.getSettings(data: data)!)
    }
    
    
    func sendHelpAPI(api: Base, data: Data) {
        controller?.getHelp(api: api, data: PresenterProcessor.shared.getHelpAPI(data: data)!)
    }
    func sendPromocodeList(api: Base, data: Data) {
        controller?.getPromocodeList(api: api, data: PresenterProcessor.shared.getPromocodes(data: data))
    }
    
    func sendUserData(api: Base, data: Data) {
        controller?.getUserData(api: api, data: PresenterProcessor.shared.userData(data: data))
    }
    
    func onError(api: Base, error: CustomError) {
        
        controller?.onError(api: api, message: error.localizedDescription , statusCode: error.statusCode)
    }
    
    func sendOath(api: Base, data: Data) {
        
        controller?.getOath(api: api, data: PresenterProcessor.shared.loginRequest(data: data))
    }
    
    func sendProfile(api: Base, data: Data) {
        
        controller?.getProfile(api: api, data: PresenterProcessor.shared.profile(data: data))
    }
    
    func sendSuccess(api: Base, data: Data) {
        controller?.success(api: api, message: PresenterProcessor.shared.success(api: api, response: data))
    }
    
    func sendServicesList(api: Base, data: Data) {
        controller?.getServiceList(api: api, data: PresenterProcessor.shared.serviceList(data: data))
    }
    
    func sendProviderList(api: Base, data: Data) {
        controller?.getProviderList(api: api, data: PresenterProcessor.shared.providerList(data: data))
    }
    
    func sendEstimateFare(api: Base, data: Data) {
        controller?.getEstimateFare(api: api, data: PresenterProcessor.shared.estimateFare(data: data))
    }
    
    func sendRequest(api: Base, data: Data) {
        controller?.getRequest(api: api, data: PresenterProcessor.shared.request(data: data))
    }
    
    func sendRequestArray(api: Base, data: Data) {
        controller?.getRequestArray(api: api, data: PresenterProcessor.shared.requestArray(data: data))
    }
    
    func sendLocationService(api: Base, data: Data) {
        controller?.getLocationService(api: api, data: PresenterProcessor.shared.locationService(data: data))
    }
    
    func sendCouponWallet(api: Base, data: Data) {
        controller?.getCouponWallet(api: api, data: PresenterProcessor.shared.couponWallet(data: data))
    }
    
    func sendCardEntityList(api: Base, data: Data) {
        controller?.getCardEnities(api: api, data: PresenterProcessor.shared.getCards(data: data))
    }
    
    func sendWalletEntity(api: Base, data: Data) {
        controller?.getWalletEntity(api: api, data: PresenterProcessor.shared.getWalletEntity(data: data))
    }
    
    func sendBrainTreeEntity(api: Base, data: Data) {
        controller?.getWalletEntity(api: api, data: PresenterProcessor.shared.getWalletEntity(data: data))
    }
    
}


