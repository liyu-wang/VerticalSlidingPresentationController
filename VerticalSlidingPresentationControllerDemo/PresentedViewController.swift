//
//  PresentedViewController.swift
//  VerticalSlidingPresentationControllerDemo
//
//  Created by Liyu Wang on 26/10/21.
//

import UIKit
import VerticalSlidingPresentationController

private enum Constants {
    static let numberOfItems = 30
    static let headerHeight: CGFloat = 40
    static let cellHeight: CGFloat = 44
}

class PresentedViewController: UIViewController, VerticalSlidingPresentedViewControllerProtocol {
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var tableView: UITableView!

    // MARK: - VerticalSlidingPresentedViewControllerProtocol
    // --------------------- starts ---------------------

    var headerView: UIView {
        barView
    }
    var scrollableView: UIScrollView {
        tableView
    }

    var dockingLocation: VerticalPresentedViewDockingLocation = .none
    var lastContentOffsetY: CGFloat = 0
    var isScrollBlocked = true

    // --------------------- ends ---------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    private func setupViews() {
        barView.backgroundColor = .green
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

// MARK: - VerticalSlidingPresentedViewControllerProtocol
// --------------------- starts ---------------------

extension PresentedViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollableViewDidScroll(scrollView)
    }
}

// --------------------- ends ---------------------
