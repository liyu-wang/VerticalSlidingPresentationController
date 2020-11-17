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

class PresentedViewController: VerticalSlidingPresentedViewController {
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var tableView: UITableView!

    // required
    override var headerView: UIView {
        return barView
    }

    // required
    override var scrollView: UIScrollView {
        return tableView
    }

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

extension PresentedViewController: UITableViewDelegate {}
