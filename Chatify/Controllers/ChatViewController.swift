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

    var user: User? {
        didSet{
            navigationItem.title = user!.name
            fetchUserMessages()
        }
    }
    var messages: [Message] = [Message]()
    
    lazy var containerTypingArea: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white.withAlphaComponent(0.79)
        return view
    }()
    let chatLogTableView: UITableView = {
        let table = UITableView()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(chatLogTableView)
        chatLogTableView.frame = view.frame
        chatLogTableView.dataSource = self
        chatLogTableView.delegate   = self
        setupMessagingContianerView()
        sendMessageButton.addTarget(self, action: #selector(handleSendingMessage), for: .touchUpInside)
    }
    
    func fetchUserMessages(){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        self.db.collection("user-messages").document(uid)
            .addSnapshotListener { docSnapshots, error in
                if error != nil{
                    print(error!.localizedDescription)
                    return
                }else{
                    self.messages = []
                    let messagesRef = self.db.collection("messages")
                    
                    if let snapshots = docSnapshots?.data()?.sorted(
                        by: { $0.value as! Double > $1.value as! Double}
                    ) {
                        for snap in snapshots {

                            messagesRef.document(snap.key).getDocument { docSnapshot, error in
                                if let safeData = docSnapshot?.data(),
                                   let sendToID = safeData["sendToID"] as? String,
                                   let sendFromID = safeData["sendFromID"] as? String,
                                   let date = safeData["Date"] as? Double,
                                   let text = safeData["text"] as? String {
                                    let message = Message(
                                        sendToID   : sendToID,
                                        sendFromID : sendFromID,
                                        Date       : date,
                                        text       : text
                                    )
                                    if message.chatPartnerID() == self.user?.id{
                                        self.messages.append(message)
                                        self.messages.sort { m1, m2 in
                                            return m1.Date < m2.Date
                                        }
                                        DispatchQueue.main.async {
                                            self.chatLogTableView.reloadData()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
    }
    
    func setupMessagingContianerView(){
        view.addSubview(containerTypingArea)
        NSLayoutConstraint.activate([
            containerTypingArea.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
            containerTypingArea.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            containerTypingArea.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            containerTypingArea.heightAnchor.constraint(equalToConstant: 85)
        ])
        
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let message = messages[indexPath.row]
        let time = Date(timeIntervalSince1970: message.Date)
        let dataFormatter = DateFormatter()
        dataFormatter.dateFormat = "hh:mm:ss a"
        cell.textLabel?.text = "\(message.text) \(dataFormatter.string(from: time)) From:\(message.sendFromID)"
        return cell
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendingMessage()
        return true
    }
}
