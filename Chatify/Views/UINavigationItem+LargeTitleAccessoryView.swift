//
//  UINavigationItem+LargeTitleAccessoryView.swift
//  Chatify
//
//  Created by Amr Mohamad on 26/11/2023.
//

import UIKit

class ProfileButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupProfileButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupProfileButton() {
//        let image: UIImage = .profile.withRenderingMode(.alwaysOriginal)
        let image: UIImage = UIImage(systemName: "person")!.withRenderingMode(.alwaysOriginal)
        setImage(image, for: .normal)
    }
}



extension UINavigationItem {
    var largeTitleAccessoryView: UIView? {
        get {
            return value(forKey: "_largeTitleAccessoryView") as? UIView
        } set {
            perform(Selector(("_setLargeTitleAccessoryView:")), with: newValue)
        }
    }
    
    var alignLargeTitleAccessoryViewToBaseline: Bool {
        get {
            return value(forKey: "_alignLargeTitleAccessoryViewToBaseline") as? Bool ?? true
        } set {
            setValue(newValue, forKey: "_alignLargeTitleAccessoryViewToBaseline")
        }
    }
}
