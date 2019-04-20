//
//  YourTripsViewController.swift
//  User
//
//  Created by CSS on 13/06/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class YourTripsDetailViewController: UITableViewController {
    
    //MARK:- IBOutlets
    
    @IBOutlet private weak var imageViewMap : UIImageView!
    @IBOutlet private weak var imageViewProvider : UIImageView!
    @IBOutlet private weak var labelProviderName : UILabel!
    @IBOutlet private weak var viewRating : FloatRatingView!
    @IBOutlet private weak var labelDate : UILabel!
    @IBOutlet private weak var labelTime : UILabel!
    @IBOutlet private weak var labelBookingId : UILabel!
    @IBOutlet private weak var labelPayViaString : UILabel!
    @IBOutlet private weak var imageViewPayVia : UIImageView!
    @IBOutlet private weak var labelPayVia : UILabel!
    @IBOutlet private weak var labelPrice : UILabel!
    @IBOutlet private weak var labelCommentsString : UILabel!
    @IBOutlet private weak var textViewComments : UITextView!
    @IBOutlet private weak var buttonCancelRide : UIButton!
    @IBOutlet private weak var buttonViewReciptAndCall : UIButton!
    @IBOutlet private weak var viewLocation : UIView!
    @IBOutlet private weak var labelSourceLocation : UILabel!
    @IBOutlet private weak var labelDestinationLocation : UILabel!
    @IBOutlet private weak var viewComments : UIView!
    @IBOutlet private weak var viewButtons : UIView!
    @IBOutlet private weak var viewMore : UIView!
    @IBOutlet private weak var buttonDispute : UIButton!
    @IBOutlet private weak var buttonLostItem : UIButton!
    
    //MARK:- Local Variable
    
    var isUpcomingTrips = false  // Boolean to handle Past and Upcoming Trips
    private var heightArray : [CGFloat] = [62,75,70,145]
    private var dataSource : Request?
    private var viewRecipt : InvoiceView?
    private var blurView : UIView?
    private var requestId : Int?
    private var disputeView : DisputeLostItemView?
    private var disputeStatusView : DisputeStatusView?
    var disputeList:[String]=[]
    
    lazy var loader  : UIView = {
        return createActivityIndicator(self.view)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialLoads()
        self.localize()
        self.setDesign()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.setLayouts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.imageViewMap.image = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewButtons.isHidden = false
        self.viewMore.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        var disputeList = DisputeList()
        disputeList.dispute_type = UserType.user.rawValue
        self.presenter?.post(api: .getDisputeList, data: disputeList.toData())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hideRecipt()
        self.viewButtons.isHidden = true
        self.viewMore.isHidden = true
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.disputeView?.removeFromSuperview()
        self.disputeView = nil
        self.disputeStatusView?.removeFromSuperview()
        self.disputeStatusView = nil
    }
    
    deinit {
        self.viewButtons.removeFromSuperview()
        self.viewMore.removeFromSuperview()
        self.disputeView?.removeFromSuperview()
        self.disputeView = nil
        self.disputeStatusView?.removeFromSuperview()
        self.disputeStatusView = nil
        
    }
}

// MARK:-  Local Methods

extension YourTripsDetailViewController {
    
