//
//  LoginViewController+Handlers.swift
//  Chatify
//
//  Created by Amr Mohamad on 24/09/2023.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage


extension LoginViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: - handle Change Between Register And Login
    
    /// Handle the switching between of Register and Login View
    @objc func handleChangeBetweenRegisterAndLogin(){
        registerAndLoginButton.setTitle(
            loginRegisterSegmentedConrtol.titleForSegment(at: loginRegisterSegmentedConrtol.selectedSegmentIndex),
            for: .normal
        )
        textFieldsStack?.arrangedSubviews[0]
            .isHidden = loginRegisterSegmentedConrtol
            .selectedSegmentIndex == 0 ? true : false
        textFieldsStack?.arrangedSubviews[1]
            .isHidden = loginRegisterSegmentedConrtol
            .selectedSegmentIndex == 0 ? true : false
        
        inputsContainerHeightConstraint?.constant = loginRegisterSegmentedConrtol
            .selectedSegmentIndex == 0 ?  125.0 : 250.0
    }
    
    //MARK: - Handle Add Profile Image
    
    /// Handle the implementation of adding profile image
    @objc func handleAddImageGesture() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[
            UIImagePickerController
                .InfoKey(rawValue: "UIImagePickerControllerEditedImage")
        ] as? UIImage {
           selectedImageFromPicker = editedImage
            
        }
        else if let selectedOriginalImage = info[
            UIImagePickerController
                .InfoKey(rawValue: "UIImagePickerControllerOriginalImage")
        ] as? UIImage{
           selectedImageFromPicker = selectedOriginalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            addImageProfile.image = selectedImage
        }
        dismiss(animated: true)
    }
    
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        print("Cancel")
//    }
    
    
    //MARK: - Handle Register And Login Action
    
    /// Handle the behavior of registerAndLoginButton
    @objc func registerAndLoginActionHandler(_ sender: UIButton) {
        // To enable authentication to get sign up
        let storage = Storage.storage()
        let uploadedProfileImage = addImageProfile.image?.jpegData(compressionQuality: 0.05)
        if sender.currentTitle == "Register"{
            let signup = Auth.auth()
            if let name = nameTextField.text,
               let email = emailTextField.text,
               let password = passwordTextField.text,
               let profileImage = uploadedProfileImage {
                // add new user
                signup.createUser(
                    withEmail: email,
                    password: password
                ) { authResult, error in
                    if let e = error {
                        print("\(e.localizedDescription)")
                    } else {
                        /* 📂 users
                                L 📄 UserID
                                        L
                                          → his name
                                          → his email
                                          → his profileImage
                         */
                        // if the user is added successfully then save his data: name, email and profileImage
                        guard let uid = authResult?.user.uid else {return}
                        let storageRec = storage.reference()
                            .child("profile_images")
                            .child("\(UUID().uuidString).jpeg")
                        let uploadTask = storageRec.putData(profileImage, metadata: nil) { metadata, error in
                            if error != nil {
                                print(error!.localizedDescription)
                            }
                            storageRec.downloadURL { url, error in
                                if let urlD = url {
                                    self.registerUserIntoDBWithUID(
                                        uid: uid,
                                        values: [
                                            "userID"          : uid,
                                            "name"            : name,
                                            "email"           : email,
                                            "profileImageURL" : urlD.absoluteString
                                        ]
                                    )
                                }
                            }
                        }
                        uploadTask.resume()
                    }
                }
            }
        }
        else {
            loginUserIntoDBtoAccessChat()
        }
    }
    
    ///Saving the data of the user depend on assigned `values`
    /// - Parameter uid: the UserID
    /// - Parameter values: a dictionary of values, the keys in string and values in any type
    func registerUserIntoDBWithUID(
        uid: String,
        values: [String: Any]
    ){
        self.db.collection("users").document(uid).setData(values) { error in
            if let e = error {
                print("\(e.localizedDescription)")
            }
            self.mainViewController = MainViewController()
            if let mainVC = self.mainViewController {
                let navVC = UINavigationController(rootViewController: mainVC)
                let u = User(
                    id             : values["userID"] as! String,
                    name           : values["name"] as! String,
                    email          :  values["email"] as! String,
                    profileImageURL:  values["profileImageURL"] as! String
                )
                mainVC.setupNavTitleWith(user: u)
                navVC.modalPresentationStyle = .fullScreen
                self.present(navVC, animated: true)
            }
        }
    }
    
    ///logging in to DataBase to load the user chats
    func loginUserIntoDBtoAccessChat(){
        let login = Auth.auth()
        if let email = emailTextField.text,
           let password = passwordTextField.text {
            login.signIn(
                withEmail: email,
                password: password) { authResult, error in
                    if error != nil{
                        print(error!.localizedDescription)
                    }
                    self.db
                        .collection("users")
                        .document(authResult!.user.uid)
                        .getDocument { snapshot, error in
                            if let safeData = snapshot?.data() {
                                self.mainViewController = MainViewController()
                                if let mainVC = self.mainViewController {
//                                    mainVC.navigationController?.title = safeData["name"] as? String
                                    mainVC.setupNavTitleWith(
                                        user: User(
                                            id             : safeData["userID"] as! String,
                                            name           : safeData["name"] as! String,
                                            email          : safeData["email"] as! String,
                                            profileImageURL: safeData["profileImageURL"] as! String
                                        )
                                    )
                                    let navVC = UINavigationController(rootViewController: mainVC)
                                    navVC.modalPresentationStyle = .fullScreen
                                    self.present(navVC, animated: true)
                        }
                    }
                }
            }
        }
    }
}
