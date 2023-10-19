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

    let db = Firestore.firestore()
    var messages: [Message] = [Message]()
    var users: [User] = [User]()
    let imgsCache = NSCache<AnyObject, AnyObject>()
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.register(ChatTableViewCell.self, forCellReuseIdentifier: ChatTableViewCell.identifier)
        tableView.separatorStyle = .none
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
        navigationController?.navigationBar.prefersLargeTitles = true
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
                .leadingAnchor.constraint(equalTo: backView.leadingAnchor).isActive = true
            hostingController.view
                .trailingAnchor.constraint(equalTo: backView.trailingAnchor).isActive = true
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

        userNameLabel.text = user.name
        containerView.addSubview(userNameLabel)

        userNameLabel.centerXAnchor
            .constraint(equalTo: imageProfile.centerXAnchor)
            .isActive = true
        userNameLabel.topAnchor
            .constraint(equalTo: imageProfile.bottomAnchor, constant: -1)
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

