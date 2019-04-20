//
//  GooglePlacesHelper.swift
//  User
//
//  Created by CSS on 10/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation
import GooglePlaces

class GooglePlacesHelper : NSObject {
    
    private var fetcher : GMSAutocompleteFetcher?
    private var filter : GMSAutocompleteFilter?
    private var gmsAutoComplete : GMSAutocompleteViewController?
    private var prediction : (([GMSAutocompletePrediction])->Void)?
    private var placesCompletion : ((GMSPlace)->Void)?
    
    // MARK:- Initilaize Fetcher
    
    private func initFetcher() {
        if fetcher == nil {
            self.fetcher = GMSAutocompleteFetcher()
            self.filter = GMSAutocompleteFilter()
            self.fetcher?.autocompleteFilter = filter
            self.fetcher?.delegate = self
        }
    }
    
    // MARK:- Show Auto Complete Predictions
    
    func getAutoComplete(with stringKey : String?, with predications : @escaping ([GMSAutocompletePrediction])->Void) {
        
        self.initFetcher()
        self.fetcher?.sourceTextHasChanged(stringKey)
        self.prediction = predications
    }
    
    // MARK:- Get Google Auto Complete
    
    func getGoogleAutoComplete(completion : @escaping ((GMSPlace)->Void)){
        
        self.gmsAutoComplete = GMSAutocompleteViewController()
        self.gmsAutoComplete?.autocompleteFilter = filter
        self.gmsAutoComplete?.primaryTextColor = .primary
        self.gmsAutoComplete?.secondaryTextColor = .secondary
        self.gmsAutoComplete?.delegate = self
        self.placesCompletion = completion
        UIApplication.topViewController()?.present(self.gmsAutoComplete!, animated: true, completion: nil)
    }
}

// MARK:- GMSAutocompleteFetcher

extension GooglePlacesHelper : GMSAutocompleteFetcherDelegate {
    
    func didFailAutocompleteWithError(_ error: Error) {
        
        print("Places Fetcher Failed with Error ",error.localizedDescription)
    }
    
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        prediction?(predictions)
    }
}

extension GooglePlacesHelper : GMSAutocompleteViewControllerDelegate {
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        
        print("Error on places ",error.localizedDescription)
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.placesCompletion?(place)
        viewController.dismiss(animated: true, completion: nil)
    }
}
