//
//  Message.swift
//  Chatify
//
//  Created by Amr Mohamad on 13/10/2023.
//

import Foundation
import FirebaseAuth

struct Message {
    var sendToID   : String
    var sendFromID : String
    var Date       : Double
    var text       : String
    
    func chatPartnerID() -> String {
        return self.sendFromID == Auth.auth().currentUser?.uid ? self.sendToID : self.sendFromID
    }
}
