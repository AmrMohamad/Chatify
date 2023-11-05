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

class ChatViewController: UIViewController,
                          UITableViewDataSource,
                          UITableViewDelegate,
                          UITextFieldDelegate {

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
    let messagesCache = NSCache<NSString, NSArray>()
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
    
    lazy var writeMessageTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Enter Message ..."
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
    let settings = FirestoreSettings()

    
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
        containerTypingArea.addSubview(writeMessageTextField)
        containerTypingArea.addSubview(sendMessageButton)
        
        NSLayoutConstraint.activate([
            sendImageButton.leadingAnchor.constraint(equalTo: containerTypingArea.leadingAnchor, constant: 12),
            sendImageButton.centerYAnchor.constraint(equalTo: containerTypingArea.centerYAnchor),
            sendImageButton.heightAnchor.constraint(equalToConstant: 44),
            sendImageButton.widthAnchor.constraint(equalToConstant: 44)
        ])
        
        NSLayoutConstraint.activate([
            writeMessageTextField.topAnchor.constraint(equalTo: containerTypingArea.topAnchor, constant: 2),
            writeMessageTextField.leadingAnchor.constraint(equalTo: sendImageButton.trailingAnchor, constant: 10),
            writeMessageTextField.trailingAnchor.constraint(equalTo: sendMessageButton.leadingAnchor, constant: -10)
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

    func fetchMessageWith(
        id: String,
        completionHandler: @escaping (Message?) -> Void
    ) {
        let messagesRef = db.collection("messages")
        messagesRef.document(id).getDocument { docSnapshot, error in
            if let mssgData   = docSnapshot,
               let sendToID   = mssgData["sendToID"] as? String,
               let sendFromID = mssgData["sendFromID"] as? String,
               let date       = mssgData["Date"] as? Double,
               let text       = mssgData["text"] as? String {
                let message = Message(
                    sendToID   : sendToID,
                    sendFromID : sendFromID,
                    Date       : date,
                    text       : text
                )
                completionHandler(message)
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
                    self.messages = []
                    if error != nil{
                        print(error!.localizedDescription)
                        return
                    }else{
                        if let snapshots = docSnapshots?.data()/*?.sorted(by: {$0.value as! Double > $1.value as! Double})*/{
                            snapshots.forEach { key,_ in
                                self.fetchMessageWith(id: key) { message in
                                    if let message = message {
                                        if message.chatPartnerID() == self.user?.id{
                                            self.messages.append(message)
                                            self.timer?.invalidate()
                                            self.timer = Timer.scheduledTimer(
                                                timeInterval: 0.3,
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
                animated: false
            )
        }
    }
    
    @objc func handleSendingMessage(){
        if let sender = Auth.auth().currentUser?.uid,
           let text   = writeMessageTextField.text {
            if text != "" {
                var ref: DocumentReference? = nil
                let currentTime = Date().timeIntervalSince1970
                ref = db.collection("messages")
                    .addDocument(
                        data: [
                            "sendFromID"   : sender,
                            "sendToID"     : user!.id,
                            "text"         : text,
                            "Date"         : currentTime
                        ]
                    ) { error in
                        if error != nil {
                            print(error!.localizedDescription)
                        }else{
                            print("send data successfully")
                            if let messageRef = ref {
                                let messageID = messageRef.documentID
                                if let userID = self.user?.id{
                                    self.sendMessageToDB(messageID: messageID,
                                                         currentTime: currentTime,
                                                         sender: sender,
                                                         receiver: userID
                                    )
                                }
                            }
                            DispatchQueue.main.async {
                                self.writeMessageTextField.text = ""
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.identifier, for: indexPath) as! MessageTableViewCell
        cell.selectionStyle = .none
        let message = messages[indexPath.row]
        handleSetupOfMessageCell(cell: cell, message: message)
        cell.messageTextContent.text = message.text
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
