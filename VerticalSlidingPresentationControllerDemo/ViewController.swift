//
//  ViewController.swift
//  VerticalSlidingPresentationControllerDemo
//
//  Created by Liyu Wang on 15/11/20.
//

import UIKit
import VerticalSlidingPresentationController

class ViewController: UIViewController {

    private var transitionController: VerticalSlidingInteractiveTransitionController?

    @IBAction func didTapPresent(_ sender: Any) {
        let presentedViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PresentedViewController") as! PresentedViewController
        presentedViewController.modalPresentationStyle = .custom
        transitionController = VerticalSlidingInteractiveTransitionController(presentedViewController: presentedViewController,
                                                                              presentingViewController: self)
        presentedViewController.transitioningDelegate = transitionController
        present(presentedViewController, animated: true)
    }
    
}

