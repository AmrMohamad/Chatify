//
//  ChatViewController+HandleZoomingView.swift
//  Chatify
//
//  Created by Amr Mohamad on 26/11/2023.
//

import UIKit

protocol ZoomingViewProtocol {
    var startFrame        : CGRect? { get set }
    var backgroundView    : UIVisualEffectView? { get set }
    var startingImageView : UIImageView? { get set }
    var zoomingView       : UIImageView? { get set }
    
    func performZoomInTapGestureForUIImageViewOfImageMessage(_ imageView: UIImageView,currentCell cell:MessageTableViewCell)
    func performZoomOutTapGestureForUIImageViewOfImageMessage(tapGesture: UITapGestureRecognizer)
    func checkOrientationForSetupZoomingView(keyWindow: UIWindow)
    func handleZoomingViewWhanUpdateLayoutOfChatView()
}
extension ChatViewController: ZoomingViewProtocol {
    
    private struct AssociatedKeys {
        static var startFrame = "startFrame"
        static var backgroundView = "backgroundView"
        static var startingImageView = "startingImageView"
        static var zoomingView = "zoomingView"
    }
    
    var startFrame: CGRect? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.startFrame) as? CGRect
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.startFrame, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var backgroundView: UIVisualEffectView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.backgroundView) as? UIVisualEffectView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.backgroundView, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var startingImageView: UIImageView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.startingImageView) as? UIImageView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.startingImageView, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var zoomingView: UIImageView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.zoomingView) as? UIImageView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.zoomingView, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }


//    var startFrame        : CGRect?
//    var backgroundView    : UIVisualEffectView?
//    var startingImageView : UIImageView?
//    var zoomingView       : UIImageView?
    
    func performZoomInTapGestureForUIImageViewOfImageMessage(_ imageView: UIImageView,currentCell cell:MessageTableViewCell){
        startingImageView = imageView
        self.startFrame = startingImageView!.convert(imageView.frame, to: nil)
        dump(startFrame)
        self.zoomingView = UIImageView(
            frame: startFrame!
        )
        zoomingView!.image = startingImageView!.image
        zoomingView!.isUserInteractionEnabled = true
        zoomingView!.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(performZoomOutTapGestureForUIImageViewOfImageMessage)
            )
        )
        if let keyWindow = self.view.window?.windowScene?.keyWindow{
            self.backgroundView = UIVisualEffectView(frame: keyWindow.frame)
            self.backgroundView!.translatesAutoresizingMaskIntoConstraints = false
            self.backgroundView!.effect = UIBlurEffect(style: .systemUltraThinMaterial)
            self.backgroundView!.alpha = 0
            keyWindow.addSubview(self.backgroundView!)
            NSLayoutConstraint.activate([
                self.backgroundView!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.backgroundView!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.backgroundView!.topAnchor.constraint(equalTo: self.view.topAnchor),
                self.backgroundView!.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
            keyWindow.addSubview(zoomingView!)
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 1,
                options: .curveEaseOut,
                animations: {
                    self.checkOrientationForSetupZoomingView(keyWindow: keyWindow)
                    self.startingImageView?.alpha = 0
                    self.backgroundView!.alpha = 1
                    self.inputAccessoryView?.alpha = 0
                    self.inputAccessoryView?.isHidden = true
                    self.zoomingView!.center = self.backgroundView!.center
                    
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
                    zoomingOutView.frame = self.startFrame!
                    zoomingOutView.layer.cornerRadius = 16
                    zoomingOutView.layer.masksToBounds = true
                    self.backgroundView?.alpha = 0
                    self.inputAccessoryView?.alpha = 1
                    self.inputAccessoryView?.isHidden = false
//                    cell.bubbleView.alpha = 1
                } completion: { complete in
                    print(complete)
                    zoomingOutView.removeFromSuperview()
                    self.startingImageView?.alpha = 1
                    self.backgroundView?.removeFromSuperview()
                    self.backgroundView = nil
                }
        }
    }
    
    internal func checkOrientationForSetupZoomingView(keyWindow: UIWindow){
        switch UIDevice.current.orientation {
        case .portrait :
            self.zoomingView!.frame = CGRect(
                x: 0, y: 0,
                width: self.view.frame.width,
                height: CGFloat(self.startFrame!.height/self.startFrame!.width * keyWindow.frame.width)
            )
            self.inputAccessoryView!.alpha = 0.0
            self.inputAccessoryView?.isHidden = true
        case .landscapeLeft, .landscapeRight :
            self.zoomingView!.frame = CGRect(
                x: 0, y: 0,
                width: self.view.frame.width * 0.50,
                height: CGFloat(self.startFrame!.height/self.startFrame!.width * (keyWindow.frame.width * 0.50))
            )
            self.inputAccessoryView!.alpha = 0.0
            self.inputAccessoryView?.isHidden = true
        default:
            self.zoomingView!.frame = CGRect(
                x: 0, y: 0,
                width: self.view.frame.width,
                height: CGFloat(self.startFrame!.height/self.startFrame!.width * keyWindow.frame.width)
            )
            self.inputAccessoryView?.alpha = 0.0
            self.inputAccessoryView?.isHidden = true
        }
    }
    
    func handleZoomingViewWhanUpdateLayoutOfChatView(){
        if let bgView = backgroundView {
            if let keyWindow = self.view.window?.windowScene?.keyWindow{
                checkOrientationForSetupZoomingView(keyWindow: keyWindow)
                self.zoomingView!.center = bgView.center
                self.inputAccessoryView?.alpha = 0.0
                self.inputAccessoryView?.isHidden = true
            }
        }
    }
}