    //  Initial Loads
    private func initialLoads() {
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back-icon").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.backButtonClick))
        if !isUpcomingTrips {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_more").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.tapMore))
        }
        self.buttonCancelRide.isHidden = !isUpcomingTrips
        self.buttonCancelRide.addTarget(self, action: #selector(self.buttonCancelRideAction(sender:)), for: .touchUpInside)
        self.buttonViewReciptAndCall.addTarget(self, action: #selector(self.buttonCallAndReciptAction(sender:)), for: .touchUpInside)
        self.buttonDispute.addTarget(self, action: #selector(self.buttonDisputeAction(sender:)), for: .touchUpInside)
        self.buttonLostItem.addTarget(self, action: #selector(self.buttonLostItemAction(sender:)), for: .touchUpInside)
        self.loader.isHidden = false
        let api : Base = self.isUpcomingTrips ? .upcomingTripDetail : .pastTripDetail
        self.presenter?.get(api: api, parameters: ["request_id":self.requestId!])
        
        self.viewRating.minRating = 1
        self.viewRating.maxRating = 5
        self.viewRating.emptyImage = #imageLiteral(resourceName: "StarEmpty")
        self.viewRating.fullImage = #imageLiteral(resourceName: "StarFull")
        self.imageViewMap.image = #imageLiteral(resourceName: "rd-map")
        UIApplication.shared.keyWindow?.addSubview(self.viewButtons)
        self.viewButtons.translatesAutoresizingMaskIntoConstraints = false
        self.viewButtons.widthAnchor.constraint(equalTo: UIApplication.shared.keyWindow!.widthAnchor, multiplier: 0.8, constant: 0).isActive = true
        self.viewButtons.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.viewButtons.bottomAnchor.constraint(equalTo: UIApplication.shared.keyWindow!.bottomAnchor, constant: -16).isActive = true
        self.viewButtons.centerXAnchor.constraint(equalTo: UIApplication.shared.keyWindow!.centerXAnchor, constant: 0).isActive = true
        
        let moreViewY = (self.navigationController?.navigationBar.frame.height)!+(self.navigationController?.navigationBar.frame.origin.y)!
        self.viewMore.frame = CGRect(x: self.view.frame.width-170, y: moreViewY , width: 150, height: 100)
        UIApplication.shared.keyWindow?.addSubview(self.viewMore)
        self.viewMore.alpha = 0
        //UIApplication.shared.keyWindow?.addSubview(self.stackViewButtons)
        
        let touchOutside: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.touchOutside))
        view.addGestureRecognizer(touchOutside)
    }
    
    @objc func touchOutside() {
        self.viewMore.alpha = 0
    }
    
    
    func setId(id : Int) {
        self.requestId = id
    }
    
    //  Localize
    private func localize() {
        
        self.buttonViewReciptAndCall.setTitle((isUpcomingTrips ? Constants.string.call:Constants.string.viewRecipt).localize().uppercased(), for: .normal)
        self.labelPayViaString.text = (isUpcomingTrips ? Constants.string.paymentMethod : Constants.string.payVia).localize()
        self.buttonLostItem.setTitle(Constants.string.lostItem.localize(), for: .normal)
        
        if isUpcomingTrips {
            self.buttonCancelRide.setTitle(Constants.string.cancelRide.localize().uppercased(), for: .normal)
        } else {
            self.labelCommentsString.text = Constants.string.comments.localize()
        }
        self.navigationItem.title = (isUpcomingTrips ? Constants.string.upcomingTripDetails : Constants.string.pastTripDetails).localize()
        
    }
    
    // Set Designs
    
    private func setDesign() {
        
        Common.setFont(to: self.labelCommentsString, isTitle: true)
        Common.setFont(to: self.labelPayViaString, isTitle:  true)
        Common.setFont(to: self.labelDate, size : 12)
        Common.setFont(to: self.labelTime, size : 12)
        Common.setFont(to: self.labelBookingId)
        Common.setFont(to: self.labelPrice)
        Common.setFont(to: self.labelProviderName)
        Common.setFont(to: self.labelSourceLocation, size : 12)
        Common.setFont(to: self.labelDestinationLocation, size : 12)
        Common.setFont(to: self.labelPayVia)
        Common.setFont(to: self.buttonViewReciptAndCall, isTitle: true)
        Common.setFont(to: self.buttonDispute, isTitle: false)
        Common.setFont(to: self.buttonLostItem, isTitle: false)
        if isUpcomingTrips {
            Common.setFont(to: self.buttonCancelRide, isTitle: true)
        }
    }
    
    //  Layouts
    
    private func setLayouts() {
        
        self.imageViewProvider.makeRoundedCorner()
        let height = tableView.tableFooterView?.frame.origin.y ?? 0//(self.buttonViewReciptAndCall.convert(self.buttonViewReciptAndCall.frame, to: UIApplication.shared.keyWindow ?? self.tableView).origin.y+self.buttonViewReciptAndCall.frame.height)
        guard height <= UIScreen.main.bounds.height else { return }
        let footerHeight = UIScreen.main.bounds.height-height
        self.tableView.tableFooterView?.frame.size.height = (footerHeight-(self.buttonViewReciptAndCall.frame.height*2)-(self.navigationController?.navigationBar.frame.height ?? 0))
    }
    
    
    //  Set values
    
    private func setValues() {
        
        let mapImage = self.dataSource?.static_map?.replacingOccurrences(of: "%7C", with: "|").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        Cache.image(forUrl: mapImage) { (image) in
            if image != nil {
                DispatchQueue.main.async {
                    self.imageViewMap.image = image
                }
            }
        }
        self.labelProviderName.text = String.removeNil(self.dataSource?.provider?.first_name) + " " + String.removeNil(self.dataSource?.provider?.last_name)
        let imageUrl = String.removeNil(self.dataSource?.provider?.avatar).contains(WebConstants.string.http) ? self.dataSource?.provider?.avatar : Common.getImageUrl(for: self.dataSource?.provider?.avatar)
        Cache.image(forUrl: imageUrl) { (image) in
            if image != nil {
                DispatchQueue.main.async {
                    self.imageViewProvider.image = image
                }
            }
        }
        
        self.viewRating.rating = Float(self.dataSource?.rating?.provider_rating ?? 0)
        let comment = self.dataSource?.rating?.provider_comment
        self.textViewComments.text = comment?.count == 0 ? Constants.string.noComments.localize() : comment
        self.labelSourceLocation.text = self.dataSource?.s_address
        self.labelDestinationLocation.text = self.dataSource?.d_address
        self.labelPayVia.text = self.dataSource?.payment_mode?.rawValue.localize()
        self.imageViewPayVia.image = self.dataSource?.payment_mode == .CASH ? #imageLiteral(resourceName: "money_icon") : #imageLiteral(resourceName: "visa")
        self.labelBookingId.text = self.dataSource?.booking_id
        
        if let dateObject = Formatter.shared.getDate(from: self.dataSource?.assigned_at, format: DateFormat.list.yyyy_mm_dd_HH_MM_ss) {
            self.labelDate.text = Formatter.shared.getString(from: dateObject, format: DateFormat.list.ddMMMyyyy)
            self.labelTime.text = Formatter.shared.getString(from: dateObject, format: DateFormat.list.hh_mm_a)
        }
        self.labelPrice.text = String.removeNil(User.main.currency)+" \(self.dataSource?.payment?.total ?? 0)"
        
        self.buttonDispute.setTitle(self.dataSource?.dispute != nil ? Constants.string.disputeStatus.localize() : Constants.string.dispute.localize(), for: .normal)
        self.buttonLostItem.setTitle(self.dataSource?.lostitem != nil ? Constants.string.lostItemStatus.localize() : Constants.string.lostItem.localize(), for: .normal)
    }
    
    //  Cancel Ride
    
    @IBAction private func buttonCancelRideAction(sender : UIButton) {
        
        if isUpcomingTrips, self.dataSource?.id != nil {
            
            self.loader.isHidden = false
            // Cancel Request
            let request = Request()
            request.request_id = self.dataSource?.id
            self.presenter?.post(api: .cancelRequest, data: request.toData())
        }
        
    }
    
    //  Call and View Recipt
    
    @IBAction private func buttonCallAndReciptAction(sender : UIButton) {
        
        if isUpcomingTrips {
            if let number = self.dataSource?.provider?.mobile {
                Common.call(to: number)
            }
        } else {
            self.showRecipt()
        }
        
    }
    
    @objc func tapMore() {
        UIView.animate(withDuration: 0.3, animations: {
            if self.viewMore?.alpha == 0.0 {
                self.viewMore.alpha = 1.0
            }else{
                self.viewMore.alpha = 0.0
            }
        })
    }
    
    @IBAction private func buttonDisputeAction(sender : UIButton) {
        self.viewMore.alpha = 0.0
        if self.dataSource?.dispute != nil {
            //            showAlert(message: Constants.string.disputecreated.localize(), okHandler: nil, fromView: self)
            showDisputeStatus(isDispute: true)
            return
        }
        self.showDisputeView(isDispute:true)
        
    }
    
    @IBAction private func buttonLostItemAction(sender : UIButton) {
        self.viewMore.alpha = 0.0
        if self.dataSource?.lostitem != nil {
            self.showDisputeStatus(isDispute: false)
            return
        }
        self.showDisputeView(isDispute: false)
    }
    
    //  Show Recipt
    private func showRecipt() {
        
        if let viewReciptView = Bundle.main.loadNibNamed(XIB.Names.InvoiceView, owner: self, options: [:])?.first as? InvoiceView, self.dataSource != nil {
            viewReciptView.isShowingRecipt = true
            viewReciptView.set(request: self.dataSource!)
            viewReciptView.frame = CGRect(origin: CGPoint(x: 0, y: (UIApplication.shared.keyWindow?.frame.height)!-viewReciptView.frame.height), size: CGSize(width: self.view.frame.width, height: viewReciptView.frame.height))
            self.viewRecipt = viewReciptView
            UIApplication.shared.keyWindow?.addSubview(viewReciptView)
            viewReciptView.show(with: .bottom) { [weak self] in
                self?.addBlurView()
            }
            viewReciptView.onClickPaynow = { [unowned self]_ in
                self.hideRecipt()
            }
            viewReciptView.onDoneClick = { [unowned self]_ in
                self.hideRecipt()
            }
        }
        
    }
    
    func showDisputeView(isDispute:Bool){
        if self.disputeView == nil, let disputeView = Bundle.main.loadNibNamed(XIB.Names.DisputeLostItemView, owner: self, options: [:])?.first as? DisputeLostItemView {
            let disputeHeight = isDispute ? disputeView.frame.height : 250
            disputeView.frame = CGRect(x: 0, y: self.view.frame.height-disputeHeight, width: self.view.frame.width, height: disputeHeight)
            self.disputeView = disputeView
            if isDispute {
                disputeView.set(value: self.disputeList, isDispute: isDispute, requestID: self.requestId ?? 0,providerID: self.dataSource?.provider?.id ?? 0)
            }else{
                disputeView.set(value: [], isDispute: isDispute, requestID: self.requestId ?? 0,providerID: self.dataSource?.provider?.id ?? 0)
            }
            
            UIApplication.shared.keyWindow?.addSubview(disputeView)
            self.disputeView?.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: CGFloat(0.5),
                           initialSpringVelocity: CGFloat(1.0),
                           options: .allowUserInteraction,
                           animations: {
                            self.disputeView?.transform = .identity },
                           completion: { Void in()  })
        }
        self.disputeView?.onClickClose = { closed in
            UIView.animate(withDuration: 0.3, animations: {
                self.disputeView?.alpha = 0
            }, completion: { (_) in
                self.disputeView?.removeFromSuperview()
                self.disputeView = nil
            })
        }
    }
    
    private func showDisputeStatus(isDispute:Bool){
        if self.disputeStatusView == nil, let disputeStatusView = Bundle.main.loadNibNamed(XIB.Names.DisputeStatusView, owner: self, options: [:])?.first as? DisputeStatusView {
            
            disputeStatusView.frame = CGRect(x: 0, y: self.view.frame.height-disputeStatusView.frame.height, width: self.view.frame.width, height: disputeStatusView.frame.height)
            self.disputeStatusView = disputeStatusView
            
            if isDispute {
                disputeStatusView.setDispute(dispute: (self.dataSource?.dispute ?? Dispute()))
            }else{
                disputeStatusView.setLostItem(lostItem: (self.dataSource?.lostitem ?? Lostitem()))
            }
            
            UIApplication.shared.keyWindow?.addSubview(disputeStatusView)
            self.disputeStatusView?.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: CGFloat(0.5),
                           initialSpringVelocity: CGFloat(1.0),
                           options: .allowUserInteraction,
                           animations: {
                            self.disputeStatusView?.transform = .identity },
                           completion: { Void in()  })
        }
        self.disputeStatusView?.onClickClose = { _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.disputeStatusView?.alpha = 0
            }, completion: { (_) in
                self.disputeStatusView?.removeFromSuperview()
                self.disputeStatusView = nil
            })
        }
    }
    
    private func addBlurView() {
        
        self.blurView = UIView(frame: UIScreen.main.bounds)
        self.blurView?.alpha = 0
        self.blurView?.backgroundColor = .black
        self.blurView?.isUserInteractionEnabled = true
        self.view.addSubview(self.blurView!)
        self.blurView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hideRecipt)))
        UIView.animate(withDuration: 0.2, animations: {
            self.blurView?.alpha = 0.6
        })
        
    }
    
    //  Remove Recipt
    @IBAction private func hideRecipt() {
        
        self.viewRecipt?.dismissView(onCompletion: {
            self.viewRecipt = nil
            self.blurView?.removeFromSuperview()
        })
    }
}

