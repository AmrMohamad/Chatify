//
//  MainViewController.swift
//  Chatify
//
//  Created by Amr Mohamad on 04/09/2023.
//

import UIKit
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore

class MainViewController: UITableViewController {

    ///The reference of the DataBase FirebaseFirestore
    let db = Firestore.firestore()
    ///messages is a array of Message datatype
    var messages: [Message] = [Message]()
    /// messageDictionary is used to avoid messages/chats duplication
    var messageDictionary: [String : Message] = [String : Message]()
    var users: [User] = [User]()
    let imgsCache = NSCache<AnyObject, AnyObject>()
    var timer: Timer?
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.shadowRadius = 2.2
        label.layer.shadowOpacity = 0.28
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 0)
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .center
        return label
    }()
    
    lazy var leftBarButtonLogOut: UIBarButtonItem = {
        let cButton = UIButton(type: .system)
        cButton.setTitle("Log Out", for: .normal)
        cButton.layer.shadowRadius = 2.2
        cButton.layer.shadowOpacity = 0.28
        cButton.layer.shadowColor = UIColor.black.cgColor
        cButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        cButton.addTarget(self, action: #selector(handeleLogOut), for: .touchUpInside)
        let button = UIBarButtonItem(customView: cButton)
        return button
    }()
    
    lazy var rightBarButtonNewChat: UIBarButtonItem = {
        let cButton = UIButton(type: .system)
        cButton.setImage(UIImage(systemName: "plus.message"), for: .normal)
        cButton.layer.shadowRadius = 2.2
        cButton.layer.shadowOpacity = 0.28
        cButton.layer.shadowColor = UIColor.black.cgColor
        cButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        cButton.addTarget(self, action: #selector(addNewMessage), for: .touchUpInside)
        let button = UIBarButtonItem(customView: cButton)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.register(ChatTableViewCell.self, forCellReuseIdentifier: ChatTableViewCell.identifier)
        tableView.separatorStyle = .none
        navigationItem.leftBarButtonItem = leftBarButtonLogOut
        navigationItem.rightBarButtonItem = rightBarButtonNewChat
        navigationController?.navigationBar.prefersLargeTitles = true
//        fetchAndProcessMessages()
        fetchUsers()
        fetchMessages()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
        guard let navBar = navigationController?
            .navigationBar else {
            fatalError("Navigation Bar not exist YET")
        }
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        let variableBlurView = VariableBlurView(
            gradientMask: UIImage(named: "Gradient")!,
            maxBlurRadius: 28,
            filterType: "variableBlur"
        )
        let hostingController = UIHostingController(rootView: variableBlurView)

        hostingController.view.backgroundColor = .clear
        hostingController.view.tag = 1
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        hostingController.didMove(toParent: self.navigationController!)
        navBar.subviews.first?.insertSubview(hostingController.view, at: 0)
        if let backView = navBar.subviews.first {
            if let shadowImage = backView.subviews.last {
                shadowImage.alpha = 0
            }
            hostingController.view
                .topAnchor.constraint(equalTo: backView.topAnchor, constant: 0).isActive = true
            hostingController.view
                .bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: 2).isActive = true
            hostingController.view
                .leadingAnchor.constraint(equalTo: navBar.leadingAnchor).isActive = true
            hostingController.view
                .trailingAnchor.constraint(equalTo: navBar.trailingAnchor).isActive = true
        }
        
        let cnav = UINavigationBarAppearance()
        cnav.configureWithOpaqueBackground()
        cnav.backgroundColor = .clear
        navBar.standardAppearance = cnav
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let navBar = navigationController?
            .navigationBar else {
            fatalError("Navigation controller not exist yet")
        }
        navBar.setBackgroundImage(nil, for: .default)
        navBar.shadowImage = nil
        if let backView = navBar.subviews.first {
            if let shadowImage = backView.subviews.first {
                shadowImage.alpha = 1
            }
        }
        navBar.subviews.first?.subviews.last?.removeFromSuperview()
        navigationController?.navigationBar.prefersLargeTitles = false
        let cnav = UINavigationBarAppearance()
        cnav.configureWithDefaultBackground()
        navBar.standardAppearance = cnav
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let largeBarView = navigationController?.navigationBar.subviews[1]{
            userNameLabel.alpha = largeBarView.alpha == 1.0 ? 0.0 : 1.0
        }
    }
    
    func setupNavTitleWith(user: User){
        let customTitleView = UIView()
        customTitleView.translatesAutoresizingMaskIntoConstraints = false
//        customTitleView.backgroundColor = .orange

        self.navigationItem.titleView = customTitleView
        customTitleView.widthAnchor
            .constraint(equalToConstant: 100)
            .isActive = true
        customTitleView.heightAnchor
            .constraint(equalToConstant: 44)
            .isActive = true
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
//        containerView.backgroundColor = .yellow
        customTitleView.addSubview(containerView)
        
        containerView.leadingAnchor
            .constraint(equalTo: customTitleView.leadingAnchor, constant: 0)
            .isActive = true
        containerView.trailingAnchor
            .constraint(equalTo: customTitleView.trailingAnchor, constant: 0)
            .isActive = true
        containerView.topAnchor
            .constraint(equalTo: customTitleView.topAnchor, constant: 0)
            .isActive = true
        containerView.bottomAnchor
            .constraint(equalTo: customTitleView.bottomAnchor, constant: 0)
            .isActive = true
        containerView.centerXAnchor
            .constraint(equalTo: customTitleView.centerXAnchor)
            .isActive = true
        containerView.centerYAnchor
            .constraint(equalTo: customTitleView.centerYAnchor)
            .isActive = true
        
        let imageProfileContainer = UIView()
        imageProfileContainer.translatesAutoresizingMaskIntoConstraints = false
//        imageProfileContainer.backgroundColor = .cyan
        imageProfileContainer.layer.cornerRadius = 15.5
        imageProfileContainer.layer.shadowRadius = 2.2
        imageProfileContainer.layer.shadowOpacity = 0.30
        imageProfileContainer.layer.shadowColor = UIColor.black.cgColor
        imageProfileContainer.layer.shadowOffset = CGSize(width: 0, height: 0)
        containerView.addSubview(imageProfileContainer)
        
        imageProfileContainer.centerXAnchor
            .constraint(equalTo: containerView.centerXAnchor)
            .isActive = true
        imageProfileContainer.topAnchor
            .constraint(equalTo: containerView.topAnchor, constant: -1)
            .isActive = true
        imageProfileContainer.heightAnchor
            .constraint(equalToConstant: 31)
            .isActive = true
        imageProfileContainer.widthAnchor
            .constraint(equalToConstant: 31)
            .isActive = true
        
        let imageProfile = UIImageView()
        imageProfile.translatesAutoresizingMaskIntoConstraints = false
        imageProfile.layer.cornerRadius = 15.5
        imageProfile.layer.masksToBounds = true
        imageProfile.loadImagefromCacheWithURLstring(urlString: user.profileImageURL)
        
        imageProfileContainer.addSubview(imageProfile)
        imageProfile.topAnchor.constraint(equalTo: imageProfileContainer.topAnchor).isActive = true
        imageProfile.bottomAnchor.constraint(equalTo: imageProfileContainer.bottomAnchor).isActive = true
        imageProfile.leadingAnchor.constraint(equalTo: imageProfileContainer.leadingAnchor).isActive = true
        imageProfile.trailingAnchor.constraint(equalTo: imageProfileContainer.trailingAnchor).isActive = true
        
        userNameLabel.text = user.name
        containerView.addSubview(userNameLabel)

        userNameLabel.centerXAnchor
            .constraint(equalTo: imageProfileContainer.centerXAnchor)
            .isActive = true
        userNameLabel.topAnchor
            .constraint(equalTo: imageProfileContainer.bottomAnchor, constant: -1)
            .isActive = true
        navigationItem.title = user.name
    }
    
    func handleNavigationToChat(of user: User){
        let chatVC = ChatViewController()
        chatVC.user = user
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    @objc func handeleLogOut(){
        do{
            try Auth.auth().signOut()
            messages.removeAll()
            messageDictionary.removeAll()
            tableView.reloadData()
        }catch {
            print(error)
        }
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
//        print(self.navigationController?.viewControllers)
        present(loginVC, animated: true)
//        navigationController?.pushViewController(loginVC, animated: true)
    }
    
    @objc func addNewMessage(){
        let newMessageVC = NewMeesageViewController()
        newMessageVC.mainVC = self
        let nav = UINavigationController(rootViewController: newMessageVC)
        nav.modalPresentationStyle = .pageSheet
        nav.sheetPresentationController?.prefersGrabberVisible = true
        nav.sheetPresentationController?.detents = [.medium(), .large()]
        nav.sheetPresentationController?.prefersScrollingExpandsWhenScrolledToEdge = false
        present(nav, animated: true)
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
                        messageType: MessageType(rawValue: "text") ?? .text,
                        sendToID   : sendToID,
                        sendFromID : sendFromID,
                        Date       : date,
                        text       : text,
                        imageInfo  : [:],
                        videoInfo  : [:]
                    )
                    completionHandler(message)
                }
                
                if let sendToID   = massgeData["sendToID"] as? String,
                   let sendFromID = massgeData["sendFromID"] as? String,
                   let date       = massgeData["Date"] as? Double,
                   let imageInfo   = massgeData["imageInfo"] as? [String:Any] {
                    let message = Message(
                        messageType: MessageType(rawValue: "image") ?? .image,
                        sendToID   : sendToID,
                        sendFromID : sendFromID,
                        Date       : date,
                        text       : "",
                        imageInfo  : imageInfo,
                        videoInfo  : [:]
                    )
                    completionHandler(message)
                }
                
                if let sendToID   = massgeData["sendToID"] as? String,
                   let sendFromID = massgeData["sendFromID"] as? String,
                   let date       = massgeData["Date"] as? Double,
                   let videoInfo  = massgeData["videoInfo"] as? [String:Any] {
                    let message = Message(
                        messageType: MessageType(rawValue: "video") ?? .video,
                        sendToID   : sendToID,
                        sendFromID : sendFromID,
                        Date       : date,
                        text       : "",
                        imageInfo  : [:],
                        videoInfo  : videoInfo
                    )
                    completionHandler(message)
                }
            }else{
                completionHandler(nil)
            }
        }
    }
    
    func fetchMessages(){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        db.collection("user-messages").document(uid).collection("chats").addSnapshotListener { qS, error in
            if let chats = qS?.documents {
                for chat in chats{
                    let lastMessage = chat.data()
                    if let lastMessageID = lastMessage["lastMessage"] as? String{
                        self.fetchMessageWith(id: lastMessageID) { message in
                            if let m = message{
                                if m.chatPartnerID() == m.sendFromID || m.chatPartnerID() == m.sendToID{
                                    if let existMessage = self.messageDictionary[m.chatPartnerID()] {
                                        if existMessage.Date > m.Date {

                                        }else{
                                            self.messageDictionary[m.chatPartnerID()] = m
                                        }
                                    }else{
                                        self.messageDictionary[m.chatPartnerID()] = m
                                    }
                                }
                                self.reloadOfChatsTable()
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func handleReloadTable(){
        self.messages = Array(self.messageDictionary.values).sorted(by: { m1, m2 in
            return m1.Date > m2.Date
        })
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func reloadOfChatsTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(
            timeInterval: 0.45,
            target: self,
            selector: #selector(self.handleReloadTable),
            userInfo: nil,
            repeats: false
        )
    }
    
    func fetchUsers(){
        db.collection("users").addSnapshotListener { snapshot, error in
            
            self.users = []
            
            if error != nil {
                print("\(error?.localizedDescription ?? "error")")
            } else {
                
                if let docs = snapshot?.documents {
                    
                    for doc in docs {
                        
                        let userData = doc.data()
                        
                        let user = User(
                            id             : doc.documentID ,
                            name           : userData["name"] as! String,
                            email          : userData["email"] as! String,
                            profileImageURL: userData["profileImageURL"] as! String
                        )
                        
                        URLSession.shared.dataTask(
                            with: URL(string: userData["profileImageURL"] as! String)!
                        ) { data, response, error in
                            
                            if let d = data {
                                
                                DispatchQueue.main.sync {
                                    
                                    if let downloadedImage = UIImage(data: d) {
                                        
                                        self.imgsCache.setObject(
                                            downloadedImage,
                                            forKey: NSString(string: userData["profileImageURL"] as! String)
                                        )
                                    }
                                }
                            }
                        }.resume()
                        
                        self.users.append(user)
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatTableViewCell.identifier, for: indexPath) as! ChatTableViewCell
        let message = messages[indexPath.row]

        var chatPartnerID: String?
        
        if message.sendFromID == Auth.auth().currentUser?.uid {
            chatPartnerID = message.sendToID
        }else{
            chatPartnerID = message.sendFromID
        }
        
        if let id = chatPartnerID {
            if let user = users.first(where: {$0.id == id}){
                cell.profileImage.loadImagefromCacheWithURLstring(urlString: user.profileImageURL)
                cell.userLabel.text = user.name
            }
        }
        if message.text != "" {
            if message.sendFromID == Auth.auth().currentUser?.uid {
                cell.lastMessageLabel.text = "You: \(message.text)"
            }else{
                cell.lastMessageLabel.text = message.text
            }
        }else if !(message.imageInfo.isEmpty){
            cell.lastMessageLabel.text = "📸 Photo"
        }else {
            cell.lastMessageLabel.text = "🎥 Video"
        }
        
        let timeOfSend = Date(timeIntervalSince1970: message.Date)
        var calender = Calendar.current
        calender.timeZone = TimeZone.current
        let result = calender.compare(timeOfSend, to: .now, toGranularity: .day)
        let dataFormatter = DateFormatter()
        
        if result == .orderedSame {
            dataFormatter.dateFormat = "hh:mm a"
            cell.timeLabel.text = dataFormatter.string(from: timeOfSend)
            cell.timeLabel.font = UIFont.systemFont(ofSize: 12)
        }else{
            dataFormatter.dateFormat = "dd/MM/yyyy"
            cell.timeLabel.text = dataFormatter.string(from: timeOfSend)
            cell.timeLabel.font = UIFont.systemFont(ofSize: 10)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        let chatPartnerID = message.chatPartnerID()
        if var user = users.first(where: {$0.id == chatPartnerID}){
            user.id = chatPartnerID
            handleNavigationToChat(of: user)
        }
    }
}

