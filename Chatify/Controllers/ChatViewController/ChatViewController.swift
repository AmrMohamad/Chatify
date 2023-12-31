//
//  ChatViewController.swift
//  Chatify
//
//  Created by Amr Mohamad on 11/10/2023.
//

import AVFoundation
import DeviceKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import MobileCoreServices
import RealmSwift
import SwiftUI
import UIKit

class ChatViewController: UIViewController,
    UITableViewDataSource,
    UITableViewDelegate,
    UITextFieldDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    UITextViewDelegate
{
    let groupOfAllowedDevices: [Device] = [
        .iPhone8,
        .iPhoneSE2,
        .iPhoneSE3,
        .iPhoneSE,
        .simulator(.iPhone8),
        .simulator(.iPhoneSE2),
        .simulator(.iPhoneSE2),
        .simulator(.iPhoneSE3),
    ]
    let device = Device.current
    let messagesCache = NSCache<AnyObject, AnyObject>()
    var user: User? {
        didSet {
            navigationItem.title = user!.name
            FirestoreManager.shared.chat.user = user
            fetchUserMessages()
        }
    }
    var messagesIDDictionary : [String:Double] = [String:Double]()
    var messagesID : [String] = [String]()
    var messages: [Message] = [Message](){
        didSet{
            messages.sort { m1, m2 in
                m1.Date < m2.Date
            }
        }
    }

    var isThereAMessageDeleted: Bool = false
    var timer: Timer?
    var currentMessageOfTappedCell: Message?

    lazy var chatLogTableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(MessageTableViewCell.self, forCellReuseIdentifier: MessageTableViewCell.identifier)
        table.allowsMultipleSelectionDuringEditing = true
        table.separatorStyle = .none
        return table
    }()

    lazy var progressOfUploadVideoView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()

    var progressOfUploadVideoViewHeight: NSLayoutConstraint?

    var progressBar: UIProgressView = {
        let bar = UIProgressView(progressViewStyle: .bar)
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.progress = 0.0
        bar.trackTintColor = .gray
        bar.layer.cornerRadius = 2.5
        bar.clipsToBounds = true
        return bar
    }()

    let variableBlurView = VariableBlurView(
        gradientMask: UIImage(named: "Gradient")!,
        maxBlurRadius: 29,
        filterType: "variableBlur"
    )
    lazy var hostingController = UIHostingController(rootView: variableBlurView)

    let NameOfUploadVideoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.text = "Video"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()

    var chatLogTableViewContentInsetBotton: CGFloat = 0.0
    var chatLogTableViewScrollIndicatorInsetsBotton: CGFloat = 0.0

    let db = Firestore.firestore()
    let storage = Storage.storage()
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        chatLogTableView.dataSource = self
        chatLogTableView.delegate = self

        view.addSubview(chatLogTableView)
        NSLayoutConstraint.activate([
            chatLogTableView.topAnchor.constraint(equalTo: view.topAnchor),
            chatLogTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            chatLogTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatLogTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        chatLogTableView.contentInset = UIEdgeInsets(
            top: 8, left: 0,
            bottom: chatLogTableViewContentInsetBotton, right: 0
        )
        chatLogTableView.scrollIndicatorInsets = UIEdgeInsets(
            top: 1, left: 0,
            bottom: chatLogTableViewScrollIndicatorInsetsBotton, right: 0
        )

        chatLogTableView.keyboardDismissMode = .interactive
        handleSetupOfObservingKB()
    }

    override func viewWillLayoutSubviews() {
        handleZoomingImageViewWhanUpdateLayoutOfChatView()
        handleZoomingVideoViewWhenUpdateLayoutOfCell()
    }

    override func viewDidLayoutSubviews() {
        if let navBar = navigationController?.navigationBar {
            view.addSubview(progressOfUploadVideoView)
            progressOfUploadVideoView.topAnchor.constraint(equalTo: navBar.bottomAnchor).isActive = true
            progressOfUploadVideoView.leadingAnchor.constraint(equalTo: navBar.leadingAnchor).isActive = true
            progressOfUploadVideoView.trailingAnchor.constraint(equalTo: navBar.trailingAnchor).isActive = true
            progressOfUploadVideoViewHeight = progressOfUploadVideoView.heightAnchor.constraint(equalTo: navBar.heightAnchor, multiplier: 0.9)
            progressOfUploadVideoViewHeight?.constant = 0
            progressOfUploadVideoViewHeight?.isActive = true
            progressOfUploadVideoView.backgroundColor = .clear

            hostingController.view.backgroundColor = .clear
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            progressOfUploadVideoView.addSubview(hostingController.view)
            hostingController.view
                .topAnchor.constraint(equalTo: progressOfUploadVideoView.topAnchor)
                .isActive = true
            hostingController.view
                .bottomAnchor.constraint(equalTo: progressOfUploadVideoView.bottomAnchor)
                .isActive = true
            hostingController.view
                .leadingAnchor.constraint(equalTo: progressOfUploadVideoView.leadingAnchor)
                .isActive = true
            hostingController.view
                .trailingAnchor.constraint(equalTo: progressOfUploadVideoView.trailingAnchor)
                .isActive = true

            progressOfUploadVideoView.addSubview(progressBar)
            NSLayoutConstraint.activate([
                progressBar.centerXAnchor.constraint(equalTo: progressOfUploadVideoView.centerXAnchor),
                progressBar.bottomAnchor.constraint(equalTo: progressOfUploadVideoView.bottomAnchor, constant: -12),
                progressBar.widthAnchor.constraint(equalTo: progressOfUploadVideoView.widthAnchor, multiplier: 0.88),
                progressBar.heightAnchor.constraint(equalTo: progressOfUploadVideoView.heightAnchor, multiplier: 0.10),
            ])
            progressOfUploadVideoView.addSubview(NameOfUploadVideoLabel)
            NSLayoutConstraint.activate([
                NameOfUploadVideoLabel.leadingAnchor.constraint(equalTo: progressOfUploadVideoView.leadingAnchor, constant: 4),
                NameOfUploadVideoLabel.topAnchor.constraint(equalTo: progressOfUploadVideoView.topAnchor, constant: 4),
            ])
            progressOfUploadVideoView.isHidden = true
        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override var inputAccessoryView: UIView? {
        return inputContainerView
    }

    lazy var inputContainerView: InputMessageContainerView = {
        let height = UIScreen.main.bounds.height
        let inputMessageContianer = InputMessageContainerView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: view.frame.width,
                height: CGFloat(height * (7.5 / 100.0))
            )
        )
        inputMessageContianer.chatViewControllerDelegate = self
        chatLogTableViewContentInsetBotton = inputMessageContianer.frame.height - 12.0
        chatLogTableViewScrollIndicatorInsetsBotton = inputMessageContianer.frame.height + 8.5
        return inputMessageContianer
    }()

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    func handleSetupOfObservingKB() {
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(showKeyboard),
                         name: UIResponder.keyboardWillShowNotification,
                         object: nil)
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(hideKeyboard),
                         name: UIResponder.keyboardWillHideNotification,
                         object: nil)
    }

    func fetchUserMessages() {
        ChatDatabaseManager.shared.fetchMessages(of: user!) { [weak self] messages, messagesIDDictionary in
            guard let self = self else {return}
            self.messages = []
            self.messagesIDDictionary = [:]
            
            self.messages = messages
            self.messagesIDDictionary = messagesIDDictionary
            
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(
                timeInterval: 0.59,
                target: self,
                selector: #selector(self.handleReloadTable),
                userInfo: nil,
                repeats: false
            )
        }
    }

    @objc func handleReloadTable() {
        DispatchQueue.main.async {
            self.messagesCache
                .setObject(
                    NSArray(array: self.messages),
                    forKey: NSString(string: self.user!.id)
                )
            self.chatLogTableView.reloadData()
            if self.isThereAMessageDeleted == false {
                self.chatLogTableView.scrollToRow(
                    at: IndexPath(row: self.messages.count - 1, section: 0),
                    at: .bottom,
                    animated: true
                )
            }
            self.isThereAMessageDeleted = false
        }

        messagesIDDictionary.sorted(by: { $1.value > $0.value }).forEach { key, _ in
            self.messagesID.append(key)
        }
    }

    @objc func handleSendingMessage() {
        if let text = inputContainerView.writeMessageTextView.text {
            if text != "" && text != "Enter Message ...." {
                FirestoreManager.shared.chat.sendMessage(
                    withProperties: [
                        "text": text,
                    ],
                    typeOfMessage: .text
                )
                DispatchQueue.main.async {
                    self.inputContainerView.writeMessageTextView.text = ""
                }
            }
        }
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        handleSendingMessage()
        return true
    }

    // MARK: - Delete message

    func deleteMessage(messageID: String) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }
        let currentUserMessagesID = getMessageDocumentFor(firstUserID: currentUserUID, secondUserID: user!.id)
        let chatPartnerMessagesID = getMessageDocumentFor(firstUserID: user!.id, secondUserID: currentUserUID)

        let deletedMessage = messages[messagesID.firstIndex(of: messageID)!]
        let indexOfDeletedMessage = messagesID.firstIndex(of: messageID)!

        messages.remove(at: indexOfDeletedMessage)
        messagesID.remove(at: indexOfDeletedMessage)
        FirestoreManager.shared.chat.updateLastMessageAfterDeleteMessage(
            deletedMessage,
            lastMessageID: messagesID.last,
            currentUserUID: currentUserUID
        )
        switch deletedMessage.messageType {
        case .text:
            FirestoreManager.shared.chat.deleteText(messageID: messageID) { [weak self] in
                guard let self = self else { return }
                FirestoreManager.shared.chat.updateLastMessage(
                    target: self,
                    currentUserDocRef: currentUserMessagesID,
                    chatPartnerDocRef: chatPartnerMessagesID,
                    messageID: messageID
                )
            }
        case .image:
            FirestoreManager.shared.chat.deleteImage(
                message: deletedMessage,
                messageID: messageID,
                index: indexOfDeletedMessage
            ) { [weak self] in
                guard let self = self else { return }
                FirestoreManager.shared.chat.updateLastMessage(
                    target: self,
                    currentUserDocRef: currentUserMessagesID,
                    chatPartnerDocRef: chatPartnerMessagesID,
                    messageID: messageID
                )
            }
        case .video:
            FirestoreManager.shared.chat.deleteVideo(
                message: deletedMessage,
                messageID: messageID,
                index: indexOfDeletedMessage
            ) { [weak self] in
                guard let self = self else { return }
                FirestoreManager.shared.chat.updateLastMessage(
                    target: self,
                    currentUserDocRef: currentUserMessagesID,
                    chatPartnerDocRef: chatPartnerMessagesID,
                    messageID: messageID
                )
            }
        case .location:
            FirestoreManager.shared.chat.deleteLocation(messageID: messageID) { [weak self] in
                guard let self = self else { return }
                FirestoreManager.shared.chat.updateLastMessage(
                    target: self,
                    currentUserDocRef: currentUserMessagesID,
                    chatPartnerDocRef: chatPartnerMessagesID,
                    messageID: messageID
                )
            }
        }
    }

    func getMessageDocumentFor(firstUserID user1: String, secondUserID user2: String) -> DocumentReference {
        return db
            .collection("user-messages").document(user1)
            .collection("chats").document(user2)
            .collection("chatContent").document("messagesID")
    }

    // MARK: - Picking an attachment

    @objc func presentAttachmentsActionSheet() {
        let attachmentsSheet = UIAlertController(title: "Attach Media", message: "What would you like to attach?", preferredStyle: .actionSheet)

        attachmentsSheet.addAction(
            UIAlertAction(title: "Photos", style: .default) { [weak self] _ in
                self?.handleSendingImageMessage()
            }
        )

        attachmentsSheet.addAction(
            UIAlertAction(title: "Videos", style: .default) { [weak self] _ in
                self?.handleSendingVideoMessage()
            }
        )

        attachmentsSheet.addAction(
            UIAlertAction(title: "Location", style: .default) { [weak self] _ in
                self?.handleSendingLocationMessage()
            }
        )

        attachmentsSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(attachmentsSheet, animated: true)
    }

    // MARK: - Sending Location

    @objc func handleSendingLocationMessage() {
        let locationPickerVC = LocationPickerViewController(coordinates: nil)
        locationPickerVC.title = "Pick a location"
        navigationController?.pushViewController(locationPickerVC, animated: true)
        locationPickerVC.completion = { [weak self] coordinates in
            self?.handleSendLocation(
                latitude: coordinates.latitude,
                longitude: coordinates.longitude
            )
        }
    }

    private func handleSendLocation(latitude lat: Double, longitude long: Double) {
        let locationProperties: [String: Any] = [
            "locationInfo": [
                "latitude": lat,
                "longitude": long,
            ] as [String: Any],
        ] as [String: Any]
        FirestoreManager.shared.chat.sendMessage(
            withProperties: locationProperties,
            typeOfMessage: .location
        )
    }

    // MARK: - Sending Video & Image

    @objc func handleSendingImageMessage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = [UTType.image.identifier]
        present(imagePicker, animated: true)
    }

    @objc func handleSendingVideoMessage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = [UTType.video.identifier, UTType.movie.identifier, UTType.mpeg.identifier]
        present(imagePicker, animated: true)
    }

    func imagePickerController(
        _: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            uploadVideoToFirebaseStorage(videoURL: videoURL)
            dismiss(animated: true) {
                self.progressOfUploadVideoView.isHidden = false
                UIView.animate(
                    withDuration: 2.8,
                    delay: 0,
                    usingSpringWithDamping: 1.2,
                    initialSpringVelocity: 1.2,
                    options: .transitionCurlDown
                ) {
                    self.progressOfUploadVideoViewHeight!.constant = self.navigationController!.navigationBar.frame.height
                }
            }
        } else {
            handleSelectedImageInfo(info)
            dismiss(animated: true)
        }
    }

    private func thumbnailVideoImageForVideo(url imageURL: URL) -> UIImage? {
        let asset = AVAsset(url: imageURL)
        let thumbnailImageGenerator = AVAssetImageGenerator(asset: asset)
        do {
            let thumbnailImage = try thumbnailImageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch {
            print(error)
        }
        return nil
    }

    private func uploadVideoToFirebaseStorage(videoURL: URL) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let titleVideo = UUID().uuidString
        let storageRecVideo = storage.reference()
            .child("chat_videos")
            .child(uid)
            .child(titleVideo)
            .child("\(titleVideo).mov")
        let storageRecVideoThumbnail = storage.reference()
            .child("chat_videos")
            .child(uid)
            .child(titleVideo)
            .child("\(titleVideo).jpeg")

        var video: Data?
        do {
            video = try NSData(contentsOf: videoURL) as Data
        } catch {
            print(error)
            return
        }
        let uploadTask = storageRecVideo.putData(video!) { _, error in
            if error != nil {
                print("error with uploading image:\n\(error!.localizedDescription)")
                return
            }
            storageRecVideo.downloadURL { url, _ in
                if let safeURLVideo = url {
                    print(safeURLVideo)

                    if let thumbnail = self.thumbnailVideoImageForVideo(url: videoURL) {
                        if let thumbnailImage = thumbnail.jpegData(compressionQuality: 0.02) {
                            let uploadThumbnail = storageRecVideoThumbnail.putData(thumbnailImage) { _, _ in

                                storageRecVideoThumbnail.downloadURL { url, _ in
                                    if let safeURLThumbnail = url {
                                        let properties: [String: Any] = [
                                            "videoInfo": [
                                                "videoTitle": titleVideo,
                                                "videoURL": safeURLVideo.absoluteString,
                                                "thumbnailVideoInfo": [
                                                    "thumbnailImageURL": safeURLThumbnail.absoluteString,
                                                    "thumbnailImageHeight": thumbnail.size.height,
                                                    "thumbnailImageWidth": thumbnail.size.width,
                                                ] as [String: Any],
                                            ] as [String: Any],
                                        ]
                                        FirestoreManager.shared.chat.sendMessage(
                                            withProperties: properties,
                                            typeOfMessage: .video
                                        )
                                    }
                                }
                            }
                            uploadThumbnail.resume()
                            uploadThumbnail.observe(.success) { _ in
                                DispatchQueue.main.async {
                                    UIView.animate(
                                        withDuration: 2.8,
                                        delay: 0,
                                        usingSpringWithDamping: 1.2,
                                        initialSpringVelocity: 1.2,
                                        options: .transitionCurlUp
                                    ) {
                                        self.progressOfUploadVideoViewHeight!.constant = 0
                                    } completion: { complate in
                                        if complate {
                                            self.progressOfUploadVideoView.isHidden = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        uploadTask.resume()

        uploadTask.observe(.progress) { storageSnapshot in
            let processPrentage = 100.0 * (Double(storageSnapshot.progress!.completedUnitCount) / Double(storageSnapshot.progress!.totalUnitCount))
            self.progressBar.progress = Float(
                Double(storageSnapshot.progress!.completedUnitCount) / Double(storageSnapshot.progress!.totalUnitCount)
            )
            self.NameOfUploadVideoLabel.text = "Video Uploading: " + String(format: "%.2f", Float(processPrentage))
            print(processPrentage)
        }
        
//        FirestoreManager.shared.uploadVideoOf(videoURL) { storageSnapshot in
//            print("alooo")
//            UIView.animate(
//                withDuration: 2.8,
//                delay: 0,
//                usingSpringWithDamping: 1.2,
//                initialSpringVelocity: 1.2,
//                options: .transitionCurlUp
//            ) {
//                self.progressOfUploadVideoViewHeight!.constant = 0
//            } completion: { complate in
//                if complate {
//                    self.progressOfUploadVideoView.isHidden = true
//                }
//            }
//            let processPrentage = 100.0 * (Double(storageSnapshot.progress!.completedUnitCount) / Double(storageSnapshot.progress!.totalUnitCount))
//            self.progressBar.progress = Float(
//                Double(storageSnapshot.progress!.completedUnitCount) / Double(storageSnapshot.progress!.totalUnitCount)
//            )
//            self.NameOfUploadVideoLabel.text = "Video Uploading: " + String(format: "%.2f", Float(processPrentage))
//            print(processPrentage)
//        }
    }

    private func handleSelectedImageInfo(_ info: [UIImagePickerController.InfoKey: Any]) {
        var selectedImageFromPicker: UIImage?

        if let editedImage = info[
            UIImagePickerController
                .InfoKey(rawValue: "UIImagePickerControllerEditedImage")
        ] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let selectedOriginalImage = info[
            UIImagePickerController
                .InfoKey(rawValue: "UIImagePickerControllerOriginalImage")
        ] as? UIImage {
            selectedImageFromPicker = selectedOriginalImage
        }

        if let selectedImage = selectedImageFromPicker {
            uploadImageToFirebaseStorage(selectedImage)
        }
    }

    private func uploadImageToFirebaseStorage(_ image: UIImage) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let uploadImage = image.jpegData(compressionQuality: 0.08)
        let imageTitle = UUID().uuidString
        let storageRec = storage.reference()
            .child("chat_images")
            .child(uid)
            .child("\(imageTitle).jpeg")
        if let safeImage = uploadImage {
            let uploadTask = storageRec.putData(safeImage, metadata: nil) { _, error in
                if error != nil {
                    print("error with uploading image:\n\(error!.localizedDescription)")
                    return
                }
                storageRec.downloadURL { url, _ in
                    if let safeURL = url {
                        self.sendMessageWithImageURL(safeURL, image, title: imageTitle)
                    }
                }
            }
            uploadTask.resume()
        }
    }

    private func sendMessageWithImageURL(_ imageURL: URL, _ image: UIImage, title: String) {
        FirestoreManager.shared.chat.sendMessage(
            withProperties: [
                "imageInfo": [
                    "imageTitle": title,
                    "imageURL": imageURL.absoluteString,
                    "imageHeight": image.size.height,
                    "imageWidth": image.size.width,
                ] as [String: Any],
            ],
            typeOfMessage: .image
        )
    }

    // MARK: - Editing Table View

    func tableView(_: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if !(messages.isEmpty) && messages[indexPath.row].sendFromID == Auth.auth().currentUser?.uid {
            return true
        } else {
            return false
        }
    }

//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        print("delete")
//    }
    func tableView(_: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "Delete") { _, _, completionHandler in
            print("delete")
            print(indexPath.row)
            self.deleteMessage(messageID: self.messagesID[indexPath.row])
            completionHandler(true)
        }
        delete.backgroundColor = .systemRed
        delete.image = UIImage(systemName: "trash")

        let actions = UISwipeActionsConfiguration(actions: [delete])
        return actions
    }
}
