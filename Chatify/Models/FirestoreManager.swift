//
//  FirestoreManager.swift
//  Chatify
//
//  Created by Amr Mohamad on 23/11/2023.
//

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import Foundation
import AVFoundation

struct FirestoreManager {
    static var shared = FirestoreManager()
    let db = Firestore.firestore()
    let storage = Storage.storage()
    var chat = Chat()
    func fetchMessageWith(
        id: String,
        completionHandler: @escaping (Message?) -> Void
    ) {
        let messagesRef = db.collection("messages")
        messagesRef.document(id).getDocument { docSnapshot, _ in
            if let messageData = docSnapshot?.data() {
                switch messageData["messageType"] as! String {
                case "text":
                    if let sendToID = messageData["sendToID"] as? String,
                       let sendFromID = messageData["sendFromID"] as? String,
                       let date = messageData["Date"] as? Double,
                       let text = messageData["text"] as? String
                    {
                        let message = Message(
                            messageType: MessageType(rawValue: "text") ?? .text,
                            sendToID: sendToID,
                            sendFromID: sendFromID,
                            Date: date,
                            text: text,
                            imageInfo: [:],
                            videoInfo: [:],
                            locationInfo: [:]
                        )
                        completionHandler(message)
                    }
                case "video":
                    if let sendToID = messageData["sendToID"] as? String,
                       let sendFromID = messageData["sendFromID"] as? String,
                       let date = messageData["Date"] as? Double,
                       let videoInfo = messageData["videoInfo"] as? [String: Any]
                    {
                        let message = Message(
                            messageType: MessageType(rawValue: "video") ?? .video,
                            sendToID: sendToID,
                            sendFromID: sendFromID,
                            Date: date,
                            text: "",
                            imageInfo: [:],
                            videoInfo: videoInfo,
                            locationInfo: [:]
                        )
                        completionHandler(message)
                    }
                case "image":
                    if let sendToID = messageData["sendToID"] as? String,
                       let sendFromID = messageData["sendFromID"] as? String,
                       let date = messageData["Date"] as? Double,
                       let imageInfo = messageData["imageInfo"] as? [String: Any]
                    {
                        let message = Message(
                            messageType: MessageType(rawValue: "image") ?? .image,
                            sendToID: sendToID,
                            sendFromID: sendFromID,
                            Date: date,
                            text: "",
                            imageInfo: imageInfo,
                            videoInfo: [:],
                            locationInfo: [:]
                        )
                        completionHandler(message)
                    }
                case "location":
                    if let sendToID = messageData["sendToID"] as? String,
                       let sendFromID = messageData["sendFromID"] as? String,
                       let date = messageData["Date"] as? Double,
                       let locationInfo = messageData["locationInfo"] as? [String: Any]
                    {
                        let message = Message(
                            messageType: MessageType(rawValue: "location") ?? .location,
                            sendToID: sendToID,
                            sendFromID: sendFromID,
                            Date: date,
                            text: "",
                            imageInfo: [:],
                            videoInfo: [:],
                            locationInfo: locationInfo
                        )
                        completionHandler(message)
                    }
                default:
                    break
                }
            } else {
                completionHandler(nil)
            }
        }
    }
    
    func fetchUsers(
        data usersData: @escaping ([User]) -> Void,
        complation after: (([User]) -> Void)? = nil
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
                        id: doc.documentID,
                        name: userData["name"] as! String,
                        email: userData["email"] as! String,
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
    
    //    func uploadVideoOf(_ videoURL: URL,progress progressOfUploading: @escaping (StorageTaskSnapshot)->()) {
    //        guard let uid = Auth.auth().currentUser?.uid else { return }
    //        let titleVideo = UUID().uuidString
    //        let storageRecVideo = storage.reference()
    //            .child("chat_videos")
    //            .child(uid)
    //            .child(titleVideo)
    //            .child("\(titleVideo).mov")
    //        let storageRecVideoThumbnail = storage.reference()
    //            .child("chat_videos")
    //            .child(uid)
    //            .child(titleVideo)
    //            .child("\(titleVideo).jpeg")
    //
    //        var video: Data?
    //        do {
    //            video = try NSData(contentsOf: videoURL) as Data
    //        } catch {
    //            print(error)
    //            return
    //        }
    //        var isUploadThumbnailFinished:Bool = false
    //
    //        let uploadTask = storageRecVideo.putData(video!) { _, error in
    //            if error != nil {
    //                print("error with uploading image:\n\(error!.localizedDescription)")
    //                return
    //            }
    //
    //            storageRecVideo.downloadURL { url, _ in
    //                if let safeURLVideo = url {
    //                    print("Successfully => \(safeURLVideo)")
    //
    //                    if let thumbnail = thumbnailVideoImageForVideo(url: videoURL) {
    //                        if let thumbnailImage = thumbnail.jpegData(compressionQuality: 0.02) {
    //                            let uploadThumbnail = storageRecVideoThumbnail.putData(thumbnailImage) { _, _ in
    //                                storageRecVideoThumbnail.downloadURL { url, _ in
    //                                    if let safeURLThumbnail = url {
    //                                        let properties: [String: Any] = [
    //                                            "videoInfo": [
    //                                                "videoTitle": titleVideo,
    //                                                "videoURL": safeURLVideo.absoluteString,
    //                                                "thumbnailVideoInfo": [
    //                                                    "thumbnailImageURL": safeURLThumbnail.absoluteString,
    //                                                    "thumbnailImageHeight": thumbnail.size.height,
    //                                                    "thumbnailImageWidth": thumbnail.size.width,
    //                                                ] as [String: Any],
    //                                            ] as [String: Any],
    //                                        ]
    //                                        FirestoreManager.shared.chat.sendMessage(
    //                                            withProperties: properties,
    //                                            typeOfMessage: .video
    //                                        )
    //                                    }
    //                                }
    //                            }
    //                            uploadThumbnail.resume()
    //                            uploadThumbnail.observe(.success) { _ in
    //                                isUploadThumbnailFinished = true
    //                            }
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //        uploadTask.resume()
    //
    //        var uploaded: Bool = isUploadThumbnailFinished {
    //            didSet {
    //                if uploaded {
    //                    uploadTask.observe(.progress) { storageTaskSnapshot in
    //                        progressOfUploading(storageTaskSnapshot)
    //                    }
    //                }
    //            }
    //        }
    //    }
    
    //    private func thumbnailVideoImageForVideo(url imageURL: URL) -> UIImage? {
    //        let asset = AVAsset(url: imageURL)
    //        let thumbnailImageGenerator = AVAssetImageGenerator(asset: asset)
    //        do {
    //            let thumbnailImage = try thumbnailImageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
    //            return UIImage(cgImage: thumbnailImage)
    //        } catch {
    //            print(error)
    //        }
    //        return nil
    //    }
    
    
}

struct Chat {
    let db = Firestore.firestore()
    let storage = Storage.storage()
    var user: User?

