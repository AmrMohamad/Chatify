//
//  MainViewController.swift
//  Chatify
//
//  Created by Amr Mohamad on 04/09/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore

class MainViewController: UITableViewController {

    let db = Firestore.firestore()
    var messages: [Message] = [Message]()
    var users: [User] = [User]()
    let imgsCache = NSCache<AnyObject, AnyObject>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.register(ChatTableViewCell.self, forCellReuseIdentifier: ChatTableViewCell.identifier)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Log Out",
            style: .plain,
            target: self,
            action: #selector(handeleLogOut)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus.message"),
            style: .plain,
            target: self,
            action: #selector(addNewMessage)
        )
        fetchUsers()
        fetchMessages()
    }

    func setupNavTitleWith(user: User){
        let customTitleView = UIView()
        customTitleView.translatesAutoresizingMaskIntoConstraints = false

        self.navigationItem.titleView = customTitleView
        customTitleView.widthAnchor
            .constraint(equalToConstant: 100)
            .isActive = true
        customTitleView.heightAnchor
            .constraint(equalToConstant: 44)
            .isActive = true
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
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
        
        
        let imageProfile = UIImageView()
        imageProfile.translatesAutoresizingMaskIntoConstraints = false
        imageProfile.loadImagefromCacheWithURLstring(urlString: user.profileImageURL)
        imageProfile.layer.cornerRadius = 15.5
        imageProfile.layer.masksToBounds = true
        containerView.addSubview(imageProfile)

        imageProfile.centerXAnchor
            .constraint(equalTo: containerView.centerXAnchor)
            .isActive = true
        imageProfile.topAnchor
            .constraint(equalTo: containerView.topAnchor, constant: -1)
            .isActive = true
        imageProfile.heightAnchor
            .constraint(equalToConstant: 31)
            .isActive = true
        imageProfile.widthAnchor
            .constraint(equalToConstant: 31)
            .isActive = true

        let userNameLabel = UILabel()
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.text = user.name
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 15)
        containerView.addSubview(userNameLabel)

        userNameLabel.centerXAnchor
            .constraint(equalTo: imageProfile.centerXAnchor)
            .isActive = true
        userNameLabel.topAnchor
            .constraint(equalTo: imageProfile.bottomAnchor, constant: -1)
            .isActive = true
        
    }
    
    func handleNavigationToChat(of user: User){
        let chatVC = ChatViewController()
        chatVC.user = user
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    @objc func handeleLogOut(){
        do{
            try Auth.auth().signOut()
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
    
    func fetchMessages(){
        db.collection("messages")
            .order(by: "Date")
            .addSnapshotListener { snapshots, error in
                self.messages = []
                if error != nil{
                    print(error!.localizedDescription)
                    return
                }
                if let snaps = snapshots {
                    for doc in snaps.documents{
                        let safeData = doc.data()
                        let message = Message(
                            sendToID   : safeData["sendToID"] as! String,
                            sendFromID : safeData["sendFromID"] as! String,
                            Date       : safeData["Date"] as! Double,
                            text       : safeData["text"] as! String
                        )
                        self.messages.append(message)
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
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
//                        DispatchQueue.main.async {
//                            self.tableView.reloadData()
//                        }
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatTableViewCell.identifier, for: indexPath) as! ChatTableViewCell
        let message = messages[indexPath.row]
        if let user = users.first(where: {$0.id == message.sendToID}){
            cell.profileImage.loadImagefromCacheWithURLstring(urlString: user.profileImageURL)
        }
        cell.userLabel.text = message.sendToID
        cell.lastMessageLabel.text = message.text
        return cell
    }
}

