//
//  ChatViewController+HandleZoomingImageView.swift
//  Chatify
//
//  Created by Amr Mohamad on 26/11/2023.
//

import UIKit

protocol ZoomingImageViewProtocol {
    var startImageFrame: CGRect? { get set }
    var backgroundImageView: UIVisualEffectView? { get set }
    var startingImageView: UIImageView? { get set }
    var zoomingImageView: UIImageView? { get set }

    func performZoomInTapGestureForUIImageViewOfImageMessage(_ imageView: UIImageView, currentCell cell: MessageTableViewCell)
    func performZoomOutTapGestureForUIImageViewOfImageMessage(tapGesture: UITapGestureRecognizer)
    func checkOrientationForSetupZoomingImageView(keyWindow: UIWindow)
    func handleZoomingImageViewWhanUpdateLayoutOfChatView()
}

extension ChatViewController: ZoomingImageViewProtocol {
    private enum AssociatedKeysOfZoomingImageView {
        static var startImageFrame = "startImageFrame"
        static var backgroundImageView = "backgroundImageView"
        static var startingImageView = "startingImageView"
        static var zoomingImageView = "zoomingImageView"
    }

    var startImageFrame: CGRect? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeysOfZoomingImageView.startImageFrame) as? CGRect
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeysOfZoomingImageView.startImageFrame, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    var backgroundImageView: UIVisualEffectView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeysOfZoomingImageView.backgroundImageView) as? UIVisualEffectView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeysOfZoomingImageView.backgroundImageView, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    var startingImageView: UIImageView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeysOfZoomingImageView.startingImageView) as? UIImageView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeysOfZoomingImageView.startingImageView, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    var zoomingImageView: UIImageView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeysOfZoomingImageView.zoomingImageView) as? UIImageView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeysOfZoomingImageView.zoomingImageView, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    func performZoomInTapGestureForUIImageViewOfImageMessage(_ imageView: UIImageView, currentCell _: MessageTableViewCell) {
        startingImageView = imageView
        startImageFrame = startingImageView!.convert(imageView.frame, to: nil)
        zoomingImageView = UIImageView(
            frame: startImageFrame!
        )
        zoomingImageView!.image = startingImageView!.image
        zoomingImageView!.isUserInteractionEnabled = true
        zoomingImageView!.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(performZoomOutTapGestureForUIImageViewOfImageMessage)
            )
        )
        if let keyWindow = view.window?.windowScene?.keyWindow {
            backgroundImageView = UIVisualEffectView(frame: keyWindow.frame)
            backgroundImageView!.translatesAutoresizingMaskIntoConstraints = false
            backgroundImageView!.effect = UIBlurEffect(style: .systemUltraThinMaterial)
            backgroundImageView!.alpha = 0
            keyWindow.addSubview(backgroundImageView!)
            NSLayoutConstraint.activate([
                backgroundImageView!.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                backgroundImageView!.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                backgroundImageView!.topAnchor.constraint(equalTo: view.topAnchor),
                backgroundImageView!.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
            keyWindow.addSubview(zoomingImageView!)
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 1,
                options: .curveEaseOut,
                animations: {
                    self.checkOrientationForSetupZoomingImageView(keyWindow: keyWindow)
                    self.startingImageView?.alpha = 0
                    self.backgroundImageView!.alpha = 1
                    self.inputAccessoryView?.alpha = 0
                    self.inputAccessoryView?.isHidden = true
                    self.zoomingImageView!.center = self.backgroundImageView!.center

                },
                completion: nil
            )
        }
    }

    @objc func performZoomOutTapGestureForUIImageViewOfImageMessage(tapGesture: UITapGestureRecognizer) {
        if let zoomingOutView = tapGesture.view as? UIImageView {
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 1,
                options: .curveEaseIn
            ) {
                zoomingOutView.frame = self.startImageFrame!
                zoomingOutView.layer.cornerRadius = 16
                zoomingOutView.layer.masksToBounds = true
                self.backgroundImageView?.alpha = 0
                self.inputAccessoryView?.alpha = 1
                self.inputAccessoryView?.isHidden = false
            } completion: { _ in
                zoomingOutView.removeFromSuperview()
                self.startingImageView?.alpha = 1
                self.backgroundImageView?.removeFromSuperview()
                self.backgroundImageView = nil
            }
        }
    }

    func checkOrientationForSetupZoomingImageView(keyWindow: UIWindow) {
        switch UIDevice.current.orientation {
        case .portrait:
            zoomingImageView!.frame = CGRect(
                x: 0, y: 0,
                width: view.frame.width,
                height: CGFloat(startImageFrame!.height / startImageFrame!.width * keyWindow.frame.width)
            )
            inputAccessoryView!.alpha = 0.0
            inputAccessoryView?.isHidden = true
        case .landscapeLeft, .landscapeRight:
            zoomingImageView!.frame = CGRect(
                x: 0, y: 0,
                width: view.frame.width * 0.50,
                height: CGFloat(startImageFrame!.height / startImageFrame!.width * (keyWindow.frame.width * 0.50))
            )
            inputAccessoryView!.alpha = 0.0
            inputAccessoryView?.isHidden = true
        default:
            zoomingImageView!.frame = CGRect(
                x: 0, y: 0,
                width: view.frame.width,
                height: CGFloat(startImageFrame!.height / startImageFrame!.width * keyWindow.frame.width)
            )
            inputAccessoryView?.alpha = 0.0
            inputAccessoryView?.isHidden = true
        }
    }

    func handleZoomingImageViewWhanUpdateLayoutOfChatView() {
        if let bgView = backgroundImageView {
            if let keyWindow = view.window?.windowScene?.keyWindow {
                checkOrientationForSetupZoomingImageView(keyWindow: keyWindow)
                zoomingImageView!.center = bgView.center
                inputAccessoryView?.alpha = 0.0
                inputAccessoryView?.isHidden = true
            }
        }
    }
}
