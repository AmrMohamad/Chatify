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
        }
    }
    
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
                db.collection("messages")
                    .addDocument(
                        data: [
                            "sendFromID"   : sender,
                            "sendToID"     : user!.id,
                            "text"         : text,
                            "Date"         : Date().timeIntervalSince1970
                        ]
                    ) { error in
                        if error != nil {
                            print(error!.localizedDescription)
                        }else{
                            print("send data successfully")
                            DispatchQueue.main.async {
                                self.writeMessageTextField.text = ""
                            }
                        }
                    }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 25
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        return cell
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendingMessage()
        return true
    }
}
