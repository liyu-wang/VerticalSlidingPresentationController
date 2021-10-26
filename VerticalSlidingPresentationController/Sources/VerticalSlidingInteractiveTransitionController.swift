//
//  VerticalSlidingInteractiveTransitionController.swift
//  
//
//  Created by Liyu Wang on 6/3/20.
//

import UIKit

public protocol VerticalSlidingInteractiveTransitionControllerDelegate: AnyObject {
    func interactiveTransitionController(_ controller: VerticalSlidingInteractiveTransitionController,
                                         didDockAt location: VerticalPresentedViewDockingLocation)
    func interactiveTransitionController(_ controller: VerticalSlidingInteractiveTransitionController,
                                         shouldAlwaysHandleGestureBeganAt point: CGPoint) -> Bool
    func interactiveTransitionControllerShouldHandleGestureUpdate(_ controller: VerticalSlidingInteractiveTransitionController) -> Bool
}

public enum VerticalPresentedViewDockingLocation {
    case none
    case upperAnchor
    case lowerAnchor
}

public struct VerticalSlidingPresentationConfig {
    public static let defaultConfig = VerticalSlidingPresentationConfig()

    public var dismissVelocityThreshold: CGFloat = 3000
    public var resetLocationAnimationDuration: TimeInterval = 0.2

    public var presentedViewTopPadding: CGFloat?
    public var presentedViewCornerRadius: CGFloat = 16
    public var dimmingViewAlpha: CGFloat = 0.5
    public var presentedViewVisiableHeightFractionAtLowerAnchor: CGFloat = 2 / 3
    public var presentedViewHeightFractionForDismissal: CGFloat = 1 / 2
}

public class VerticalSlidingInteractiveTransitionController: NSObject {
    weak var delegate: VerticalSlidingInteractiveTransitionControllerDelegate?
    private let config: VerticalSlidingPresentationConfig
    private let presentationController: VerticalSlidingPresentationController
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var initialPresentedViewCenter: CGPoint!
    private var gestureBeganWhenDockingAtUpperAnchor: Bool!
    private var shouldAlwaysHandleGesture: Bool!
    private var presentedViewOffsetY: CGFloat = 0
    private var presentedViewDockingLocation: VerticalPresentedViewDockingLocation = .none {
        didSet {
            delegate?.interactiveTransitionController(self, didDockAt: presentedViewDockingLocation)
        }
    }

    public init(presentedViewController: UIViewController & VerticalSlidingInteractiveTransitionControllerDelegate,
         presentingViewController: UIViewController,
         config: VerticalSlidingPresentationConfig = VerticalSlidingPresentationConfig.defaultConfig) {
        self.config = config
        presentationController = VerticalSlidingPresentationController(presentedViewController: presentedViewController,
                                                                       presenting: presentingViewController,
                                                                       config: config)
        super.init()
        delegate = presentedViewController
        presentationController.presentationDelegate = self
        panGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                      action: #selector(VerticalSlidingInteractiveTransitionController.twoPhaseSlidingInteractiveTransition(gesture:)))
        panGestureRecognizer.delegate = self
        presentedViewDockingLocation = .lowerAnchor
        presentedViewController.view.addGestureRecognizer(panGestureRecognizer)
    }
}

private extension VerticalSlidingInteractiveTransitionController {
    @objc
    func twoPhaseSlidingInteractiveTransition(gesture: UIPanGestureRecognizer) {
        guard let presentedView = presentationController.presentedView else { return }
        let translation = gesture.translation(in: presentationController.containerView)
        switch gesture.state {
        case .began:
            initialPresentedViewCenter = presentedView.center
            gestureBeganWhenDockingAtUpperAnchor = initialPresentedViewCenter.y == presentationController.centerYOfPresentedViewWhenDockingAtUpperAnchor
            let point = gesture.location(in: gesture.view)
            shouldAlwaysHandleGesture = delegate?.interactiveTransitionController(self, shouldAlwaysHandleGestureBeganAt: point) ?? true
            presentedViewOffsetY = 0
        case .changed:
            if !shouldAlwaysHandleGesture {
                guard delegate?.interactiveTransitionControllerShouldHandleGestureUpdate(self) == true else {
                    if gestureBeganWhenDockingAtUpperAnchor {
                        gesture.setTranslation(CGPoint(x: 0, y: 0), in: presentationController.containerView)
                    }
                    return
                }
            }
            var newCenterY = initialPresentedViewCenter.y + translation.y + presentedViewOffsetY
            if newCenterY <= presentationController.centerYOfPresentedViewWhenDockingAtUpperAnchor {
                newCenterY = presentationController.centerYOfPresentedViewWhenDockingAtUpperAnchor
                if presentedViewDockingLocation != .upperAnchor {
                    presentedViewDockingLocation = .upperAnchor
                    presentedViewOffsetY = newCenterY - initialPresentedViewCenter.y
                    gestureBeganWhenDockingAtUpperAnchor = true
                }
            } else {
                if presentedViewDockingLocation != .none {
                    presentedViewDockingLocation = .none
                }
            }
            presentedView.center = CGPoint(x: initialPresentedViewCenter.x,
                                          y: newCenterY)
        case .ended:
            let velocity = gesture.velocity(in: gesture.view).y
            if velocity >= config.dismissVelocityThreshold {
                presentationController.presentingViewController.dismiss(animated: true, completion: nil)
            }

            switch presentedView.frame.origin.y {
            case presentationController.originYOfPresentedViewWhenDockingAtUpperAnchor:
                break
            case presentationController.originYOfPresentedViewWhenDockingAtUpperAnchor..<presentationController.anchorBouncingThreshold:
                animate(presentedView, to: .upperAnchor)
            case presentationController.anchorBouncingThreshold..<presentationController.dismissalThreshold:
                animate(presentedView, to: .lowerAnchor)
            default:
                presentationController.presentingViewController.dismiss(animated: true, completion: nil)
            }
        default:
            break
        }
    }

    func animate(_ view: UIView, to location: VerticalPresentedViewDockingLocation) {
        UIView.animate(withDuration: config.resetLocationAnimationDuration, animations: {
            view.center = self.presentationController.frameOfPresentedViewInContainerView(at: location).center
        }, completion: {_ in
            if self.presentedViewDockingLocation != location {
                self.presentedViewDockingLocation = location
            }
        })
    }
}

extension VerticalSlidingInteractiveTransitionController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        let velocity = panGestureRecognizer.velocity(in: panGestureRecognizer.view)
        return abs(velocity.y) > abs(velocity.x)
    }
}

extension VerticalSlidingInteractiveTransitionController: UIViewControllerTransitioningDelegate {
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        assert(presentationController.presentedViewController === presented, "Incorrect presentatedViewController has been used.")
        return presentationController
    }

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return VerticalSlidingPresentAnimator()
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return VerticalSlidingDismissAnimator()
    }
}

extension VerticalSlidingInteractiveTransitionController: VerticalSlidingPresentationControllerDelegate {
    func presentationControllerDidCompletePresentation(_ controller: VerticalSlidingPresentationController) {
        delegate?.interactiveTransitionController(self, didDockAt: presentedViewDockingLocation)
    }

    func presentationControllerDidReceiveTapOnDimmingView(_ controller: VerticalSlidingPresentationController) {
        presentationController.presentingViewController.dismiss(animated: true, completion: nil)
    }

    func presentationControllerPresentedViewDockingLocation(_ controller: VerticalSlidingPresentationController) -> VerticalPresentedViewDockingLocation {
        return presentedViewDockingLocation
    }
}
