//
//  VerticalSlidingPresentedViewController.swift
//  VerticalSlidingPresentationController
//
//  Created by Liyu Wang on 17/11/20.
//

import UIKit

open class VerticalSlidingPresentedViewController: UIViewController {
    open var headerView: UIView {
        return header
    }

    open var scrollView: UIScrollView {
        return scrollableView
    }

    private lazy var header: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var scrollableView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private var dockingLocation: VerticalPresentedViewDockingLocation = .none {
        didSet {
            switch dockingLocation {
            case .none, .lowerAnchor:
                isScrollBlocked = true
            case .upperAnchor:
                isScrollBlocked = false
            }
            scrollView.showsVerticalScrollIndicator = !isScrollBlocked
        }
    }
    private var lastContentOffsetY: CGFloat = 0
    private var isScrollBlocked = true

    open override func loadView() {
        super.loadView()
        loadCustomViews()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension VerticalSlidingPresentedViewController {
    @objc
    open func loadCustomViews() {
        view.addSubview(headerView)
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}

extension VerticalSlidingPresentedViewController: UIScrollViewDelegate {
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
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

extension VerticalSlidingPresentedViewController: VerticalSlidingInteractiveTransitionControllerDelegate {
    public func interactiveTransitionController(_ controller: VerticalSlidingInteractiveTransitionController, didDockAt location: VerticalPresentedViewDockingLocation) {
        dockingLocation = location
    }

    public func interactiveTransitionController(_ controller: VerticalSlidingInteractiveTransitionController, shouldAlwaysHandleGestureBeganAt point: CGPoint) -> Bool {
        return headerView.frame.contains(point)
    }

    public func interactiveTransitionControllerShouldHandleGestureUpdate(_ controller: VerticalSlidingInteractiveTransitionController) -> Bool {
        return isScrollBlocked
    }
}
