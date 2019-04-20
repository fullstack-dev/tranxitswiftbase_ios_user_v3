//
//  LocationSelectionView.swift
//  User
//
//  Created by CSS on 09/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit
import GooglePlaces

class LocationSelectionView: UIView {
    
    // Mark:- IBOutlets
    
    @IBOutlet weak var viewTop : UIView!
    @IBOutlet weak var tableViewBottom : UITableView!
    @IBOutlet private weak var viewBack : UIView!
    @IBOutlet  weak var textFieldSource : UITextField!
    @IBOutlet  weak var textFieldDestination : UITextField!
    
    // @IBOutlet private weak var viewSourceCancel : UIView!
    //@IBOutlet private weak var viewDestinationCancel : UIView!
    
    // Mark:- Local Variables
    
    private var googlePlacesHelper : GooglePlacesHelper?
    private var locationSerivce : LocationService?
    
    typealias Address = (source : Bind<LocationDetail>?,destination : LocationDetail?)
    
    private var completion : ((Address)->Void)? // On dismiss send address
    
    private var address : Address? // Current Address
    {
        didSet{
            if address?.source != nil {
                self.textFieldSource.text = self.address?.source?.value?.address
            }
            if address?.destination != nil {
                self.textFieldDestination.text = self.address?.destination?.address
            }
        }
    }
    
    //    private var sections = 2 // show Favourite if no search text is entered
    
    private var datasource = [GMSAutocompletePrediction]() {  // Predictions List
        didSet {
            DispatchQueue.main.async {
                print("Reloaded")
                self.tableViewBottom.reloadData()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialLoads()
        self.setDesign()
    }
}

// MARK:- Local Methods

extension LocationSelectionView {
    
    // Set Designs
    
    private func setDesign() {
        
        Common.setFont(to: textFieldSource)
        Common.setFont(to: textFieldDestination)
    }
    
    private func localize() {
        
        self.textFieldSource.placeholder = Constants.string.source.localize()
        self.textFieldDestination.placeholder = Constants.string.destination.localize()
    }
    
    private func initialLoads() {
        self.localize()
        self.googlePlacesHelper = GooglePlacesHelper()
        self.tableViewBottom.isHidden = true
        self.viewTop.alpha = 0
        UIView.animate(withDuration: 0.2, animations: {
            self.viewTop.alpha = 1
        }) { _ in
            self.tableViewBottom.isHidden = false
            self.tableViewBottom.show(with: .bottom, duration: 0.3, completion: nil)
        }
        self.tableViewBottom.delegate = self
        self.tableViewBottom.dataSource = self
        self.textFieldSource.delegate = self
        self.textFieldDestination.delegate = self
        self.tableViewBottom.register(UINib(nibName: XIB.Names.LocationTableViewCell, bundle: nil), forCellReuseIdentifier:XIB.Names.LocationTableViewCell)
        self.tableViewBottom.register(UINib(nibName: XIB.Names.LocationHeaderTableViewCell, bundle: nil), forCellReuseIdentifier:XIB.Names.LocationHeaderTableViewCell)
        self.viewBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backButtonAction)))
        self.textFieldSource.isEnabled = ![RideStatus.accepted, .arrived, .pickedup, .started].contains(riderStatus)
    }
    
    func setValues(address : Address, completion :@escaping (Address)->Void){
        //self.endEditingForce()
        self.address = address
        self.completion = completion
        if self.address?.source == nil {
            self.textFieldSource.becomeFirstResponder()
        } else {
            self.textFieldDestination.becomeFirstResponder()
        }
    }
    
    @IBAction private func backButtonAction() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.tableViewBottom.frame.origin.y = self.tableViewBottom.frame.height
            self.viewTop.frame.origin.y = -self.viewTop.frame.height
        }) { (_) in
            self.isHidden = true
            self.removeFromSuperview()
        }
    }
    
    private func getPredications(from string : String?){
        
        self.googlePlacesHelper?.getAutoComplete(with: string, with: { (predictions) in
            self.datasource = predictions
        })
    }
    
    // Did Select at Indexpath
    
    private func select(at indexPath : IndexPath){
        
        if indexPath.section == 0 {
            
            if favouriteLocations[indexPath.row].location != nil {
                
                self.autoFill(with: favouriteLocations[indexPath.row].location)
                
            } else {
                
                self.googlePlacesHelper?.getGoogleAutoComplete(completion: { (place) in
                    
                    favouriteLocations[indexPath.row].location = (place.formattedAddress ?? .Empty, place.coordinate)
                    
                    let service = Service() // Save Favourite location in Server
                    service.address = place.formattedAddress
                    service.latitude = place.coordinate.latitude
                    service.longitude = place.coordinate.longitude
                    let type : CoreDataEntity = indexPath.row == 0 ? .home : .work
                    service.type = type.rawValue.lowercased()
                    CoreDataHelper().insert(data: (String.removeNil(place.formattedAddress), LocationCoordinate(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)), entityName: type) // Inserting into Local Storage
                    self.presenter?.post(api: Base.locationServicePostDelete, data: service.toData())
                    
                    DispatchQueue.main.async {
                        self.tableViewBottom.reloadData()
                        self.autoFill(with: favouriteLocations[indexPath.row].location)
                    }
                    
                })
            }
        } else {
            
            self.autoFill(with: (datasource[indexPath.row].attributedFullText.string, LocationCoordinate(latitude: 0, longitude: 0)))
            
            if datasource.count > indexPath.row {
                let placeID = datasource[indexPath.row].placeID
                GMSPlacesClient.shared().lookUpPlaceID(placeID ) { (place, error) in
                    
                    if error != nil {
                        
                        self.make(toast: error!.localizedDescription)
                        
                    } else if let addressString = place?.formattedAddress, let coordinate = place?.coordinate{
                        // print("\nselected ---- ",coordinate)
                        DispatchQueue.main.async {
                            self.autoFill(with: (addressString,coordinate))
                        }
                        
                    }
                }
            }
        }
    }
    
    //  Auto Fill At
    
    private func autoFill(with location : LocationDetail?){ //, with array : [T]
        
        if textFieldSource.isEditing {
            self.address?.source?.value = location//array  array [indexPath.row].location
            self.address?.source = self.address?.source // Temporary fix to call didSet
        } else {
            self.address?.destination = location
        }
        
        if self.address?.source?.value != nil, self.address?.destination != nil {
            self.completion?(self.address!)
            // print("\nselected ----->>",self.completion, self.address!.destination, self.address!.source?.value?.coordinate)
            self.backButtonAction()
        }
    }
    
    //  Get Table View Cell
    
    private func getCell(for indexPath : IndexPath)->UITableViewCell{
        
        if indexPath.section == 0 { // Favourite Locations
            
            if let tableCell = self.tableViewBottom.dequeueReusableCell(withIdentifier: XIB.Names.LocationHeaderTableViewCell, for: indexPath) as? LocationHeaderTableViewCell, favouriteLocations.count>indexPath.row {
                
                tableCell.textLabel?.text = favouriteLocations[indexPath.row].address.localize()
                tableCell.detailTextLabel?.text = favouriteLocations[indexPath.row].location?.address ?? Constants.string.addLocation.localize()
                Common.setFont(to: tableCell.textLabel!)
                Common.setFont(to: tableCell.detailTextLabel!, size : 12)
                return tableCell
            }
            
        } else  { // Predications
            
            if let tableCell = self.tableViewBottom.dequeueReusableCell(withIdentifier: XIB.Names.LocationTableViewCell, for: indexPath) as? LocationTableViewCell, datasource.count>indexPath.row{
                tableCell.imageLocationPin.image = #imageLiteral(resourceName: "ic_location_pin")
                let placesClient = GMSPlacesClient.shared()
                placesClient.lookUpPlaceID(datasource[indexPath.row].placeID , callback: { (place, error) -> Void in
                    if let error = error {
                        print("lookup place id query error: \(error.localizedDescription)")
                        return
                    }
                    if let place = place {
                        let formatAddress = place.formattedAddress
                        let addressName = place.name
                        let formatAddressString = formatAddress!.replacingOccurrences(of: "\(addressName ?? ""), ", with: "", options: .literal, range: nil)
                        tableCell.lblLocationTitle.text = addressName
                        tableCell.lblLocationSubTitle.text = formatAddressString
                    }
                })
                Common.setFont(to: tableCell.lblLocationTitle!)
                Common.setFont(to: tableCell.lblLocationSubTitle!)
                return tableCell
            }
        }
        return UITableViewCell()
    }
}

