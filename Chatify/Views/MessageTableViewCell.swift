//
//  MessageTableViewCell.swift
//  Chatify
//
//  Created by Amr Mohamad on 26/10/2023.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    static let identifier = "MessageCell"
    
    let messageTextContent: UILabel = {
        let tv = UILabel()
        tv.backgroundColor = .clear
        tv.textColor = .white
        tv.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        tv.numberOfLines = 0
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
        label.font = UIFont.systemFont(ofSize: 9.2, weight: .semibold)
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
    let imageMessageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = .brown
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    
    var bubbleViewTrailingAnchor : NSLayoutConstraint?
    var bubbleViewLeadingAnchor : NSLayoutConstraint?
    var bubbleViewHeightAnchor : NSLayoutConstraint?
    var bubbleViewWidthAnchor : NSLayoutConstraint?
    
    lazy var bubbleViewWidthAnchorDefault = bubbleView.widthAnchor
        .constraint(lessThanOrEqualTo: self.widthAnchor, multiplier: 0.85)
    lazy var bubbleViewHeightAnchorDefault = bubbleView.heightAnchor
        .constraint(greaterThanOrEqualToConstant: 34)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(imageProfileOfChatPartner)
        NSLayoutConstraint.activate([
            imageProfileOfChatPartner.leadingAnchor
                .constraint(equalTo: self.leadingAnchor, constant: 10),
            imageProfileOfChatPartner.bottomAnchor
                .constraint(equalTo: self.bottomAnchor, constant: -4),
            imageProfileOfChatPartner.heightAnchor
                .constraint(equalToConstant: 34.5),
            imageProfileOfChatPartner.widthAnchor
                .constraint(equalToConstant: 32)
        ])
        
        addSubview(bubbleView)
        bubbleView.topAnchor
            .constraint(equalTo: self.topAnchor, constant: 4)
            .isActive = true
        bubbleViewTrailingAnchor = bubbleView.trailingAnchor
            .constraint(equalTo: self.trailingAnchor, constant:-10)
        bubbleViewTrailingAnchor?.isActive = true
        bubbleViewLeadingAnchor = bubbleView.leadingAnchor
            .constraint(equalTo: imageProfileOfChatPartner.trailingAnchor, constant: 8)
        bubbleViewLeadingAnchor?.isActive = false
        bubbleView.bottomAnchor
            .constraint(equalTo: self.bottomAnchor, constant: -4)
            .isActive = true
        bubbleViewWidthAnchor = bubbleView.widthAnchor
            .constraint(lessThanOrEqualTo: self.widthAnchor, multiplier: 0.85)
        bubbleViewWidthAnchor?.isActive = true
        bubbleViewHeightAnchor = bubbleView.heightAnchor
            .constraint(greaterThanOrEqualToConstant: 34)
        bubbleViewHeightAnchor?.isActive = true
        
        bubbleView.addSubview(messageTextContent)
        NSLayoutConstraint.activate([
            messageTextContent.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 2),
            messageTextContent.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant:-54),
            messageTextContent.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -2),
            messageTextContent.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageTextContent.widthAnchor.constraint(greaterThanOrEqualToConstant: 34)
        ])
        bubbleView.addSubview(imageMessageView)
        NSLayoutConstraint.activate([
            imageMessageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor),
            imageMessageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor),
            imageMessageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
            imageMessageView.topAnchor.constraint(equalTo: bubbleView.topAnchor)
        ])
        
        bubbleView.addSubview(timeOfSend)
        NSLayoutConstraint.activate([
            timeOfSend.leadingAnchor.constraint(equalTo: messageTextContent.trailingAnchor, constant: 1),
            timeOfSend.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -6),
            timeOfSend.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -3),
            timeOfSend.heightAnchor.constraint(equalToConstant: 10)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
