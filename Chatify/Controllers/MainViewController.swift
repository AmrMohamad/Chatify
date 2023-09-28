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
        navigationController?.navigationBar.prefersLargeTitles = true
        checkIfUserIsLogin()
    }
    func setupNavTitle(){
        print("555555555555")
        if let uid = Auth.auth().currentUser?.uid {
            db.collection("users").document(uid).getDocument { snapshot, error in
                if let userData = snapshot?.data() {
                    self.navigationItem.title = userData["name"] as? String
                }
            }
        }
    }
    func checkIfUserIsLogin(){
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handeleLogOut), with: nil, afterDelay: 0)
        } else {
            let uid = Auth.auth().currentUser!.uid
            db.collection("users").document(uid).getDocument { snapshot, error in
                if let userData = snapshot?.data() {
                    self.navigationItem.title = userData["name"] as? String
                }
            }
        }
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

