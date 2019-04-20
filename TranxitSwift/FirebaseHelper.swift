//
//  FirebaseHelper.swift
//  ChatPOC
//
//  Created by CSS on 06/03/18.
//  Copyright © 2018 CSS. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import UIKit

typealias UploadTask = StorageUploadTask
typealias SnapShot = DataSnapshot
typealias EventType = DataEventType

class FirebaseHelper{
    
    private var ref: DatabaseReference?
    
    private var storage : Storage?
    
    static var shared = FirebaseHelper()
    
    // Write Text Message
    
    func write(to requestId : Int, with text : String, type chatType : ChatType = .single,userId : Int, driverId : Int){
        
        self.storeData(to: requestId, with: text, mime: .text, type: chatType, userId: userId, driverId: driverId)
        
    }
    
    // Upload from data
    
    func write(to userId : Int, with data : Data, mime type : Mime, type chatType : ChatType = .single, completion : @escaping (Bool)->())->UploadTask{
        
        let metadata = self.initializeStorage(with: type)
        
        return self.upload(data: data,forUser : userId, mime: type, type : chatType, metadata: metadata, completion: { (url) in
            
            completion(url != nil)
            guard url != nil else {
                return
            }
            self.storeData(to: userId, with: url, mime: type, type: chatType, userId: 0, driverId: 0)
            
        })
        
    }
    
    
    // Upload from Filepath
    
    func write(to userId : Int, file url : URL, mime type : Mime, type chatType : ChatType = .single , completion : @escaping (Bool)->())->UploadTask{
        
        let metadata = self.initializeStorage(with: type)
        
        return self.upload(file: url,forUser : userId, mime: type, type : chatType,metadata: metadata, completion: { (urlValue) in
            
            completion(urlValue != nil)
            guard urlValue != nil else {
                return
            }
            
            if let audioUrl = URL(string: urlValue!), let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
                do {
                    try FileManager.default.moveItem(at: url, to: destinationUrl)
                } catch let err {
                    print("Error ",err.localizedDescription)
                }
            }
            
            self.storeData(to: userId, with: urlValue, mime: type, type: chatType, userId: 0, driverId: 0)
            
        })
        
    }
    
    // Update Message in Specific Path
    
    func update(chat: ChatEntity, key : String, toUser requestId : Int, type chatType : ChatType = .single){
        
        let chatPath = Common.getChatId(with: requestId)
        chat.timestamp = (chat.timestamp ?? 0) * 1000 // multiplying for Date Fix Android
        self.update(chat: chat, key: key, inRoom: chatPath)
        
    }
    
    // Get unread chat messages
    func getUnreadMessages(for userId : Int,chatType : ChatType = .single,  completion : @escaping ((_ userId : Int,_ count : Int)->Void)) {
        self.initializeDB()
        
        if chatType == .single {
            self.ref?.child(Common.getChatId(with: userId)).queryOrdered(byChild: FirebaseConstants.main.read).queryEqual(toValue: 0).observe(.value, with: { (snapShot) in
                if let snapValue = snapShot.value as? NSDictionary, let snaps =  snapValue.allValues as? [NSDictionary] {
                    var count = 0
                    for snap in snaps where (snap[FirebaseConstants.main.user] as? Int) != User.main.id{
                        count += 1
                    }
                    completion(userId,count)
                }
            })
        } else if chatType == .group {
            self.ref?.child(Common.getChatId(with: userId)).queryOrdered(byChild: FirebaseConstants.main.user).observe(.value, with: { (snapShot) in
                if let snapValue = snapShot.value as? NSDictionary, let snaps =  snapValue.allValues as? [NSDictionary] {
                    var count = 0
                    for snap in snaps where !((snap[FirebaseConstants.main.readedMembers] as? [Int])?.contains(User.main.id!) ?? false) {
                        count += 1
                    }
                    completion(userId,count)
                }
            })
        }
        
    }
}


//MARK:- Helper Functions

extension FirebaseHelper {
    
    // Initializing DB
    
    private func initializeDB(){
        if self.ref == nil {
            let db = Database.database()
            // db.isPersistenceEnabled = true
            self.ref = db.reference()
        }
    }
    
    // Initializing Storage
    
