//
//  ChatViewController+HandleZoomingVideoView.swift
//  Chatify
//
//  Created by Amr Mohamad on 02/12/2023.
//

import UIKit
import AVKit
import AVFoundation

protocol ZoomingVideoViewProtocol {
    var startVideoFrame     : CGRect? { get set }
    var backgroundVideoView : UIVisualEffectView? { get set }
    var startingVideoView   : UIImageView? { get set }
    var zoomingVideoView    : UIImageView? { get set }
    var isPlaying           : Bool? { get set }
    
    func performZoomInTapGestureForVideoMessage(_ videoView: UIImageView, currentCell cell: MessageTableViewCell)
    func performZoomOutTapGestureForVideoMessage(tapGesture: UITapGestureRecognizer)
    func checkOrientationForSetupZoomingVideoView(keyWindow: UIWindow)
    func handleZoomingVideoViewWhenUpdateLayoutOfCell()
}

extension ChatViewController: ZoomingVideoViewProtocol {
    
    // Properties from the protocol
    private struct AssociatedKeysOfZoomingVideoView {
        static var startVideoFrame     = "startVideoFrame"
        static var backgroundVideoView = "backgroundVideoView"
        static var startingVideoView   = "startingVideoView"
        static var zoomingVideoView    = "zoomingVideoView"
        static var isPlaying           = "isPlaying"
    }
    var startVideoFrame: CGRect?{
        get {
            return objc_getAssociatedObject(self, &AssociatedKeysOfZoomingVideoView.startVideoFrame) as? CGRect
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeysOfZoomingVideoView.startVideoFrame, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    var backgroundVideoView: UIVisualEffectView?{
        get {
            return objc_getAssociatedObject(self, &AssociatedKeysOfZoomingVideoView.backgroundVideoView) as? UIVisualEffectView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeysOfZoomingVideoView.backgroundVideoView, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    var startingVideoView: UIImageView?{
        get {
            return objc_getAssociatedObject(self, &AssociatedKeysOfZoomingVideoView.startingVideoView) as? UIImageView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeysOfZoomingVideoView.startingVideoView, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    var zoomingVideoView: UIImageView?{
        get {
            return objc_getAssociatedObject(self, &AssociatedKeysOfZoomingVideoView.zoomingVideoView) as? UIImageView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeysOfZoomingVideoView.zoomingVideoView, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    var isPlaying: Bool?{
        get {
            return objc_getAssociatedObject(self, &AssociatedKeysOfZoomingVideoView.isPlaying) as? Bool
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeysOfZoomingVideoView.isPlaying, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    // Additional properties for video handling
    private struct AssociatedKeysOfVideoPlayer {
        static var player          = "player"
        static var playerLayer     = "playerLayer"
        static var playPauseButton = "playPauseButton"
    }
    private var player: AVPlayer? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeysOfVideoPlayer.player) as? AVPlayer
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeysOfVideoPlayer.player, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    private var playerLayer: AVPlayerLayer? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeysOfVideoPlayer.playerLayer) as? AVPlayerLayer
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeysOfVideoPlayer.playerLayer, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    private var playPauseButton: UIButton? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeysOfVideoPlayer.playPauseButton) as? UIButton
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeysOfVideoPlayer.playPauseButton, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
        

    // ... Other properties and methods specific to your cell
    
    // Implement protocol methods
    
    func performZoomInTapGestureForVideoMessage(_ videoView: UIImageView, currentCell cell: MessageTableViewCell) {
        startingVideoView = videoView
        self.startVideoFrame = startingVideoView!.convert(videoView.frame, to: nil)

        // Set up the zoomed-in view
        self.zoomingVideoView = UIImageView(
            frame: startVideoFrame!
        )
        zoomingVideoView!.image = startingVideoView!.image
        zoomingVideoView!.isUserInteractionEnabled = true
        zoomingVideoView?.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(performZoomOutTapGestureForVideoMessage)
            )
        )
        if let keyWindow = self.view.window?.windowScene?.keyWindow{
            backgroundVideoView = UIVisualEffectView(frame: keyWindow.frame)
            backgroundVideoView!.translatesAutoresizingMaskIntoConstraints = false
            backgroundVideoView!.effect = UIBlurEffect(style: .systemUltraThinMaterial)
            backgroundVideoView!.alpha = 0
            keyWindow.addSubview(backgroundVideoView!)
            NSLayoutConstraint.activate([
                backgroundVideoView!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                backgroundVideoView!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                backgroundVideoView!.topAnchor.constraint(equalTo: self.view.topAnchor),
                backgroundVideoView!.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
            // Animate the transition
            keyWindow.addSubview(zoomingVideoView!)
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 1,
                options: .curveEaseOut) {
                    self.checkOrientationForSetupZoomingVideoView(keyWindow: keyWindow)
                    // Additional animation setup
                    self.startingVideoView?.alpha = 0
                    self.backgroundVideoView!.alpha = 1
                    self.inputAccessoryView?.alpha = 0
                    self.inputAccessoryView?.isHidden = true
                    self.zoomingVideoView!.center = self.backgroundVideoView!.center
                } completion: { [weak self] isComplate in
                    guard let self = self else {return}
                    self.isPlaying = false
                    if isComplate {
                        self.setupPlayerLayer(cell: cell)
                    }
                }
        }
    }
    private func setupPlayerLayer(cell: MessageTableViewCell) {
        if let videoURL = cell.videoURL {
            player = AVPlayer(url: videoURL)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = zoomingVideoView!.bounds
            zoomingVideoView?.layer.addSublayer(playerLayer!)

            playPauseButton = UIButton(type: .system)
            playPauseButton!.setImage(UIImage(systemName: "play.fill"), for: .normal)
            playPauseButton!.tintColor = .white
            playPauseButton!.addTarget(self, action: #selector(handlePlayingAndPausingVideo), for: .touchUpInside)
            playPauseButton!.translatesAutoresizingMaskIntoConstraints = false

            zoomingVideoView!.addSubview(playPauseButton!)
            NSLayoutConstraint.activate([
                playPauseButton!.centerXAnchor.constraint(equalTo: zoomingVideoView!.centerXAnchor),
                playPauseButton!.centerYAnchor.constraint(equalTo: zoomingVideoView!.centerYAnchor),
                playPauseButton!.widthAnchor.constraint(equalToConstant: 50),
                playPauseButton!.heightAnchor.constraint(equalToConstant: 50),
            ])
        }
    }
    @objc func handlePlayingAndPausingVideo(){
        print("PlayingAndPausingVideo")
        if isPlaying! {
            print(isPlaying)
            player?.pause()
            playPauseButton!.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }else{
            print(isPlaying)
            player?.play()
            playPauseButton!.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
        isPlaying = !isPlaying!
    }
    
    @objc func performZoomOutTapGestureForVideoMessage(tapGesture: UITapGestureRecognizer) {
        // Resume video playback during zoom-out
        player?.pause()
        if let zoomingOutVideoView = tapGesture.view as? UIImageView{
            // Animate the transition back to the original state
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 1,
                options: .curveEaseIn){
                    // Additional animation setup
                    self.playerLayer?.isHidden = true
                    zoomingOutVideoView.frame = self.startVideoFrame!
                    zoomingOutVideoView.layer.cornerRadius = 16
                    zoomingOutVideoView.layer.masksToBounds = true
                    self.backgroundVideoView?.alpha = 0
                    self.inputAccessoryView?.alpha = 1
                    self.inputAccessoryView?.isHidden = false
                } completion: { complete in
                    // Completion handling
                    zoomingOutVideoView.removeFromSuperview()
                    self.startingVideoView?.alpha = 1
                    self.backgroundVideoView?.removeFromSuperview()
                    self.backgroundVideoView = nil
                }
        }
    }

    internal func checkOrientationForSetupZoomingVideoView(keyWindow: UIWindow) {
        // Adjust the frame of the zoomed-in view based on the device orientation
        switch UIDevice.current.orientation {
        case .portrait :
            self.zoomingVideoView!.frame = CGRect(
                x: 0, y: 0,
                width: self.view.frame.width,
                height: CGFloat(self.startVideoFrame!.height/self.startVideoFrame!.width * keyWindow.frame.width)
            )
            self.inputAccessoryView!.alpha = 0.0
            self.inputAccessoryView?.isHidden = true
        case .landscapeLeft, .landscapeRight :
            self.zoomingVideoView!.frame = CGRect(
                x: 0, y: 0,
                width: self.view.frame.width * 0.50,
                height: CGFloat(self.startVideoFrame!.height/self.startVideoFrame!.width * (keyWindow.frame.width * 0.50))
            )
            self.inputAccessoryView!.alpha = 0.0
            self.inputAccessoryView?.isHidden = true
        default:
            self.zoomingVideoView!.frame = CGRect(
                x: 0, y: 0,
                width: self.view.frame.width,
                height: CGFloat(self.startVideoFrame!.height/self.startVideoFrame!.width * keyWindow.frame.width)
            )
            self.inputAccessoryView?.alpha = 0.0
            self.inputAccessoryView?.isHidden = true
        }
    }
    func handleZoomingVideoViewWhenUpdateLayoutOfCell() {
        // Handle updates when the layout of the cell changes during zooming
        if let bgView = backgroundVideoView {
            if let keyWindow = self.view.window?.windowScene?.keyWindow{
                checkOrientationForSetupZoomingVideoView(keyWindow: keyWindow)
                self.zoomingVideoView!.center = bgView.center
                self.inputAccessoryView?.alpha = 0.0
                self.inputAccessoryView?.isHidden = true
            }
        }
    }

    // Additional methods for video playback control, setup, etc.
    // ...
}
