//
//  Message.swift
//  Chatify
//
//  Created by Amr Mohamad on 13/10/2023.
//

import Foundation
import FirebaseAuth

///Message is a value type contain the data of message
struct Message {
    var messageType: MessageType
    var sendToID   : String
    var sendFromID : String
    var Date       : Double
    var text       : String
    var imageInfo  : [String : Any]
    var videoInfo  : [String : Any]
    
    ///chatPartnerID is returning the ID of receiver
    func chatPartnerID() -> String {
        return self.sendFromID == Auth.auth().currentUser?.uid ? self.sendToID : self.sendFromID
    }
}

enum MessageType: String {
    case image = "image"
    case video = "video"
    case text  = "text"
}
