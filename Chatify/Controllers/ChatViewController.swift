//
//  ChatViewController.swift
//  Chatify
//
//  Created by Amr Mohamad on 11/10/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore

class ChatViewController: UIViewController,
                          UITableViewDataSource,
                          UITableViewDelegate,
                          UITextFieldDelegate {

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
//            if let id = user?.id{
//                print("didSet")
//                messagesCache.setObject(NSArray(array: messages), forKey: NSString(string: id))
//                dump(messagesCache.object(forKey: NSString(string: id)))
//            }
        }
    }
    var timer: Timer?
    
//    lazy var containerTypingArea: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = .white.withAlphaComponent(0.90)
//        return view
//    }()
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
        chatLogTableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 60, right: 0)
        chatLogTableView.scrollIndicatorInsets = UIEdgeInsets(top: 1, left: 0, bottom: 50, right: 0)
        
//        setupMessagingContianerView()
        sendMessageButton.addTarget(self, action: #selector(handleSendingMessage), for: .touchUpInside)
        //There are two ways to handle the keyboard
        //First one:
//        handleSetupOfObservingKB()
        //Second:
        chatLogTableView.keyboardDismissMode = .interactive
        
    }
    
    
    //There are two ways to handle the keyboard
    //Second way:
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
        containerTypingArea.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 65)
        containerTypingArea.backgroundColor = .white.withAlphaComponent(0.95)
