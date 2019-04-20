//
//  SingleChatController.swift
//  User
//
//  Created by CSS on 05/03/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit
import Lightbox

// ENUM Chat Type

enum ChatType : Int {
    
    case single = 1
    case group = 2
    case media = 3
    
}

class SingleChatController: UIViewController {
    
    //Mark:- IBOutlets
    
    @IBOutlet private var tableView : UITableView!
    @IBOutlet private var bottomConstraint : NSLayoutConstraint!
    @IBOutlet private var textViewSingleChat : UITextView!
    @IBOutlet private weak var viewCamera : UIView!
    @IBOutlet private weak var viewRecord : UIView!
    @IBOutlet private weak var viewSend : UIView!
    @IBOutlet private weak var progressViewImage : UIProgressView!
    
    //Mark:- Local Variable
    
    private var navigationTapgesture : UITapGestureRecognizer!
    private var imageButtonView : UIImageView? // used to modify profile image after changes
    private var datasource = [ChatResponse]()   // Current Chat Data
    private var currentUser : (Provider)! // Current User Data
    private var chatType :  ChatType!   // Current Chat eg:-  single or group
    private var addedObservers = [UInt]() // Added Observers
    private var viewJustAppeared = true
    private var isConversationToneEnabled = false
    private var currentUserId = 0
    private var requestId = 0
    
    private let senderCellTextId = "sender"
    private let recieverCellTextId = "reciever"
    private let senderMediaId = "senderMedia"
    private let reciverMediaId = "reciverMedia"
    
    let avPlayerHelper = AVPlayerHelper()
    let chatSenderNib = "ChatSender"
    let chatRecieverNib = "ChatReciever"
    let imageCellSenderNib = "ImageCellSender"
    let imageCellRecieverNib = "ImageCellReciever"
    
    private lazy var loader : UIView = {
        createActivityIndicator(UIApplication.shared.keyWindow ?? self.view)
    }()
    
    private var isSendShown = false {
        
        didSet {
            self.viewCamera.isHidden = true //isSendShown
            self.viewSend.isHidden = !isSendShown
            self.viewRecord.isHidden = true
        }
    }
    // Deinit
    deinit {  // Remove the current firebase observer
        
        FirebaseHelper.shared.remove(observers: self.addedObservers)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialLoads()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateUI()
        self.viewJustAppeared = true
        self.isConversationToneEnabled = true//UserDefaults.standard.bool(forKey: Keys.list.conversationTones)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.removeGestureRecognizer(self.navigationTapgesture)
    }
    
}

//Mark:- Local Methods

extension SingleChatController {
    
    //Set Current User Data
    func set(user : Provider, chatType : ChatType = .single, requestId : Int){
        
        self.currentUser = user
        self.chatType = chatType
        self.currentUserId = currentUser.id ?? 0
        self.requestId = requestId
    }
    
    // Make Tone
    private func makeTone(){
        
        if self.isConversationToneEnabled {
            DispatchQueue.main.async {
                self.avPlayerHelper.play(file: "mesageTone.wav", isLooped: false)
            }
        }
    }
    
