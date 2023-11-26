//
//  ChatViewController.swift
//  Chatify
//
//  Created by Amr Mohamad on 11/10/2023.
//

import UIKit
import SwiftUI
import DeviceKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import FirebaseStorage
import MobileCoreServices
import AVFoundation

class ChatViewController: UIViewController,
                          UITableViewDataSource,
                          UITableViewDelegate,
                          UITextFieldDelegate,
                          UIImagePickerControllerDelegate,
                          UINavigationControllerDelegate,
                          UITextViewDelegate {

    let groupOfAllowedDevices: [Device] = [
        .iPhone8,
        .iPhoneSE2,
        .iPhoneSE3,
        .iPhoneSE,
        .simulator(.iPhone8),
        .simulator(.iPhoneSE2),
        .simulator(.iPhoneSE2),
        .simulator(.iPhoneSE3),
    ]
    let device = Device.current
    let messagesCache = NSCache<AnyObject, AnyObject>()
    var user: User? {
        didSet{
            navigationItem.title = user!.name
            fetchUserMessages()
        }
    }
    var messagesIDDictionary : [String:Double] = [String:Double]()
    var messagesID : [String] = [String]()
    var messages: [Message] = [Message](){
        didSet{
            messages.sort { m1, m2 in
                return m1.Date < m2.Date
            }
        }
    }
    var isThereAMessageDeleted: Bool = false
    var timer: Timer?
    
    lazy var chatLogTableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(MessageTableViewCell.self, forCellReuseIdentifier: MessageTableViewCell.identifier)
        table.allowsMultipleSelectionDuringEditing = true
        table.separatorStyle = .none
        return table
    }()
    
    lazy var progressOfUploadVideoView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    var progressOfUploadVideoViewHeight: NSLayoutConstraint?
    
    var progressBar : UIProgressView = {
        let bar = UIProgressView(progressViewStyle: .bar)
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.progress = 0.0
        bar.trackTintColor = .gray
        bar.layer.cornerRadius = 2.5
        bar.clipsToBounds = true
        return bar
    }()
    
    let variableBlurView = VariableBlurView(
        gradientMask: UIImage(named: "Gradient")!,
        maxBlurRadius: 29,
        filterType: "variableBlur"
    )
    lazy var hostingController = UIHostingController(rootView: variableBlurView)
    
    let NameOfUploadVideoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.text = "Video"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    var chatLogTableViewContentInsetBotton: CGFloat = 0.0
    var chatLogTableViewScrollIndicatorInsetsBotton: CGFloat = 0.0
    
    let db = Firestore.firestore()
    let storage = Storage.storage()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatLogTableView.dataSource = self
        chatLogTableView.delegate   = self
        
        view.addSubview(chatLogTableView)
        NSLayoutConstraint.activate([
            chatLogTableView.topAnchor.constraint(equalTo: view.topAnchor),
            chatLogTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            chatLogTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatLogTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        chatLogTableView.contentInset = UIEdgeInsets(
            top: 8, left: 0,
            bottom: chatLogTableViewContentInsetBotton, right: 0
        )
        chatLogTableView.scrollIndicatorInsets = UIEdgeInsets(
            top: 1, left: 0,
            bottom: chatLogTableViewScrollIndicatorInsetsBotton, right: 0
        )
        
        chatLogTableView.keyboardDismissMode = .interactive
        handleSetupOfObservingKB()
    }
    
    override func viewWillLayoutSubviews() {
        handleZoomingViewWhanUpdateLayoutOfChatView()
    }
    override func viewDidLayoutSubviews() {
        if let navBar = navigationController?.navigationBar{
            view.addSubview(progressOfUploadVideoView)
            progressOfUploadVideoView.topAnchor.constraint(equalTo: navBar.bottomAnchor).isActive = true
            progressOfUploadVideoView.leadingAnchor.constraint(equalTo: navBar.leadingAnchor).isActive = true
            progressOfUploadVideoView.trailingAnchor.constraint(equalTo: navBar.trailingAnchor).isActive = true
            progressOfUploadVideoViewHeight =  progressOfUploadVideoView.heightAnchor.constraint(equalTo: navBar.heightAnchor, multiplier: 0.9)
            progressOfUploadVideoViewHeight?.constant = 0
            progressOfUploadVideoViewHeight?.isActive = true
            progressOfUploadVideoView.backgroundColor = .clear
            
            hostingController.view.backgroundColor = .clear
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            progressOfUploadVideoView.addSubview(hostingController.view)
            hostingController.view
                .topAnchor.constraint(equalTo: progressOfUploadVideoView.topAnchor)
                .isActive = true
            hostingController.view
                .bottomAnchor.constraint(equalTo: progressOfUploadVideoView.bottomAnchor)
                .isActive = true
            hostingController.view
                .leadingAnchor.constraint(equalTo: progressOfUploadVideoView.leadingAnchor)
                .isActive = true
            hostingController.view
                .trailingAnchor.constraint(equalTo: progressOfUploadVideoView.trailingAnchor)
                .isActive = true
            
            progressOfUploadVideoView.addSubview(progressBar)
            NSLayoutConstraint.activate([
                progressBar.centerXAnchor.constraint(equalTo: progressOfUploadVideoView.centerXAnchor),
                progressBar.bottomAnchor.constraint(equalTo: progressOfUploadVideoView.bottomAnchor, constant: -12),
                progressBar.widthAnchor.constraint(equalTo: progressOfUploadVideoView.widthAnchor, multiplier: 0.88),
                progressBar.heightAnchor.constraint(equalTo: progressOfUploadVideoView.heightAnchor, multiplier: 0.10)
            ])
            progressOfUploadVideoView.addSubview(NameOfUploadVideoLabel)
            NSLayoutConstraint.activate([
                NameOfUploadVideoLabel.leadingAnchor.constraint(equalTo: progressOfUploadVideoView.leadingAnchor, constant: 4),
                NameOfUploadVideoLabel.topAnchor.constraint(equalTo: progressOfUploadVideoView.topAnchor, constant: 4)
            ])
            progressOfUploadVideoView.isHidden = true
            
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    override var inputAccessoryView: UIView?{
        get{
            return inputContainerView
        }
    }
    lazy var inputContainerView: InputMessageContainerView = {
        let height = UIScreen.main.bounds.height
        let inputMessageContianer = InputMessageContainerView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: view.frame.width,
                height: CGFloat(height * (7.5/100.0))
            )
        )
        inputMessageContianer.chatViewControllerDelegate = self
        chatLogTableViewContentInsetBotton = inputMessageContianer.frame.height - 12.0
        chatLogTableViewScrollIndicatorInsetsBotton = inputMessageContianer.frame.height + 8.5
        return inputMessageContianer
    }()
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    func handleSetupOfObservingKB(){
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(showKeyboard),
                         name: UIResponder.keyboardWillShowNotification,
                         object: nil
            )
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(hideKeyboard),
                         name: UIResponder.keyboardWillHideNotification,
                         object: nil
            )
    }
    @objc func showKeyboard(notification: Notification){
        let kbFrameSize = notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect
        if let heightOfKB = kbFrameSize?.height{
            if device.isOneOf(groupOfAllowedDevices){
                chatLogTableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: heightOfKB, right: 0)
                chatLogTableView.scrollIndicatorInsets = UIEdgeInsets(top: 1, left: 0, bottom: heightOfKB + 6 , right: 0)
            }else{
                chatLogTableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: heightOfKB - 20, right: 0)
                chatLogTableView.scrollIndicatorInsets = UIEdgeInsets(top: 1, left: 0, bottom: heightOfKB - 16 , right: 0)
            }
            if let lastVisibleCell = chatLogTableView.visibleCells.last as? MessageTableViewCell {
                if lastVisibleCell.messageTextContent.text == messages[self.messages.count - 1].text{
                    chatLogTableView.scrollToRow(
                        at: IndexPath(row: self.messages.count - 1 , section: 0),
                        at: .bottom,
                        animated: true
                    )
                }
            }
        }
    }
    @objc func hideKeyboard(notification: Notification){
        if device.isOneOf(groupOfAllowedDevices){
            chatLogTableView.contentInset = UIEdgeInsets(
                top: 8,
                left: 0,
                bottom: chatLogTableViewContentInsetBotton + 12,
                right: 0
            )
            chatLogTableView.scrollIndicatorInsets = UIEdgeInsets(
                top: 1,
                left: 0,
                bottom: chatLogTableViewScrollIndicatorInsetsBotton + 14,
                right: 0
            )
        }else{
            chatLogTableView.contentInset = UIEdgeInsets(
                top: 8,
                left: 0,
                bottom: chatLogTableViewContentInsetBotton,
                right: 0
            )
            chatLogTableView.scrollIndicatorInsets = UIEdgeInsets(
                top: 1,
                left: 0,
                bottom: chatLogTableViewScrollIndicatorInsetsBotton,
                right: 0
            )
        }
    }

    func fetchUserMessages(){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        self.db.collection("user-messages").document(uid)
            .collection("chats").document(user!.id)
            .collection("chatContent").document("messagesID")
            .addSnapshotListener { docSnapshots, error in
                if error != nil{
                    print(error!.localizedDescription)
                    return
                }else{
                    self.messages = []
                    self.messagesIDDictionary = [:]
                    self.messagesID = []
                    if let snapshots = docSnapshots?.data()/*?.sorted(by: {$0.value as! Double > $1.value as! Double})*/{
                        self.messagesIDDictionary = snapshots as! [String:Double]
                        snapshots.forEach { key,_ in
                            FirestoreManager.manager.fetchMessageWith(id: key) { message in
                                if let message = message {
                                    if message.chatPartnerID() == self.user?.id{
                                        self.messages.append(message)
                                        self.timer?.invalidate()
                                        self.timer = Timer.scheduledTimer(
                                            timeInterval: 0.59,
                                            target: self,
                                            selector: #selector(self.handleReloadTable),
                                            userInfo: nil,
                                            repeats: false
                                        )
                                    }
                                }
                            }
                        }
                    }else {
                        print("emtpy")
                    }
                }
            }
    }
    @objc func handleReloadTable(){
        DispatchQueue.main.async {
            self.messagesCache
                .setObject(
                    NSArray(array: self.messages),
                    forKey: NSString(string: self.user!.id)
                )
            self.chatLogTableView.reloadData()
            if self.isThereAMessageDeleted == false{
                self.chatLogTableView.scrollToRow(
                    at: IndexPath(row: self.messages.count - 1 , section: 0),
                    at: .bottom,
                    animated: true
                )
            }
            self.isThereAMessageDeleted = false
        }
        
        self.messagesIDDictionary.sorted(by: {$1.value > $0.value }).forEach { key,_ in
            self.messagesID.append(key)
        }
    }
    
    @objc func handleSendingMessage(){
        
        if let text = inputContainerView.writeMessageTextView.text{
            if text != "" && text != "Enter Message ...." {
                sendMessage(
                    withProperties: [
                        "text" : text
                    ],
                    typeOfMessage: .text
                )
                DispatchQueue.main.async {
                    self.inputContainerView.writeMessageTextView.text = ""
                }
            }
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendingMessage()
        return true
    }
    
    private func sendMessage(
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
    
    func deleteMessage(messageID: String) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }
        let currentUserMessagesID = self.db
            .collection("user-messages").document(currentUserUID)
            .collection("chats").document(self.user!.id)
            .collection("chatContent").document("messagesID")

        let chatPartnerMessagesID = self.db
            .collection("user-messages").document(self.user!.id)
            .collection("chats").document(currentUserUID)
            .collection("chatContent").document("messagesID")
        let deletedMessage = self.messages[messagesID.firstIndex(of: messageID)!]

        switch deletedMessage.messageType {
        case .text:
            messages.remove(at: messagesID.firstIndex(of: messageID)!)
            messagesID.remove(at: messagesID.firstIndex(of: messageID)!)
            if let lastMessageID = messagesID.last {
                self.db
                    .collection("user-messages").document(deletedMessage.chatPartnerID())
                    .collection("chats").document(currentUserUID)
                    .setData(["lastMessage":lastMessageID])
                self.db
                    .collection("user-messages").document(currentUserUID)
                    .collection("chats").document(deletedMessage.chatPartnerID())
                    .setData(["lastMessage":lastMessageID])
            }
            FirestoreManager.manager.chat.deleteText(messageID: messageID) {
                currentUserMessagesID.updateData([messageID: FieldValue.delete()]) { error in
                    guard error == nil else {
                        print(error as Any)
                        return
                    }
                    DispatchQueue.main.async {
                        self.isThereAMessageDeleted = true
                    }
                }
                chatPartnerMessagesID.updateData([messageID: FieldValue.delete()]) { error in
                    guard error == nil else {
                        print(error as Any)
                        return
                    }
                }
                
                DispatchQueue.main.async {
                    self.chatLogTableView.reloadData()
                }
            }

        case .image:
            FirestoreManager.manager.chat.deleteImage(
                messages: self.messages,
                messageID: messageID,
                index: messagesID.firstIndex(of: messageID)!
            ) {
                currentUserMessagesID.updateData([messageID: FieldValue.delete()]) { error in
                    guard error == nil else {
                        print(error as Any)
                        return
                    }
                    DispatchQueue.main.async {
                        self.isThereAMessageDeleted = true
                    }
                }
                chatPartnerMessagesID.updateData([messageID: FieldValue.delete()]) { error in
                    guard error == nil else {
                        print(error as Any)
                        return
                    }
                    DispatchQueue.main.async {
                        self.chatLogTableView.reloadData()
                    }
                }
            }
        case .video:
            FirestoreManager.manager.chat.deleteVideo(
                messages: self.messages,
                messageID: messageID,
                index: messagesID.firstIndex(of: messageID)!
            ) {
                currentUserMessagesID.updateData([messageID: FieldValue.delete()]) { error in
                    guard error == nil else {
                        print(error as Any)
                        return
                    }
                    DispatchQueue.main.async {
                        self.isThereAMessageDeleted = true
                    }
                }
                chatPartnerMessagesID.updateData([messageID: FieldValue.delete()]) { error in
                    guard error == nil else {
                        print(error as Any)
                        return
                    }
                    DispatchQueue.main.async {
                        self.chatLogTableView.reloadData()
                    }
                }
            }
        }
    }
    
    //MARK: - Sending Video & Image
    
    @objc func handleSendingMediaMessage(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = [UTType.image.identifier,UTType.video.identifier,UTType.movie.identifier,UTType.mpeg.identifier]
        present(imagePicker, animated: true)
    }
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL{
            uploadVideoToFirebaseStorage(videoURL: videoURL)
            dismiss(animated: true) {
                self.progressOfUploadVideoView.isHidden = false
                UIView.animate(
                    withDuration: 2.8,
                    delay: 0,
                    usingSpringWithDamping: 1.2,
                    initialSpringVelocity: 1.2,
                    options: .transitionCurlDown) {
                        
                        self.progressOfUploadVideoViewHeight!.constant = self.navigationController!.navigationBar.frame.height
                    }
            }
        }else {
            handleSelectedImageInfo(info)
            dismiss(animated: true)
        }
        
    }
    
    private func thumbnailVideoImageForVideo(url imageURL: URL)-> UIImage?{
        let asset = AVAsset(url: imageURL)
        let thumbnailImageGenerator = AVAssetImageGenerator(asset: asset)
        do{
            let thumbnailImage = try thumbnailImageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        }catch {
            print(error)
        }
        return nil
    }
    
    private func uploadVideoToFirebaseStorage(videoURL: URL){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let titleVideo = UUID().uuidString
        let storageRecVideo = storage.reference()
            .child("chat_videos")
            .child(uid)
            .child(titleVideo)
            .child("\(titleVideo).mov")
        let storageRecVideoThumbnail = storage.reference()
            .child("chat_videos")
            .child(uid)
            .child(titleVideo)
            .child("\(titleVideo).jpeg")
            
        
        var video: Data?
        do {
            video = try NSData(contentsOf: videoURL) as Data
        } catch {
            print(error)
            return
        }
        let uploadTask = storageRecVideo.putData(video!) { storageMetaData, error in
            if error != nil {
                print("error with uploading image:\n\(error!.localizedDescription)")
                return
            }
            storageRecVideo.downloadURL { url, error in
                if let safeURLVideo = url {
                    print(safeURLVideo)
                    
                    if let thumbnail = self.thumbnailVideoImageForVideo(url: videoURL) {
                        
                        if let thumbnailImage = thumbnail.jpegData(compressionQuality: 0.02){
                            
                            let uploadThumbnail = storageRecVideoThumbnail.putData(thumbnailImage) { storageMetaData, error in
                                
                                storageRecVideoThumbnail.downloadURL { url, error in
                                    if let safeURLThumbnail = url{
                                        let properties: [String: Any] = [
                                            "videoInfo" : [
                                                "videoTitle"         : titleVideo,
                                                "videoURL"           : safeURLVideo.absoluteString,
                                                "thumbnailVideoInfo" : [
                                                    "thumbnailImageURL"    : safeURLThumbnail.absoluteString,
                                                    "thumbnailImageHeight" : thumbnail.size.height,
                                                    "thumbnailImageWidth"  : thumbnail.size.width
                                                ] as [String : Any]
                                            ] as [String : Any]
                                        ]
                                        self.sendMessage(withProperties: properties, typeOfMessage: .video)
                                    }
                                }
                            }
                            uploadThumbnail.resume()
                            uploadThumbnail.observe(.success) { _ in
                                DispatchQueue.main.async {
                                    UIView.animate(
                                        withDuration: 2.8,
                                        delay: 0,
                                        usingSpringWithDamping: 1.2,
                                        initialSpringVelocity: 1.2,
                                        options: .transitionCurlUp) {
                                            self.progressOfUploadVideoViewHeight!.constant = 0
                                        } completion: { complate in
                                            if complate {
                                                self.progressOfUploadVideoView.isHidden = true
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
            }
        }
        uploadTask.resume()
        
        uploadTask.observe(.progress) { storageSnapshot in
            let processPrentage = 100.0 * (Double(storageSnapshot.progress!.completedUnitCount)/Double(storageSnapshot.progress!.totalUnitCount))
            self.progressBar.progress = Float(
                (Double(storageSnapshot.progress!.completedUnitCount)/Double(storageSnapshot.progress!.totalUnitCount))
            )
            self.NameOfUploadVideoLabel.text = "Video Uploading: " + String(format: "%.2f", Float(processPrentage))
            print(processPrentage)
        }
        
        
    }
    private func handleSelectedImageInfo(_ info:[UIImagePickerController.InfoKey : Any]){
        var selectedImageFromPicker: UIImage?

        if let editedImage = info[
            UIImagePickerController
                .InfoKey(rawValue: "UIImagePickerControllerEditedImage")
        ] as? UIImage {
           selectedImageFromPicker = editedImage

        }
        else if let selectedOriginalImage = info[
            UIImagePickerController
                .InfoKey(rawValue: "UIImagePickerControllerOriginalImage")
        ] as? UIImage{
           selectedImageFromPicker = selectedOriginalImage
        }

        if let selectedImage = selectedImageFromPicker {
           uploadImageToFirebaseStorage(selectedImage)
        }
    }
    private func uploadImageToFirebaseStorage(_ image: UIImage ){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let uploadImage = image.jpegData(compressionQuality: 0.08)
        let imageTitle = UUID().uuidString
        let storageRec = storage.reference()
            .child("chat_images")
            .child(uid)
            .child("\(imageTitle).jpeg")
        if let safeImage = uploadImage {
            let uploadTask = storageRec.putData(safeImage, metadata: nil) { storageMetaData, error in
                if error != nil {
                    print("error with uploading image:\n\(error!.localizedDescription)")
                    return
                }
                storageRec.downloadURL { url, error in
                    if let safeURL = url {
                        self.sendMessageWithImageURL(safeURL,image,title: imageTitle)
                    }
                }
            }
            uploadTask.resume()
        }
    }
    
    private func sendMessageWithImageURL(_ imageURL:URL, _ image:UIImage, title: String){
        sendMessage(
            withProperties: [
                "imageInfo" : [
                    "imageTitle"  : title,
                    "imageURL"    : imageURL.absoluteString,
                    "imageHeight" : image.size.height,
                    "imageWidth"  : image.size.width
                ] as [String : Any]
            ],
            typeOfMessage: .image
        )
    }
    //MARK: - Editing Table View
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if !(messages.isEmpty) && messages[indexPath.row].sendFromID == Auth.auth().currentUser?.uid {
            return true
        }else {
            return false
        }
        
    }
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        print("delete")
//    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "Delete") { action, view, completionHandler in
            print("delete")
            print(indexPath.row)
            self.deleteMessage(messageID: self.messagesID[indexPath.row])
            completionHandler(true)
        }
        delete.backgroundColor = .systemRed
        delete.image = UIImage(systemName: "trash")
        
        let actions = UISwipeActionsConfiguration(actions: [delete])
        return actions
    }
    
    //MARK: - Viewing the data of chat tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.identifier, for: indexPath) as! MessageTableViewCell
        cell.chatVC = self
        cell.selectionStyle = .none
        let message = messages[indexPath.row]
        handleSetupOfThePositionOfMessageCell(cell: cell, message: message)
        switch message.messageType {
        case .image:
            handleSetupOfImageMessageCell(cell, withContentOf: message)
        case .video:
            handleSetupOfVideoMessageCell(cell, withContentOf: message)
        case .text:
            handleSetupOfTextMessageCell(cell, withContentOf: message)
        }
        let timeOfSend = Date(timeIntervalSince1970: message.Date)
        let dataFormatter = DateFormatter()
        dataFormatter.dateFormat = "hh:mm a"
        cell.timeOfSend.text = dataFormatter.string(from: timeOfSend)
        return cell
    }
    
    //MARK: - Depend on type of message type hpw the cell will be handled
    
    private func handleSetupOfThePositionOfMessageCell(cell: MessageTableViewCell, message: Message){

        if let profileImageURL = self.user?.profileImageURL{
            cell.imageProfileOfChatPartner.loadImagefromCacheWithURLstring(urlString: profileImageURL)
        }
        
        if message.sendFromID == Auth.auth().currentUser?.uid {
            //Blue
            cell.bubbleView.backgroundColor = MessageTableViewCell.blueColor
            cell.messageTextContent.textColor = .white
            cell.timeOfSend.textColor = .white
            cell.bubbleViewLeadingAnchor?.isActive = false
            cell.bubbleViewTrailingAnchor?.isActive = true
            cell.imageProfileOfChatPartner.isHidden = true
        }else{
            //Gray
            cell.bubbleView.backgroundColor = MessageTableViewCell.grayColor
            cell.messageTextContent.textColor = .black
            cell.timeOfSend.textColor = .black
            cell.bubbleViewLeadingAnchor?.isActive = true
            cell.bubbleViewTrailingAnchor?.isActive = false
            cell.imageProfileOfChatPartner.isHidden = false
        }
    }
    
    private func sizeOfText(_ text: String) -> CGRect {
        return NSString(string: text).boundingRect(
            with: CGSize(width: 200, height: 1000),
            options: NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin),
            attributes: [
                .font : UIFont.systemFont(ofSize: 16)
            ],
            context: nil
        )
    }
    private func handleSetupOfTextMessageCell(_ cell: MessageTableViewCell, withContentOf  message: Message){
        cell.messageTextContent.text = message.text
        cell.imageMessageView.isHidden = true
        cell.messageTextContent.isHidden = false
        cell.bubbleViewHeightAnchor?.isActive = false
        cell.bubbleViewHeightAnchor = cell.bubbleView.heightAnchor.constraint(equalToConstant: CGFloat((sizeOfText(message.text).height * 0.832) + 30.4))
        cell.bubbleViewHeightAnchor?.isActive = true
        
        cell.bubbleViewWidthAnchor?.isActive = false
        cell.bubbleViewWidthAnchor = cell.bubbleView.widthAnchor.constraint(equalToConstant: CGFloat(sizeOfText(message.text).width + 80.0))
        cell.bubbleViewWidthAnchor?.isActive = true
        cell.playButton.isHidden = true
    }
    
    private func handleSetupOfImageMessageCell(_ cell: MessageTableViewCell, withContentOf  message: Message){
        if let uploadImageURL = message.imageInfo["imageURL"] as? String{
            cell.imageMessageView.loadImagefromCacheWithURLstring(urlString: uploadImageURL)
        }
        cell.bubbleViewHeightAnchor?.isActive = false
        cell.bubbleViewWidthAnchor?.isActive = false
        if let height = message.imageInfo["imageHeight"] as? CGFloat,
           let width = message.imageInfo["imageWidth"] as? CGFloat{
            cell.bubbleViewHeightAnchor = cell.bubbleView.heightAnchor.constraint(equalToConstant: CGFloat(height * 0.36))
            cell.bubbleViewHeightAnchor?.isActive = true
            
            cell.bubbleViewWidthAnchor = cell.bubbleView.widthAnchor.constraint(equalToConstant: CGFloat(width * 0.36))
            cell.bubbleViewWidthAnchor?.isActive = true
        }
        cell.bubbleView.backgroundColor = .clear
        cell.imageMessageView.isHidden = false
        cell.messageTextContent.isHidden = true
        cell.playButton.isHidden = true
    }
    
    private func handleSetupOfVideoMessageCell(_ cell: MessageTableViewCell, withContentOf  message: Message){
        if let videoURL = message.videoInfo["videoURL"] as? String{
            cell.videoURL = URL(string: videoURL)
        }
        if let videoThumbnail = message.videoInfo["thumbnailVideoInfo"] as? [String: Any] {
            if let thumbnailURL = videoThumbnail["thumbnailImageURL"] as? String{
                cell.imageMessageView.loadImagefromCacheWithURLstring(urlString: thumbnailURL)
            }
        }
        cell.bubbleViewHeightAnchor?.isActive = false
        cell.bubbleViewWidthAnchor?.isActive = false
        if let thumbnailVideoInfo = message.videoInfo["thumbnailVideoInfo"] as? [String : Any] {
            if let height = thumbnailVideoInfo["thumbnailImageHeight"] as? CGFloat,
               let width = thumbnailVideoInfo["thumbnailImageWidth"] as? CGFloat{
                cell.bubbleViewHeightAnchor = cell.bubbleView.heightAnchor.constraint(equalToConstant: CGFloat(height * 0.48))
                cell.bubbleViewHeightAnchor?.isActive = true
                
                cell.bubbleViewWidthAnchor = cell.bubbleView.widthAnchor.constraint(equalToConstant: CGFloat(width * 0.48))
                cell.bubbleViewWidthAnchor?.isActive = true
            }
            cell.bubbleView.backgroundColor = .clear
            cell.imageMessageView.isHidden = false
            cell.messageTextContent.isHidden = true
            cell.playButton.isHidden = false
        }
    }
    
    //MARK: - ZoomingView of image message
    
    var startFrame        : CGRect?
    var backgroundView    : UIVisualEffectView?
    var startingImageView : UIImageView?
    var zoomingView       : UIImageView?
    
    func performZoomInTapGestureForUIImageViewOfImageMessage(_ imageView: UIImageView,currentCell cell:MessageTableViewCell){
        startingImageView = imageView
        self.startFrame = startingImageView!.convert(imageView.frame, to: nil)
        dump(startFrame)
        self.zoomingView = UIImageView(
            frame: startFrame!
        )
        zoomingView!.image = startingImageView!.image
        zoomingView!.isUserInteractionEnabled = true
        zoomingView!.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(performZoomOutTapGestureForUIImageViewOfImageMessage)
            )
        )
        if let keyWindow = self.view.window?.windowScene?.keyWindow{
            self.backgroundView = UIVisualEffectView(frame: keyWindow.frame)
            self.backgroundView!.translatesAutoresizingMaskIntoConstraints = false
            self.backgroundView!.effect = UIBlurEffect(style: .systemUltraThinMaterial)
            self.backgroundView!.alpha = 0
            keyWindow.addSubview(self.backgroundView!)
            NSLayoutConstraint.activate([
                self.backgroundView!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.backgroundView!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.backgroundView!.topAnchor.constraint(equalTo: self.view.topAnchor),
                self.backgroundView!.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
            keyWindow.addSubview(zoomingView!)
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 1,
                options: .curveEaseOut,
                animations: {
                    self.checkOrientationForSetupZoomingView(keyWindow: keyWindow)
                    self.startingImageView?.alpha = 0
                    self.backgroundView!.alpha = 1
                    self.inputAccessoryView?.alpha = 0
                    self.inputAccessoryView?.isHidden = true
                    self.zoomingView!.center = self.backgroundView!.center
                    
                },
                completion: nil
            )
        }
    }
    
    @objc func performZoomOutTapGestureForUIImageViewOfImageMessage(tapGesture: UITapGestureRecognizer){
        if let zoomingOutView = tapGesture.view as? UIImageView{
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 1,
                options: .curveEaseIn) {
                    zoomingOutView.frame = self.startFrame!
                    zoomingOutView.layer.cornerRadius = 16
                    zoomingOutView.layer.masksToBounds = true
                    self.backgroundView?.alpha = 0
                    self.inputAccessoryView?.alpha = 1
                    self.inputAccessoryView?.isHidden = false
//                    cell.bubbleView.alpha = 1
                } completion: { complete in
                    print(complete)
                    zoomingOutView.removeFromSuperview()
                    self.startingImageView?.alpha = 1
                    self.backgroundView?.removeFromSuperview()
                    self.backgroundView = nil
                }
        }
    }
    
    private func checkOrientationForSetupZoomingView(keyWindow: UIWindow){
        switch UIDevice.current.orientation {
        case .portrait :
            self.zoomingView!.frame = CGRect(
                x: 0, y: 0,
                width: self.view.frame.width,
                height: CGFloat(self.startFrame!.height/self.startFrame!.width * keyWindow.frame.width)
            )
            self.inputAccessoryView!.alpha = 0.0
            self.inputAccessoryView?.isHidden = true
        case .landscapeLeft, .landscapeRight :
            self.zoomingView!.frame = CGRect(
                x: 0, y: 0,
                width: self.view.frame.width * 0.50,
                height: CGFloat(self.startFrame!.height/self.startFrame!.width * (keyWindow.frame.width * 0.50))
            )
            self.inputAccessoryView!.alpha = 0.0
            self.inputAccessoryView?.isHidden = true
        default:
            self.zoomingView!.frame = CGRect(
                x: 0, y: 0,
                width: self.view.frame.width,
                height: CGFloat(self.startFrame!.height/self.startFrame!.width * keyWindow.frame.width)
            )
            self.inputAccessoryView?.alpha = 0.0
            self.inputAccessoryView?.isHidden = true
        }
    }
    
    func handleZoomingViewWhanUpdateLayoutOfChatView(){
        if let bgView = backgroundView {
            if let keyWindow = self.view.window?.windowScene?.keyWindow{
                checkOrientationForSetupZoomingView(keyWindow: keyWindow)
                self.zoomingView!.center = bgView.center
                self.inputAccessoryView?.alpha = 0.0
                self.inputAccessoryView?.isHidden = true
            }
        }
    }
}
