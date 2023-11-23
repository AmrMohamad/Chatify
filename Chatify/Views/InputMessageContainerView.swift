//
//  InputMessageContianerView.swift
//  Chatify
//
//  Created by Amr Mohamad on 23/11/2023.
//

import UIKit

class InputMessageContainerView: UIView, UITextViewDelegate {
    var chatViewControllerDelegate : ChatViewController? {
        didSet{
            sendMessageButton
                .addTarget(chatViewControllerDelegate,
                           action: #selector(
                            chatViewControllerDelegate!.handleSendingMessage
                           ),
                           for: .touchUpInside
                )
            sendMediaButton
                .addTarget(chatViewControllerDelegate,
                           action: #selector(
                            chatViewControllerDelegate!.handleSendingMediaMessage
                           ),
                           for: .touchUpInside
                )
        }
    }
    lazy var sendMediaButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "photo.on.rectangle.angled"), for: .normal)
        return button
    }()
    lazy var sendMessageButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Send", for: .normal)
        return button
    }()
    lazy var writeMessageTextView: UITextView = {
        let tf = UITextView()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = .clear
        tf.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        tf.text = "Enter Message ...."
        tf.textColor = UIColor.lightGray
        tf.delegate = self
        return tf
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGroupedBackground.withAlphaComponent(0.95)
        
        addSubview(sendMediaButton)
        addSubview(writeMessageTextView)
        addSubview(sendMessageButton)
        
        NSLayoutConstraint.activate([
            sendMediaButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            sendMediaButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            sendMediaButton.heightAnchor.constraint(equalToConstant: 44),
            sendMediaButton.widthAnchor.constraint(equalToConstant: 44)
        ])
        
        NSLayoutConstraint.activate([
            writeMessageTextView.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            writeMessageTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
            writeMessageTextView.leadingAnchor.constraint(equalTo: sendMediaButton.trailingAnchor, constant: 10),
            writeMessageTextView.trailingAnchor.constraint(equalTo: sendMessageButton.leadingAnchor, constant: -10)
            ]
        )
        
        NSLayoutConstraint.activate([
            sendMessageButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            sendMessageButton.topAnchor.constraint(equalTo: sendMediaButton.topAnchor),
            sendMessageButton.bottomAnchor.constraint(equalTo: sendMediaButton.bottomAnchor),
            sendMessageButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            sendMessageButton.widthAnchor.constraint(equalToConstant: 44)
            ]
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter Message ...."
            textView.textColor = UIColor.lightGray
        }
    }
}
