//
//  DisputeStatusView.swift
//  TranxitUser
//
//  Created by Ansar on 19/01/19.
//  Copyright © 2019 Appoets. All rights reserved.
//

import UIKit

class DisputeStatusView: UIView {
    
    @IBOutlet private weak var tableview : UITableView!
    @IBOutlet private weak var lblHeading : UILabel!
    @IBOutlet private weak var btnClose : UIButton!
    @IBOutlet private weak var btnCall : UIButton!
    @IBOutlet private weak var viewHeader : UIView!
    
    private var dispute:Dispute?
    private var lostItem:Lostitem?
    
    var isDispute:Bool = false
    var onClickClose : ((Bool)->Void)?
    
    var statusOpen : UIColor {
        return #colorLiteral(red: 0.9058823529, green: 0.9215686275, blue: 1, alpha: 1)
    }
    
    var statusOpenFont : UIColor {
        return #colorLiteral(red: 0.1058823529, green: 0.4, blue: 0.9333333333, alpha: 1)
    }
    
    var statusClose : UIColor {
        return #colorLiteral(red: 1, green: 0.9058823529, blue: 0.9294117647, alpha: 1)
    }
    
    var statusCloseFont : UIColor {
        return #colorLiteral(red: 0.9333333333, green: 0.1058823529, blue: 0.3137254902, alpha: 1)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialLoads()
    }
    
}

//MARK :- Local Methods

extension DisputeStatusView {
    
    private func initialLoads() {
        self.alpha = 1
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.tableview.register(UINib(nibName: XIB.Names.DisputeSenderCell, bundle: nil), forCellReuseIdentifier: XIB.Names.DisputeSenderCell)
        self.tableview.register(UINib(nibName: XIB.Names.DisputeReceiverCell, bundle: nil), forCellReuseIdentifier: XIB.Names.DisputeReceiverCell)
        self.btnClose.addTarget(self, action: #selector(tapClose), for: .touchUpInside)
        self.btnCall.addTarget(self, action: #selector(tapCall), for: .touchUpInside)
        self.btnCall.imageWith(color: .primary, for: .normal) // Tint color
        self.addShadow()
    }
    
    func setDispute(dispute:Dispute) {
        lblHeading.text = Constants.string.dispute.localize()
        self.dispute = dispute
        isDispute = true
        self.tableview.reloadInMainThread()
    }
    
    func setLostItem(lostItem:Lostitem) {
        lblHeading.text = Constants.string.lostItem.localize()
        self.lostItem = lostItem
        isDispute = false
        self.tableview.reloadInMainThread()
    }
    
    @IBAction func tapCall() {
        Common.call(to: supportNumber)
    }
    
    @objc func tapClose() {
        onClickClose!(true)
    }
    
    func addShadow() {
        viewHeader.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        viewHeader.layer.shadowOpacity = 0.5
        viewHeader.layer.shadowOffset = CGSize(width: 10 , height: 10)
        viewHeader.layer.shadowRadius = 5
    }
    
}


// MARK:- UITableViewDelegate

extension DisputeStatusView : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if dispute?.dispute_type == UserType.user.rawValue {
            return 110
        }
        else{
            return 90
        }
    }
    
}

// Mark :- UITableViewDataSource

extension DisputeStatusView : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return self.getCell(for: indexPath)
    }
    
    private func getCell(for indexPath:IndexPath) -> UITableViewCell {
        if isDispute {
            if dispute != nil {
                if indexPath.row == 0 {
                    if dispute?.dispute_type == UserType.user.rawValue {
                        if let tableCell = tableview.dequeueReusableCell(withIdentifier: XIB.Names.DisputeSenderCell, for: indexPath) as? DisputeSenderCell {
                            tableCell.imgProfile.setImage(with: Common.getImageUrl(for: User.main.picture), placeHolder: #imageLiteral(resourceName: "userPlaceholder"))
                            tableCell.lblName.text = Constants.string.you.localize()
                            tableCell.lblStatus.text = self.dispute?.status?.uppercased()
                            tableCell.viewStatus.backgroundColor = self.dispute?.status == DisputeStatus.open.rawValue ? self.statusOpen : self.statusClose
                            tableCell.lblStatus.textColor = self.dispute?.status == DisputeStatus.open.rawValue ? self.statusOpenFont : self.statusCloseFont
                            tableCell.lblContent.text = self.dispute?.dispute_name
                            return tableCell
                        }
                    }
                }else{
                    if dispute?.comments != nil{
                        if let tableCell = tableview.dequeueReusableCell(withIdentifier: XIB.Names.DisputeReceiverCell, for: indexPath) as? DisputeReceiverCell {
                            tableCell.lblName.text = Constants.string.admin.localize()
                            tableCell.lblContent.text = self.dispute?.comments
                            return tableCell
                        }
                    }
                }
            }
        }else{
            if indexPath.row == 0 {
                if let tableCell = tableview.dequeueReusableCell(withIdentifier: XIB.Names.DisputeSenderCell, for: indexPath) as? DisputeSenderCell {
                    tableCell.imgProfile.setImage(with: Common.getImageUrl(for: User.main.picture), placeHolder: #imageLiteral(resourceName: "userPlaceholder"))
                    tableCell.lblName.text = Constants.string.you.localize()
                    tableCell.lblStatus.text = self.lostItem?.status?.uppercased()
                    tableCell.viewStatus.backgroundColor = self.lostItem?.status == DisputeStatus.open.rawValue ? self.statusOpen : self.statusClose
                    tableCell.lblStatus.textColor = self.lostItem?.status == DisputeStatus.open.rawValue ? self.statusOpenFont : self.statusCloseFont
                    tableCell.lblContent.text = self.lostItem?.lost_item_name
                    return tableCell
                }
            }else{
                if lostItem?.comments != nil {
                    if let tableCell = tableview.dequeueReusableCell(withIdentifier: XIB.Names.DisputeReceiverCell, for: indexPath) as? DisputeReceiverCell {
                        tableCell.lblName.text = Constants.string.admin.localize()
                        tableCell.lblContent.text = self.lostItem?.comments
                        return tableCell
                    }
                }
            }
        }
        return UITableViewCell()
    }
}