    func sendMessage(
        withProperties properties: [String: Any],
        typeOfMessage type: MessageType
    ) {
        if properties.isEmpty {
            return
        } else {
            if let sender = Auth.auth().currentUser?.uid {
                let currentTime = Date().timeIntervalSince1970
                var values: [String: Any] = [
                    "messageType": type.rawValue,
                    "sendFromID": sender,
                    "sendToID": user!.id,
                    "Date": currentTime,
                ]
                properties.forEach { values[$0] = $1 }
                var ref: DocumentReference?
                ref = db.collection("messages")
                    .addDocument(data: values) { error in
                        if error != nil {
                            print("error with sending message: \(error!.localizedDescription)")
                            return
                        }
                        if let messageRef = ref {
                            let messageID = messageRef.documentID
                            if let userID = self.user?.id {
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
    ) {
        let se = db.collection("user-messages").document(sendFromID)
            .collection("chats").document(user!.id)
            .collection("chatContent").document("messagesID")

        se.updateData([messageID: currentTime]) { error in
            self.db.collection("user-messages").document(sendFromID).setData(["hasChats": true])
            self.db.collection("user-messages").document(sendFromID)
                .collection("chats").document(sendToID).setData(["lastMessage": messageID])
            if error != nil {
                se.setData([messageID: currentTime])
            }
        }

        let re = db.collection("user-messages").document(user!.id)
            .collection("chats").document(sendFromID)
            .collection("chatContent").document("messagesID")

        re.updateData([messageID: currentTime]) { error in
            self.db.collection("user-messages").document(sendToID).setData(["hasChats": true])
            self.db.collection("user-messages").document(sendToID)
                .collection("chats").document(sendFromID).setData(["lastMessage": messageID])
            if error != nil {
                re.setData([messageID: currentTime])
            }
        }
    }

    func deleteText(messageID: String, completion: @escaping () -> Void) {
        // Additional logic for text messages if needed
        db.collection("messages").document(messageID).delete { error in
            if let error = error {
                print(error)
            } else {
                completion()
            }
        }
    }

    func deleteImage(message: Message, messageID: String, index _: Int, completion: @escaping () -> Void) {
        // Additional logic for image messages if needed
        db.collection("messages").document(messageID).delete { error in
            if let error = error {
                print(error)
            } else {
                completion()
            }
            if let imageTitle = message.imageInfo["imageTitle"] as? String {
                guard let currentUserUID = Auth.auth().currentUser?.uid else { return }
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

    func deleteVideo(message: Message, messageID: String, index _: Int, completion: @escaping () -> Void) {
        // Additional logic for video messages if needed
        db.collection("messages").document(messageID).delete { error in
            if let error = error {
                print(error)
            } else {
                completion()
            }
            if let titleVideo = message.videoInfo["videoTitle"] as? String {
                guard let currentUserUID = Auth.auth().currentUser?.uid else { return }
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

    func deleteLocation(messageID: String, completion: @escaping () -> Void) {
        db.collection("messages").document(messageID).delete { error in
            if let error = error {
                print(error)
            } else {
                completion()
            }
        }
    }

    func updateLastMessage(
        target: ChatViewController? = nil,
        currentUserDocRef: DocumentReference,
        chatPartnerDocRef: DocumentReference,
        messageID: String
    ) {
        guard let strongSelf = target else { return }
        currentUserDocRef.updateData([messageID: FieldValue.delete()]) { error in
            guard error == nil else {
                print(error as Any)
                return
            }
            DispatchQueue.main.async {
                strongSelf.isThereAMessageDeleted = true
            }
        }
        chatPartnerDocRef.updateData([messageID: FieldValue.delete()]) { error in
            guard error == nil else {
                print(error as Any)
                return
            }
            DispatchQueue.main.async {
                strongSelf.chatLogTableView.reloadData()
            }
        }
    }

    func updateLastMessageAfterDeleteMessage(
        _ deletedMessage: Message,
        lastMessageID: String?,
        currentUserUID uid: String
    ) {
        if lastMessageID != nil {
            db
                .collection("user-messages").document(deletedMessage.chatPartnerID())
                .collection("chats").document(uid)
                .setData(["lastMessage": lastMessageID!])
            db
                .collection("user-messages").document(uid)
                .collection("chats").document(deletedMessage.chatPartnerID())
                .setData(["lastMessage": lastMessageID!])
        } else {
            return
        }
    }
}
