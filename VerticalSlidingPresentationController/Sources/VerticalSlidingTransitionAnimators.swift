//
//  VerticalSlidingPresentAnimator.swift
//  
//
//  Created by Liyu Wang on 6/3/20.
//

import UIKit

private enum Constants {
    static let animationDuration: TimeInterval = 0.4
}

class VerticalSlidingPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionContext?.isAnimated == true ? Constants.animationDuration : 0
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toViewController = transitionContext.viewController(forKey: .to),
            let toView = transitionContext.view(forKey: .to)
            else {
                transitionContext.completeTransition(true)
                return
        }

        let containerView = transitionContext.containerView
        var toViewInitialFrame = transitionContext.initialFrame(for: toViewController)
        let toViewFinalFrame = transitionContext.finalFrame(for: toViewController)

        containerView.addSubview(toView)

        toViewInitialFrame.origin = CGPoint(x: containerView.bounds.minX, y: containerView.bounds.maxY)
        toViewInitialFrame.size = toViewFinalFrame.size
        toView.frame = toViewInitialFrame

        let tansitionDuration = transitionDuration(using: transitionContext)
        UIView.animate(
            withDuration: tansitionDuration,
            animations: {
                toView.frame = toViewFinalFrame
            },
            completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
}

class VerticalSlidingDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionContext?.isAnimated == true ? Constants.animationDuration : 0
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromViewController = transitionContext.viewController(forKey: .from),
            let fromView = transitionContext.view(forKey: .from)
            else {
                transitionContext.completeTransition(true)
                return
        }

        var fromViewFinalFrame = transitionContext.finalFrame(for: fromViewController)
        fromViewFinalFrame = fromView.frame.offsetBy(dx: 0, dy: fromView.frame.height)

        let tansitionDuration = transitionDuration(using: transitionContext)
        UIView.animate(
            withDuration: tansitionDuration,
            delay: 0,
            options: transitionContext.isInteractive ? .curveLinear : [],
            animations: {
                fromView.frame = fromViewFinalFrame
            },
            completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
}
