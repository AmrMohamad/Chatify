//
//  ChatViewController+UITableViewDataSource.swift
//  Chatify
//
//  Created by Amr Mohamad on 27/11/2023.
//

import CoreLocation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import UIKit

/// Viewing the data of chat tableview
extension ChatViewController {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.identifier, for: indexPath) as! MessageTableViewCell
        cell.chatVC = self
        cell.selectionStyle = .none
        let message = messages[indexPath.row]
        handleSetupOfThePositionOfMessageCell(cell: cell, message: message)
        switch message.messageType {
        case .image:
            handleSetupOfImageMessageCell(cell, withContentOf: message)
        case .video:
            handleSetupOfVideoMessageCell(cell, withContentOf: message)
        case .text:
            handleSetupOfTextMessageCell(cell, withContentOf: message)
        case .location:
            handleSetupOfLocationMessageCell(cell, withContentOf: message)
        }
        let timeOfSend = Date(timeIntervalSince1970: message.Date)
        let dataFormatter = DateFormatter()
        dataFormatter.dateFormat = "hh:mm a"
        cell.timeOfSend.text = dataFormatter.string(from: timeOfSend)
        return cell
    }

    private func handleSetupOfThePositionOfMessageCell(cell: MessageTableViewCell, message: Message) {
        if let profileImageURL = user?.profileImageURL {
            cell.imageProfileOfChatPartner.loadImagefromCacheWithURLstring(urlString: profileImageURL)
        }

        if message.sendFromID == Auth.auth().currentUser?.uid {
            // Blue
            cell.bubbleView.backgroundColor = MessageTableViewCell.blueColor
            cell.messageTextContent.textColor = .white
            cell.timeOfSend.textColor = .white
            cell.bubbleViewLeadingAnchor?.isActive = false
            cell.bubbleViewTrailingAnchor?.isActive = true
            cell.imageProfileOfChatPartner.isHidden = true
        } else {
            // Gray
            cell.bubbleView.backgroundColor = MessageTableViewCell.grayColor
            cell.messageTextContent.textColor = .black
            cell.timeOfSend.textColor = .black
            cell.bubbleViewLeadingAnchor?.isActive = true
            cell.bubbleViewTrailingAnchor?.isActive = false
            cell.imageProfileOfChatPartner.isHidden = false
        }
    }

    private func sizeOfText(_ text: String) -> CGRect {
        return NSString(string: text).boundingRect(
            with: CGSize(width: 200, height: 1000),
            options: NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin),
            attributes: [
                .font: UIFont.systemFont(ofSize: 16),
            ],
            context: nil
        )
    }

    // MARK: - Depend on type of message type how the cell will be handled

    private func handleSetupOfTextMessageCell(_ cell: MessageTableViewCell, withContentOf message: Message) {
        cell.messageTextContent.text = message.text
        cell.imageMessageView.isHidden = true
        cell.messageTextContent.isHidden = false
        cell.bubbleViewHeightAnchor?.isActive = false
        cell.bubbleViewHeightAnchor = cell.bubbleView.heightAnchor.constraint(equalToConstant: CGFloat((sizeOfText(message.text).height * 0.832) + 30.4))
        cell.bubbleViewHeightAnchor?.isActive = true

        cell.bubbleViewWidthAnchor?.isActive = false
        cell.bubbleViewWidthAnchor = cell.bubbleView.widthAnchor.constraint(equalToConstant: CGFloat(sizeOfText(message.text).width + 80.0))
        cell.bubbleViewWidthAnchor?.isActive = true
        cell.startPlayButton.isHidden = true
        cell.snapOfMap.isHidden = true
    }

    private func handleSetupOfImageMessageCell(_ cell: MessageTableViewCell, withContentOf message: Message) {
        if let uploadImageURL = message.imageInfo["imageURL"] as? String {
            cell.imageMessageView.loadImagefromCacheWithURLstring(urlString: uploadImageURL)
        }
        cell.bubbleViewHeightAnchor?.isActive = false
        cell.bubbleViewWidthAnchor?.isActive = false
        if let height = message.imageInfo["imageHeight"] as? CGFloat,
           let width = message.imageInfo["imageWidth"] as? CGFloat
        {
            cell.bubbleViewHeightAnchor = cell.bubbleView.heightAnchor.constraint(equalToConstant: CGFloat(height * 0.36))
            cell.bubbleViewHeightAnchor?.isActive = true

            cell.bubbleViewWidthAnchor = cell.bubbleView.widthAnchor.constraint(equalToConstant: CGFloat(width * 0.36))
            cell.bubbleViewWidthAnchor?.isActive = true
        }
        cell.bubbleView.backgroundColor = .clear
        cell.imageMessageView.isHidden = false
        cell.messageTextContent.isHidden = true
        cell.startPlayButton.isHidden = true
        cell.snapOfMap.isHidden = true
    }

    private func handleSetupOfVideoMessageCell(_ cell: MessageTableViewCell, withContentOf message: Message) {
        if let videoURL = message.videoInfo["videoURL"] as? String {
            cell.videoURL = URL(string: videoURL)
        }
        if let videoThumbnail = message.videoInfo["thumbnailVideoInfo"] as? [String: Any] {
            if let thumbnailURL = videoThumbnail["thumbnailImageURL"] as? String {
                cell.imageMessageView.loadImagefromCacheWithURLstring(urlString: thumbnailURL)
            }
        }
        cell.bubbleViewHeightAnchor?.isActive = false
        cell.bubbleViewWidthAnchor?.isActive = false
        if let thumbnailVideoInfo = message.videoInfo["thumbnailVideoInfo"] as? [String: Any] {
            if let height = thumbnailVideoInfo["thumbnailImageHeight"] as? CGFloat,
               let width = thumbnailVideoInfo["thumbnailImageWidth"] as? CGFloat
            {
                cell.bubbleViewHeightAnchor = cell.bubbleView.heightAnchor.constraint(equalToConstant: CGFloat(height * 0.48))
                cell.bubbleViewHeightAnchor?.isActive = true

                cell.bubbleViewWidthAnchor = cell.bubbleView.widthAnchor.constraint(equalToConstant: CGFloat(width * 0.48))
                cell.bubbleViewWidthAnchor?.isActive = true
            }
            cell.bubbleView.backgroundColor = .clear
            cell.imageMessageView.isHidden = false
            cell.messageTextContent.isHidden = true
            cell.startPlayButton.isHidden = false
            cell.snapOfMap.isHidden = true
        }
    }

    private func handleSetupOfLocationMessageCell(_ cell: MessageTableViewCell, withContentOf message: Message) {
        cell.imageMessageView.isHidden = true
        cell.messageTextContent.isHidden = true
        cell.startPlayButton.isHidden = true
        cell.snapOfMap.isHidden = false
        let lat = message.locationInfo["latitude"] as! CLLocationDegrees
        let long = message.locationInfo["longitude"] as! CLLocationDegrees
        print(lat, long)
        cell.snapOfMap.configureSnap(with: CLLocation(latitude: lat, longitude: long))
        cell.bubbleViewWidthAnchor?.isActive = false
        cell.bubbleViewWidthAnchor = cell.bubbleView.widthAnchor.constraint(equalToConstant: 256)
        cell.bubbleViewWidthAnchor?.isActive = true
        cell.bubbleViewHeightAnchor?.isActive = false
        cell.bubbleViewHeightAnchor = cell.bubbleView.heightAnchor.constraint(equalToConstant: 256)
        cell.bubbleViewHeightAnchor?.isActive = true
        currentMessageOfTappedCell = message
        cell.snapOfMap.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(didTaped)
        )
        )
    }

    @objc func didTaped(_: UITapGestureRecognizer) {
        if let message = currentMessageOfTappedCell {
            let latitude = message.locationInfo["latitude"] as! Double
            let longitude = message.locationInfo["longitude"] as! Double
            let vc = LocationPickerViewController(coordinates: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            vc.title = "Location"
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
