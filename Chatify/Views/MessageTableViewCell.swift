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
    
    let bubbleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0, green: 137/225, blue: 249/225, alpha: 1)
        view.layer.cornerRadius = 11.3333
        view.layer.masksToBounds = true
        return view
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(bubbleView)
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:-10),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.85),
            bubbleView.heightAnchor.constraint(greaterThanOrEqualToConstant: 34)
        ])
        bubbleView.addSubview(messageTextContent)
        NSLayoutConstraint.activate([
            messageTextContent.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 4),
            messageTextContent.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant:-14),
            messageTextContent.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -4),
            messageTextContent.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 14),
            messageTextContent.widthAnchor.constraint(greaterThanOrEqualToConstant: 34)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
