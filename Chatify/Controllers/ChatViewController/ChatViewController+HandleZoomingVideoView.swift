//
//  ChatViewController+HandleZoomingVideoView.swift
//  Chatify
//
//  Created by Amr Mohamad on 02/12/2023.
//

import UIKit
import AVFoundation

protocol ZoomingVideoViewProtocol {
    var startVideoFrame: CGRect? { get set }
    var backgroundVideoView: UIVisualEffectView? { get set }
    var startingVideoView: UIView? { get set }
    var zoomingVideoView: UIView? { get set }
    
    func performZoomInTapGestureForVideoMessage(_ videoView: UIView, currentCell cell: MessageTableViewCell)
    func performZoomOutTapGestureForVideoMessage(tapGesture: UITapGestureRecognizer)
    func checkOrientationForSetupZoomingVideoView(keyWindow: UIWindow)
    func handleZoomingVideoViewWhenUpdateLayoutOfCell()
}

extension ChatViewController: ZoomingVideoViewProtocol {
    
    // Properties from the protocol
    private struct AssociatedKeysOfZoomingVideoView {
        static var startVideoFrame = "startVideoFrame"
        static var backgroundVideoView = "backgroundVideoView"
        static var startingVideoView = "startingVideoView"
        static var zoomingVideoView = "zoomingVideoView"
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
    var startingVideoView: UIView?{
        get {
            return objc_getAssociatedObject(self, &AssociatedKeysOfZoomingVideoView.startingVideoView) as? UIView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeysOfZoomingVideoView.startingVideoView, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    var zoomingVideoView: UIView?{
        get {
            return objc_getAssociatedObject(self, &AssociatedKeysOfZoomingVideoView.zoomingVideoView) as? UIView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeysOfZoomingVideoView.zoomingVideoView, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    // Additional properties for video handling
    private struct AssociatedKeysOfVideoPlayer {
        static var player = "player"
        static var playerLayer = "playerLayer"
        // Add other associated keys as needed
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
    
        

    // ... Other properties and methods specific to your cell
    
    // Implement protocol methods
    
    func performZoomInTapGestureForVideoMessage(_ videoView: UIView, currentCell cell: MessageTableViewCell) {
        startingVideoView = videoView
        // Pause the video playback during zoom-in
        player?.pause()

        // Set up the zoomed-in view
        // ...

        // Animate the transition
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1,
            options: .curveEaseOut,
            animations: {
                self.checkOrientationForSetupZoomingVideoView(keyWindow: UIApplication.shared.windows.first!)
                // Additional animation setup
            },
            completion: nil
        )
    }

    func performZoomOutTapGestureForVideoMessage(tapGesture: UITapGestureRecognizer) {
        // Resume video playback during zoom-out
        player?.play()

        // Animate the transition back to the original state
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1,
            options: .curveEaseIn,
            animations: {
                // Additional animation setup
            },
            completion: { complete in
                // Completion handling
            }
        )
    }

    func checkOrientationForSetupZoomingVideoView(keyWindow: UIWindow) {
        // Adjust the frame of the zoomed-in view based on the device orientation
        // ...
    }

    func handleZoomingVideoViewWhenUpdateLayoutOfCell() {
        // Handle updates when the layout of the cell changes during zooming
        // ...
    }

    // Additional methods for video playback control, setup, etc.
    // ...
}
