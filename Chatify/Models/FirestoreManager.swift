//
//  FirestoreManager.swift
//  Chatify
//
//  Created by Amr Mohamad on 23/11/2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import FirebaseStorage

struct FirestoreManager {
    static var manager = FirestoreManager()
    let db = Firestore.firestore()
    var chat = Chat()
    func fetchMessageWith(
        id: String,
        completionHandler: @escaping (Message?) -> Void
    ) {
        let messagesRef = db.collection("messages")
        messagesRef.document(id).getDocument { docSnapshot, error in
            if let messageData = docSnapshot?.data(){
                switch messageData["messageType"] as! String {
                case "text":
                    if let sendToID   = messageData["sendToID"] as? String,
                       let sendFromID = messageData["sendFromID"] as? String,
                       let date       = messageData["Date"] as? Double,
                       let text       = messageData["text"] as? String {
                        let message = Message(
                            messageType: MessageType(rawValue: "text") ?? .text,
                            sendToID    : sendToID,
                            sendFromID  : sendFromID,
                            Date        : date,
                            text        : text,
                            imageInfo   : [:],
                            videoInfo   : [:],
                            locationInfo: [:]
                        )
                        completionHandler(message)
                    }
                case "video":
                    if let sendToID   = messageData["sendToID"] as? String,
                       let sendFromID = messageData["sendFromID"] as? String,
                       let date       = messageData["Date"] as? Double,
                       let videoInfo  = messageData["videoInfo"] as? [String:Any] {
                        let message = Message(
                            messageType: MessageType(rawValue: "video") ?? .video,
                            sendToID    : sendToID,
                            sendFromID  : sendFromID,
                            Date        : date,
                            text        : "",
                            imageInfo   : [:],
                            videoInfo   : videoInfo,
                            locationInfo: [:]
                        )
                        completionHandler(message)
                    }
                case "image":
                    if let sendToID   = messageData["sendToID"] as? String,
                       let sendFromID = messageData["sendFromID"] as? String,
                       let date       = messageData["Date"] as? Double,
                       let imageInfo   = messageData["imageInfo"] as? [String:Any] {
                        let message = Message(
                            messageType: MessageType(rawValue: "image") ?? .image,
                            sendToID    : sendToID,
                            sendFromID  : sendFromID,
                            Date        : date,
                            text        : "",
                            imageInfo   : imageInfo,
                            videoInfo   : [:],
                            locationInfo: [:]
                        )
                        completionHandler(message)
                    }
                case "location":
                    if let sendToID   = messageData["sendToID"] as? String,
                       let sendFromID = messageData["sendFromID"] as? String,
                       let date       = messageData["Date"] as? Double,
                       let locationInfo  = messageData["locationInfo"] as? [String:Any] {
                        let message = Message(
                            messageType: MessageType(rawValue: "location") ?? .location,
                            sendToID    : sendToID,
                            sendFromID  : sendFromID,
                            Date        : date,
                            text        : "",
                            imageInfo   : [:],
                            videoInfo   : [:],
                            locationInfo: locationInfo
                        )
                        completionHandler(message)
                    }
                default:
                    break
                }
            }else{
                completionHandler(nil)
            }
        }
    }
    
    func fetchUsers(
        data usersData: @escaping ([User]) -> Void,
        complation after: ( ([User])->())? = nil
    ) {
        db.collection("users").addSnapshotListener { snapshot, error in
            var users: [User] = []

            guard error == nil else {
                print("\(error?.localizedDescription ?? "error")")
                usersData([])
                return
            }
            
            if let docs = snapshot?.documents {
                for doc in docs {
                    let userData = doc.data()
                    
                    let user = User(
                        id             : doc.documentID,
                        name           : userData["name"] as! String,
                        email          : userData["email"] as! String,
                        profileImageURL: userData["profileImageURL"] as! String
                    )
                    users.append(user)
                }
                
                usersData(users)
                after?(users)
                
            }
        }
    }

    func downloadImage(urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data, error == nil {
                let image = UIImage(data: data)
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }
}

struct Chat {
    let db = Firestore.firestore()
    let storage = Storage.storage()
    var user: User?
    
