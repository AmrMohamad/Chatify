//
//  LoginViewController.swift
//  Chatify
//
//  Created by Amr Mohamad on 10/09/2023.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class LoginViewController: UIViewController {
    var inputsContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        
        return view
    }()
    
    let registerAndLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        button.backgroundColor = UIColor(red: 80/255, green: 101/255, blue: 161/255, alpha: 1)
        button.layer.cornerRadius = 12
        return button
    }()
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Name"
        tf.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        return tf
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Email Address"
        tf.textContentType = .emailAddress
        tf.keyboardType = .emailAddress
        tf.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Password"
        tf.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        tf.isSecureTextEntry = true
        return tf
    }()
    
    let icon : UIImageView = {
        let image = UIImageView(image: UIImage(systemName: "message.fill"))
        image.contentMode = .scaleAspectFit
        image.tintColor = .white
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    lazy var loginRegisterSegmentedConrtol: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Log In", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentIndex = 1
        sc.setTitleTextAttributes(
            [
            NSAttributedString.Key.foregroundColor : UIColor.white
            ],
            for: .normal
        )
        sc.setTitleTextAttributes(
            [
            NSAttributedString.Key.foregroundColor : UIColor(red: 61/255, green: 91/255, blue: 151/255, alpha: 1)
            ],
            for: .selected
        )
        sc.addTarget(self,
                     action: #selector(handleChangeBetweenRegisterAndLogin),
                     for: .valueChanged
        )
        
        return sc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 61/255, green: 91/255, blue: 151/255, alpha: 1)
        
        view.addSubview(icon)
        view.addSubview(loginRegisterSegmentedConrtol)
        view.addSubview(inputsContainer)
        view.addSubview(registerAndLoginButton)
        
        
        setupInputsContainerConstraints()
        setupRegisterLoginButtonConstraints()
        setupIconConstraints()
        setuploginRegisterSegmentedConrtolConstraints()
        
        registerAndLoginButton.addTarget(self, action: #selector(registerAndLoginActionHandler), for: .touchUpInside)
       
    }
    
    var textFieldsStack: UIStackView?
    var inputsContainerHeightConstraint: NSLayoutConstraint?
    @objc func handleChangeBetweenRegisterAndLogin(){
        registerAndLoginButton.setTitle(
            loginRegisterSegmentedConrtol.titleForSegment(at: loginRegisterSegmentedConrtol.selectedSegmentIndex),
            for: .normal
        )
        textFieldsStack?.arrangedSubviews[0].isHidden = loginRegisterSegmentedConrtol
            .selectedSegmentIndex == 0 ? true : false
        
        inputsContainerHeightConstraint?.constant = loginRegisterSegmentedConrtol
            .selectedSegmentIndex == 0 ?  125.0 : 200.0
    }
    // For get a database connection
    let db = Firestore.firestore()
    
    @objc func registerAndLoginActionHandler(_ sender: UIButton) {
        // To enable authentication to get sign up
        let signup = Auth.auth()
        if let name = nameTextField.text,
           let email = emailTextField.text,
           let password = passwordTextField.text {
            // add new user
            signup.createUser(
                withEmail: email,
                password: password
            ) { authResult, error in
                if let e = error {
                    print("\(e.localizedDescription)")
                } else {
                    // if the user is added successfully then save his data: name and email
                    guard let uid = authResult?.user.uid else {return}
                    /* 📂 users
                             L 📄 UserID
                                    L
                                        → his name
                                        → his email
                    */
                    self.db.collection("users").document(uid).setData([
                        "name" : name,
                        "email": email
                    ]) { error in
                        if let e = error {
                            print("\(e.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
    
    func setupIconConstraints() {
        icon.centerXAnchor
            .constraint(equalTo: view.centerXAnchor)
            .isActive = true
        icon.topAnchor
            .constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1/2)
            .isActive = true
        icon.widthAnchor
            .constraint(equalTo: view.widthAnchor, multiplier: 0.80)
            .isActive = true
        icon.heightAnchor
            .constraint(equalTo: view.heightAnchor, multiplier: 1/5)
            .isActive = true
        
    }
    
    func setupInputsContainerConstraints(){
        // Postion of InputsContainer
        inputsContainer.centerXAnchor
            .constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainer.centerYAnchor
            .constraint(equalTo: view.centerYAnchor).isActive = true
        // Size of InputsContainer
        inputsContainerHeightConstraint = inputsContainer.heightAnchor
            .constraint(equalToConstant: 200)
        inputsContainerHeightConstraint?.isActive = true
        inputsContainer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85).isActive = true
        // Stack catch inputs of account data
        textFieldsStack = UIStackView(
            arrangedSubviews: [
                nameTextField,
                emailTextField,
                passwordTextField
            ]
        )
        textFieldsStack?.translatesAutoresizingMaskIntoConstraints = false
        textFieldsStack?.axis         = .vertical
        textFieldsStack?.alignment    = .fill
        textFieldsStack?.distribution = .fillEqually
        textFieldsStack?.spacing      = 0
        inputsContainer.addSubview(textFieldsStack ?? UIView())
        textFieldsStack?.centerXAnchor
            .constraint(equalTo: inputsContainer.centerXAnchor)
            .isActive = true
        textFieldsStack?.centerYAnchor
            .constraint(equalTo: inputsContainer.centerYAnchor)
            .isActive = true
        textFieldsStack?.topAnchor
            .constraint(equalTo: inputsContainer.topAnchor, constant: 0)
            .isActive = true
        textFieldsStack?.bottomAnchor
            .constraint(equalTo: inputsContainer.bottomAnchor, constant: 0)
            .isActive = true
        textFieldsStack?.leadingAnchor
            .constraint(equalTo: inputsContainer.leadingAnchor, constant: 2)
            .isActive = true
        textFieldsStack?.trailingAnchor
            .constraint(equalTo: inputsContainer.trailingAnchor, constant: -2)
            .isActive = true
        
        nameTextField.heightAnchor
            .constraint(equalTo: inputsContainer.heightAnchor, multiplier: 1/3)
            .isActive = true
        
    }
    
    func setupRegisterLoginButtonConstraints(){
        registerAndLoginButton.centerXAnchor
            .constraint(equalTo: view.centerXAnchor)
            .isActive = true
        registerAndLoginButton.topAnchor
            .constraint(equalTo: inputsContainer.bottomAnchor, constant: 12)
            .isActive = true
        registerAndLoginButton.widthAnchor
            .constraint(equalTo: inputsContainer.widthAnchor)
            .isActive = true
        registerAndLoginButton.heightAnchor
            .constraint(equalTo: view.heightAnchor, multiplier: 1/11)
            .isActive = true
    }
    
    func setuploginRegisterSegmentedConrtolConstraints() {
        loginRegisterSegmentedConrtol.centerXAnchor
            .constraint(equalTo: view.centerXAnchor)
            .isActive = true
        loginRegisterSegmentedConrtol.bottomAnchor
            .constraint(equalTo: inputsContainer.topAnchor, constant: -12)
            .isActive = true
        loginRegisterSegmentedConrtol.heightAnchor
            .constraint(equalToConstant: 50)
            .isActive = true
        loginRegisterSegmentedConrtol.widthAnchor
            .constraint(equalTo: inputsContainer.widthAnchor, multiplier: 0.7)
            .isActive = true
    }
}
