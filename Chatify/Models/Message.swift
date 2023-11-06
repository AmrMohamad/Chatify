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
    var sendToID   : String
    var sendFromID : String
    var Date       : Double
    var text       : String
    var imageInfo   : [String : Any]
    
//    init(sendToID: String, sendFromID: String, Date: Double, text: String) {
//        self.sendToID = sendToID
//        self.sendFromID = sendFromID
//        self.Date = Date
//        self.text = text
//    }
//    init(sendToID: String, sendFromID: String, Date: Double, imageURL: String) {
//        self.sendToID = sendToID
//        self.sendFromID = sendFromID
//        self.Date = Date
//        self.imageURL = imageURL
//    }
    
    ///chatPartnerID is returning the ID of receiver
    func chatPartnerID() -> String {
        return self.sendFromID == Auth.auth().currentUser?.uid ? self.sendToID : self.sendFromID
    }
}
