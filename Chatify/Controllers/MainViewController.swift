//
//  MainViewController.swift
//  Chatify
//
//  Created by Amr Mohamad on 04/09/2023.
//

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import SwiftUI
import UIKit

class MainViewController: UITableViewController {
    /// The reference of the DataBase FirebaseFirestore
    weak var db = Firestore.firestore()
    /// messages is a array of Message datatype
    var messages: [Message] = .init()
    /// messageDictionary is used to avoid messages/chats duplication
    var messageDictionary: [String: Message] = .init()
    var users: [User] = .init()
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

    lazy var imageProfileContainer: UIView = {
        let imageProfileContainer = UIView()
        imageProfileContainer.translatesAutoresizingMaskIntoConstraints = false
        imageProfileContainer.layer.cornerRadius = 15.5
        imageProfileContainer.layer.shadowRadius = 2.2
        imageProfileContainer.layer.shadowOpacity = 0.30
        imageProfileContainer.layer.shadowColor = UIColor.black.cgColor
        imageProfileContainer.layer.shadowOffset = CGSize(width: 0, height: 0)
        imageProfileContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(navToSettingsVC)))
        return imageProfileContainer
    }()

    lazy var imageProfileContainerLargeTitleNavBar: UIView = {
        let imageProfileContainer = UIView()
        imageProfileContainer.translatesAutoresizingMaskIntoConstraints = false
        imageProfileContainer.layer.cornerRadius = 15.5
        imageProfileContainer.layer.shadowRadius = 2.2
        imageProfileContainer.layer.shadowOpacity = 0.30
        imageProfileContainer.layer.shadowColor = UIColor.black.cgColor
        imageProfileContainer.layer.shadowOffset = CGSize(width: 0, height: 0)
        imageProfileContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(navToSettingsVC)))
        return imageProfileContainer
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.register(ChatTableViewCell.self, forCellReuseIdentifier: ChatTableViewCell.identifier)
        tableView.separatorStyle = .none
        navigationItem.leftBarButtonItem = leftBarButtonLogOut
        navigationItem.rightBarButtonItem = rightBarButtonNewChat
        navigationController?.navigationBar.prefersLargeTitles = true

        fetchUsers()
        fetchMessages()
    }

    override func viewWillAppear(_: Bool) {
        fetchMessages()
        navigationController?.navigationBar.prefersLargeTitles = true
        guard let navBar = navigationController?
            .navigationBar
        else {
            fatalError("Navigation Bar not exist YET")
        }
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        lazy var variableBlurView = VariableBlurView(
            gradientMask: UIImage(named: "Gradient")!,
            maxBlurRadius: 28,
            filterType: "variableBlur"
        )
        lazy var hostingController = UIHostingController(rootView: variableBlurView)

        hostingController.view.backgroundColor = .clear
        hostingController.view.tag = 1
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        hostingController.didMove(toParent: navigationController!)
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

    override func viewWillDisappear(_: Bool) {
        guard let navBar = navigationController?
            .navigationBar
        else {
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

    override func scrollViewDidScroll(_: UIScrollView) {
        if let largeBarView = navigationController?.navigationBar.subviews[1] {
            userNameLabel.alpha = largeBarView.alpha == 1.0 ? 0.0 : 1.0
            imageProfileContainer.alpha = largeBarView.alpha == 1.0 ? 0.0 : 1.0
        }
    }

    func setupNavTitleWith(user: User) {
        let customTitleView = UIView()
        customTitleView.translatesAutoresizingMaskIntoConstraints = false

        navigationItem.largeTitleAccessoryView = imageProfileContainerLargeTitleNavBar
        navigationItem.alignLargeTitleAccessoryViewToBaseline = false

        navigationItem.titleView = customTitleView
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

        let imageProfileLargeTitle = UIImageView()
        imageProfileLargeTitle.translatesAutoresizingMaskIntoConstraints = false
        imageProfileLargeTitle.layer.cornerRadius = 15.5
        imageProfileLargeTitle.layer.masksToBounds = true
        imageProfileLargeTitle.loadImagefromCacheWithURLstring(urlString: user.profileImageURL)
        imageProfileContainerLargeTitleNavBar.heightAnchor
            .constraint(equalToConstant: 34)
            .isActive = true
        imageProfileContainerLargeTitleNavBar.widthAnchor
            .constraint(equalToConstant: 34)
            .isActive = true
        imageProfileContainerLargeTitleNavBar.addSubview(imageProfileLargeTitle)
        imageProfileLargeTitle.topAnchor.constraint(equalTo: imageProfileContainerLargeTitleNavBar.topAnchor).isActive = true
        imageProfileLargeTitle.bottomAnchor.constraint(equalTo: imageProfileContainerLargeTitleNavBar.bottomAnchor).isActive = true
        imageProfileLargeTitle.leadingAnchor.constraint(equalTo: imageProfileContainerLargeTitleNavBar.leadingAnchor).isActive = true
        imageProfileLargeTitle.trailingAnchor.constraint(equalTo: imageProfileContainerLargeTitleNavBar.trailingAnchor).isActive = true

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

    func handleNavigationToChat(of user: User) {
        let chatVC = ChatViewController()
        chatVC.user = user
        navigationController?.pushViewController(chatVC, animated: true)
    }

    @objc func navToSettingsVC() {
        let settingsVC = ChatifySettingsViewController(style: .insetGrouped)
        navigationController?.pushViewController(settingsVC, animated: true)
    }

    @objc func handeleLogOut() {
        do {
            try Auth.auth().signOut()
            messages.removeAll()
            messageDictionary.removeAll()
            tableView.reloadData()
        } catch {
            print(error)
        }
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
//        print(self.navigationController?.viewControllers)
        present(loginVC, animated: true)
//        navigationController?.pushViewController(loginVC, animated: true)
    }

    @objc func addNewMessage() {
        let newMessageVC = NewMeesageViewController()
        newMessageVC.mainVC = self
        let nav = UINavigationController(rootViewController: newMessageVC)
        nav.modalPresentationStyle = .pageSheet
        nav.sheetPresentationController?.prefersGrabberVisible = true
        nav.sheetPresentationController?.detents = [.medium(), .large()]
        nav.sheetPresentationController?.prefersScrollingExpandsWhenScrolledToEdge = false
        present(nav, animated: true)
    }

    func fetchMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        if let refDB = db {
            refDB.collection("user-messages").document(uid).collection("chats").addSnapshotListener { qS, _ in
                self.messageDictionary = [:]
                self.messages = []
                if let chats = qS?.documents {
                    for chat in chats {
                        let lastMessage = chat.data()
                        if let lastMessageID = lastMessage["lastMessage"] as? String {
                            FirestoreManager.shared.fetchMessageWith(id: lastMessageID) { message in
                                if let m = message {
                                    if m.chatPartnerID() == m.sendFromID || m.chatPartnerID() == m.sendToID {
                                        if let existMessage = self.messageDictionary[m.chatPartnerID()] {
                                            if existMessage.Date > m.Date {
                                            } else {
                                                self.messageDictionary[m.chatPartnerID()] = m
                                            }
                                        } else {
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
    }

    @objc func handleReloadTable() {
        messages = Array(messageDictionary.values).sorted(by: { m1, m2 in
            m1.Date > m2.Date
        })
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func reloadOfChatsTable() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: 0.45,
            target: self,
            selector: #selector(handleReloadTable),
            userInfo: nil,
            repeats: false
        )
    }

    func fetchUsers() {
        FirestoreManager.shared.fetchUsers { usersData in
            self.users = usersData
        } complation: { usersData in
            usersData.forEach { user in
                FirestoreManager.shared.downloadImage(urlString: user.profileImageURL) { image in
                    if let img = image {
                        DispatchQueue.main.async {
                            self.imgsCache.setObject(img, forKey: NSString(string: user.profileImageURL))
                        }
                    }
                }
            }
        }
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return messages.count
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 68
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatTableViewCell.identifier, for: indexPath) as! ChatTableViewCell
        let message = messages[indexPath.row]

        var chatPartnerID: String?

        if message.sendFromID == Auth.auth().currentUser?.uid {
            chatPartnerID = message.sendToID
        } else {
            chatPartnerID = message.sendFromID
        }

        if let id = chatPartnerID {
            if let user = users.first(where: { $0.id == id }) {
                cell.profileImage.loadImagefromCacheWithURLstring(urlString: user.profileImageURL)
                cell.userLabel.text = user.name
            }
        }
        switch message.messageType {
        case .text:
            if message.sendFromID == Auth.auth().currentUser?.uid {
                cell.lastMessageLabel.text = "You: \(message.text)"
            } else {
                cell.lastMessageLabel.text = message.text
            }
        case .image:
            cell.lastMessageLabel.text = "📸 Photo"
        case .video:
            cell.lastMessageLabel.text = "🎥 Video"
        case .location:
            cell.lastMessageLabel.text = "📍 Location"
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
        } else {
            dataFormatter.dateFormat = "dd/MM/yyyy"
            cell.timeLabel.text = dataFormatter.string(from: timeOfSend)
            cell.timeLabel.font = UIFont.systemFont(ofSize: 10)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        let chatPartnerID = message.chatPartnerID()
        if var user = users.first(where: { $0.id == chatPartnerID }) {
            user.id = chatPartnerID
            handleNavigationToChat(of: user)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
