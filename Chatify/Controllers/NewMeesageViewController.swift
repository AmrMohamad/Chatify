//
//  NewMeesageViewController.swift
//  Chatify
//
//  Created by Amr Mohamad on 20/09/2023.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class NewMeesageViewController: UITableViewController {

    let db = Firestore.firestore()
    var users: [User] = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Massage"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(handleCancelAction)
        )
        
        tableView.register(
            AddNewUserCell.self,
            forCellReuseIdentifier: AddNewUserCell.identifier
        )
        tableView.separatorStyle = .none
        
        fetchUsers()
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
                        let user = User(name: userData["name"] as! String,
                                        email: userData["email"] as! String,
                                        profileImageURL: userData["profileImageURL"] as! String
                        )
                        self.users.append(user)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    @objc func handleCancelAction(){
        dismiss(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: AddNewUserCell.identifier,
            for: indexPath
        ) as! AddNewUserCell
        var contentOfCell = cell.defaultContentConfiguration()
        contentOfCell.text = users[indexPath.row].name
        contentOfCell.secondaryText = users[indexPath.row].email
        cell.contentConfiguration = contentOfCell
        return cell
    }
}
