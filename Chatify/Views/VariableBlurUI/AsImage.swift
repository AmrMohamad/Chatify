//
//  AsImage.swift
//  Chatify
//
//  Created by Amr Mohamad on 19/10/2023.
//

//  AsImage.swift
//  Todoey-UIKit-iOS16
//
//  Created by Amr Mohamad on 01/09/2023.
//

import UIKit
import SwiftUI

extension UIHostingController {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: self.view.bounds.size)
        return renderer.image { context in
            self.view.layer.render(in: context.cgContext)
        }
    }
}

extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        return renderer.image { context in
            layer.render(in: context.cgContext)
        }
    }
}
