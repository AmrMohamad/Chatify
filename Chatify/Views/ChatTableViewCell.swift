//
//  ChatTableViewCell.swift
//  Chatify
//
//  Created by Amr Mohamad on 14/10/2023.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    
    static let identifier = "ChatCell"
    
    let profileImage: UIImageView = {
        let img = UIImageView(image: UIImage(systemName: "person.crop.circle"))
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFill
        img.layer.cornerRadius = 22.5
        img.layer.masksToBounds = true
        return img
    }()
    let userLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "userLabel"
        return label
    }()
    let lastMessageLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "emailLabel"
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(profileImage)
        setupProfileImageConstraints()
        setupLabelsConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupProfileImageConstraints() {
        profileImage.leadingAnchor
            .constraint(equalTo: contentView.leadingAnchor, constant: 16)
            .isActive = true
        profileImage.heightAnchor
            .constraint(equalToConstant: 45)
            .isActive = true
        profileImage.widthAnchor
            .constraint(equalToConstant: 45)
            .isActive = true
        profileImage.centerYAnchor
            .constraint(equalTo: contentView.centerYAnchor)
            .isActive = true
    }
    
    func setupLabelsConstraints() {
        let stackLabels = UIStackView(
            arrangedSubviews: [
                userLabel,
                lastMessageLabel
            ]
        )
        stackLabels.translatesAutoresizingMaskIntoConstraints = false
        stackLabels.axis         = .vertical
        stackLabels.alignment    = .fill
        stackLabels.distribution = .fillEqually
        stackLabels.spacing      = 8
        contentView.addSubview(stackLabels)
        
        stackLabels.leadingAnchor
            .constraint(equalTo: profileImage.trailingAnchor, constant: 16)
            .isActive = true
        
//        stackLabels.trailingAnchor
//            .constraint(equalTo: contentView.trailingAnchor, constant: -16)
//            .isActive = true
//        stackLabels.topAnchor
//            .constraint(equalTo: contentView.topAnchor, constant: 10.5)
//            .isActive = true
//        stackLabels.bottomAnchor
//            .constraint(equalTo: contentView.bottomAnchor, constant: -10.5)
//            .isActive = true
        
    }
    
}