//MARK:-  UITableViewDelegate

extension LocationSelectionView : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return indexPath.section == 0 ? (datasource.count>0 ? 0 : 60) : 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        UIView.animate(withDuration: 0.5) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        self.select(at: indexPath)
    }
}

// MARK:- UITableViewDataSource

extension LocationSelectionView : UITableViewDataSource  {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2 //datasource.count == 0 ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (section == 0) ? (datasource.count>0 ? 0 : favouriteLocations.count) : datasource.count // && datasource.count==0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return self.getCell(for: indexPath)
    }
}

// MARK:- UITextFieldDelegate

extension LocationSelectionView : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.datasource = []
        self.getPredications(from: textField.text)
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.datasource = []
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        
        guard let text = textField.text, !text.isEmpty, range.location>0 || range.length>1 else {
            self.datasource = []
            return true
        }
        let searchText = text+string
        
        //        guard searchText.count else {
        //            return false
        //        }
        
        self.getPredications(from: searchText)
        
        print(textField.text ?? "", "  ", string, "   ", range.location, "  ", range.length)
        
        return true
    }
}

// MARK:- PostViewProtocol

extension LocationSelectionView : PostViewProtocol {
    
    func onError(api: Base, message: String, statusCode code: Int) {
        
        DispatchQueue.main.async {
            if let viewController = UIApplication.topViewController() {
                showAlert(message: message, okHandler: nil, fromView: viewController)
            }
        }
    }
    
    func getLocationService(api: Base, data: LocationService?) {
        
        storeFavouriteLocations(from: data)
    }
    
    func success(api: Base, message: String?) {
        
        if api == .locationServicePostDelete {
            self.presenter?.get(api: .locationService, parameters: nil)
        }
    }
}
