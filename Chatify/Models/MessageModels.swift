//
//  Message.swift
//  Chatify
//
//  Created by Amr Mohamad on 13/10/2023.
//

import Foundation
import FirebaseAuth
import RealmSwift

///Message is a value type contain the data of message
struct Message {
    var messageType: MessageType
    var sendToID   : String
    var sendFromID : String
    var Date       : Double
    var text       : String
    var imageInfo  : [String : Any]
    var videoInfo  : [String : Any]
    var locationInfo  : [String : Any]
    
    ///chatPartnerID is returning the ID of receiver
    func chatPartnerID() -> String {
        return self.sendFromID == Auth.auth().currentUser?.uid ? self.sendToID : self.sendFromID
    }
}

///Types of Message
enum MessageType: String, PersistableEnum{
    case image    = "image"
    case video    = "video"
    case text     = "text"
    case location = "location"
}

class MessageRealmObject: Object{
    @Persisted var id           : String
    @Persisted var messageType  : MessageType?
    @Persisted var sendToID     : String?
    @Persisted var sendFromID   : String?
    @Persisted var Date         : Date?
    @Persisted var text         : String?
    
    @Persisted var imageInfo    : Map<String,AnyRealmValue>
    @Persisted var videoInfo    : Map<String,AnyRealmValue>
    @Persisted var locationInfo : Map<String,AnyRealmValue>
    
    
    @Persisted(originProperty: "messages") var messages: LinkingObjects<UserRealmObject>
}