//        containerTypingArea.translatesAutoresizingMaskIntoConstraints = false
//        containerTypingArea.bottomAnchor.constraint(equalTo: self.view.bottomAnchor,constant: 0).isActive = true
//        containerTypingArea.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
//        containerTypingArea.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
//        containerTypingArea.heightAnchor.constraint(equalToConstant: 85).isActive = true
        
        containerTypingArea.addSubview(writeMessageTextField)
        containerTypingArea.addSubview(sendMessageButton)
        
        NSLayoutConstraint.activate([
            writeMessageTextField.topAnchor.constraint(equalTo: containerTypingArea.topAnchor, constant: 8),
            writeMessageTextField.leadingAnchor.constraint(equalTo: containerTypingArea.leadingAnchor, constant: 12),
            writeMessageTextField.widthAnchor.constraint(equalTo: containerTypingArea.widthAnchor, multiplier: 0.80),
            writeMessageTextField.heightAnchor.constraint(equalTo: containerTypingArea.heightAnchor, multiplier: 0.70)
            ]
        )
        
        NSLayoutConstraint.activate([
            sendMessageButton.centerYAnchor.constraint(equalTo: writeMessageTextField.centerYAnchor),
            sendMessageButton.leadingAnchor.constraint(equalTo: writeMessageTextField.trailingAnchor, constant: 10),
            sendMessageButton.topAnchor.constraint(equalTo: writeMessageTextField.topAnchor),
            sendMessageButton.bottomAnchor.constraint(equalTo: writeMessageTextField.bottomAnchor),
            sendMessageButton.trailingAnchor.constraint(equalTo: containerTypingArea.trailingAnchor, constant: -10)
            ]
        )
        return containerTypingArea
    }()
    //First one:
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        NotificationCenter.default.removeObserver(self)
//    }
//    var containerTypingAreabottomAnchor : NSLayoutConstraint?
//    func handleSetupOfObservingKB(){
//        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
//    }
//    @objc func showKeyboard(notification: Notification){
//        let kbFrameSize = notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect
//        let kbDuration =  notification.userInfo?["UIKeyboardAnimationDurationUserInfoKey"] as? Double
//
//        if let heightOfKB = kbFrameSize?.height,
//           let durationOfKB = kbDuration{
//            containerTypingAreabottomAnchor?.constant = -heightOfKB
//            UIView.animate(withDuration: durationOfKB) {
//                self.view.layoutIfNeeded()
//            }
//            chatLogTableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 60 + heightOfKB, right: 0)
//            let lastVisibleCell = chatLogTableView.visibleCells.last as? MessageTableViewCell
//            if lastVisibleCell?.messageTextContent.text == messages[self.messages.count - 1].text{
//                chatLogTableView.scrollToRow(
//                    at: IndexPath(row: self.messages.count - 1 , section: 0),
//                    at: .bottom,
//                    animated: true
//                )
//            }
//        }
//    }
//    @objc func hideKeyboard(notification: Notification){
//        let kbDuration =  notification.userInfo?["UIKeyboardAnimationDurationUserInfoKey"] as? Double
//        if let durationOfKB = kbDuration{
//            containerTypingAreabottomAnchor?.constant = 0
//            UIView.animate(withDuration: durationOfKB) {
//                self.view.layoutIfNeeded()
//            }
//            chatLogTableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 60, right: 0)
//        }
//    }
//
    
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
                .addSnapshotListener { docSnapshots, error in
                    self.messages = []
                    if error != nil{
                        print(error!.localizedDescription)
                        return
                    }else{
                        if let snapshots = docSnapshots?.data()?.sorted(by: {$0.value as! Double > $1.value as! Double}){
                            snapshots.forEach { key,_ in
                                self.fetchMessageWith(id: key) { message in
                                    if let message = message {
                                        if message.chatPartnerID() == self.user?.id{
                                            self.messages.append(message)
                                            self.timer?.invalidate()
                                            self.timer = Timer.scheduledTimer(
                                                timeInterval: 0.8,
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
    
//    func setupMessagingContianerView(){
//        view.addSubview(containerTypingArea)
//        //handle the keyboard, First way:
//        /*
//        containerTypingAreabottomAnchor = containerTypingArea.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
//        containerTypingAreabottomAnchor?.isActive = true
//        */
//        containerTypingArea.bottomAnchor.constraint(equalTo: self.view.bottomAnchor,constant: 0).isActive = true
//        containerTypingArea.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
//        containerTypingArea.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
//        containerTypingArea.heightAnchor.constraint(equalToConstant: 85).isActive = true
//
//        containerTypingArea.addSubview(writeMessageTextField)
//        containerTypingArea.addSubview(sendMessageButton)
//
//        NSLayoutConstraint.activate([
//            writeMessageTextField.topAnchor.constraint(equalTo: containerTypingArea.topAnchor, constant: 8),
//            writeMessageTextField.leadingAnchor.constraint(equalTo: containerTypingArea.leadingAnchor, constant: 12),
//            writeMessageTextField.widthAnchor.constraint(equalTo: containerTypingArea.widthAnchor, multiplier: 0.80),
//            writeMessageTextField.heightAnchor.constraint(equalTo: containerTypingArea.heightAnchor, multiplier: 0.70)
//            ]
//        )
//
//        NSLayoutConstraint.activate([
//            sendMessageButton.centerYAnchor.constraint(equalTo: writeMessageTextField.centerYAnchor),
//            sendMessageButton.leadingAnchor.constraint(equalTo: writeMessageTextField.trailingAnchor, constant: 10),
//            sendMessageButton.topAnchor.constraint(equalTo: writeMessageTextField.topAnchor),
//            sendMessageButton.bottomAnchor.constraint(equalTo: writeMessageTextField.bottomAnchor),
//            sendMessageButton.trailingAnchor.constraint(equalTo: containerTypingArea.trailingAnchor, constant: -10)
//            ]
//        )
//    }
    
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
                                
                                let se = self.db.collection("user-messages").document(sender)
                                se.updateData([messageID:currentTime]) { error in
                                    if error != nil {
                                        se.setData([messageID:currentTime])
                                    }
                                }
                                
                                let re = self.db.collection("user-messages").document(self.user!.id)
                                re.updateData([messageID:currentTime]) { error in
                                    if error != nil {
                                        re.setData([messageID:currentTime])
                                    }
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
