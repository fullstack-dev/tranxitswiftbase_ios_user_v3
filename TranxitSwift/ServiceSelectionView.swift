//
//  ServiceSelectionView.swift
//  User
//
//  Created by CSS on 11/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class ServiceSelectionView: UIView {
    
    // Mark:- IBOutlets
    
    @IBOutlet private weak var collectionViewService : UICollectionView!
    @IBOutlet private weak var labelServiceTitle : UILabel!
    @IBOutlet var buttonService : UIButton!
    @IBOutlet var buttonMore : UIButton!
    @IBOutlet private weak var buttonChange : UIButton!
    @IBOutlet private weak var labelCapacity : UILabel!
    @IBOutlet private weak var buttonGetPricing : UIButton!
    @IBOutlet weak var labelCardNumber : UILabel!
    @IBOutlet weak var imageViewCard : UIImageView!
    @IBOutlet weak var progressView : UIProgressView!
    
    //MARK:- Local variable
    
    private var rateView : RateView?
    private var isPresented = false
    private var timer : Timer?
    private let timerSchedule : TimeInterval = 30
    private var timerValue : TimeInterval = 0
    private var datasource = [Service]()
    private var selectedItem : Service? // Current Selected Item
    private var selectedRow = -1
    private var sourceCoordinate = LocationCoordinate()
    private var destinationCoordinate = LocationCoordinate()
    
    var onClickPricing : ((_ selectedItem : Service?)->Void)? // Get Pricing List
    var onClickChangePayment : (()->Void)? // Onlclick Change Pricing
    
    var isServiceSelected = true {
        didSet{
            self.changeCollectionData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialLoads()
        self.localize()
        self.setDesign()
    }
}

// MARK:- Local Methods

extension ServiceSelectionView {
    
    private func initialLoads() {
        
        self.collectionViewService.delegate = self
        self.collectionViewService.dataSource = self
        self.collectionViewService.register(UINib(nibName: XIB.Names.ServiceSelectionCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: XIB.Names.ServiceSelectionCollectionViewCell)
        self.isServiceSelected = true
        self.buttonGetPricing.addTarget(self, action: #selector(self.onClickGetPricing), for: .touchUpInside)
        self.imageViewCard.image = #imageLiteral(resourceName: "money_icon")
        self.labelCardNumber.text = Constants.string.cash.localize()
        self.setProgressView()
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.panAction(sender:))))
    }
    // Set Progress View
    private func setProgressView() {
        
        self.progressView.progressTintColor = .primary
        self.resetProgressView()
        self.progressView.progressViewStyle = .bar
        
    }
    
    //  Reset Progress view
    private func resetProgressView() {
        DispatchQueue.main.async {
            self.progressView.progress = 0
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    private func startProgressing() {
        timerValue = 0
        timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    @IBAction private func timerAction() {
        self.timerValue  += 1
        UIView.animate(withDuration: 0.5, animations: {
            self.progressView.progress = Float(self.timerValue/self.timerSchedule)
        })
    }
    
    //  Set Designs
    
    private func setDesign() {
        
        Common.setFont(to: labelServiceTitle, isTitle: true)
        Common.setFont(to: buttonMore)
        Common.setFont(to: buttonService)
        // Common.setFont(to: buttonChange)
        Common.setFont(to: buttonChange, isTitle: true)
        Common.setFont(to: labelCapacity)
        Common.setFont(to: labelCardNumber)
    }
    
    // Localize
    
    private func localize(){
        
        self.buttonMore.setTitle(Constants.string.more.localize(), for: .normal)
        self.buttonService.setTitle(Constants.string.service.localize(), for: .normal)
        //self.buttonChange.setTitle(Constants.string.change.localize().uppercased(), for: .normal)
        self.buttonGetPricing.setTitle(Constants.string.getPricing.localize(), for: .normal)
    }
    
    private func changeCollectionData(){
        DispatchQueue.main.async {
            self.labelServiceTitle.text = (self.isServiceSelected ? Constants.string.selectService : Constants.string.more).localize()
            self.buttonService.isHidden = self.isServiceSelected
            //   self.buttonMore.isHidden = !self.isServiceSelected
            self.collectionViewService.reloadData()
        }
    }
    
    func setAddress(source : LocationCoordinate, destination : LocationCoordinate) {
        
        self.sourceCoordinate = source
        self.destinationCoordinate = destination
    }
    
    // Set Source
    func set(source : [Service]) {
        
        self.selectedRow = -1
        self.datasource = source
        self.selectedItem = source.first
        self.collectionViewService.reloadData()
        //self.collectionViewService.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .top)
        //        self.collectionViewService.cellForItem(at: IndexPath(item: 0, section: 0))?.isSelected = true
        //        if let id = source.first?.id {
        //            self.getEstimateFareFor(serviceId: id)
        //        }
        self.collectionView(self.collectionViewService, didSelectItemAt: IndexPath(item: 0, section: 0))
    }
    
    @IBAction private func onClickGetPricing() {
        self.onClickPricing?(self.selectedItem)
    }
    
    //  Show Rate View
    
    private func showRateView() {
        
        if self.rateView == nil {
            self.rateView = Bundle.main.loadNibNamed(XIB.Names.RateView, owner: self, options: [:])?.first as? RateView
            self.rateView?.frame = CGRect(origin: CGPoint(x: 0, y: self.frame.height-self.rateView!.frame.height), size: CGSize(width: self.frame.width, height: self.rateView!.frame.height))
            self.rateView?.onCancel = {
                self.removeRateView()
            }
            self.addSubview(self.rateView!)
            self.rateView?.show(with: .bottom, completion: nil)
        }
        self.rateView?.set(values: self.selectedItem)
    }
    
    @IBAction private func panAction(sender : UIPanGestureRecognizer) {
        
        guard !isPresented else {
            return
        }
        if sender.state == .began {
            
            self.addRateView()
            self.setTransform(transform: CGAffineTransform(scaleX: 0, y: 0), alpha: 0)
        }
        else if sender.state == .changed {
            let point = sender.translation(in: UIApplication.shared.keyWindow ?? self)
            print("point  ",point)
            let value = (abs(point.y)/self.frame.height)*1.5
            UIView.animate(withDuration: 0.3) {
                self.setTransform(transform: CGAffineTransform(scaleX: value, y: value), alpha: value)
            }
            if value>0.3 {
                self.isPresented = true
                UIView.animate(withDuration: 0.3) {
                    self.setTransform(transform: .identity, alpha: 1)
                }
            }
            
        }
        else {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.setTransform(transform: CGAffineTransform(scaleX: 0, y: 0), alpha: 0)
            }, completion: { _ in
                self.removeRateView()
            })
        }
    }
    
    // Get Estimate Fare
    
    func getEstimateFareFor(serviceId : Int) {
        
        DispatchQueue.global(qos: .userInteractive).async {
            var estimateFare = EstimateFareRequest()
            estimateFare.s_latitude = self.sourceCoordinate.latitude
            estimateFare.s_longitude = self.sourceCoordinate.longitude
            estimateFare.d_latitude = self.destinationCoordinate.latitude
            estimateFare.d_longitude = self.destinationCoordinate.longitude
            estimateFare.service_type = serviceId
            self.presenter?.get(api: .estimateFare, parameters: estimateFare.JSONRepresentation)
        }
        self.resetProgressView()
        self.startProgressing()
    }
    
    private func addRateView() {
        
        if self.rateView == nil {
            self.rateView = Bundle.main.loadNibNamed(XIB.Names.RateView, owner: self, options: [:])?.first as? RateView
            self.rateView?.frame = CGRect(origin: CGPoint(x: 0, y: self.frame.height-self.rateView!.frame.height), size: CGSize(width: self.frame.width, height: self.rateView!.frame.height))
            self.rateView?.onCancel = {
                self.removeRateView()
            }
            self.addSubview(self.rateView!)
        }
        self.rateView?.set(values: self.selectedItem)
    }
    
    private func setTransform(transform : CGAffineTransform, alpha : CGFloat) {
        
        self.rateView?.alpha = alpha
        self.rateView?.transform = transform
        self.rateView?.center = CGPoint(x: self.rateView!.frame.width/2, y: self.frame.height-(self.rateView!.frame.height/2))
    }
    
    
    //  Remove Rate View
    
    private func removeRateView() {
        
        self.isPresented = false
        self.rateView?.dismissView(onCompletion: {
            self.rateView = nil
        })
    }
}

