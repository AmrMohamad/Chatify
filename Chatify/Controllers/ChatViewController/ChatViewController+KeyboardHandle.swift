//
//  ChatViewController+KeyboardHandle.swift
//  Chatify
//
//  Created by Amr Mohamad on 08/01/2024.
//

import UIKit

extension ChatViewController {
    @objc func showKeyboard(notification: Notification) {
        let kbFrameSize = notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect
        if let heightOfKB = kbFrameSize?.height {
            if device.isOneOf(groupOfAllowedDevices) {
                chatLogTableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: heightOfKB, right: 0)
                chatLogTableView.scrollIndicatorInsets = UIEdgeInsets(top: 1, left: 0, bottom: heightOfKB + 6, right: 0)
            } else {
                chatLogTableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: heightOfKB - 20, right: 0)
                chatLogTableView.scrollIndicatorInsets = UIEdgeInsets(top: 1, left: 0, bottom: heightOfKB - 16, right: 0)
            }
            if let lastVisibleCell = chatLogTableView.visibleCells.last as? MessageTableViewCell {
                if lastVisibleCell.messageTextContent.text == messages[messages.count - 1].text {
                    chatLogTableView.scrollToRow(
                        at: IndexPath(row: messages.count - 1, section: 0),
                        at: .bottom,
                        animated: true
                    )
                }
            }
        }
    }

    @objc func hideKeyboard(notification _: Notification) {
        if device.isOneOf(groupOfAllowedDevices) {
            chatLogTableView.contentInset = UIEdgeInsets(
                top: 8,
                left: 0,
                bottom: chatLogTableViewContentInsetBotton + 12,
                right: 0
            )
            chatLogTableView.scrollIndicatorInsets = UIEdgeInsets(
                top: 1,
                left: 0,
                bottom: chatLogTableViewScrollIndicatorInsetsBotton + 14,
                right: 0
            )
        } else {
            chatLogTableView.contentInset = UIEdgeInsets(
                top: 8,
                left: 0,
                bottom: chatLogTableViewContentInsetBotton,
                right: 0
            )
            chatLogTableView.scrollIndicatorInsets = UIEdgeInsets(
                top: 1,
                left: 0,
                bottom: chatLogTableViewScrollIndicatorInsetsBotton,
                right: 0
            )
        }
    }
}
