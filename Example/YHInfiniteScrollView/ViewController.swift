//
//  ViewController.swift
//  YHInfiniteScrollView
//
//  Created by Yonghwi Nam on 10/10/2017.
//  Copyright (c) 2017 DooZerStage. All rights reserved.
//

import UIKit
import YHInfiniteScrollView

fileprivate let SCREEN_WIDTH: CGFloat               =           UIScreen.main.bounds.width
fileprivate let SCREEN_HEIHGT: CGFloat              =           UIScreen.main.bounds.height
fileprivate let STATUSBAR_HEIGHT: CGFloat           =           (SCREEN_HEIHGT == 812.0) ? 44.0 : 20.0
fileprivate let BOTTOM_GUIDE_HEIGHT: CGFloat        =           (SCREEN_HEIHGT == 812.0) ? 34.0 : 0.0

class ViewController: UIViewController, YHInfiniteScrollViewDelegate {

    // MARK: - IBOutlet
    @IBOutlet weak var mainContainer: UIView!
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add YHInfiniteScrollView by using layout constraints
        self.addInfiniteView()
        
        // Add YHInfiniteScrollView by using frame
//        self.addInfiniteViewWithFrame(rect: CGRect.init(origin: CGPoint.zero, size: self.sizeOfMainContainer()))
    }
    
    
    // MARK: - YHInfiniteViewDelegate
    func didScroll(atContentOffsetX: CGFloat) {
        print("didScroll(atContentOffsetX: CGFloat) : \(atContentOffsetX)")
    }
    
    func willScrollToNextView(atIndex: Int, contentObject: Any) {
        print("willScrollToNextView(atIndex: \(atIndex), contentObject: \(contentObject)")
    }
    
    func didScrollToNextView(atIndex: Int, contentObject: Any) {
        print("didScrollToNextView(atIndex: \(atIndex), contentObject: \(contentObject)")
    }
    
    func willScrollToPreviousView(atIndex: Int, contentObject: Any) {
        print("willScrollToPreviousView(atIndex: \(atIndex), contentObject: \(contentObject)")
    }
    
    func didScrollToPreviousView(atIndex: Int, contentObject: Any) {
        print("didScrollToPreviousView(atIndex: \(atIndex), contentObject: \(contentObject)")
    }
    
    // MARK: - Private Method
    fileprivate func addInfiniteView() {
        // Initialize YHInfiniteScrollView with layout constraints
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
    
    fileprivate func addInfiniteViewWithFrame(rect: CGRect) {
        let infiniteScrollView = YHInfiniteScrollView.init(frame: rect, contentObjects: self.contentsViewControllers())
        infiniteScrollView.delegate = self
        self.mainContainer.addSubview(infiniteScrollView)
    }
    
    fileprivate func sizeOfMainContainer() -> CGSize {
        let width = SCREEN_WIDTH
        let height = SCREEN_HEIHGT - STATUSBAR_HEIGHT - BOTTOM_GUIDE_HEIGHT
        
        return CGSize.init(width: width, height: height)
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

