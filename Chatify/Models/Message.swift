//
//  Message.swift
//  Chatify
//
//  Created by Amr Mohamad on 13/10/2023.
//

import Foundation

protocol MessageBody {
    var sendToID   : String { get set }
    var sendFromID : String { get set }
    var Date       : Double { get set }
    var text       : String { get set }
}

struct Message: MessageBody {
    var sendToID   : String
    var sendFromID : String
    var Date       : Double
    var text       : String
}
