//
//  ChatViewController.swift
//  Chatify
//
//  Created by Amr Mohamad on 11/10/2023.
//

import UIKit
import DeviceKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import FirebaseStorage

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
    var messages: [Message] = [Message](){
        didSet{
            messages.sort { m1, m2 in
                return m1.Date < m2.Date
            }
        }
    }
    var timer: Timer?
    
    lazy var chatLogTableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(MessageTableViewCell.self, forCellReuseIdentifier: MessageTableViewCell.identifier)
        table.separatorStyle = .none
        return table
    }()
    
    lazy var writeMessageTextView: UITextView = {
        let tf = UITextView()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = .clear
        tf.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        tf.text = "Enter Message ...."
        tf.textColor = UIColor.lightGray
        tf.delegate = self
        return tf
    }()
    lazy var sendMessageButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Send", for: .normal)
        return button
    }()
    lazy var sendImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "photo.on.rectangle.angled"), for: .normal)
        return button
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
        
        sendMessageButton.addTarget(self, action: #selector(handleSendingMessage), for: .touchUpInside)
        sendImageButton.addTarget(self, action: #selector(handleSendingImageMessage), for: .touchUpInside)
        
        chatLogTableView.keyboardDismissMode = .interactive
        handleSetupOfObservingKB()
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    override var inputAccessoryView: UIView?{
        get{
            return inputContainerView
        }
    }
    lazy var inputContainerView: UIView = {
        let containerTypingArea = UIView()
        let height = UIScreen.main.bounds.height
        containerTypingArea.frame = CGRect(
            x: 0,
            y: 0,
            width: view.frame.width,
            height: CGFloat(height * (7.5/100.0))
        )
        chatLogTableViewContentInsetBotton = containerTypingArea.frame.height - 12.0
        chatLogTableViewScrollIndicatorInsetsBotton = containerTypingArea.frame.height + 8.5
        containerTypingArea.backgroundColor = .systemGroupedBackground.withAlphaComponent(0.95)
        
        containerTypingArea.addSubview(sendImageButton)
        containerTypingArea.addSubview(writeMessageTextView)
        containerTypingArea.addSubview(sendMessageButton)
        
        NSLayoutConstraint.activate([
            sendImageButton.leadingAnchor.constraint(equalTo: containerTypingArea.leadingAnchor, constant: 12),
            sendImageButton.centerYAnchor.constraint(equalTo: containerTypingArea.centerYAnchor),
            sendImageButton.heightAnchor.constraint(equalToConstant: 44),
            sendImageButton.widthAnchor.constraint(equalToConstant: 44)
        ])
        
        NSLayoutConstraint.activate([
            writeMessageTextView.topAnchor.constraint(equalTo: containerTypingArea.topAnchor, constant: 2),
            writeMessageTextView.bottomAnchor.constraint(equalTo: containerTypingArea.bottomAnchor, constant: -2),
            writeMessageTextView.leadingAnchor.constraint(equalTo: sendImageButton.trailingAnchor, constant: 10),
            writeMessageTextView.trailingAnchor.constraint(equalTo: sendMessageButton.leadingAnchor, constant: -10)
            ]
        )
        
        NSLayoutConstraint.activate([
            sendMessageButton.centerYAnchor.constraint(equalTo: containerTypingArea.centerYAnchor),
            sendMessageButton.topAnchor.constraint(equalTo: sendImageButton.topAnchor),
            sendMessageButton.bottomAnchor.constraint(equalTo: sendImageButton.bottomAnchor),
            sendMessageButton.trailingAnchor.constraint(equalTo: containerTypingArea.trailingAnchor, constant: -10),
            sendMessageButton.widthAnchor.constraint(equalToConstant: 44)
            ]
        )
        return containerTypingArea
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
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter Message ...."
            textView.textColor = UIColor.lightGray
        }
    }

    func fetchMessageWith(
        id: String,
        completionHandler: @escaping (Message?) -> Void
    ) {
        let messagesRef = db.collection("messages")
        messagesRef.document(id).getDocument { docSnapshot, error in
            if let massgeData = docSnapshot{
                
                if let sendToID   = massgeData["sendToID"] as? String,
                   let sendFromID = massgeData["sendFromID"] as? String,
                   let date       = massgeData["Date"] as? Double,
                   let text       = massgeData["text"] as? String {
                    let message = Message(
                        sendToID   : sendToID,
                        sendFromID : sendFromID,
                        Date       : date,
                        text       : text,
                        imageInfo  : [:]
                    )
                    completionHandler(message)
                }
                
                if let sendToID   = massgeData["sendToID"] as? String,
                   let sendFromID = massgeData["sendFromID"] as? String,
                   let date       = massgeData["Date"] as? Double,
                   let imageInfo   = massgeData["imageInfo"] as? [String:Any] {
                    let message = Message(
                        sendToID   : sendToID,
                        sendFromID : sendFromID,
                        Date       : date,
                        text       : "",
                        imageInfo  : imageInfo
                    )
                    completionHandler(message)
                }
            }else{
                completionHandler(nil)
            }
        }
    }
    func fetchUserMessages(){
        if let userID = user?.id{
            dump(messagesCache.object(forKey: NSString(string: userID)) as? [Message])
        }
        if let userID = user?.id,
           let messages = messagesCache.object(forKey: NSString(string: userID)) as? [Message]{
            print("STORED")
            self.messages = messages
        }else {
            print("Not STORED")
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
                        if let snapshots = docSnapshots?.data()/*?.sorted(by: {$0.value as! Double > $1.value as! Double})*/{
                            snapshots.forEach { key,_ in
                                self.fetchMessageWith(id: key) { message in
                                    if let message = message {
                                        if message.chatPartnerID() == self.user?.id{
                                            self.messages.append(message)
                                            self.timer?.invalidate()
                                            self.timer = Timer.scheduledTimer(
                                                timeInterval: 0.49,
                                                target: self,
                                                selector: #selector(self.handleReloadTable),
                                                userInfo: nil,
                                                repeats: false
                                            )
                                        }
                                    }
                                }
                            }
                        }
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
            self.chatLogTableView.scrollToRow(
                at: IndexPath(row: self.messages.count - 1 , section: 0),
                at: .bottom,
                animated: true
            )
        }
    }
    
    @objc func handleSendingImageMessage(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
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
        dismiss(animated: true)
    }
    
    private func uploadImageToFirebaseStorage(_ image: UIImage ){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let uploadImage = image.jpegData(compressionQuality: 0.08)
        let storageRec = storage.reference()
            .child("chat_images")
            .child(uid)
            .child("\(UUID().uuidString).jpeg")
        if let safeImage = uploadImage {
            let uploadTask = storageRec.putData(safeImage, metadata: nil) { storageMetaData, error in
                if error != nil {
                    print("error with uploading image:\n\(error!.localizedDescription)")
                    return
                }
                storageRec.downloadURL { url, error in
                    if let safeURL = url {
                        self.sendMessageWithImageURL(safeURL,image)
                    }
                }
            }
            uploadTask.resume()
        }
    }
    
    private func sendMessageWithImageURL(_ imageURL:URL, _ image:UIImage){
        sendMessage(
            withProperties: [
                "imageInfo" : [
                    "imageURL"    : imageURL.absoluteString,
                    "imageHeight" : image.size.height,
                    "imageWidth"  : image.size.width
                ] as [String : Any]
            ]
        )
    }
    
    @objc func handleSendingMessage(){
        
        if let text = writeMessageTextView.text{
            if text != "" && text != "Enter Message ...." {
                sendMessage(
                    withProperties: [
                        "text" : text
                    ]
                )
                DispatchQueue.main.async {
                    self.writeMessageTextView.text = ""
                }
            }
        }
    }
    private func sendMessage(
        withProperties properties: [String: Any]
    ){
        if properties.isEmpty{
            return
        }else {
            if let sender = Auth.auth().currentUser?.uid{
                let currentTime = Date().timeIntervalSince1970
                var values: [String: Any] = [
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
    private func sendMessageToDB(messageID: String, currentTime: TimeInterval,sender sendFromID: String,receiver sendToID: String){
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    private func handleSetupOfMessageCell(cell: MessageTableViewCell, message: Message){

        if let profileImageURL = self.user?.profileImageURL{
            cell.imageProfileOfChatPartner.loadImagefromCacheWithURLstring(urlString: profileImageURL)
        }
        
        if let uploadImageURL = message.imageInfo["imageURL"] as? String{
            cell.imageMessageView.loadImagefromCacheWithURLstring(urlString: uploadImageURL)
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
    
    private func handleMessageContainImage(cell: MessageTableViewCell, message: Message){
        
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.identifier, for: indexPath) as! MessageTableViewCell
        cell.selectionStyle = .none
        let message = messages[indexPath.row]
        handleSetupOfMessageCell(cell: cell, message: message)
        if message.imageInfo.isEmpty {
            cell.messageTextContent.text = message.text
            cell.imageMessageView.isHidden = true
            cell.messageTextContent.isHidden = false
            cell.bubbleViewHeightAnchor?.isActive = false
            cell.bubbleViewHeightAnchor = cell.bubbleView.heightAnchor.constraint(equalToConstant: CGFloat((sizeOfText(message.text).height * 0.832) + 30.4))
            cell.bubbleViewHeightAnchor?.isActive = true
            
            cell.bubbleViewWidthAnchor?.isActive = false
            cell.bubbleViewWidthAnchor = cell.bubbleView.widthAnchor.constraint(equalToConstant: CGFloat(sizeOfText(message.text).width + 80.0))
            cell.bubbleViewWidthAnchor?.isActive = true
        }else{
            cell.bubbleViewHeightAnchor?.isActive = false
            cell.bubbleViewWidthAnchor?.isActive = false
            if let height = message.imageInfo["imageHeight"] as? CGFloat,
               let width = message.imageInfo["imageWidth"] as? CGFloat{
                cell.bubbleViewHeightAnchor = cell.bubbleView.heightAnchor.constraint(equalToConstant: CGFloat(height * 0.34))
                cell.bubbleViewHeightAnchor?.isActive = true
                
                cell.bubbleViewWidthAnchor = cell.bubbleView.widthAnchor.constraint(equalToConstant: CGFloat(width * 0.34))
                cell.bubbleViewWidthAnchor?.isActive = true
            }
            cell.bubbleView.backgroundColor = .clear
            cell.imageMessageView.isHidden = false
            cell.messageTextContent.isHidden = true
        }
        let timeOfSend = Date(timeIntervalSince1970: message.Date)
        let dataFormatter = DateFormatter()
        dataFormatter.dateFormat = "hh:mm a"
        cell.timeOfSend.text = dataFormatter.string(from: timeOfSend)
        return cell
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendingMessage()
        return true
    }
}
