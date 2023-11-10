//
//  MessageTableViewCell.swift
//  Chatify
//
//  Created by Amr Mohamad on 26/10/2023.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    static let identifier = "MessageCell"
    
    var chatVC: ChatViewController?
    
    let messageTextContent: UILabel = {
        let tv = UILabel()
        tv.backgroundColor = .clear
        tv.textColor = .white
        tv.font = UIFont.systemFont(ofSize: 15.5, weight: .medium)
        tv.numberOfLines = 0
        tv.adjustsFontSizeToFitWidth = true
        tv.minimumScaleFactor = 0.5
        tv.lineBreakMode = .byWordWrapping
        tv.textAlignment = .natural
        tv.allowsDefaultTighteningForTruncation = true
        tv.sizeToFit()
        tv.translatesAutoresizingMaskIntoConstraints = false
        
        return tv
    }()
    static let blueColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
    static let grayColor = UIColor(red: 198/225, green: 198/225, blue: 198/225, alpha: 1)
    let bubbleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = blueColor
        view.layer.cornerRadius = 11.3333
        view.layer.masksToBounds = true
        return view
    }()
    let timeOfSend: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = "10:10 pm"
        label.font = UIFont.systemFont(ofSize: 9.2, weight: .bold)
        label.textColor = .white
        return label
    }()
    let imageProfileOfChatPartner: UIImageView = {
        let image = UIImageView(image: UIImage(systemName: "person"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = .lightGray
        image.layer.cornerRadius = 16
        image.layer.masksToBounds = true
        image.contentMode = .scaleAspectFill
        return image
    }()
    lazy var imageMessageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
//        image.backgroundColor = .lightGray
        image.layer.cornerRadius = 16
        image.layer.masksToBounds = true
        image.contentMode = .scaleAspectFill
        image.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(handleOpenImageMessage)
            )
        )
        image.isUserInteractionEnabled = true
        return image
    }()
    
    
    var bubbleViewTrailingAnchor : NSLayoutConstraint?
    var bubbleViewLeadingAnchor : NSLayoutConstraint?
    var bubbleViewHeightAnchor : NSLayoutConstraint?
    var bubbleViewWidthAnchor : NSLayoutConstraint?
    
    var imageMessageViewWidthAnchor : NSLayoutConstraint?
    var imageMessageViewHeightAnchor : NSLayoutConstraint?
    
    lazy var bubbleViewWidthAnchorDefault = bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75)
    lazy var bubbleViewHeightAnchorDefault = bubbleView.heightAnchor.constraint(greaterThanOrEqualToConstant: 34)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(imageProfileOfChatPartner)
        NSLayoutConstraint.activate([
            imageProfileOfChatPartner.leadingAnchor
                .constraint(equalTo: contentView.leadingAnchor, constant: 10),
            imageProfileOfChatPartner.bottomAnchor
                .constraint(equalTo: contentView.bottomAnchor, constant: -4),
            imageProfileOfChatPartner.heightAnchor
                .constraint(equalToConstant: 34.5),
            imageProfileOfChatPartner.widthAnchor
                .constraint(equalToConstant: 32)
        ])
        
        contentView.addSubview(bubbleView)
        bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4)
            .isActive = true
        bubbleViewTrailingAnchor = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:-10)
        bubbleViewTrailingAnchor?.isActive = true
        bubbleViewLeadingAnchor = bubbleView.leadingAnchor.constraint(equalTo: imageProfileOfChatPartner.trailingAnchor, constant: 8)
        bubbleViewLeadingAnchor?.isActive = false
        bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
            .isActive = true
        
        bubbleViewWidthAnchor = bubbleViewWidthAnchorDefault
        bubbleViewWidthAnchor?.isActive = true
        
        bubbleViewHeightAnchor = bubbleViewHeightAnchorDefault
        bubbleViewHeightAnchor?.isActive = true
        
        bubbleView.addSubview(imageMessageView)
        NSLayoutConstraint.activate([
            imageMessageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor),
            imageMessageView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
            imageMessageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor),
            imageMessageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor)
        ])
        
        bubbleView.addSubview(messageTextContent)
        NSLayoutConstraint.activate([
            messageTextContent.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 3),
            messageTextContent.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant:-20),
            messageTextContent.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -3),
            messageTextContent.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 11),
            messageTextContent.widthAnchor.constraint(greaterThanOrEqualToConstant: 34)
        ])
        
        bubbleView.addSubview(timeOfSend)
        NSLayoutConstraint.activate([
            timeOfSend.leadingAnchor.constraint(equalTo: messageTextContent.trailingAnchor, constant: -32),
            timeOfSend.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -6),
            timeOfSend.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -3),
            timeOfSend.heightAnchor.constraint(equalToConstant: 10),
//            timeOfSend.widthAnchor.
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func handleOpenImageMessage(tapGesture: UITapGestureRecognizer){
        if let imageView = tapGesture.view as? UIImageView {
            self.chatVC?.performZoomInTapGestureForUIImageViewOfImageMessage(imageView, currentCell: self)
        }
    }
}