// MARK:- UICollectionViewDelegate

extension ServiceSelectionView : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if datasource.count>indexPath.row {
            self.collectionViewService.cellForItem(at: IndexPath(item: self.selectedRow, section: 0))?.isSelected = false
            if selectedRow == indexPath.row {
                showRateView()
            }
            self.selectedRow = indexPath.row
            self.selectedItem = self.datasource[indexPath.row]
            self.labelCapacity.text = "1-\(Int.removeNil(self.selectedItem?.capacity))"
            if selectedItem?.pricing == nil, let id = self.selectedItem?.id {
                self.getEstimateFareFor(serviceId: id)
            }
        }
        
    }
}

// MARK:- UICollectionViewDelegateFlowLayout

extension ServiceSelectionView : UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width/3.5)
        let height = collectionView.frame.height-10
        return CGSize(width: width, height: height)
    }
}

// MARK:- UICollectionViewDataSource

extension ServiceSelectionView : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        return self.getCellFor(itemAt: indexPath)
    }
    
    private func getCellFor(itemAt indexPath : IndexPath)->UICollectionViewCell{
        
        if let collectionCell = self.collectionViewService.dequeueReusableCell(withReuseIdentifier: XIB.Names.ServiceSelectionCollectionViewCell, for: indexPath) as? ServiceSelectionCollectionViewCell {
            if datasource.count > indexPath.row, let id = datasource[indexPath.row].id {
                collectionCell.set(value: datasource[indexPath.row])
                NotificationCenter.default.post(name: .providers, object: nil, userInfo: [Notification.Name.providers.rawValue: id])
            }
            collectionCell.isSelected = indexPath.row == selectedRow
            return collectionCell
        }
        return UICollectionViewCell()
    }
}

// MARK:- PostViewProtocol

extension ServiceSelectionView : PostViewProtocol {
    
    func onError(api: Base, message: String, statusCode code: Int) {
        DispatchQueue.main.async {
            self.resetProgressView()
            self.make(toast: message)
        }
    }
    
    func getEstimateFare(api: Base, data: EstimateFare?) {
        
        if self.datasource.count > selectedRow {
            self.datasource[selectedRow].pricing = data
            DispatchQueue.main.async {
                self.resetProgressView()
                self.collectionViewService.reloadItems(at: [IndexPath(item: self.selectedRow, section: 0)])
            }
        }
    }
}


