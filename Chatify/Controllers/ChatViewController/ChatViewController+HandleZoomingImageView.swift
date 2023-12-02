//
//  ChatViewController+HandleZoomingView.swift
//  Chatify
//
//  Created by Amr Mohamad on 26/11/2023.
//

import UIKit

protocol ZoomingImageViewProtocol {
    var startImageFrame   : CGRect? { get set }
    var backgroundImageView    : UIVisualEffectView? { get set }
    var startingImageView : UIImageView? { get set }
    var zoomingImageView  : UIImageView? { get set }
    
    func performZoomInTapGestureForUIImageViewOfImageMessage(_ imageView: UIImageView,currentCell cell:MessageTableViewCell)
    func performZoomOutTapGestureForUIImageViewOfImageMessage(tapGesture: UITapGestureRecognizer)
    func checkOrientationForSetupZoomingImageView(keyWindow: UIWindow)
    func handleZoomingImageViewWhanUpdateLayoutOfChatView()
}
extension ChatViewController: ZoomingImageViewProtocol {
    
    private struct AssociatedKeysOfZoomingImageView {
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

    func performZoomInTapGestureForUIImageViewOfImageMessage(_ imageView: UIImageView,currentCell cell:MessageTableViewCell){
        startingImageView = imageView
        self.startImageFrame = startingImageView!.convert(imageView.frame, to: nil)
        dump(startImageFrame)
        self.zoomingImageView = UIImageView(
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
        if let keyWindow = self.view.window?.windowScene?.keyWindow{
            self.backgroundImageView = UIVisualEffectView(frame: keyWindow.frame)
            self.backgroundImageView!.translatesAutoresizingMaskIntoConstraints = false
            self.backgroundImageView!.effect = UIBlurEffect(style: .systemUltraThinMaterial)
            self.backgroundImageView!.alpha = 0
            keyWindow.addSubview(self.backgroundImageView!)
            NSLayoutConstraint.activate([
                self.backgroundImageView!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.backgroundImageView!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.backgroundImageView!.topAnchor.constraint(equalTo: self.view.topAnchor),
                self.backgroundImageView!.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
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
    
    @objc func performZoomOutTapGestureForUIImageViewOfImageMessage(tapGesture: UITapGestureRecognizer){
        if let zoomingOutView = tapGesture.view as? UIImageView{
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 1,
                options: .curveEaseIn) {
                    zoomingOutView.frame = self.startImageFrame!
                    zoomingOutView.layer.cornerRadius = 16
                    zoomingOutView.layer.masksToBounds = true
                    self.backgroundImageView?.alpha = 0
                    self.inputAccessoryView?.alpha = 1
                    self.inputAccessoryView?.isHidden = false
                } completion: { complete in
                    print(complete)
                    zoomingOutView.removeFromSuperview()
                    self.startingImageView?.alpha = 1
                    self.backgroundImageView?.removeFromSuperview()
                    self.backgroundImageView = nil
                }
        }
    }
    
    internal func checkOrientationForSetupZoomingImageView(keyWindow: UIWindow){
        switch UIDevice.current.orientation {
        case .portrait :
            self.zoomingImageView!.frame = CGRect(
                x: 0, y: 0,
                width: self.view.frame.width,
                height: CGFloat(self.startImageFrame!.height/self.startImageFrame!.width * keyWindow.frame.width)
            )
            self.inputAccessoryView!.alpha = 0.0
            self.inputAccessoryView?.isHidden = true
        case .landscapeLeft, .landscapeRight :
            self.zoomingImageView!.frame = CGRect(
                x: 0, y: 0,
                width: self.view.frame.width * 0.50,
                height: CGFloat(self.startImageFrame!.height/self.startImageFrame!.width * (keyWindow.frame.width * 0.50))
            )
            self.inputAccessoryView!.alpha = 0.0
            self.inputAccessoryView?.isHidden = true
        default:
            self.zoomingImageView!.frame = CGRect(
                x: 0, y: 0,
                width: self.view.frame.width,
                height: CGFloat(self.startImageFrame!.height/self.startImageFrame!.width * keyWindow.frame.width)
            )
            self.inputAccessoryView?.alpha = 0.0
            self.inputAccessoryView?.isHidden = true
        }
    }
    
    func handleZoomingImageViewWhanUpdateLayoutOfChatView(){
        if let bgView = backgroundImageView {
            if let keyWindow = self.view.window?.windowScene?.keyWindow{
                checkOrientationForSetupZoomingImageView(keyWindow: keyWindow)
                self.zoomingImageView!.center = bgView.center
                self.inputAccessoryView?.alpha = 0.0
                self.inputAccessoryView?.isHidden = true
            }
        }
    }
}
