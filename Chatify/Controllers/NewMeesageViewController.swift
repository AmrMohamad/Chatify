//
//  NewMeesageViewController.swift
//  Chatify
//
//  Created by Amr Mohamad on 20/09/2023.
//

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import RealmSwift
import UIKit

class NewMeesageViewController: UITableViewController {
    let realm = try! Realm()
    let db = Firestore.firestore()
    var users: [User] = .init()
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

    func fetchUsers() {
        FirestoreManager.shared.fetchUsers { usersData in
            self.users = usersData
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    @objc func handleCancelAction() {
        dismiss(animated: true)
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return users.count
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 66
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: AddNewUserCell.identifier,
            for: indexPath
        ) as! AddNewUserCell

        cell.profileImage.loadImagefromCacheWithURLstring(urlString: users[indexPath.row].profileImageURL)
        cell.emailLabel.text = users[indexPath.row].email
        cell.userLabel.text = users[indexPath.row].name
        return cell
    }

    var mainVC: MainViewController?
    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
//        let userRealm = UserRealmObject()
//        userRealm.id              = user.id
//        userRealm.email           = user.email
//        userRealm.name            = user.name
//        userRealm.profileImageURL = user.profileImageURL
//        let userExisting = realm.object(ofType: UserRealmObject.self, forPrimaryKey: user.id)
//        if let u = userExisting {
//            if u.id != userRealm.id {
//
//            }
//        }else {
//            do{
//                try realm.write({
//                    realm.add(userRealm)
//                })
//            } catch {
//                print("Error Saving Data \(error)")
//            }
//        }
        dismiss(animated: true) {
            self.mainVC?.handleNavigationToChat(of: user)
        }
    }
}
