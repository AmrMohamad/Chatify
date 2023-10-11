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
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
//        navigationController?.navigationBar.prefersLargeTitles = true
        checkIfUserIsLogin()
        
    }

    func checkIfUserIsLogin(){
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handeleLogOut), with: nil, afterDelay: 0)
        } else {
            let uid = Auth.auth().currentUser!.uid
            db.collection("users").document(uid).getDocument { snapShot, error in
                if error != nil {
                    print(error!)
                    return
                }
                if let safeData = snapShot?.data() {
                    self.setupNavTitleWith(
                        user: User(
                            name: safeData["name"] as! String,
                            email: safeData["email"] as! String,
                            profileImageURL: safeData["profileImageURL"] as! String
                                  )
                    )
                }
            }
        }
    }

    func setupNavTitleWith(user: User){
        let customTitleView = UIView()
//        customTitleView.translatesAutoresizingMaskIntoConstraints = false
        customTitleView.frame = CGRect(
            x: 0,
            y: 0,
            width: 100 ,
            height: 44
        )
        self.navigationItem.titleView = customTitleView
//        customTitleView.backgroundColor = .red
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
//        r.backgroundColor = .gray
        customTitleView.addSubview(containerView)
        containerView.leadingAnchor.constraint(equalTo: customTitleView.leadingAnchor, constant: 1).isActive = true
        containerView.trailingAnchor.constraint(equalTo: customTitleView.trailingAnchor, constant: -1).isActive = true
        containerView.topAnchor.constraint(equalTo: customTitleView.topAnchor, constant: 2).isActive = true
        containerView.bottomAnchor.constraint(equalTo: customTitleView.bottomAnchor, constant: -1).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        containerView.widthAnchor.constraint(equalToConstant: 160).isActive = true
        
        
        let imageProfile = UIImageView()
        imageProfile.translatesAutoresizingMaskIntoConstraints = false
        imageProfile.loadImagefromCacheWithURLstring(urlString: user.profileImageURL)
        imageProfile.layer.cornerRadius = 15.5
        imageProfile.layer.masksToBounds = true
        containerView.addSubview(imageProfile)

        imageProfile.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        imageProfile.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: 29).isActive = true
        imageProfile.heightAnchor.constraint(equalToConstant: 31).isActive = true
        imageProfile.widthAnchor.constraint(equalToConstant: 31).isActive = true

        let userNameLabel = UILabel()
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.text = user.name
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 15)
        containerView.addSubview(userNameLabel)

        userNameLabel.centerXAnchor.constraint(equalTo: imageProfile.centerXAnchor).isActive = true
        userNameLabel.topAnchor.constraint(equalTo: imageProfile.bottomAnchor, constant: -1).isActive = true
        customTitleView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleNavigationToChat))
        )
    }
    
    @objc func handleNavigationToChat(){
        self.navigationController?.pushViewController(ChatViewController(), animated: true)
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
        let nav = UINavigationController(rootViewController: newMessageVC)
        nav.modalPresentationStyle = .pageSheet
        nav.sheetPresentationController?.prefersGrabberVisible = true
        nav.sheetPresentationController?.detents = [.medium(), .large()]
        nav.sheetPresentationController?.prefersScrollingExpandsWhenScrolledToEdge = false
        present(nav, animated: true)
    }
}

