//
//  ViewController.swift
//  YHInfiniteScrollView
//
//  Created by Yonghwi Nam on 10/10/2017.
//  Copyright (c) 2017 DooZerStage. All rights reserved.
//

import UIKit
import YHInfiniteScrollView

class ViewController: UIViewController, YHInfiniteScrollViewDelegate {

    // MARK: - IBOutlet
    @IBOutlet weak var mainContainer: UIView!
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addInfiniteView()
        
    }
    
    // MARK: - Private Method
    fileprivate func addInfiniteView() {
        
        let infiniteScrollView = YHInfiniteScrollView.init(frame: CGRect.zero, contentObjects: self.contentsViewControllers())
        infiniteScrollView.translatesAutoresizingMaskIntoConstraints = false
        infiniteScrollView.delegate = self
        
        self.mainContainer.addSubview(infiniteScrollView)
        
        let alcTop = NSLayoutConstraint.init(item: infiniteScrollView, attribute: .top, relatedBy: .equal, toItem: self.mainContainer, attribute: .top, multiplier: 1.0, constant: 0.0)
        let alcLeading = NSLayoutConstraint.init(item: infiniteScrollView, attribute: .leading, relatedBy: .equal, toItem: self.mainContainer, attribute: .leading, multiplier: 1.0, constant: 0.0)
        let alcBottom = NSLayoutConstraint.init(item: infiniteScrollView, attribute: .bottom, relatedBy: .equal, toItem: self.mainContainer, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let alcTrailing = NSLayoutConstraint.init(item: infiniteScrollView, attribute: .trailing, relatedBy: .equal, toItem: self.mainContainer, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        
        self.mainContainer.addConstraints([alcTop, alcLeading, alcBottom, alcTrailing])
    }

    
    // MARK: - Helper
    // Return content view controllers
    fileprivate func contentsViewControllers() -> [UIViewController] {
        let firstViewContorller = self.viewControllerFromStoryboard("FirstViewController") as! FirstViewController
        let secondViewController = self.viewControllerFromStoryboard("SecondViewController") as! SecondViewController
        let thirdViewController = self.viewControllerFromStoryboard("ThirdViewController") as! ThirdViewController
        let fourthViewController = self.viewControllerFromStoryboard("FourthViewController") as! FourthViewController
        let fifthViewController = self.viewControllerFromStoryboard("FifthViewController") as! FifthViewController
        
        self.addChildViewController(firstViewContorller)
        self.addChildViewController(secondViewController)
        self.addChildViewController(thirdViewController)
        self.addChildViewController(fourthViewController)
        self.addChildViewController(fifthViewController)
        
        return [firstViewContorller, secondViewController, thirdViewController, fourthViewController, fifthViewController]
    }
    
    // Return view controller from storyboard
    fileprivate func viewControllerFromStoryboard(_ identifier: String) -> UIViewController {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: identifier)
        
        return viewController!
    }

}

