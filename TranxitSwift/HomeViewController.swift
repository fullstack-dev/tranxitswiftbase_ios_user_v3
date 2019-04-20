    //
    //  HomeViewController.swift
    //  User
    //
    //  Created by CSS on 02/05/18.
    //  Copyright © 2018 Appoets. All rights reserved.
    //
    
    import UIKit
    import KWDrawerController
    import GoogleMaps
    import GooglePlaces
    import DateTimePicker
    import Firebase
    import MapKit
    import PaymentSDK
    import Reachability
    import BraintreeDropIn
    import Braintree
    
    var riderStatus : RideStatus = .none // Provider Current Status
    
    class HomeViewController: UIViewController {
        
        
        //MARK:- IBOutlets
        
        @IBOutlet private var viewSideMenu : UIView!
        @IBOutlet private var viewCurrentLocation : UIView!
        @IBOutlet weak var viewMapOuter : UIView!
        @IBOutlet weak private var viewFavouriteSource : UIView!
        @IBOutlet weak private var viewFavouriteDestination : UIView!
        @IBOutlet weak private var imageViewFavouriteSource : ImageView!
        @IBOutlet weak private var imageViewFavouriteDestination : ImageView!
        @IBOutlet weak var viewSourceLocation : UIView!
        @IBOutlet weak var viewDestinationLocation : UIView!
        @IBOutlet weak private var viewAddress : UIView!
        @IBOutlet weak var viewAddressOuter : UIView!
        @IBOutlet weak var textFieldSourceLocation : UITextField!
        @IBOutlet weak private var textFieldDestinationLocation : UITextField!
        @IBOutlet weak private var imageViewMarkerCenter : UIImageView!
        @IBOutlet weak private var imageViewSideBar : UIImageView!
        @IBOutlet weak var buttonSOS : UIButton!
        @IBOutlet weak private var viewHomeLocation : UIView!
        @IBOutlet weak private var viewWorkLocation : UIView!
        @IBOutlet weak var viewChangeDestinaiton : UIView!
        @IBOutlet weak var viewLocationDot : UIView!
        @IBOutlet weak var viewLocationButtons : UIStackView!
        @IBOutlet weak var buttonWithoutDest:UIButton! //not used
        @IBOutlet var constraint : NSLayoutConstraint!
        
        //MARK:- Local Variable
        
        var withoutDest:Bool = false
        var currentRequestId = 0
        var pathIndex = 0
        var isInvoiceShowed:Bool = false
        private var isUserInteractingWithMap = false // Boolean to handle Mapview User interaction
        private var isScheduled = false // Flag For Schedule
        var isTapDone:Bool = false
        
        var sourceLocationDetail : Bind<LocationDetail>? = Bind<LocationDetail>(nil)
        var currentLocation = Bind<LocationCoordinate>(defaultMapLocation)
        
        var providerLastLocation = LocationCoordinate()
        //var serviceSelectionView : ServiceSelectionView?
        var estimationFareView : RequestSelectionView?
        var couponView : CouponView?
        var locationSelectionView : LocationSelectionView?
        var requestLoaderView : LoaderView?
        var invoiceView : InvoiceView?
        var ratingView : RatingView?
        var rideNowView : RideNowView?
        var floatyButton : Floaty?
        var reasonView : ReasonView?
        var timerETA : Timer?
        var cancelReason = [ReasonEntity]()
        var markersProviders = [GMSMarker]()
        var reRouteTimer : Timer?
        var listOfProviders : [Provider]?
        var selectedService : Service?
        var mapViewHelper : GoogleMapsHelper?
        final var currentProvider: Provider?
        
        
        // private let transition = CircularTransition()  // Translation to for location Tap
        // private var favouriteViewSource : LottieView?
        // private var favouriteViewDestination : LottieView?
        //  private var favouriteLocations : LocationService? //[(type : String,address: [LocationDetail])]() // Favourite Locations of User
        
        lazy var markerProviderLocation : GMSMarker = {  // Provider Location Marker
            let marker = GMSMarker()
            let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
            imageView.contentMode =  .scaleAspectFit
            imageView.image = #imageLiteral(resourceName: "map-vehicle-icon-black")
            marker.iconView = imageView
            marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            marker.map = self.mapViewHelper?.mapView
            return marker
        }()
        
        private var selectedLocationView = UIView() // View to change the location pinpoint
        {
            didSet{
                if !([viewSourceLocation, viewDestinationLocation].contains(selectedLocationView)) {
                    [viewSourceLocation, viewDestinationLocation].forEach({ $0?.transform = .identity })
                }
            }
        }
        
        var isOnBooking = false {  // Boolean to handle back using side menu button
            didSet {
                self.imageViewSideBar.image = isOnBooking ? #imageLiteral(resourceName: "back-icon") : #imageLiteral(resourceName: "menu_icon")
            }
        }
        
        private var isSourceFavourited = false {  // Boolean to handle favourite source location
            didSet{
                self.isAddFavouriteLocation(in: self.viewFavouriteSource, isAdd: isSourceFavourited)
            }
        }
        
        private var isDestinationFavourited = false { // Boolean to handle favourite destination location
            didSet{
                self.isAddFavouriteLocation(in: self.viewFavouriteDestination, isAdd: isDestinationFavourited)
            }
        }
        
        var destinationLocationDetail : LocationDetail? {  // Destination Location Detail
            didSet{
                DispatchQueue.main.async {
                    self.isDestinationFavourited = false // reset favourite location on change
                    if self.destinationLocationDetail == nil {
                        self.isDestinationFavourited = false
                    }
                    self.textFieldDestinationLocation.text = (self.destinationLocationDetail?.address.removingWhitespaces().isEmpty ?? true) ? nil : self.destinationLocationDetail?.address
                }
            }
        }
        
        var rideStatusView : RideStatusView? {
            didSet {
                if self.rideStatusView == nil {
                    self.floatyButton?.removeFromSuperview()
                }
            }
        }
        
        lazy var loader  : UIView = {
            return createActivityIndicator(self.view)
        }()
        
        //MARKERS
        
        var sourceMarker : GMSMarker = {
            let marker = GMSMarker()
            marker.title = Constants.string.ETA.localize()
            marker.appearAnimation = .pop
            marker.icon =  #imageLiteral(resourceName: "sourcePin").resizeImage(newWidth: 30)
            return marker
        }()
        
        var destinationMarker : GMSMarker = {
            let marker = GMSMarker()
            marker.appearAnimation = .pop
            marker.icon =  #imageLiteral(resourceName: "destinationPin").resizeImage(newWidth: 30)
            return marker
        }()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.initialLoads()
            self.localize()
            driverAppExist()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            self.viewWillAppearCustom()
            
            // Chat push redirection
            NotificationCenter.default.addObserver(self, selector: #selector(isChatPushRedirection), name: NSNotification.Name("ChatPushRedirection"), object: nil)
        }
        
        @objc func isChatPushRedirection() {
            
            if let ChatPage = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.SingleChatController) as? SingleChatController {
                ChatPage.set(user: self.currentProvider ?? Provider(), requestId: self.currentRequestId)
                let navigation = UINavigationController(rootViewController: ChatPage)
                self.present(navigation, animated: true, completion: nil)
            }
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)

            NotificationCenter.default.removeObserver(self)
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        override func viewWillLayoutSubviews() {
            super.viewWillLayoutSubviews()
            self.viewLayouts()
        }
        
    }
    
    
    
    // MARK:- Local  Methods
    
    extension HomeViewController {
        
        private func initialLoads() {
            
            self.addMapView()
            self.getFavouriteLocations()
            self.viewSideMenu.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.sideMenuAction)))
            self.navigationController?.isNavigationBarHidden = true
            self.viewFavouriteDestination.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.favouriteLocationAction(sender:))))
            self.viewFavouriteSource.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.favouriteLocationAction(sender:))))
            [self.viewSourceLocation, self.viewDestinationLocation].forEach({ $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.locationTapAction(sender:))))})
            self.currentLocation.bind(listener: { (locationCoordinate) in
                // TODO:- Handle Current Location
                if locationCoordinate != nil {
                    self.mapViewHelper?.moveTo(location: locationCoordinate!, with: self.viewMapOuter.center)
                }
            })
            self.viewCurrentLocation.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.getCurrentLocation)))
            self.sourceLocationDetail?.bind(listener: { (locationDetail) in
                //                if locationDetail == nil {
                //                    self.isSourceFavourited = false
                //                }
                DispatchQueue.main.async {
                    self.isSourceFavourited = false // reset favourite location on change
                    self.textFieldSourceLocation.text = locationDetail?.address
                    self.textFieldSourceLocation.textColor = .black
                }
            })
            // destination pin
            
            
            self.viewDestinationLocation.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            self.checkForProviderStatus()
            self.buttonSOS.isHidden = true
            self.buttonSOS.addTarget(self, action: #selector(self.buttonSOSAction), for: .touchUpInside)
            self.setDesign()
            NotificationCenter.default.addObserver(self, selector: #selector(self.observer(notification:)), name: .providers, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.networkChanged(notification:)), name: NSNotification.Name.reachabilityChanged, object: nil)
            
            //            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShowRateView(info:)), name: .UIKeyboardWillShow, object: nil)
            //            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHideRateView(info:)), name: .UIKeyboardWillHide, object: nil)      }
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            self.presenter?.get(api: .getProfile, parameters: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.presenter?.get(api: .cancelReason, parameters: nil)
            })
            //MARK :Hide it , android is not have
            self.viewFavouriteSource.isHidden = true
            self.viewFavouriteDestination.isHidden = true
            self.viewChangeDestinaiton.isHidden = true
            self.viewChangeDestinaiton.backgroundColor = .primary
            //            self.buttonWithoutDest.addTarget(self, action: #selector(tapWithoutDest), for: .touchUpInside)
            self.reRouteTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true, block: { (_) in
                if isRerouteEnable {
                    self.drawPolyline(isReroute: true)
                    print("Reroute Timer")
                }
                if riderStatus == .pickedup {
                    self.updateCamera()
                }
            })
        }
        
        //  viewWillAppearCustom
        
        private func viewWillAppearCustom() {
            isInvoiceShowed = false
            self.navigationController?.isNavigationBarHidden = true
            self.localize()
            self.getFavouriteLocationsFromLocal()
            self.getAllProviders()
        }
        
        //  View Will Layouts
        
        private func viewLayouts() {
            
            self.viewCurrentLocation.makeRoundedCorner()
            self.mapViewHelper?.mapView?.frame = viewMapOuter.bounds
            self.viewSideMenu.makeRoundedCorner()
            self.navigationController?.isNavigationBarHidden = true
        }
        
        @IBAction private func getCurrentLocation(){
            
            self.viewCurrentLocation.addPressAnimation()
            if currentLocation.value != nil {
                self.mapViewHelper?.getPlaceAddress(from: currentLocation.value!, on: { (locationDetail) in  // On Tapping current location, set
                    if self.selectedLocationView == self.viewSourceLocation {
                        self.sourceLocationDetail?.value = locationDetail
                    } else if self.selectedLocationView == self.viewDestinationLocation {
                        self.destinationLocationDetail = locationDetail
                    }
                })
                self.mapViewHelper?.moveTo(location: self.currentLocation.value!, with: self.viewMapOuter.center)
            }
        }
        
        //  Localize
        
        private func localize(){
            
            self.textFieldSourceLocation.placeholder = Constants.string.source.localize()
            self.textFieldDestinationLocation.placeholder = Constants.string.destination.localize()
            //            self.buttonWithoutDest.setTitle(Constants.string.withoutDest, for: .normal)
            
        }
        
        func getAllProviders() {
            if currentLocation.value?.latitude != nil || currentLocation.value?.longitude != nil {
                let json = [Constants.string.latitude : self.sourceLocationDetail?.value?.coordinate.latitude ?? defaultMapLocation.latitude, Constants.string.longitude : self.sourceLocationDetail?.value?.coordinate.longitude ?? defaultMapLocation.longitude] as [String : Any]
                self.presenter?.get(api: .getProviders, parameters: json)
            }
        }
        
        //  Set Design
        
        private func setDesign() {
            
            Common.setFont(to: textFieldSourceLocation)
            Common.setFont(to: textFieldDestinationLocation)
            //            Common.setFont(to: buttonWithoutDest)
            //            Common.setFont(to: buttonWithoutDest, isTitle: true, size: 17)
            //            buttonWithoutDest.titleLabel?.textColor = .primary
        }
        
        //  Add Mapview
        
        private func addMapView(){
            
            self.mapViewHelper = GoogleMapsHelper()
            self.mapViewHelper?.getMapView(withDelegate: self, in: self.viewMapOuter)
            self.getCurrentLocationDetails()
        }
        // Getting current location detail
        private func getCurrentLocationDetails() {
            self.mapViewHelper?.getCurrentLocation(onReceivingLocation: { (location) in
                if self.sourceLocationDetail?.value == nil {
                    self.mapViewHelper?.getPlaceAddress(from: location.coordinate, on: { (locationDetail) in
                        self.sourceLocationDetail?.value = locationDetail
                    })
                }
                self.currentLocation.value = location.coordinate
            })
        }
        
        //    @objc func tapWithoutDest() {
        //        self.getServicesList()
        //        withoutDest = true
        //    }
        
        
        func showRideNowWithoutDest(with source : [Service]) {
            
            
            if self.rideNowView == nil {
                
                self.rideNowView = Bundle.main.loadNibNamed(XIB.Names.RideNowView, owner: self, options: [:])?.first as? RideNowView
                self.rideNowView?.frame = CGRect(origin: CGPoint(x: 0, y: self.view.frame.height-self.rideNowView!.frame.height), size: CGSize(width: self.view.frame.width, height: self.rideNowView!.frame.height))
                self.rideNowView?.clipsToBounds = false
                self.rideNowView?.show(with: .bottom, completion: nil)
                self.view.addSubview(self.rideNowView!)
                self.isOnBooking = true
                self.rideNowView?.onClickProceed = { [weak self] service in
                    self?.showEstimationView(with: service)
                }
                self.rideNowView?.onClickService = { [weak self] service in
                    guard let self = self else {return}
                    self.sourceMarker.snippet = service?.pricing?.time
                    self.mapViewHelper?.mapView?.selectedMarker = (service?.pricing?.time) == nil ? nil : self.sourceMarker
                    self.selectedService = service
                    self.showProviderInCurrentLocation(with: self.listOfProviders!, serviceTypeID: (service?.id)!)
                }
                
            }
            self.rideNowView?.setAddress(source: currentLocation.value!, destination: currentLocation.value!)
            self.rideNowView?.set(source: source)
        }
        
        //  Observer
        
        @objc private func observer(notification : Notification) {
            
            if notification.name == .providers, let _ = notification.userInfo?[Notification.Name.providers.rawValue] as? [Service] {
                //                showProviderInCurrentLocation(with: serviceArray, serviceTypeID: 0)
            }
        }
        
        //  Get Favourite Location From Local
        
        private func getFavouriteLocationsFromLocal() {
            
            let favouriteLocationFromLocal = CoreDataHelper().favouriteLocations()
            [self.viewHomeLocation, self.viewWorkLocation].forEach({
                $0?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.viewLocationButtonAction(sender:))))
                $0?.isHidden = true
            })
            for location in favouriteLocationFromLocal
            {
                switch location.key {
                case CoreDataEntity.work.rawValue where location.value is Work:
                    if let workObject = location.value as? Work, let address = workObject.address {
                        if let index = favouriteLocations.firstIndex(where: { $0.address == Constants.string.work}) {
                            favouriteLocations[index] = (location.key, (address, LocationCoordinate(latitude: workObject.latitude, longitude: workObject.longitude)))
                        } else {
                            favouriteLocations.append((location.key, (address, LocationCoordinate(latitude: workObject.latitude, longitude: workObject.longitude))))
                        }
                        self.viewWorkLocation.isHidden = false
                    }
                case CoreDataEntity.home.rawValue where location.value is Home:
                    if let homeObject = location.value as? Home, let address = homeObject.address {
                        if let index = favouriteLocations.firstIndex(where: { $0.address == Constants.string.home}) {
                            favouriteLocations[index] = (location.key, (address, LocationCoordinate(latitude: homeObject.latitude, longitude: homeObject.longitude)))
                        }
                        else {
                            favouriteLocations.append((location.key, (address, LocationCoordinate(latitude: homeObject.latitude, longitude: homeObject.longitude))))
                        }
                        self.viewHomeLocation.isHidden = false
                    }
                default:
                    break
                    
                }
            }
        }
        
        //  View Location Action
        
        @IBAction private func viewLocationButtonAction(sender : UITapGestureRecognizer) {
            
            guard let senderView = sender.view else { return }
            if senderView == viewHomeLocation, let location = CoreDataHelper().favouriteLocations()[CoreDataEntity.home.rawValue] as? Home, let addressString = location.address {
                self.destinationLocationDetail = (addressString, LocationCoordinate(latitude: location.latitude, longitude: location.longitude))
            } else if senderView == viewWorkLocation, let location = CoreDataHelper().favouriteLocations()[CoreDataEntity.work.rawValue] as? Work, let addressString = location.address {
                self.destinationLocationDetail = (addressString, LocationCoordinate(latitude: location.latitude, longitude: location.longitude))
            }
            
            if destinationLocationDetail == nil { // No Previous Location Avaliable
                self.showLocationView()
            } else {
                print("Polydraw 1")
                self.drawPolyline(isReroute: false) // Draw polyline between source and destination
                self.getServicesList() // get Services
                //                self.withoutDest = false
            }
            
        }
        
        
        //  Favourite Location Action
        
        @IBAction private func favouriteLocationAction(sender : UITapGestureRecognizer) {
            
            guard let senderView = sender.view else { return }
            senderView.addPressAnimation()
            if senderView == viewFavouriteSource {
                self.isSourceFavourited = self.sourceLocationDetail?.value != nil ? !self.isSourceFavourited : false
            } else if senderView == viewFavouriteDestination {
                self.isDestinationFavourited = self.destinationLocationDetail != nil ? !self.isDestinationFavourited : false
            }
        }
        
        //  Favourite Location Action
        
        private func isAddFavouriteLocation(in viewFavourite : UIView, isAdd : Bool) {
            
            if viewFavourite == viewFavouriteSource {
                self.imageViewFavouriteSource.image = (isAdd ? #imageLiteral(resourceName: "like") : #imageLiteral(resourceName: "unlike")).withRenderingMode(.alwaysTemplate)
            } else {
                self.imageViewFavouriteDestination.image = (isAdd ? #imageLiteral(resourceName: "like") : #imageLiteral(resourceName: "unlike")).withRenderingMode(.alwaysTemplate)
            }
            self.favouriteLocationApi(in: viewFavourite, isAdd: isAdd) // Send to Api Call
            
        }
        
        //  Favourite Location Action
        
        @IBAction private func locationTapAction(sender : UITapGestureRecognizer) {
            
            guard let senderView = sender.view  else { return }
            if riderStatus != .none, senderView == viewSourceLocation { // Ignore if user is onRide and trying to change source location
                return
            }
            self.selectedLocationView.transform = CGAffineTransform.identity
            
            if self.selectedLocationView == senderView {
                self.showLocationView()
            }
            else {
                self.selectedLocationView = senderView
                self.selectionViewAction(in: senderView)
            }
            self.selectedLocationView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            self.viewAddress.bringSubviewToFront(self.selectedLocationView)
            // self.showLocationView()
        }
        
        
        //  Show Marker on Location
        
        private func selectionViewAction(in currentSelectionView : UIView){
            
            if currentSelectionView == self.viewSourceLocation {
                
                if let coordinate = self.sourceLocationDetail?.value?.coordinate{
                    self.plotMarker(marker: &sourceMarker, with: coordinate)
                    print("Source Marker - ", coordinate.latitude, " ",coordinate.longitude)
                }
                else {
                    self.showLocationView()
                }
            }
            else if currentSelectionView == self.viewDestinationLocation {
                
                if let coordinate = self.destinationLocationDetail?.coordinate{
                    self.plotMarker( marker: &destinationMarker, with: coordinate)
                    print("Destination Marker - ", coordinate.latitude, " ",coordinate.longitude)
                }
                else {
                    self.showLocationView()
                }
            }
        }
        
        private func plotMarker(marker : inout GMSMarker, with coordinate : CLLocationCoordinate2D){
            
            marker.position = coordinate
            marker.map = self.mapViewHelper?.mapView
            self.mapViewHelper?.mapView?.animate(toLocation: coordinate)
        }
        
        //  Show Location View
        
        @IBAction private func showLocationView() {
            
            if let locationView = Bundle.main.loadNibNamed(XIB.Names.LocationSelectionView, owner: self, options: [:])?.first as? LocationSelectionView {
                locationView.frame = self.view.bounds
                locationView.setValues(address: (sourceLocationDetail,destinationLocationDetail)) { [weak self] (address) in
                    guard let self = self else {return}
                    self.sourceLocationDetail = address.source
                    if riderStatus != .pickedup { //
                        self.destinationLocationDetail = address.destination
                        self.drawPolyline(isReroute: false)  // Draw polyline between source and destination
                    }
                    if [RideStatus.accepted, .arrived, .pickedup, .started].contains(riderStatus) {
                        if let dAddress = address.destination?.address, let coordinate = address.destination?.coordinate {
                            
                            if coordinate.latitude != 0 && coordinate.longitude != 0 {
                                if riderStatus == .pickedup {
                                    showAlert(message: Constants.string.locationChange.localize(), okHandler: {
                                        self.destinationLocationDetail = address.destination
                                        self.extendTrip(requestID: self.currentRequestId, dLat: coordinate.latitude, dLong: coordinate.longitude, address: dAddress)
                                        self.drawPolyline(isReroute: false)
                                    }, cancelHandler: {
                                        
                                    }, fromView: self)
                                }
                            }
                            self.updateLocation(with: (dAddress,coordinate))
                        }
                    }
                    else {
                        self.removeUnnecessaryView(with: .cancelled) // Remove services or ride now if previously open
                        self.getServicesList() // get Services
                        //                        self.withoutDest = false
                    }
                }
                self.view.addSubview(locationView)
                if selectedLocationView == self.viewSourceLocation {
                    locationView.textFieldSource.becomeFirstResponder()
                } else {
                    locationView.textFieldDestination.becomeFirstResponder()
                }
                self.selectedLocationView.transform = .identity
                self.selectedLocationView = UIView()
                self.locationSelectionView = locationView
            }
        }
        
        // MARK:- Remove Location VIew
        
        func removeLocationView() {
            
            UIView.animate(withDuration: 0.3, animations: {
                self.locationSelectionView?.tableViewBottom.frame.origin.y = (self.locationSelectionView?.tableViewBottom.frame.height) ?? 0
                self.locationSelectionView?.viewTop.frame.origin.y = -(self.locationSelectionView?.viewTop.frame.height ?? 0)
            }) { (_) in
                self.locationSelectionView?.isHidden = true
                self.locationSelectionView?.removeFromSuperview()
                self.locationSelectionView = nil
            }
        }
        
        // Draw Polyline
        
        func drawPolyline(isReroute:Bool) {
            
            // self.imageViewMarkerCenter.isHidden = true
            if var sourceCoordinate = self.sourceLocationDetail?.value?.coordinate,
                let destinationCoordinate = self.destinationLocationDetail?.coordinate {  // Draw polyline from source to destination
                
                self.mapViewHelper?.mapView?.clear()
                self.sourceMarker.map = self.mapViewHelper?.mapView
                self.destinationMarker.map = self.mapViewHelper?.mapView
                if isReroute{
                    isRerouteEnable = false
                    let coordinate = CLLocationCoordinate2D(latitude: (providerLastLocation.latitude), longitude: (providerLastLocation.longitude))
                    sourceCoordinate = coordinate
                }
                if !isReroute {
                    self.sourceMarker.position = sourceCoordinate
                    self.destinationMarker.position = destinationCoordinate
                }
                //self.selectionViewAction(in: self.viewSourceLocation)
                //self.selectionViewAction(in: self.viewDestinationLocation)
                self.mapViewHelper?.mapView?.drawPolygon(from: sourceCoordinate, to: destinationCoordinate)
                self.selectedLocationView = UIView()
            }
        }
        
        // MARK:- Get Favourite Locations
        
        private func getFavouriteLocations(){
            
            favouriteLocations.append((Constants.string.home,nil))
            favouriteLocations.append((Constants.string.work,nil))
            self.presenter?.get(api: .locationService, parameters: nil)
        }
        
        //  Cancel Request if it exceeds a certain interval
        
        @IBAction func validateRequest() {
            
            if riderStatus == .searching {
                UIApplication.shared.keyWindow?.makeToast(Constants.string.noDriversFound.localize())
                self.cancelRequest()
            }
        }
        
        //  SideMenu Button Action
        
        @IBAction private func sideMenuAction(){
            
            if self.isOnBooking { // If User is on Ride Selection remove all view and make it to default
                self.clearAllView()
                print("ViewAddressOuter ", #function)
            } else {
                self.drawerController?.openSide(selectedLanguage == .arabic ? .right : .left)
                self.viewSideMenu.addPressAnimation()
            }
            
        }
        
        // Clear Map
        
        func clearAllView() {
            self.removeLoaderView()
            self.removeUnnecessaryView(with: .cancelled)
            self.clearMapview()
            self.viewAddressOuter.isHidden = false
            self.viewLocationButtons.isHidden = false
        }
        
        
        //  Show DateTimePicker
        
        func schedulePickerView(on completion : @escaping ((Date)->())){
            
            var dateComponents = DateComponents()
            dateComponents.day = 7
            let now = Date()
            let maximumDate = Calendar.current.date(byAdding: dateComponents, to: now)
            dateComponents.minute = 5
            dateComponents.day = nil
            let minimumDate = Calendar.current.date(byAdding: dateComponents, to: now)
            let datePicker = DateTimePicker.create(minimumDate: minimumDate, maximumDate: maximumDate)
            datePicker.includeMonth = true
            datePicker.cancelButtonTitle = Constants.string.Cancel.localize()
            
            datePicker.doneButtonTitle = Constants.string.Done.localize()
            datePicker.is12HourFormat = true
            datePicker.dateFormat = DateFormat.list.hhmmddMMMyyyy
            datePicker.highlightColor = .primary
            datePicker.doneBackgroundColor = .secondary
            datePicker.completionHandler = { date in
                completion(date)
                print(date)
            }
            datePicker.show()
        }
        
        //  Observe Network Changes
        @objc private func networkChanged(notification : Notification) {
            if let reachability = notification.object as? Reachability, ([Reachability.Connection.cellular, .wifi].contains(reachability.connection)) {
                self.getCurrentLocationDetails()
            }
        }
        
    }
    
    // Mark:- If driver app exist
    
    extension HomeViewController {
        
        // if driver app exist need to show warning alert
        func driverAppExist() {
            let app = UIApplication.shared
            let bundleId = driverBundleID+"://"
            
            if app.canOpenURL(URL(string: bundleId)!) {
                let appExistAlert = UIAlertController(title: "", message: Constants.string.warningMsg.localize(), preferredStyle: .actionSheet)
                
                appExistAlert.addAction(UIAlertAction(title: Constants.string.Continue.localize(), style: .default, handler: { (Void) in
                    print("App is install")
                }))
                present(appExistAlert, animated: true, completion: nil)
            }
            else {
                print("App is not installed")
            }
        }
    }
    
    // MARK:- GMSMapViewDelegate
    
    extension HomeViewController : GMSMapViewDelegate {
        
        func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
            
            if self.isUserInteractingWithMap {
                
                func getUpdate(on location : CLLocationCoordinate2D, completion :@escaping ((LocationDetail)->Void)) {
                    self.drawPolyline(isReroute: false)
                    print("Polydraw 3")
                    self.getServicesList()
                    //                    self.withoutDest = false
                    self.mapViewHelper?.getPlaceAddress(from: location, on: { (locationDetail) in
                        completion(locationDetail)
                    })
                }
                
                if self.selectedLocationView == self.viewSourceLocation, self.sourceLocationDetail != nil {
                    
                    if let location = mapViewHelper?.mapView?.projection.coordinate(for: viewMapOuter.center) {
                        self.sourceLocationDetail?.value?.coordinate = location
                        getUpdate(on: location) { (locationDetail) in
                            self.sourceLocationDetail?.value = locationDetail
                        }
                    }
                }
                else if self.selectedLocationView == self.viewDestinationLocation, self.destinationLocationDetail != nil {
                    
                    if let location = mapViewHelper?.mapView?.projection.coordinate(for: viewMapOuter.center) {
                        self.destinationLocationDetail?.coordinate = location
                        getUpdate(on: location) { (locationDetail) in
                            self.destinationLocationDetail = locationDetail
                            if riderStatus == .pickedup {
                                showAlert(message: Constants.string.locationChange.localize(), okHandler: {
                                    
                                    self.extendTrip(requestID: self.currentRequestId, dLat: locationDetail.coordinate.latitude, dLong: locationDetail.coordinate.longitude, address: locationDetail.address)
                                }, cancelHandler: {
                                    
                                }, fromView: self)
                            }else{
                                self.updateLocation(with: locationDetail) // Update Request Destination Location
                            }
                        }
                    }
                }
            }
            self.isMapInteracted(false)
        }
        
        func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
            
            print("Gesture ",gesture)
            self.isUserInteractingWithMap = gesture
            
            if self.isUserInteractingWithMap {
                self.isMapInteracted(true)
            }
            
        }
        
        func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
            
            // return
            
            if isUserInteractingWithMap {
                
                if self.selectedLocationView == self.viewSourceLocation, self.sourceLocationDetail != nil {
                    
                    self.sourceMarker.map = nil
                    self.imageViewMarkerCenter.tintColor = .secondary
                    self.imageViewMarkerCenter.image = #imageLiteral(resourceName: "sourcePin").withRenderingMode(.alwaysTemplate)
                    self.imageViewMarkerCenter.isHidden = true // false
                    //                if let location = mapViewHelper?.mapView?.projection.coordinate(for: viewMapOuter.center) {
                    //                    self.sourceLocationDetail?.value?.coordinate = location
                    //                    self.mapViewHelper?.getPlaceAddress(from: location, on: { (locationDetail) in
                    //                        print(locationDetail)
                    //                        self.sourceLocationDetail?.value = locationDetail
                    ////                        let sLocation = self.sourceLocationDetail
                    ////                        self.sourceLocationDetail = sLocation
                    //                    })
                    //                }
                    
                    
                } else if self.selectedLocationView == self.viewDestinationLocation, self.destinationLocationDetail != nil {
                    
                    self.destinationMarker.map = nil
                    self.imageViewMarkerCenter.tintColor = .primary
                    self.imageViewMarkerCenter.image = #imageLiteral(resourceName: "destinationPin").withRenderingMode(.alwaysTemplate)
                    self.imageViewMarkerCenter.isHidden = true//false
                    //                if let location = mapViewHelper?.mapView?.projection.coordinate(for: viewMapOuter.center) {
                    //                    self.destinationLocationDetail?.coordinate = location
                    //                    self.mapViewHelper?.getPlaceAddress(from: location, on: { (locationDetail) in
                    //                        print(locationDetail)
                    //                        self.destinationLocationDetail = locationDetail
                    //                    })
                    //                }
                }
                
            }
            //        else {
            //            self.destinationMarker.map = self.mapViewHelper?.mapView
            //            self.sourceMarker.map = self.mapViewHelper?.mapView
            //            self.imageViewMarkerCenter.isHidden = true
            //        }
            
        }
        
        func extendTrip(requestID:Int,dLat:Double,dLong:Double,address:String) {
            var extendTrip = ExtendTrip()
            extendTrip.request_id = requestID
            extendTrip.latitude = dLat
            extendTrip.longitude = dLong
            extendTrip.address = address
            self.presenter?.post(api: .extendTrip, data: extendTrip.toData())
        }
        
    }
    
    // MARK:- Service Calls
    
    extension HomeViewController  {
        
        // Check For Service Status
        
        private func checkForProviderStatus() {
            
            HomePageHelper.shared.startListening(on: { (error, request) in
                
                if error != nil {
                    riderStatus = .none
                    //                    DispatchQueue.main.async {
                    //                        showAlert(message: error?.localizedDescription, okHandler: nil, fromView: self)
                    //                    }
                } else if request != nil {
                    if let requestId = request?.id {
                        self.currentRequestId = requestId
                    }
                    if let pLatitude = request?.provider?.latitude, let pLongitude = request?.provider?.longitude {
                        DispatchQueue.main.async {
                            //                            self.moveProviderMarker(to: LocationCoordinate(latitude: pLatitude, longitude: pLongitude))
                            self.getDataFromFirebase(providerID: (request?.provider?.id)!)
                            // MARK:- Showing Provider ETA
                            let currentStatus = request?.status ?? .none
                            if [RideStatus.accepted, .started, .arrived, .pickedup].contains(currentStatus) {
                                self.showETA(with: LocationCoordinate(latitude: pLatitude, longitude: pLongitude))
                            }
                        }
                    }
                    guard riderStatus != request?.status else {
                        return
                    }
                    riderStatus = request?.status ?? .none
                    self.isScheduled = ((request?.is_scheduled ?? false) && riderStatus == .searching)
                    self.handle(request: request!)
                } else {
                    
                    let previousStatus = riderStatus
                    riderStatus = request?.status ?? .none
                    if riderStatus != previousStatus {
                        self.clearMapview()
                    }
                    if self.isScheduled {
                        self.isScheduled = false
                        //                        if let yourtripsVC = Router.main.instantiateViewController(withIdentifier: Storyboard.Ids.YourTripsPassbookViewController) as? YourTripsPassbookViewController {
                        //                            yourtripsVC.isYourTripsSelected = true
                        //                            yourtripsVC.isFirstBlockSelected = false
                        //                            self.navigationController?.pushViewController(yourtripsVC, animated: true)
                        //                        }
                        self.removeUnnecessaryView(with: .cancelled)
                    } else {
                        self.removeUnnecessaryView(with: .none)
                    }
                    
                }
            })
        }
        
        func getDataFromFirebase(providerID:Int)  {
            Database .database()
                .reference()
                .child("loc_p_\(providerID)").observe(.value, with: { (snapshot) in
                    guard let _ = snapshot.value as? NSDictionary else {
                        print("Error")
                        return
                    }
                    let providerLoc = ProviderLocation(from: snapshot)
                    
                    /* var latDouble = 0.0 //for android sending any or double
                     var longDouble = 0.0
                     var bearingDouble = 0.0
                     if let latitude = dict.value(forKey: "lat") as? Double {
                     latDouble = Double(latitude)
                     }else{
                     let strLat = dict.value(forKey: "lat")
                     latDouble = Double("\(strLat ?? 0.0)")!
                     }
                     if let longitude = dict.value(forKey: "lng") as? Double {
                     longDouble = Double(longitude)
                     }else{
                     let strLong = dict.value(forKey: "lng")
                     longDouble = Double("\(strLong ?? 0.0)")!
                     }
                     if let bearing = dict.value(forKey: "bearing") as? Double {
                     bearingDouble = bearing
                     } */
                    
                    //                    if let pLatitude = latDouble, let pLongitude = longDouble {
                    DispatchQueue.main.async {
                        print("Moving \(String(describing: providerLoc?.lat)) \(String(describing: providerLoc?.lng))")
                        self.moveProviderMarker(to: LocationCoordinate(latitude: providerLoc?.lat ?? defaultMapLocation.latitude , longitude: providerLoc?.lng ?? defaultMapLocation.longitude),bearing: providerLoc?.bearing ?? 0.0)
                        if polyLinePath.path != nil {
                            if riderStatus == .pickedup {
                                self.updateTravelledPath(currentLoc: CLLocationCoordinate2D(latitude: providerLoc?.lat ?? defaultMapLocation.latitude, longitude: providerLoc?.lng ?? defaultMapLocation.longitude))
                                self.mapViewHelper?.checkPolyline(coordinate:  LocationCoordinate(latitude: providerLoc?.lat ?? defaultMapLocation.latitude , longitude: providerLoc?.lng ?? defaultMapLocation.longitude))
                            }
                        }
                    }
                })
        }
        
        
        // Get Services provided by Provider
        
        private func getServicesList() {
            if self.sourceLocationDetail?.value != nil, self.destinationLocationDetail != nil, riderStatus == .none || riderStatus == .searching { // Get Services only if location Available
                self.presenter?.get(api: .servicesList, parameters: nil)
            }
            //without destination
            //            if self.withoutDest {
            //                self.presenter?.get(api: .servicesList, parameters: nil)
            //            }
        }
        
        // Get Estimate Fare
        
        func getEstimateFareFor(serviceId : Int,isWODest:Bool) {
            
            DispatchQueue.global(qos: .userInteractive).async {
                
                
                guard let sourceLocation = self.sourceLocationDetail?.value?.coordinate, let destinationLocation = self.destinationLocationDetail?.coordinate, sourceLocation.latitude>0, sourceLocation.longitude>0, destinationLocation.latitude>0, destinationLocation.longitude>0 else {
                    return
                }
                var estimateFare = EstimateFareRequest()
                estimateFare.s_latitude = sourceLocation.latitude
                estimateFare.s_longitude = sourceLocation.longitude
                estimateFare.d_latitude = destinationLocation.latitude
                estimateFare.d_longitude = destinationLocation.longitude
                estimateFare.service_type = serviceId
                
                self.presenter?.get(api: .estimateFare, parameters: estimateFare.JSONRepresentation)
                
            }
        }
        
        
        
        // Cancel Request
        
        func cancelRequest(reason : String? = nil) {
            
            if self.currentRequestId>0 {
                let request = Request()
                request.request_id = self.currentRequestId
                request.cancel_reason = reason
                self.presenter?.post(api: .cancelRequest, data: request.toData())
            }
        }
        
        
        // Create Request
        
        func createRequest(for service : Service, isScheduled : Bool, scheduleDate : Date?, cardEntity entity : CardEntity?, paymentType : PaymentType) {
            // Validate whether the card entity has valid data
            if paymentType == .CARD && entity == nil {
                UIApplication.shared.keyWindow?.make(toast: Constants.string.selectCardToContinue.localize())
                return
            }
            
            self.showLoaderView()
            DispatchQueue.global(qos: .background).async {
                let request = Request()
                request.s_address = self.sourceLocationDetail?.value?.address
                request.s_latitude = self.sourceLocationDetail?.value?.coordinate.latitude
                request.s_longitude = self.sourceLocationDetail?.value?.coordinate.longitude
                request.d_address = self.destinationLocationDetail?.address
                request.d_latitude = self.destinationLocationDetail?.coordinate.latitude
                request.d_longitude = self.destinationLocationDetail?.coordinate.longitude
                request.service_type = service.id
                request.payment_mode = paymentType
                request.distance = "\(service.pricing?.distance ?? 0)"
                request.use_wallet = service.pricing?.useWallet
                request.card_id = entity?.card_id
                if isScheduled {
                    if let dateString = Formatter.shared.getString(from: scheduleDate, format: DateFormat.list.ddMMyyyyhhmma) {
                        let dateArray = dateString.components(separatedBy: " ")
                        request.schedule_date = dateArray.first
                        request.schedule_time = dateArray.last
                    }
                }
                if let couponId = service.promocode?.id {
                    request.promocode_id = couponId
                }
                self.presenter?.post(api: .sendRequest, data: request.toData())
                
            }
        }
        
        // MARK:- Update Location for Existing Request
        
        func updateLocation(with detail : LocationDetail) {
            //.pickedup
            guard [RideStatus.accepted, .arrived, .started].contains(riderStatus) else { return } // Update Location only if status falls under certain category
            
            let request = Request()
            request.request_id = self.currentRequestId
            request.address = detail.address
            request.latitude = detail.coordinate.latitude
            request.longitude = detail.coordinate.longitude
            self.presenter?.post(api: .updateRequest, data: request.toData())
            
        }
        
        //  Change Payment Type For existing Request
        func updatePaymentType(with cardDetail : CardEntity?, paymentType: PaymentType) {
            let request = Request()
            request.request_id = self.currentRequestId
            if paymentType == .CARD {
                request.payment_mode = .CARD
                request.card_id = cardDetail!.card_id
            }
            else {
                request.payment_mode = paymentType
            }
            self.loader.isHideInMainThread(false)
            self.presenter?.post(api: .updateRequest, data: request.toData())
        }
        
        //  Favourite Location on Other Category
        func favouriteLocationApi(in view : UIView, isAdd : Bool) {
            
            guard isAdd else { return }
            
            let service = Service() // Save Favourite location in Server
            service.type = CoreDataEntity.other.rawValue.lowercased()
            if view == self.viewFavouriteSource, let address = self.sourceLocationDetail?.value {
                service.address = address.address
                service.latitude = address.coordinate.latitude
                service.longitude = address.coordinate.longitude
            } else if view == self.viewFavouriteDestination, self.destinationLocationDetail != nil {
                service.address = self.destinationLocationDetail!.address
                service.latitude = self.destinationLocationDetail!.coordinate.latitude
                service.longitude = self.destinationLocationDetail!.coordinate.longitude
            } else { return }
            
            self.presenter?.post(api: .locationServicePostDelete, data: service.toData())
            
        }
    }
    
    // MARK:- PostViewProtocol
    
    extension HomeViewController : PostViewProtocol {
        
        func onError(api: Base, message: String, statusCode code: Int) {
            
            DispatchQueue.main.async {
                self.loader.isHidden = true
                if api == .locationServicePostDelete {
                    UIApplication.shared.keyWindow?.make(toast: message)
                } else {
                    if code != StatusCode.notreachable.rawValue && api != .checkRequest && api != .cancelRequest{
                        showAlert(message: message, okHandler: nil, fromView: self)
                    }
                    
                }
                if api == .sendRequest {
                    self.removeLoaderView()
                }
            }
        }
        
        func getServiceList(api: Base, data: [Service]) {
            
            if api == .servicesList {
                DispatchQueue.main.async {  // Show Services
                    //                    if self.withoutDest {
                    //                        self.showRideNowWithoutDest(with: data)
                    //                    }else{
                    self.showRideNowView(with: data)
                    //                    }
                    
                }
            }
            
        }
        
        func getProviderList(api: Base, data: [Provider]) {
            if api == .getProviders {  // Show Providers in Current Location
                DispatchQueue.main.async {
                    self.listOfProviders = data
                    self.showProviderInCurrentLocation(with: self.listOfProviders!,serviceTypeID:0)
                }
            }
        }
        
        func getRequest(api: Base, data: Request?) {
            
            print(data?.request_id ?? 0)
            if api == .sendRequest {
                self.success(api: api, data: nil)
                
                self.currentRequestId = data?.request_id ?? 0
                self.checkForProviderStatus()
                
                if data?.message == Constants.string.scheduleReqMsg {
                    UIApplication.shared.keyWindow?.makeToast(Constants.string.rideCreated.localize())
                    clearAllView()
                    self.removeLoaderView()
                }else{
                    DispatchQueue.main.async {
                        self.showLoaderView(with: self.currentRequestId)
                    }
                }
            }
        }
        
        func success(api: Base, message: String?) {
            riderStatus = .none
            self.loader.isHideInMainThread(true)
        }
        
        func getWalletEntity(api: Base, data: WalletEntity?) {
            
        }
        
        func success(api: Base, data: WalletEntity?) {
            
            
            if api == .updateRequest {
                riderStatus = .none
                return
            }
            else if api == .locationServicePostDelete {
                self.presenter?.get(api: .locationService, parameters: nil)
            }else if api == .rateProvider  {
                riderStatus = .none
                getAllProviders()
                return
            }
            else if api == .payNow {
                self.isInvoiceShowed = true
                
                //                paytym
                //                self.makePaymentWithPaytm(paymentEntity: data)
                
                //                payumoney
                //                self.makePaymentWithPayumoney(paymentEntity: data)
                
            }
            else if api == .cancelRequest{
                riderStatus = .none
            }
            else {
                riderStatus = .none // Make Ride Status to Default
                //                if api == .payNow { // Remove PayNow if Card Payment is Success
                //                    self.removeInvoiceView()
                //                }
            }
        }
        
        func getLocationService(api: Base, data: LocationService?) {
            
            self.loader.isHideInMainThread(true)
            storeFavouriteLocations(from: data)
        }
        
        func getProfile(api: Base, data: Profile?) {
            Common.storeUserData(from: data)
            storeInUserDefaults()
        }
        
        func getReason(api: Base, data: [ReasonEntity]) {
            self.cancelReason = data
        }
        
        func getExtendTrip(api: Base, data: ExtendTrip) {
            print(data)
        }
    }
    
    //MARK:- PayTM Payment Gateway
    extension HomeViewController {
        func makePaymentWithPaytm(paymentEntity: PayTmEntity?) {
            
            PGServerEnvironment().selectServerDialog(self.view, completionHandler: {(type: ServerType) -> Void in
                
                let amount: String = "\(paymentEntity?.TXN_AMOUNT ?? 0.0)"
                let customerId: String = "\(paymentEntity?.CUST_ID ?? "")"
                let type :ServerType = .eServerTypeStaging
                let order = PGOrder(orderID: (paymentEntity?.ORDER_ID)!,
                                    customerID: customerId,
                                    amount: amount,
                                    eMail: (paymentEntity?.EMAIL)!,
                                    mobile: (paymentEntity?.MOBILE_NO)!)
                
                order.params = [Constants().mid: (paymentEntity?.MID)!,
                                Constants().orderId: (paymentEntity?.ORDER_ID)!,
                                Constants().custId: customerId,
                                Constants().mobileNo: (paymentEntity?.MOBILE_NO)!,
                                Constants().emailId: (paymentEntity?.EMAIL)!,
                                Constants().channelId: (paymentEntity?.CHANNEL_ID)!,
                                Constants().website: (paymentEntity?.WEBSITE)!,
                                Constants().txnAmount: amount,
                                Constants().industryType: (paymentEntity?.INDUSTRY_TYPE_ID)!,
                                Constants().checksumhash: (paymentEntity?.CHECKSUMHASH)!,
                                Constants().callbackUrl: (paymentEntity?.CALLBACK_URL)!]
                
                let txnController = PGTransactionViewController().initTransaction(for: order) as! PGTransactionViewController
                //                self.txnController = self.txnController?.initTransaction(for: order) as? PGTransactionViewController
                txnController.title = "Paytm Payments"
                txnController.setLoggingEnabled(true)
                if(type != ServerType.eServerTypeNone) {
                    txnController.serverType = type
                } else {
                    return
                }
                txnController.merchant = PGMerchantConfiguration.defaultConfiguration()
                txnController.delegate = self
                self.navigationController?.pushViewController(txnController, animated: true)
            })
        }
    }
    
    //MARK:- PGTransactionDelegate
    
    extension HomeViewController: PGTransactionDelegate {
        //this function triggers when transaction gets finished
        func didFinishedResponse(_ controller: PGTransactionViewController, response responseString: String) {
            let msg : String = responseString
            var titlemsg : String = ""
            if let data = responseString.data(using: String.Encoding.utf8) {
                do {
                    if let jsonresponse = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] , jsonresponse.count > 0{
                        titlemsg = jsonresponse["STATUS"] as? String ?? ""
                    }
                } catch {
                    print("Something went wrong")
                }
            }
            let actionSheetController: UIAlertController = UIAlertController(title: titlemsg , message: msg, preferredStyle: .alert)
            let cancelAction : UIAlertAction = UIAlertAction(title: "OK", style: .cancel) {
                action -> Void in
                controller.navigationController?.popViewController(animated: true)
            }
            actionSheetController.addAction(cancelAction)
            self.present(actionSheetController, animated: true, completion: nil)
        }
        //this function triggers when transaction gets cancelled
        func didCancelTrasaction(_ controller : PGTransactionViewController) {
            controller.navigationController?.popViewController(animated: true)
        }
        //Called when a required parameter is missing.
        func errorMisssingParameter(_ controller : PGTransactionViewController, error : NSError?) {
            controller.navigationController?.popViewController(animated: true)
        }
    }
    
    
    //MARK:- BrainTree Payment
    
    extension HomeViewController {
        func fetchBrainTreeClientToken() {
            self.presenter?.get(api: .getbraintreenonce, parameters: nil)
        }
        
        func getBrainTreeToken(api: Base, data: TokenEntity) {
            guard let token: String = data.token else {
                return
            }
            self.showDropIn(newToken: token)
        }
        
        
        func showDropIn(newToken: String) {
            let newRequest =  BTDropInRequest()
            let dropIn = BTDropInController(authorization: newToken, request: newRequest)
            { (controller, result, error) in
                if (error != nil) {
                    print("ERROR")
                } else if (result?.isCancelled == true) {
                    print("CANCELLED")
                } else if let result = result {
                    // Use the BTDropInResult properties to update your UI
                    // result.paymentOptionType
                    // result.paymentMethod
                    // result.paymentIcon
                    // result.paymentDescription
                    print(result)
                }
                controller.dismiss(animated: true, completion: nil)
            }
            self.present(dropIn!, animated: true, completion: nil)
        }
    }
    
    // Mark:- Pay with payumoney on Invoice payment
    
    extension HomeViewController {
        func makePaymentWithPayumoney(paymentEntity: PayUMoneyEntity) {
            print(paymentEntity as Any)
            PayUServiceHelper.sharedManager()?.getPayment(self, paymentEntity.email, "8179722510", paymentEntity.firstname,"\((paymentEntity.amount)!)", paymentEntity.txnid, paymentEntity.merchant_id, paymentEntity.key, paymentEntity.payu_salt, paymentEntity.surl, paymentEntity.curl, productInfo: paymentEntity.productinfo, udf1: "\(self.currentRequestId)", didComplete: { (dict, error) in
                
                if let result = dict?["result"] as? NSDictionary {
                    var payUEntity = PayUMoneyEntity()
                    payUEntity.request_id = self.currentRequestId
                    let txnId = (result.value(forKey: Constants().stxnid))
                    let param = [Constants().sid : self.currentRequestId,
                                 Constants().spay : txnId!,
                                 Constants().swallet : 0,
                                 Constants().stype : UserType.user.rawValue,
                                 Constants().suid : User.main.id ?? ""] as [String : Any]
                    self.presenter?.get(api: .payUMoneySuccessResponse, parameters: param)
                }
                
            }) { (error) in
                print("Payment Process Breaked")
            }
        }
    }
    
    
    
    
    
    
    
