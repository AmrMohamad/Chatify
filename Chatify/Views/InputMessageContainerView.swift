//
//  InputMessageContainerView.swift
//  Chatify
//
//  Created by Amr Mohamad on 23/11/2023.
//

import UIKit

class InputMessageContainerView: UIView, UITextViewDelegate {
    var chatViewControllerDelegate: ChatViewController? {
        didSet {
            sendMessageButton
                .addTarget(chatViewControllerDelegate,
                           action: #selector(
                               chatViewControllerDelegate!.handleSendingMessage
                           ),
                           for: .touchUpInside)
            sendAttachmentButton
                .addTarget(chatViewControllerDelegate,
                           action: #selector(
                               chatViewControllerDelegate!.presentAttachmentsActionSheet
                           ),
                           for: .touchUpInside)
        }
    }

    lazy var sendAttachmentButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
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

        addSubview(sendAttachmentButton)
        addSubview(writeMessageTextView)
        addSubview(sendMessageButton)

        NSLayoutConstraint.activate([
            sendAttachmentButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            sendAttachmentButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            sendAttachmentButton.heightAnchor.constraint(equalToConstant: 44),
            sendAttachmentButton.widthAnchor.constraint(equalToConstant: 44),
        ])

        NSLayoutConstraint.activate([
            writeMessageTextView.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            writeMessageTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
            writeMessageTextView.leadingAnchor.constraint(equalTo: sendAttachmentButton.trailingAnchor, constant: 10),
            writeMessageTextView.trailingAnchor.constraint(equalTo: sendMessageButton.leadingAnchor, constant: -10),
        ]
        )

        NSLayoutConstraint.activate([
            sendMessageButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            sendMessageButton.topAnchor.constraint(equalTo: sendAttachmentButton.topAnchor),
            sendMessageButton.bottomAnchor.constraint(equalTo: sendAttachmentButton.bottomAnchor),
            sendMessageButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            sendMessageButton.widthAnchor.constraint(equalToConstant: 44),
        ]
        )
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Handling text field

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
