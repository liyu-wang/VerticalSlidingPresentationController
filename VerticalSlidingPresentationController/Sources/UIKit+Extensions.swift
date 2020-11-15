//
//  UIkit+Extensions.swift
//  
//
//  Created by Liyu Wang on 10/3/20.
//

import UIKit

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}

extension UIViewController {
    @objc var topBarHeight: CGFloat {
        if #available(*, iOS 13) {
            return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) +
                (self.navigationController?.navigationBar.frame.height ?? 0.0)
        } else {
            return UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.frame.height ?? 0)
        }
    }
}

extension UINavigationController {
    override var topBarHeight: CGFloat {
        if #available(*, iOS 13) {
            return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) + navigationBar.frame.height
        } else {
            return UIApplication.shared.statusBarFrame.height + navigationBar.frame.height
        }
    }
}