    func sendMessage(
        withProperties properties: [String: Any],
        typeOfMessage type: MessageType
    ){
        if properties.isEmpty{
            return
        }else {
            if let sender = Auth.auth().currentUser?.uid{
                let currentTime = Date().timeIntervalSince1970
                var values: [String: Any] = [
                    "messageType"  : type.rawValue,
                    "sendFromID"   : sender,
                    "sendToID"     : user!.id,
                    "Date"         : currentTime
                ]
                properties.forEach({values[$0] = $1})
                var ref: DocumentReference? = nil
                ref = db.collection("messages")
                    .addDocument(data: values) { error in
                        if error != nil {
                            print("error with sending message: \(error!.localizedDescription)")
                            return
                        }
                        if let messageRef = ref {
                            let messageID = messageRef.documentID
                            if let userID = self.user?.id{
                                self.sendMessageToDB(
                                    messageID: messageID,
                                    currentTime: currentTime,
                                    sender: sender,
                                    receiver: userID
                                )
                            }
                        }
                    }
            }
        }
    }
    private func sendMessageToDB(
        messageID: String,
        currentTime: TimeInterval,
        sender sendFromID: String,
        receiver sendToID: String
    ){
        let se = self.db.collection("user-messages").document(sendFromID)
            .collection("chats").document(self.user!.id)
            .collection("chatContent").document("messagesID")
        
        se.updateData([messageID:currentTime]) { error in
            self.db.collection("user-messages").document(sendFromID).setData(["hasChats":true])
            self.db.collection("user-messages").document(sendFromID)
                .collection("chats").document(sendToID).setData(["lastMessage":messageID])
            if error != nil {
                se.setData([messageID:currentTime])
            }
        }
        
        let re = self.db.collection("user-messages").document(self.user!.id)
            .collection("chats").document(sendFromID)
            .collection("chatContent").document("messagesID")
        
        re.updateData([messageID:currentTime]) { error in
            self.db.collection("user-messages").document(sendToID).setData(["hasChats":true])
            self.db.collection("user-messages").document(sendToID)
                .collection("chats").document(sendFromID).setData(["lastMessage":messageID])
            if error != nil {
                re.setData([messageID:currentTime])
            }
        }
    }
    
    func deleteText(messageID: String, completion: @escaping ()->()) {
        // Additional logic for text messages if needed
        self.db.collection("messages").document(messageID).delete { error in
            if let error = error {
                print(error)
            }else {
                completion()
            }
        }
    }
    
    func deleteImage(message: Message ,messageID: String, index: Int, completion: @escaping ()->()) {
        // Additional logic for image messages if needed
        self.db.collection("messages").document(messageID).delete { error in
            if let error = error {
                print(error)
            }else {
                completion()
            }
            if let imageTitle = message.imageInfo["imageTitle"] as? String {
                guard let currentUserUID = Auth.auth().currentUser?.uid else {return}
                let storageRecImage = self.storage.reference()
                    .child("chat_images")
                    .child(currentUserUID)
                    .child("\(imageTitle).jpeg")
                storageRecImage.delete { error in
                    if let error = error {
                        print(error)
                    }
                    
                }
            }
        }
    }
    
    func deleteVideo(message: Message ,messageID: String, index: Int, completion: @escaping ()->()) {
        // Additional logic for video messages if needed
        self.db.collection("messages").document(messageID).delete { error in
            if let error = error {
                print(error)
            }else {
                completion()
            }
            if let titleVideo = message.videoInfo["videoTitle"] as? String {
                guard let currentUserUID = Auth.auth().currentUser?.uid else {return}
                let storageRecVideo = self.storage.reference()
                    .child("chat_videos")
                    .child(currentUserUID)
                    .child(titleVideo)
                    .child("\(titleVideo).mov")
                let storageRecVideoThumbnail = self.storage.reference()
                    .child("chat_videos")
                    .child(currentUserUID)
                    .child(titleVideo)
                    .child("\(titleVideo).jpeg")
                storageRecVideo.delete { error in
                    if let error = error {
                        print(error)
                    }
                    storageRecVideoThumbnail.delete { error in
                        if let error = error {
                            print(error)
                        }
                        
                    }
                }
            }
        }
    }
}
