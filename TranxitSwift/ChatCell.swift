//
//  TableViewCell.swift
//  ChatPOC
//
//  Created by CSS on 06/03/18.
//  Copyright © 2018 CSS. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {
    
    //MARK: - IBOutlet
    
    @IBOutlet private var viewCell : UIView!
    @IBOutlet private var labelCell : UILabel?
    @IBOutlet private var labelTime : UILabel!
    @IBOutlet private var imageViewStatus : UIImageView!
    @IBOutlet private var imageViewAttachment : UIImageView?
    @IBOutlet private var activityIndicator : UIActivityIndicatorView?
    @IBOutlet private var labelSenderName : UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageViewStatus.isHidden = true
    }
    
    func setSender(values : ChatResponse, requestId : Int) {
        
        self.set(values: values.response, isRecieved: false)
        self.imageViewStatus.image = values.response?.read == MessageStatus.sent.rawValue ? #imageLiteral(resourceName: "sent") : #imageLiteral(resourceName: "read")
    }
    
    //Set Sender Detail only for Group
    func setSenderDetail(detail : String?){
        
        self.labelSenderName?.text = detail
    }
    
    func setRecieved(values : ChatResponse, chatType : ChatType = .single, requestId : Int){
        
        guard let entity = values.response , let key = values.key else {
            return
        }
        if entity.read == MessageStatus.sent.rawValue {
            entity.read = MessageStatus.read.rawValue
            FirebaseHelper.shared.update(chat: entity, key: key, toUser: requestId)
        }
        self.set(values: values.response, isRecieved: true)
        self.imageViewStatus.isHidden = true // hiding message status for reciever
        
        if chatType == .group, let _ = values.response?.sender {
            self.labelSenderName?.text = values.response?.number
        }
    }
    
    private func set(values : ChatEntity?, isRecieved : Bool){
        
        if values?.type != Mime.text.rawValue {
            self.imageViewAttachment?.image = #imageLiteral(resourceName: "backgroundImage")  // 
            Cache.image(forUrl: values?.url, completion: { (image) in
                DispatchQueue.main.async {
                    self.activityIndicator?.stopAnimating()
                    if image != nil {
                        self.imageViewAttachment?.image = image
                    }else {
                        self.imageViewAttachment?.image = #imageLiteral(resourceName: "backgroundImage")
                    }
                }
            })
        }
        else {
            self.labelCell?.text = values?.text
        }
        self.labelCell?.textColor = isRecieved ? .black : .white
        self.viewCell.backgroundColor = isRecieved ? .white : UIColor.lightGray
        self.labelTime.text = Formatter.shared.relativePast(for: Date(timeIntervalSince1970: TimeInterval(values?.timestamp ?? 0)))
        self.layoutIfNeeded()
    }
}