    // Update UI
    private func updateUI() {
        
        self.tableView.reloadRows(at: tableView.indexPathsForVisibleRows ?? [IndexPath(row: 0, section: 0)], with: .fade)
        self.navigationTapgesture = UITapGestureRecognizer(target: self, action: #selector(self.navigationBarTapped))
        self.navigationController?.navigationBar.addGestureRecognizer(self.navigationTapgesture)
        self.navigationItem.title = String.removeNil(currentUser.first_name)+" "+String.removeNil(currentUser.last_name)
        Cache.image(forUrl: Common.getImageUrl(for: currentUser.avatar)) { (image) in
            if image != nil {
                DispatchQueue.main.async {
                    self.imageButtonView?.image = image?.resizeImage(newWidth: 30)?.withRenderingMode(.alwaysOriginal)
                }
            }
        }
    }
    
    // Initial Loads
    private func initialLoads(){
        
        if traitCollection.forceTouchCapability == .available {  // Set Peek and pop for Image Preview
            self.registerForPreviewing(with: self, sourceView: self.tableView)  // Setting image preview for tableview cells
        }
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        } 
        let backButtonArrow = UIBarButtonItem(image: #imageLiteral(resourceName: "close-1"), style: .plain, target: self, action: #selector(self.backAction))
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        let imageButton = UIBarButtonItem(image: #imageLiteral(resourceName: "userPlaceholder").resizeImage(newWidth: 30)?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.navigationBarTapped))
        Cache.image(forUrl: Common.getImageUrl(for: currentUser.avatar)) { (image) in
            if image != nil {
                DispatchQueue.main.async {
                    
                    let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
                    imageView.makeRoundedCorner()
                    imageView.image = image?.resizeImage(newWidth: 30)?.withRenderingMode(.alwaysOriginal)
                    imageView.contentMode = .scaleAspectFill
                    imageButton.customView = imageView
                    imageButton.customView?.isUserInteractionEnabled = true
                    // imageButton.image = #imageLiteral(resourceName: "account").resizeImage(newWidth: 40)?.withRenderingMode(.alwaysOriginal)
                    // imageButton.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.navigationBarTapped)))
                    self.imageButtonView = imageView
                }
            }
        }
        
        self.navigationItem.leftBarButtonItems = [backButtonArrow,fixedSpace,imageButton]
        
        //        if chatType == .single {  // Media call only allowed to single chat
        //
        //            let callButton = UIBarButtonItem(image: #imageLiteral(resourceName: "call_icon"), style: .plain, target: self, action: #selector(self.callButtonAction))
        //            let videoButton = UIBarButtonItem(image: #imageLiteral(resourceName: "video_icon"), style: .plain, target: self, action: #selector(self.videoButtonAction))
        //
        //            self.navigationItem.rightBarButtonItems?.append(contentsOf: [videoButton,callButton])
        //        }
        
        self.addKeyBoardObserver(with: bottomConstraint)
        self.textViewSingleChat.delegate = self
        self.tableView.register(UINib(nibName: chatSenderNib, bundle: .main), forCellReuseIdentifier: senderCellTextId)
        self.tableView.register(UINib(nibName: chatRecieverNib, bundle: .main), forCellReuseIdentifier: recieverCellTextId)
        self.tableView.register(UINib(nibName: imageCellSenderNib, bundle: .main), forCellReuseIdentifier: senderMediaId)
        self.tableView.register(UINib(nibName: imageCellRecieverNib, bundle: .main), forCellReuseIdentifier: reciverMediaId)
        
        self.viewSend.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.sendOnclick)))
        self.viewRecord.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.recordOnclick)))
        self.viewCamera.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.cameraOnclick)))
        self.isSendShown = false
        self.startObservers()
    }
    
    //  Start Observers
    private func startObservers(){
        
        let chatPath = Common.getChatId(with: requestId)
        
        let childObserver = FirebaseHelper.shared.observe(path : chatPath, with: .childAdded) { (childValue) in
            
            if self.datasource.count>0, let child = childValue.first {
                DispatchQueue.main.async {
                    self.tableView.beginUpdates()
                    if self.datasource.filter({ $0.key == child.key }).count == 0 {
                        self.datasource.append(child)
                        self.tableView.insertRows(at: [IndexPath(row: self.datasource.count-1, section: 0)], with: .fade)
                    }
                    self.tableView.endUpdates()
                    self.tableView.scrollToRow(at: IndexPath(row: self.datasource.count-1, section: 0), at: .bottom, animated: false)
                }
                self.makeTone()
            }
            else {
                self.datasource =  childValue
                DispatchQueue.main.async {
                    self.reload()
                }
            }
        }
        
        let modifedObserver = FirebaseHelper.shared.observe(path : chatPath, with: .childChanged) { (childValue) in
            
            if let childNode = childValue.first, let index = self.datasource.index(where: { (chat) -> Bool in
                chat.key == childNode.key
            })
            {
                self.datasource[index] = childNode
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                }
            }
        }
        self.addedObservers.append(childObserver)
        self.addedObservers.append(modifedObserver)
    }
    
    @IBAction private func backAction() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func navigationBarTapped() {
        print("Navigstion bar tapped ")
    }
    
    @IBAction private func reload() {
        
        self.tableView.reloadData()
        if self.datasource.count>0{
            UIView.animate(withDuration: 0.5, animations: {  // reload and scroll to last index
                self.tableView.scrollToRow(at: IndexPath(row: self.datasource.count-1, section: 0), at: .top, animated: false)
            })
        }
    }
    
    @IBAction private func moreButtonAction(){
        
    }
    
    @IBAction private func cameraOnclick(){
        
        SelectImageView.main.show(imagePickerIn: self) { (images) in
            
            if let image = images.first, let imageData = image.resizeImage(newWidth: 400), let data = imageData.pngData() {
                
                self.progressViewImage.isHidden = false
                
                let task = FirebaseHelper.shared.write(to: self.requestId, with: data, mime: .image, type : self.chatType, completion: { (isCompleted) in
                    
                    DispatchQueue.main.async {
                        self.progressViewImage.isHidden = true
                    }
                    print("isCompleted  -- ",isCompleted)
                    
                })
                
                task.observe(.progress, handler: { (snapShot) in
                    
                    DispatchQueue.main.async {
                        self.progressViewImage.progress = (Float(snapShot.progress!.completedUnitCount/snapShot.progress!.totalUnitCount)) 
                    }
                    
                    print("Progress  ",(snapShot.progress!.completedUnitCount/snapShot.progress!.totalUnitCount) * 100)
                })
            }
        }
    }
    
    @IBAction private func recordOnclick() {
        
    }
    
    @IBAction private func sendOnclick() {
        
        FirebaseHelper.shared.write(to: self.requestId, with: self.textViewSingleChat.text, type : self.chatType, userId : Int.removeNil(User.main.id), driverId : currentUserId)
        // self.sendPush(with: self.textViewSingleChat.text)
        // self.initimateServerAboutChat()
        let message = "\(User.main.firstName ?? .Empty) : \(self.textViewSingleChat.text ?? .Empty)"
        DispatchQueue.global(qos: .background).async {
            var chatObject = ChatPush()
            chatObject.sender = .provider
            chatObject.user_id = self.currentUserId
            chatObject.message = message
            self.presenter?.post(api: .chatPush, data: chatObject.toData())
        }
        self.textViewSingleChat.text = .Empty
        self.textViewDidEndEditing(self.textViewSingleChat)
    }
    
    @IBAction private func backButtonAction(){
        
        if navigationController == nil {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesBegan(touches, with: event)
        
        if let touch = touches.first {
            let currentPoint = touch.location(in: self.view)
            print(currentPoint)
            if !self.textViewSingleChat.bounds.contains(currentPoint){
                self.textViewSingleChat.resignFirstResponder()
            }
        }
    }
    
    private func setEmptyView(){
        
        DispatchQueue.main.async {
            
            self.tableView.backgroundView = self.datasource.count == 0 ?  {
                
                let label = UILabel(frame: self.tableView.bounds)
                label.textAlignment = .center
                label.text = Constants.string.noChatHistory
                Common.setFont(to: label, isTitle: true)
                return label
                
                }() : nil
        }
    }
    
    // Show Image Preview
    
    private func getImagePreview(index : Int)->LightboxController?{
        
        if datasource.count>index, datasource[index].response?.type == Mime.image.rawValue, let url = URL(string: (datasource[index].response?.url) ?? .Empty) {
            
            let image = LightboxImage(imageURL: url)
            
            let lightBox = LightboxController(images: [image], startIndex: 0)
            lightBox.dynamicBackground = true
            LightboxConfig.CloseButton.image = #imageLiteral(resourceName: "close-1")
            LightboxConfig.CloseButton.text = .Empty
            LightboxConfig.CloseButton.size = CGSize(width: 25, height: 25)
            LightboxConfig.PageIndicator.enabled = false
            return lightBox
        }
        return nil
    }
}


