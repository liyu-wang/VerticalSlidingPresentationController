//
//  VerticalSlidingPresentationController.swift
//
//
//  Created by Liyu Wang on 6/3/20.
//

import UIKit

protocol VerticalSlidingPresentationControllerDelegate: class {
    func presentationControllerDidCompletePresentation(_ controller: VerticalSlidingPresentationController)
    func presentationControllerDidReceiveTapOnDimmingView(_ controller: VerticalSlidingPresentationController)
    func presentationControllerPresentedViewDockingLocation(_ controller: VerticalSlidingPresentationController) -> VerticalPresentedViewDockingLocation
}

class VerticalSlidingPresentationController: UIPresentationController {
    weak var presentationDelegate: VerticalSlidingPresentationControllerDelegate?

    private let config: VerticalSlidingPresentationConfig
    private var dimmingView: UIView!
    private var presentationWrappingView: UIView!
    private var presentedViewTopPadding: CGFloat {
        return config.presentedViewTopPadding ?? presentingViewController.topBarHeight
    }

    override var presentedView: UIView? {
        return presentationWrappingView
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        let dockingLocation = presentationDelegate?.presentationControllerPresentedViewDockingLocation(self) ?? .lowerAnchor
        return frameOfPresentedViewInContainerView(at: dockingLocation)
    }

    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController, config: VerticalSlidingPresentationConfig) {
        self.config = config
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    override func presentationTransitionWillBegin() {
        guard
            let presentedViewControllerView = super.presentedView,
            let containerView = containerView
            else { return }

        presentationWrappingView = UIView(frame: frameOfPresentedViewInContainerView)

        let rounedCornerViewRect = presentationWrappingView.bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: -config.presentedViewCornerRadius, right: 0))
        let presentationRoundedCornerView = UIView(frame: rounedCornerViewRect)
        presentationRoundedCornerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        presentationRoundedCornerView.layer.cornerRadius = config.presentedViewCornerRadius
        presentationRoundedCornerView.layer.masksToBounds = true

        let wrapperViewRect = presentationRoundedCornerView.bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: config.presentedViewCornerRadius, right: 0))
        let presentedViewControllerWrapperView = UIView(frame: wrapperViewRect)
        presentedViewControllerWrapperView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        presentedViewControllerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        presentedViewControllerView.frame = presentedViewControllerWrapperView.bounds

        presentedViewControllerWrapperView.addSubview(presentedViewControllerView)
        presentationRoundedCornerView.addSubview(presentedViewControllerWrapperView)
        presentationWrappingView.addSubview(presentationRoundedCornerView)

        dimmingView = UIView(frame: containerView.bounds)
        dimmingView.backgroundColor = .black
        dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                action: #selector(VerticalSlidingPresentationController.dimmingViewTapped(sender:))))
        containerView.addSubview(dimmingView)

        guard let transitionCoordinator = presentingViewController.transitionCoordinator else {
            dimmingView.alpha = config.dimmingViewAlpha
            return
        }

        dimmingView.alpha = 0
        transitionCoordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = self.config.dimmingViewAlpha
        }, completion: nil)
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        if completed {
            presentationDelegate?.presentationControllerDidCompletePresentation(self)
        } else {
            presentationWrappingView = nil
            dimmingView = nil
        }
    }

    override func dismissalTransitionWillBegin() {
        guard let transitionCoordinator = presentingViewController.transitionCoordinator else {
            return
        }

        transitionCoordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0
        }, completion: nil)
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            presentationWrappingView = nil
            dimmingView = nil
        }
    }

    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        if container === presentedViewController {
            containerView?.setNeedsLayout()
        }
    }

    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        let size = super.size(forChildContentContainer: container, withParentContainerSize: parentSize)
        guard container === presentedViewController else {
            return size
        }
        return CGSize(width: size.width, height: size.height - presentedViewTopPadding)
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        if let containerViewBounds = containerView?.bounds {
            dimmingView.frame = containerViewBounds
        }
        presentationWrappingView.frame = frameOfPresentedViewInContainerView
    }

    @objc
    func dimmingViewTapped(sender: UITapGestureRecognizer) {
        presentationDelegate?.presentationControllerDidReceiveTapOnDimmingView(self)
    }

    func frameOfPresentedViewInContainerView(at position: VerticalPresentedViewDockingLocation) -> CGRect {
        guard let containerViewBounds = containerView?.bounds else { return .zero }
        let presentedViewContentSize = size(forChildContentContainer: presentedViewController,
                                            withParentContainerSize: containerViewBounds.size)
        var presentedViewControllerFrame = containerViewBounds
        presentedViewControllerFrame.size.height = presentedViewContentSize.height
        presentedViewControllerFrame.origin.y = containerViewBounds.maxY - (position == .lowerAnchor ? presentedViewContentSize.height * config.presentedViewVisiableHeightFractionAtLowerAnchor : presentedViewContentSize.height)
        return presentedViewControllerFrame
    }
}

extension VerticalSlidingPresentationController {
    var originYOfPresentedViewWhenDockingAtUpperAnchor: CGFloat {
        guard
            let containerView = containerView,
            let presentedView = presentedView
            else { return 0 }
        return containerView.bounds.height - presentedView.bounds.height
    }

    var centerYOfPresentedViewWhenDockingAtUpperAnchor: CGFloat {
        guard let presentedView = presentedView else { return 0 }
        return originYOfPresentedViewWhenDockingAtUpperAnchor + presentedView.bounds.height / 2
    }

    var anchorBouncingThreshold: CGFloat {
        guard let presentedView = presentedView else { return 0 }
        return originYOfPresentedViewWhenDockingAtUpperAnchor + presentedView.bounds.height * (1 - config.presentedViewVisiableHeightFractionAtLowerAnchor) / 2
    }

    var dismissalThreshold: CGFloat {
        guard let presentedView = presentedView else { return 0 }
        return originYOfPresentedViewWhenDockingAtUpperAnchor + presentedView.bounds.height * config.presentedViewHeightFractionForDismissal
    }
}