    private func initializeStorage(with type : Mime)->StorageMetadata{
        
        if self.storage == nil {
            self.storage = Storage.storage()
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = type.contentType
        
        return metadata
    }
    
    // Update Values in specific path
    
    private func update(chat : ChatEntity, key : String, inRoom room : String){
        
        var chatEntity = chat.JSONRepresentation
        chatEntity.removeValue(forKey: FirebaseConstants.main.timestamp)
        self.ref?.child(room).child(key).updateChildValues(chatEntity)
        
    }
    
    // Common Function to Store Data
    
    private func storeData(to requestId : Int, with string : String?, mime type : Mime, type chatType : ChatType, userId : Int, driverId : Int){
        let chat = ChatEntity()
        chat.read = MessageStatus.sent.rawValue
        chat.user = User.main.id
        chat.sender = UserType.user.rawValue
        chat.number = String.removeNil(User.main.mobile)
        chat.readedMembers = [User.main.id!]
        chat.timestamp = Formatter.shared.removeDecimal(from: Date().timeIntervalSince1970*1000)
        chat.type = type.rawValue
        chat.userId = userId
        chat.driverId = driverId
        
        if type == .text {
            chat.text = string
        } else {
            chat.url = string
        }
        
        if chatType == .group {
            chat.groupId = userId
        }
        
        self.initializeDB()
        let chatPath = Common.getChatId(with: requestId)
        self.ref?.child(chatPath).child(self.ref!.childByAutoId().key!).setValue(chat.JSONRepresentation)
    }
    
    
    // Upload Data to Storage Bucket
    
    private func upload(data : Data,forUser user : Int, mime : Mime, type chatType : ChatType, metadata : StorageMetadata, completion : @escaping (_  downloadUrl : String?) -> ())->UploadTask{
        
        let chatPath = Common.getChatId(with: user)
        let ref = self.storage?.reference(withPath: chatPath).child(ProcessInfo().globallyUniqueString+mime.ext)
        let uploadTask = ref?.putData(data, metadata: metadata, completion: { (metaData, error) in
            
            if error != nil ||  metaData == nil {
                
                print(" Error in uploading  ", error!.localizedDescription)
                
            } else {
                
                if let image = UIImage(data: data) {  // Store the uploaded image in Cache
                    ref?.downloadURL(completion: { (url, error) in
                        completion(url?.absoluteString)
                        if let urlObject = url?.absoluteString {
                            Cache.shared.setObject(image, forKey: urlObject as AnyObject)
                        }
                    })
                    
                }
            }
        })
        
        return uploadTask!
        
    }
    
    
    //Upload File to Storage Bucket
    
    private func upload(file url : URL,forUser user : Int, mime : Mime, type chatType : ChatType, metadata : StorageMetadata, completion : @escaping (_  downloadUrl : String?) -> ())->UploadTask{
        
        let chatPath = Common.getChatId(with: user)
        let ref = self.storage?.reference(withPath: chatPath).child(ProcessInfo().globallyUniqueString+mime.ext)
        let uploadTask = ref?.putFile(from: url, metadata: metadata, completion: { (metaData, error) in
            
            if error != nil || metaData == nil {
                
                print(" Error in uploading  ", error!.localizedDescription)
                
            } else {
                
                ref?.downloadURL(completion: { (url, error) in
                    completion(url?.absoluteString)
                })
            }
            
        })
        
        return uploadTask!
    }
}

//MARK:- Observers
extension FirebaseHelper {
    
    // Observe if any value changes
    
    func observe(path : String, with eventType : EventType, value : @escaping ([ChatResponse])->())->UInt {
        
        self.initializeDB()
        return self.ref!.child(path).queryOrderedByKey().observe(eventType, with: { (snapShot) in
            value(self.getModal(from: snapShot))
            
        })
    }
    
    // Observe with limit
    
    func observe(path : String, with eventType : EventType, limit : UInt, value : @escaping ([ChatResponse])->()) {
        
        self.initializeDB()
        self.ref!.child(path).queryOrderedByKey().queryLimited(toLast: limit).observeSingleEvent(of: eventType) { (snap) in
            value(self.getModal(from: snap))
            // print(snap.childrenCount,"    \n",snap.value)
        }
    }
    
    // Remove Firebase Observers
    
    func remove(observers : [UInt]){
        
        self.initializeDB()
        
        for observer in observers {
            
            self.ref?.removeObserver(withHandle: observer)
            
        }
    }
    
    // Observe Last message
    
    func observeLastMessage(path : String, with : EventType, value : @escaping ([ChatResponse])->())->UInt {
        
        self.initializeDB()
        
        return self.ref!.child(path).queryLimited(toLast: 1).observe(with, with: { (snapShot) in
            
            value(self.getModal(from: snapShot))
            
        })
    }
    
    // Get Values From SnapShot
    
    private func getModal(from snapShot : SnapShot)->[ChatResponse]{
        print("Fetched from DB ",snapShot.childrenCount)
        var chatArray = [ChatResponse]()
        var response : ChatResponse?
        var chat : ChatEntity?
        
        if let snaps = snapShot.valueInExportFormat() as? [String : NSDictionary] {
            
            for snap in snaps {
                
                self.getChatEntity(with: &response, chat: &chat, snap: snap)
                chatArray.append(response!)
            }
        }
        else if let snaps = snapShot.value as? NSDictionary {
            
            self.getChatEntity(with: &response, chat: &chat, snap: (key: snapShot.key , value: snaps))
            chatArray.append(response!)
        }
        
        return chatArray.sorted(by: { (obj1, obj2) -> Bool in
            return Int.removeNil(obj1.response?.timestamp)<Int.removeNil(obj2.response?.timestamp)
        })
    }
    
    private func getChatEntity( with response : inout ChatResponse?, chat : inout ChatEntity?,snap : (key : String, value : NSDictionary)){
        
        response = ChatResponse()
        chat = ChatEntity()
        response?.key = snap.key
        
        chat?.read = snap.value.value(forKey: FirebaseConstants.main.read) as? Int
        chat?.sender = snap.value.value(forKey: FirebaseConstants.main.sender) as? String
        chat?.user = snap.value.value(forKey: FirebaseConstants.main.user) as? Int
        chat?.text = snap.value.value(forKey: FirebaseConstants.main.text) as? String
        if let dateValue = (snap.value.value(forKey: FirebaseConstants.main.timestamp) as? Int), dateValue>1000 {
            chat?.timestamp = dateValue/1000 // Subtracting milliseconds from dateobject
            print("Date since   \(Formatter.shared.relativePast(for: Date(timeIntervalSince1970: TimeInterval(dateValue/1000))))")
        }
        chat?.type = snap.value.value(forKey: FirebaseConstants.main.type) as? String
        chat?.url = snap.value.value(forKey: FirebaseConstants.main.url) as? String
        chat?.number = snap.value.value(forKey: FirebaseConstants.main.number) as? String
        chat?.groupId = snap.value.value(forKey: FirebaseConstants.main.groupId) as? Int
        if chat?.type == Mime.audio.rawValue{ // Setting initial value for Audio File
            response?.progress = 0
        }
        chat?.readedMembers = snap.value.value(forKey: FirebaseConstants.main.readedMembers) as? [Int]
        response?.response = chat
    }
}


