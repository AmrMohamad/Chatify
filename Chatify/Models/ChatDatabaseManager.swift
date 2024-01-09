//
//  ChatifyDatabaseManager.swift
//  Chatify
//
//  Created by Amr Mohamad on 19/12/2023.
//

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import MobileCoreServices
import RealmSwift
import SwiftUI
import UIKit

protocol ChatDatabaseManagerProtocol {
    
    func fetchMessages(of user: User, completion: @escaping ([Message],[String: Double])->Void)
    func deleteMessage()
    func sendLocation()
    func sendImage()
    func sendVideo()
    
}
class ChatDatabaseManager: ChatDatabaseManagerProtocol {
    
    static let shared = ChatDatabaseManager()
    
    let db = Firestore.firestore()
    
    private init () {}
    
    func fetchMessages(
        of user: User,
        completion: @escaping ([Message],[String: Double])->Void
    ) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        var messages: [Message] = [Message]()
        db.collection("user-messages").document(uid)
            .collection("chats").document(user.id)
            .collection("chatContent").document("messagesID")
            .addSnapshotListener { docSnapshots, error in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                } else {
                    if let snapshots = docSnapshots?.data() {
                        messages = []
                        let messagesIDDictionary = snapshots as! [String: Double]
                        snapshots.forEach { key, _ in
                            FirestoreManager.shared.fetchMessageWith(id: key) { message in
                                if let message = message {
                                    if message.chatPartnerID() == user.id {
                                        messages.append(message)
                                        completion(messages,messagesIDDictionary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
    }
    
    func deleteMessage() {
        
    }
    
    func sendLocation() {
        
    }
    
    func sendImage() {
        
    }
    
    func sendVideo() {
        
    }
    
}