// MARK:- Postview Protocol

extension YourTripsDetailViewController: PostViewProtocol {
    
    func onError(api: Base, message: String, statusCode code: Int) {
        DispatchQueue.main.async {
            self.loader.isHidden = true
            showAlert(message: message, okHandler: nil, fromView: self)
        }
    }
    
    func getRequestArray(api: Base, data: [Request]) {
        
        if data.count>0 {
            self.dataSource = data.first
        }
        
        DispatchQueue.main.async {
            self.loader.isHidden = true
            self.setValues()
        }
    }
    
    func getDisputeList(api: Base, data: [DisputeList]) {
        for disputeName in data {
            self.disputeList.append(disputeName.dispute_name ?? "")
        }
    }
    
}

//// MARK:- ScrollView Delegate
//
//extension YourTripsDetailViewController {
//
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        guard scrollView.contentOffset.y<0 else { return }
//
//        let inset = abs(scrollView.contentOffset.y/imageViewMap.frame.height)
//
//        self.imageViewMap.transform = CGAffineTransform(scaleX: 1+inset, y: 1+inset)
//
//    }
//
//}

extension YourTripsDetailViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if isUpcomingTrips && indexPath.row == 3 {
            return 0
        } else  {
            return heightArray[indexPath.row]
        }
        
    }
    
}



