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
import Inject

class LoginViewController: UIViewController {
    
    var mainViewController: MainViewController?
    
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
        tf.autocapitalizationType = .none
        tf.textContentType = .username
        tf.isSecureTextEntry = false
//        tf.textContentType = .emailAddress
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
        tf.textContentType = .password
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        return tf
    }()
    
    let icon : UIImageView = {
        let image = UIImageView(image: UIImage(named: "Chatify logo"))
        image.contentMode = .scaleAspectFill
        image.tintColor = .white
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    lazy var addImageProfile : UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "person.crop.circle.fill.badge.plus")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.tintColor   = UIColor(red: 61/255, green: 91/255, blue: 151/255, alpha: 1)
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(handleAddImageGesture)
            )
        )
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
    
    lazy var containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    var containerStackViewTopAnchor: NSLayoutConstraint?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 61/255, green: 91/255, blue: 151/255, alpha: 1)
        
//        view.addSubview(icon)
//        view.addSubview(loginRegisterSegmentedConrtol)
//        view.addSubview(inputsContainer)
//        view.addSubview(registerAndLoginButton)
        view.addSubview(containerStackView)
        containerStackView.axis = .vertical
        containerStackView.spacing = 5
        containerStackView.alignment = .center
        containerStackView.distribution = .fill
        
        NSLayoutConstraint.activate([
            containerStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            containerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15)
        ])
        containerStackViewTopAnchor = containerStackView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor)
        containerStackViewTopAnchor?.isActive = true
        containerStackView.insertArrangedSubview(icon, at: 0)
        containerStackView.insertArrangedSubview(loginRegisterSegmentedConrtol, at: 1)
        containerStackView.insertArrangedSubview(inputsContainer, at: 2)
        containerStackView.insertArrangedSubview(registerAndLoginButton, at: 3)
        
        
        setupInputsContainerConstraints()
        setupRegisterLoginButtonConstraints()
        setupIconConstraints()
        setuploginRegisterSegmentedConrtolConstraints()
        
        registerAndLoginButton.addTarget(self, action: #selector(registerAndLoginActionHandler), for: .touchUpInside)
        handleSetupOfObservingKB()
        initializeHideKeyboard()
    }
    
    public var textFieldsStack: UIStackView?
    public var inputsContainerHeightConstraint: NSLayoutConstraint?

    // For get a database connection
    let db = Firestore.firestore()
    
    func setupIconConstraints() {

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

        // Size of InputsContainer
        inputsContainerHeightConstraint = inputsContainer.heightAnchor
            .constraint(equalToConstant: 250)
        inputsContainerHeightConstraint?.isActive = true
        inputsContainerHeightConstraint?.priority = .required
        inputsContainer.widthAnchor
            .constraint(equalTo: view.widthAnchor, multiplier: 0.85)
            .isActive = true
        // Stack catch inputs of account data
        textFieldsStack = UIStackView(
            arrangedSubviews: [
                addImageProfile,
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
//        let nameTextFieldHeightAnchor: NSLayoutConstraint = nameTextField.heightAnchor.constraint(equalToConstant: 62.5)
//        nameTextFieldHeightAnchor.isActive = true
//        let emailTextFieldHeightAnchor: NSLayoutConstraint = emailTextField.heightAnchor.constraint(equalToConstant: 62.5)
//        emailTextFieldHeightAnchor.isActive = true
//        let passwordTextFieldHeightAnchor: NSLayoutConstraint = passwordTextField.heightAnchor.constraint(equalToConstant: 62.5)
//        passwordTextFieldHeightAnchor.isActive = true
//        let addImageProfileHeightAnchor: NSLayoutConstraint = addImageProfile.heightAnchor.constraint(equalToConstant: 62.5)
//        addImageProfileHeightAnchor.isActive = true
        NSLayoutConstraint.activate([
            nameTextField.heightAnchor.constraint(equalToConstant: 62.5),
            emailTextField.heightAnchor.constraint(equalToConstant: 62.5),
            passwordTextField.heightAnchor.constraint(equalToConstant: 62.5),
            addImageProfile.heightAnchor.constraint(equalToConstant: 62.5)
        ])
        
        
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
            .constraint(equalTo: view.heightAnchor, multiplier: 0.054)
            .isActive = true
        loginRegisterSegmentedConrtol.widthAnchor
            .constraint(equalTo: inputsContainer.widthAnchor, multiplier: 0.7)
            .isActive = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleSetupOfObservingKB(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showKeyboard),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hideKeyboard),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    lazy var containerStackViewBottomAnchor: NSLayoutConstraint = containerStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
    
    @objc func showKeyboard(notification: Notification){
        let kbFrameSize = notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect
        let kbDuration =  notification.userInfo?["UIKeyboardAnimationDurationUserInfoKey"] as? Double
        
        if let heightOfKB = kbFrameSize?.height,
           let duration = kbDuration{
            containerStackViewBottomAnchor.constant = -heightOfKB
            containerStackViewBottomAnchor.isActive = true
            containerStackViewTopAnchor?.isActive = false
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func hideKeyboard(notification: Notification){
        let kbDuration =  notification.userInfo?["UIKeyboardAnimationDurationUserInfoKey"] as? Double
        
        if let durationOfKB = kbDuration{
            if let topConstraint = containerStackViewTopAnchor{
                containerStackViewBottomAnchor.isActive = false
                containerStackView.removeConstraint(containerStackViewBottomAnchor)
                containerStackViewTopAnchor?.isActive = true
            }
            UIView.animate(withDuration: durationOfKB) {
                self.view.layoutIfNeeded()
            }
        }
    }
    func initializeHideKeyboard(){
        //Declare a Tap Gesture Recognizer which will trigger our dismissMyKeyboard() function
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissMyKeyboard))
        //Add this tap gesture recognizer to the parent view
        view.addGestureRecognizer(tap)
    }
    @objc func dismissMyKeyboard(){
        //endEditing causes the view (or one of its embedded text fields) to resign the first responder status.
        //In short- Dismiss the active keyboard.
        view.endEditing(true)
    }

}
