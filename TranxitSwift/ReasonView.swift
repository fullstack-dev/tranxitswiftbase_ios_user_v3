//
//  ReasonView.swift
//  User
//
//  Created by CSS on 26/07/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class ReasonView: UIView, UIScrollViewDelegate {
    
    @IBOutlet private weak var tableview : UITableView!
    @IBOutlet private weak var scrollView : UIScrollView!
    @IBOutlet private weak var labelTitle : UILabel!
    @IBOutlet private weak var buttonClose : UIButton!
    
    private var datasource:[String] = []
    private var selectedIndexPath = IndexPath(row: -1, section: -1)
    
    var onClickClose : ((Bool)->Void)?
    var didSelectReason : ((String)->Void)?
    
    private var isShowTextView = false {
        didSet {
            self.tableview.tableFooterView = isShowTextView ? self.getTextView() : nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tableview.dataSource = self
        self.tableview.delegate = self
        self.tableview.register(UINib(nibName: XIB.Names.CancelListTableViewCell, bundle: nil), forCellReuseIdentifier: XIB.Names.CancelListTableViewCell)
        self.isShowTextView = false
        Common.setFont(to: labelTitle)
        labelTitle.text = Constants.string.reasonForCancellation.localize()
        buttonClose.addTarget(self, action: #selector(self.buttonCloseAction), for: .touchUpInside)
    }
}

// MARK:-  Local Methods

extension ReasonView {
    
    // Creating Dynamic Text View
    
    private func getTextView()->UIView{
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height/2))
        let textView = UITextView(frame: CGRect(x: 16, y: 8, width: self.frame.width-32, height: (self.frame.height/2)-16))
        //textView.contentInset = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        Common.setFont(to: textView)
        textView.returnKeyType = .send
        textView.enablesReturnKeyAutomatically = true
        textView.delegate = self
        textView.borderLineWidth = 1
        textView.cornerRadius = 10
        textView.borderColor = .lightGray
        textView.toolbarPlaceholder = Constants.string.othersIfAny.localize()
        scrollView.contentOffset = CGPoint(x: 0, y: scrollView.contentSize.height)
        textView.becomeFirstResponder()
        view.addSubview(textView)
        return view
    }
    
    func set(value:[ReasonEntity])  {
        for reason in value {
            self.datasource.append(reason.reason!)
        }
        self.datasource.append(Constants.string.othersIfAny)
        self.tableview.reloadInMainThread()
    }
    
    // Button Done Action
    
    @IBAction private func buttonCloseAction() {
        self.onClickClose!(true)
    }
}

// MARK:- UITableViewDelegate

extension ReasonView : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.2) {
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
        tableView.cellForRow(at: selectedIndexPath)?.accessoryType = .none
        self.selectedIndexPath = indexPath
        tableView.cellForRow(at: selectedIndexPath)?.accessoryType = .checkmark
        
        if (indexPath.row == (datasource.count-1)) {
            if !self.isShowTextView {
                self.isShowTextView = true
            }
        }
        else {
            self.didSelectReason?(self.datasource[indexPath.row])
        }
    }
}

// MARK:- UITableViewDataSource

extension ReasonView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let tableCell = tableview.dequeueReusableCell(withIdentifier: XIB.Names.CancelListTableViewCell, for: indexPath) as? CancelListTableViewCell, self.datasource.count > indexPath.row {
            tableCell.textLabel?.text = self.datasource[indexPath.row]
            Common.setFont(to:  tableCell.textLabel!)
            return tableCell
        }
        return UITableViewCell()
    }
}

// MARK:- UITextViewDelegate

extension ReasonView : UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            self.didSelectReason?(textView.text)
            return false
        }
        return true
    }
}

