//
//  LoginViewController.swift
//  Chatify
//
//  Created by Amr Mohamad on 10/09/2023.
//

import UIKit

class LoginViewController: UIViewController {
    var inputsContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        
        return view
    }()
    
    let registerButton: UIButton = {
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
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 61/255, green: 91/255, blue: 151/255, alpha: 1)
        
        view.addSubview(inputsContainer)
        setupInputsContainerConstraints()
        view.addSubview(registerButton)
        setupRegisterButtonConstraints()
        view.addSubview(icon)
        setupIconConstraints()
    }
    
    func setupInputsContainerConstraints(){
        // Postion of InputsContainer
        inputsContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        // Size of InputsContainer
        inputsContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/4).isActive = true
        inputsContainer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85).isActive = true
        // Stack catch inputs of account data
        let textFieldsStack = UIStackView(
            arrangedSubviews: [
                nameTextField,
                emailTextField,
                passwordTextField
            ]
        )
        textFieldsStack.translatesAutoresizingMaskIntoConstraints = false
        textFieldsStack.axis         = .vertical
        textFieldsStack.alignment    = .fill
        textFieldsStack.distribution = .fillEqually
        textFieldsStack.spacing      = 0
        inputsContainer.addSubview(textFieldsStack)
        textFieldsStack
            .centerXAnchor
            .constraint(equalTo: inputsContainer.centerXAnchor)
            .isActive = true
        textFieldsStack
            .centerYAnchor
            .constraint(equalTo: inputsContainer.centerYAnchor)
            .isActive = true
        textFieldsStack
            .topAnchor
            .constraint(equalTo: inputsContainer.topAnchor, constant: 0)
            .isActive = true
        textFieldsStack
            .bottomAnchor
            .constraint(equalTo: inputsContainer.bottomAnchor, constant: 0)
            .isActive = true
        textFieldsStack
            .leadingAnchor
            .constraint(equalTo: inputsContainer.leadingAnchor, constant: 2)
            .isActive = true
        textFieldsStack
            .trailingAnchor
            .constraint(equalTo: inputsContainer.trailingAnchor, constant: -2)
            .isActive = true
        nameTextField.heightAnchor.constraint(equalTo: inputsContainer.heightAnchor, multiplier: 1/3).isActive = true
        
    }
    func setupRegisterButtonConstraints(){
        registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registerButton.topAnchor.constraint(equalTo: inputsContainer.bottomAnchor, constant: 12).isActive = true
        registerButton.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
        registerButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/11).isActive = true
    }
    
    func setupIconConstraints() {
        icon.centerXAnchor
            .constraint(equalTo: view.centerXAnchor)
            .isActive = true
        
        icon.bottomAnchor
            .constraint(equalTo: inputsContainer.topAnchor, constant: -12)
            .isActive = true
        
        icon.widthAnchor
            .constraint(equalTo: view.widthAnchor, multiplier: 0.80)
            .isActive = true
        icon.heightAnchor
            .constraint(equalTo: view.heightAnchor, multiplier: 1/5)
            .isActive = true
        
    }
}