//MARK:- UITableViewDataSource

extension SingleChatController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let chat = datasource[indexPath.row].response, let tableCell = tableView.dequeueReusableCell(withIdentifier: getCellId(from: chat), for: indexPath) as? ChatCell {
            
            if chat.sender == UserType.user.rawValue {
                
                tableCell.setSender(values: datasource[indexPath.row], requestId: requestId)
                
            } else {
                
                tableCell.setRecieved(values: datasource[indexPath.row], chatType: self.chatType, requestId: self.requestId)
            }
            
            return tableCell
        }
        return UITableViewCell()
    }
    
    private func getCellId(from entity : ChatEntity)->String {
        
        if entity.sender == UserType.user.rawValue {
            return entity.type == Mime.text.rawValue ? senderCellTextId : senderMediaId
        } else {
            return entity.type == Mime.text.rawValue ? recieverCellTextId : reciverMediaId
        }
        
    }
}

//MARK:- UITableViewDelegate

extension SingleChatController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if self.datasource[indexPath.row].response?.type == Mime.text.rawValue {
            return UITableView.automaticDimension
        }
        
        return 400 * (568 / UIScreen.main.bounds.height)
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Preview Image
        
        if let lightBox = self.getImagePreview(index: indexPath.row){
            
            self.present(lightBox, animated: true, completion: nil)
            
        }
        
        UIView.animate(withDuration: 0.2) {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
}


//MARK:- UITextViewDelegate

extension SingleChatController : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == Constants.string.writeSomething {
            textView.text = .Empty
            textView.textColor = .black
        }
        self.reload()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text == .Empty {
            textView.text = Constants.string.writeSomething
            textView.textColor = .lightGray
            isSendShown = false
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if !textView.text.isEmpty {
            isSendShown = true
        } else  {
            isSendShown = false
        }
        
    }
}


//MARK:- UIViewControllerPreviewingDelegate

extension SingleChatController : UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController?{
        
        guard let indexPath = tableView.indexPathForRow(at: location),  // Getting image from tableview and show in peek preview
            let cell = tableView.cellForRow(at: indexPath),
            let vc = self.getImagePreview(index: indexPath.row) else {
                return nil
        }
        
        previewingContext.sourceRect = cell.frame
        vc.dismissalDelegate = self
        return vc
    }
    
    // pop
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController){
        
        self.present(viewControllerToCommit, animated: true, completion: nil)
        
    }
}


//MARK:- PostViewProtocol

extension SingleChatController : PostViewProtocol {
    
    func onError(api: Base, message: String, statusCode code: Int) {
        
        DispatchQueue.main.async {
            self.view.make(toast: message)
        }
        print("Error in ",api,"  ", message)
        
    }
}

//MARK:- LightboxControllerDismissalDelegate

extension SingleChatController : LightboxControllerDismissalDelegate {
    
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        
        controller.navigationController?.popViewController(animated: true)
        
    }
}




