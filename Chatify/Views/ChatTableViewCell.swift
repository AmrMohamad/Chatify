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
        img.layer.cornerRadius = 24
        img.layer.masksToBounds = true
        return img
    }()

    let userLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "userLabel"
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        return label
    }()

    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "HH:MM:SS"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        return label
    }()

    let lastMessageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "emailLabel"
        label.textColor = .darkGray
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(profileImage)
        setupProfileImageConstraints()
        setupLabelsConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupProfileImageConstraints() {
        profileImage.leadingAnchor
            .constraint(equalTo: contentView.leadingAnchor, constant: 16)
            .isActive = true
        profileImage.heightAnchor
            .constraint(equalToConstant: 48)
            .isActive = true
        profileImage.widthAnchor
            .constraint(equalToConstant: 48)
            .isActive = true
        profileImage.centerYAnchor
            .constraint(equalTo: contentView.centerYAnchor)
            .isActive = true
    }

    func setupLabelsConstraints() {
        let UserNameAndTimeContainerView = UIView()
//        UserNameAndTimeContainerView.backgroundColor = .yellow

        UserNameAndTimeContainerView.addSubview(userLabel)
        UserNameAndTimeContainerView.addSubview(timeLabel)

        userLabel.leadingAnchor
            .constraint(equalTo: UserNameAndTimeContainerView.leadingAnchor, constant: 0)
            .isActive = true
        userLabel.trailingAnchor
            .constraint(equalTo: timeLabel.leadingAnchor, constant: -2)
            .isActive = true
        userLabel.topAnchor
            .constraint(equalTo: UserNameAndTimeContainerView.topAnchor, constant: 1)
            .isActive = true
        userLabel.bottomAnchor
            .constraint(equalTo: UserNameAndTimeContainerView.bottomAnchor, constant: -1)
            .isActive = true

        timeLabel.trailingAnchor
            .constraint(equalTo: UserNameAndTimeContainerView.trailingAnchor, constant: -2)
            .isActive = true
        timeLabel.topAnchor
            .constraint(equalTo: userLabel.topAnchor, constant: 2)
            .isActive = true
        timeLabel.bottomAnchor
            .constraint(equalTo: userLabel.bottomAnchor, constant: -2)
            .isActive = true
        timeLabel.widthAnchor
            .constraint(equalTo: UserNameAndTimeContainerView.widthAnchor, multiplier: 0.193)
            .isActive = true

        let DetailsOfChatStackView = UIStackView(
            arrangedSubviews: [
                UserNameAndTimeContainerView,
                lastMessageLabel,
            ]
        )
        DetailsOfChatStackView.translatesAutoresizingMaskIntoConstraints = false
        DetailsOfChatStackView.axis = .vertical
        DetailsOfChatStackView.alignment = .fill
        DetailsOfChatStackView.distribution = .fillEqually
        DetailsOfChatStackView.spacing = 1
        contentView.addSubview(DetailsOfChatStackView)

        DetailsOfChatStackView.leadingAnchor
            .constraint(equalTo: profileImage.trailingAnchor, constant: 16)
            .isActive = true
        DetailsOfChatStackView.trailingAnchor
            .constraint(equalTo: trailingAnchor, constant: -16)
            .isActive = true
        DetailsOfChatStackView.topAnchor
            .constraint(equalTo: profileImage.topAnchor, constant: 6)
            .isActive = true
        DetailsOfChatStackView.bottomAnchor
            .constraint(equalTo: profileImage.bottomAnchor, constant: -6)
            .isActive = true
    }
}
