//
//  VerticalSlidingPresentedViewControllerProtocol.swift
//  VerticalSlidingPresentationController
//
//  Created by Liyu Wang on 26/10/21.
//

import UIKit

public protocol VerticalSlidingPresentedViewControllerProtocol: UIScrollViewDelegate, VerticalSlidingInteractiveTransitionControllerDelegate {
    var headerView: UIView { get }
    var scrollableView: UIScrollView { get }
    var dockingLocation: VerticalPresentedViewDockingLocation { get set }
    var lastContentOffsetY: CGFloat { get set }
    var isScrollBlocked: Bool { get set }
    func scrollableViewDidScroll(_ scrollView: UIScrollView)
}

extension VerticalSlidingPresentedViewControllerProtocol {
    /// FIXME: Unfortunately, @objc functions may not currently be in protocol extensions
    /// https://stackoverflow.com/questions/39487168/non-objc-method-does-not-satisfy-optional-requirement-of-objc-protocol
    /// We have to call scrollableViewDidScroll inside scrollViewDidScroll
    public func scrollableViewDidScroll(_ scrollView: UIScrollView) {
        if isScrollBlocked {
            if dockingLocation == .upperAnchor && scrollView.contentOffset.y > lastContentOffsetY {
                isScrollBlocked = false
            }
        } else {
            if scrollView.contentOffset.y <= 0 {
                isScrollBlocked = true
                lastContentOffsetY = 0
            }
        }
        guard isScrollBlocked else {
            lastContentOffsetY = scrollView.contentOffset.y
            return
        }
        if scrollView.contentOffset.y != lastContentOffsetY {
            scrollView.contentOffset.y = lastContentOffsetY
        }
    }
}

extension VerticalSlidingPresentedViewControllerProtocol {
    public func interactiveTransitionController(_ controller: VerticalSlidingInteractiveTransitionController, didDockAt location: VerticalPresentedViewDockingLocation) {
        dockingLocation = location
        switch dockingLocation {
        case .none, .lowerAnchor:
            isScrollBlocked = true
        case .upperAnchor:
            isScrollBlocked = false
        }
        scrollableView.showsVerticalScrollIndicator = !isScrollBlocked
    }

    public func interactiveTransitionController(_ controller: VerticalSlidingInteractiveTransitionController, shouldAlwaysHandleGestureBeganAt point: CGPoint) -> Bool {
        return headerView.frame.contains(point)
    }

    public func interactiveTransitionControllerShouldHandleGestureUpdate(_ controller: VerticalSlidingInteractiveTransitionController) -> Bool {
        return isScrollBlocked
    }
}
