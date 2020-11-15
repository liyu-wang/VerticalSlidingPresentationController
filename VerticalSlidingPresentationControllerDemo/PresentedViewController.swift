//
//  PresentedViewController.swift
//  VerticalSlidingPresentationControllerDemo
//
//  Created by Liyu Wang on 7/3/20.
//  Copyright © 2020 Liyu Wang. All rights reserved.
//

import UIKit
import VerticalSlidingPresentationController

private enum Constants {
    static let numberOfItems = 30
    static let headerHeight: CGFloat = 40
    static let cellHeight: CGFloat = 44
}

class PresentedViewController: UIViewController {
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Required
    
    private var dockingLocation: VerticalPresentedViewDockingLocation = .none {
        didSet {
            switch dockingLocation {
            case .none, .lowerAnchor:
                isScrollBlocked = true
            case .upperAnchor:
                isScrollBlocked = false
            }
            tableView.showsVerticalScrollIndicator = !isScrollBlocked
        }
    }
    private var lastContentOffsetY: CGFloat = 0
    private var isScrollBlocked = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
}

private extension PresentedViewController {
    func setupViews() {
        barView.layer.cornerRadius = 2.5
        tableView.rowHeight = Constants.cellHeight
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension PresentedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Constants.numberOfItems
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
}

// MARK: - Required

extension PresentedViewController: UITableViewDelegate {}

extension PresentedViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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

extension PresentedViewController: VerticalSlidingInteractiveTransitionControllerDelegate {
    func interactiveTransitionController(_ controller: VerticalSlidingInteractiveTransitionController, didDockAt location: VerticalPresentedViewDockingLocation) {
        dockingLocation = location
    }

    func interactiveTransitionController(_ controller: VerticalSlidingInteractiveTransitionController, shouldAlwaysHandleGestureBeganAt point: CGPoint) -> Bool {
        return barView.frame.contains(point)
    }

    func interactiveTransitionControllerShouldHandleGestureUpdate(_ controller: VerticalSlidingInteractiveTransitionController) -> Bool {
        return isScrollBlocked
    }
}
