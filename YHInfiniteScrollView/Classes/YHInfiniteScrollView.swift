//
//  YHInfiniteScrollView.swift
//
//  Created by Yonghwi Nam on 10/08/2017.
//  Copyright © 2017 DooZerStage. All rights reserved.
//

import Foundation
import UIKit

// MARK: - YHInfiniteScrollViewDelegate
@objc public protocol YHInfiniteScrollViewDelegate: class {
    
    @objc optional func didScroll(atContentOffsetX: CGFloat)
    
    @objc optional func willScrollToNextView(atIndex: Int)
    @objc optional func willScrollToNextView(atIndex: Int, contentObject: Any)
    
    @objc optional func didScrollToNextView(atIndex: Int)
    @objc optional func didScrollToNextView(atIndex: Int, contentObject: Any)
    
    @objc optional func willScrollToPreviousView(atIndex: Int)
    @objc optional func willScrollToPreviousView(atIndex: Int, contentObject: Any)
    
    @objc optional func didScrollToPreviousView(atIndex: Int)
    @objc optional func didScrollToPreviousView(atIndex: Int, contentObject: Any)
}

// Rotation Queue의 Content View의 Index를 식별 하기 위해 사용
fileprivate let DEFAULT_CONTENTVIEW_TAG                     = 8000

// Rotation Queue 크기
fileprivate let ROTATION_QUEUE_COUNT                         = 3

open class YHInfiniteScrollView: UIView, UIScrollViewDelegate {
    
    // Main ScrollView
    fileprivate var mainScrollView: UIScrollView!
    
    // 전체 ContentView를 저장할 Queue
    fileprivate var contentQueue: [Any] = Array()
    
    // 순환 처리를 위한 Rotation Queue (ex. 0,1,2 -> 2,0,1 -> 1,2,0... )
    fileprivate var rotationQueue: [UIView]!
    
    public var delegate: YHInfiniteScrollViewDelegate?
    
    // MARK: View Life Cycle
    // @param contentObjects : Infinite ScrollView에 보여질 Contents (UIView or UIViewController)
    public init(frame: CGRect, contentObjects: [Any]) {
        super.init(frame: frame)
        
        self.contentQueue = self.contentQueueWithViewTag(contentObjects)
        self.rotationQueue = firstQueue(self.contentQueue)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        print("aDecoder")
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // Root View 설정
        self.clipsToBounds = true
        self.backgroundColor = UIColor.orange
        
        // Root View에  Main ScrollView 추가
        self.mainScrollView = self.configureScrollView(frame: rect)
        self.addSubview(self.mainScrollView)
        
        // Main ScrollView에 Rotation Queue의 ContentView 추가
        self.setRotationQueueToScrollView()
    }
    
    // MARK: - UIScrollViewDelegate
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Delegate 호출
        self.performDelegateForScrollViewDidScroll(scrollView)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // 좌/우 마지막 스크롤일때 스크롤이 시작되기전 Rotation Queue 변경
        self.changeRotationQueue(scrollView)
        
        // Delegate 호출
        self.performDelegateForScrollViewWillBeginDraging(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Delegate 호출
        self.performDelegateForScrollViewDidEndDecelerating(scrollView)
    }
    
    
    // MARK: Public Method
    // 'toIndex'에 해당 하는 ContentView 이동
    func scrollToContentView(toIndex: Int) {
        // ScrollView에 있는 기존 ContentView 삭제
        self.removeAllrotationQueue()
        
        // 기존 Rotation Queue 삭제
        self.rotationQueue.removeAll()
        
        // 'toIndex'를 시작으로 새로운 Rotation Queue 생성
        self.rotationQueue = self.newRotationQueue(fromIndex: toIndex)
        
        // 새로운 Rotation Queue에 저장된 ContentView의 Frame 설정
        self.setRotationQueueToScrollView()
        
        // ContentOffset 첫 화면 이동
        self.moveContentOffsetX(toIndex: 0)
    }
    
    
    // MARK: - Private Method
    // Main ScrollView 기본 구성
    fileprivate func configureScrollView(frame: CGRect) -> UIScrollView {
        let scrollView = UIScrollView.init(frame: frame)
        scrollView.delegate = self
        scrollView.bounces = false
        scrollView.isPagingEnabled = true
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = UIColor.blue
        scrollView.contentSize = CGSize.init(width: frame.size.width * CGFloat.init(ROTATION_QUEUE_COUNT), height: frame.size.height)
        
        return scrollView
    }
    
    // Delegate호출시 전달 할 Index 계산을 위하여
    // ContentQueue에 저장된 Object에 View Tag 설정
    fileprivate func contentQueueWithViewTag(_ contentObject: [Any]) -> [Any] {
        var result: [Any] = Array()
        for (index, object) in contentObject.enumerated() {
            if object is UIViewController {
                let viewController = object as! UIViewController
                viewController.view.tag = DEFAULT_CONTENTVIEW_TAG + index
            } else {
                let view = object as! UIView
                view.tag = DEFAULT_CONTENTVIEW_TAG + index
            }
            result.append(object)
        }
        
        return result
    }
    
    // ContentObject로부터 View 객체 반환.
    fileprivate func viewFromContentObject(_ contentObject: Any) -> UIView{
        if let vc = contentObject as? UIViewController {
            return vc.view
        } else {
            return contentObject as! UIView
        }
    }
    
    // ContentQueue에서 최초 화면에 보여질 Index 0,1,2의 Queue 반환
    fileprivate func firstQueue(_ contentQueue: [Any]) -> [UIView] {
        var queue: [UIView] = Array()
        
        for i in 0..<ROTATION_QUEUE_COUNT {
            queue.append(self.viewFromContentObject(contentQueue[i]))
        }
        
        return queue
    }
    
    // Index에 해당하는 View Frame 반환
    fileprivate func contentViewFrameInRotationQueue(_ atIndex: Int) -> CGRect {
        let contentWidth = self.bounds.width
        let contentHeight = self.bounds.height
        
        return CGRect.init(x: CGFloat.init(atIndex) * contentWidth, y: 0, width: contentWidth, height: contentHeight)
    }
    
    // 메인 스크롤뷰에 순환뷰 추가 및 Frame 설정
    fileprivate func setRotationQueueToScrollView() {
        for (index, view) in self.rotationQueue.enumerated() {
            view.frame = contentViewFrameInRotationQueue(index)
            if !view.isDescendant(of: self.mainScrollView) {
                self.mainScrollView.addSubview(view)
            }
        }
    }
    
    // 사용자의 스크롤 방향이 우측 (->)인지 확인
    fileprivate func isRightScrollingInScrollView(_ scrollView: UIScrollView) -> Bool {
        var result: Bool = false
        
        if scrollView.panGestureRecognizer.translation(in: scrollView.superview).x > 0 {
            result = true
        }
        
        return result
    }
    
    // 스크롤의 마지막에서 스크롤 방향에 따라 다음에 보여질 화면 삽입과
    // Rotation Queue에서 밀려난 ContentView 삭제
    fileprivate func swapRotationQueue(isRightScrolling: Bool) {
        
        // 현재 보여지고 있는 ContentView
        var currentView: UIView!
        
        // Rotation Queue에서 삭제될 ContentView
        var deleteView: UIView!
        
        // Scroll 방향에 따라 Rotation Queue에 삽입될 Index
        var insertIndex: Int!
        
        // Rotation Queue에서 삭제될 ContentView의 Index
        var deleteIndex: Int!
        
        // 첫 화면에서 스크롤 방향이 우측 일때(->)
        if isRightScrolling {
            
            // Rotation Queue Index 0의 ContentView
            currentView = self.rotationQueue.first!
            
            // 다음에 보여질 화면이 삽입될 Index는 Index 0앞에 위치
            insertIndex = self.rotationQueue.startIndex
            
            // Index 0에 삽입된 ContentView로 인해 마지막 ContentView 삭제
            deleteView = self.rotationQueue.last
            
            // 삭제할 ContentView의 Index
            deleteIndex = self.rotationQueue.endIndex
            
        } else { // 마지막 화면에서 스크롤 방향이 좌측 (<-)
            
            // Rotation Queue Index 2의 ContentView
            currentView = self.rotationQueue.last
            
            // 다음에 보여질 화면이 마지막 Index에 위치
            insertIndex = self.rotationQueue.endIndex
            
            // Index 2에 삽입된 ContentView로 인해 첫번째 ContentView 삭제
            deleteView = self.rotationQueue.first
            
            // 삭제할 ContentView의 Index
            deleteIndex = self.rotationQueue.startIndex
        }
        
        // 위에 설정된 currentViw, isRightScrolling, insertIndex 값에 의해 Rotation Queue에 새로는 View 삽입
        self.rotationQueue.insert(self.nextView(fromCurrentView: currentView, isRightScrolling: isRightScrolling), at: insertIndex)
        
        // ScrollView에서 삭제
        deleteView.removeFromSuperview()
        
        // deleteIndex에 해당하는 ContentView 삭제
        self.rotationQueue.remove(at: deleteIndex)
    }
    
    // Content Queue에서 스크롤 방향에 따라
    // 현재 보여지는 ContentView를 기준으로 다음에 보여질 View 반환
    fileprivate func nextView(fromCurrentView: UIView, isRightScrolling: Bool) -> UIView {
        
        // Content Queue의 마지막 Index
        let lastIndex = self.contentQueue.count - 1
        
        // Content Queue에서 현재 화면의 Index
        let indexOfCurrentView = self.indexOfCurrentViewInContentQueue(contentView: fromCurrentView)//self.contentQueue.index(of: fromCurrentView)
        
        // 다음 화면의 Index 초기값 설정
        var indexOfNextView = 0
        
        // 마지막 화면에서 스크롤이 우측 방향(->)일때
        if isRightScrolling {
            
            // 다음 화면의 Index는 현재 화면 Index - 1
            indexOfNextView = indexOfCurrentView - 1
        } else {
            
            // 다음 화면의 Index는 현재 화면의 Index + 1
            indexOfNextView = indexOfCurrentView + 1
        }
        
        // 다음 화면 Index가 음수일때 즉, 첫 화면에서 '우측' 방향 스크롤일 경우
        // 전체 Content Queue의 마지막 화면을 보여주기 위해 마지막 Index 설정
        if indexOfNextView < 0 {
            indexOfNextView = lastIndex
        }
        
        // 다음 화면 Index가 마지막 Index보다 클때 즉, 마지막 화면에서 '좌측' 방향 스크롤일 경우
        // 전체 Content Queue의 첫 화면을 보여주기 위해 Index 0 설정
        if indexOfNextView > lastIndex {
            indexOfNextView = 0
        }
        
        // 다음화면 Index로 부터 Rotation Queue에 들어갈 ContentView 반환
        var nextView: UIView!
        let contentObject = self.contentQueue[indexOfNextView]
        
        if let vc: UIViewController = contentObject as? UIViewController {
            nextView = vc.view
        } else {
            nextView = contentObject as! UIView
        }
        
        return nextView!
    }
    
    // Scroll 방향에 따라 RotationQueue의 순서 변경
    fileprivate func changeRotationQueue(byScrollDirection isRightScrolling: Bool) {
        let contetOffsetX = self.mainScrollView.contentOffset.x
        
        // 첫 화면이면서 스크롤 방향이 오른쪽일때 (->)
        // 첫 화면을 두번째 화면 좌표로 이동하고, 마지막 화면을 첫번째 화면 좌표로 이동
        if contetOffsetX == 0 && isRightScrolling{
            self.swapRotationQueue(isRightScrolling: isRightScrolling)
            self.setRotationQueueToScrollView()
            
            // ContentOffset을 두번째 화면으로 이동 시킨다.
            self.mainScrollView.contentOffset = CGPoint.init(x: self.bounds.width, y: 0)
        }
        
        // 마지막 화면이고 스크롤 방향이 왼쪽일때 (<-)
        // 마지막 화면을 두번째 화면 좌표로 이동하고, 첫 화면을 마지막 화면 좌표로 이동후,
        // ContentOffset을 두번째 화면으로 이동 시킨다.
        if contetOffsetX == (self.bounds.width * 2) && !isRightScrolling {
            self.swapRotationQueue(isRightScrolling: isRightScrolling)
            self.setRotationQueueToScrollView()
            
            // ContentOffset을 두번째 화면으로 이동 시킨다.
            self.mainScrollView.contentOffset = CGPoint.init(x: self.bounds.width, y: 0)
        }
    }
    
    // Scroll 방향에 따라 RotationQueue의 순서 변경
    fileprivate func changeRotationQueue(_ scrollView: UIScrollView) {
        // 스크롤 방향 확인
        let isRightScrolling = self.isRightScrollingInScrollView(scrollView)
        
        changeRotationQueue(byScrollDirection: isRightScrolling)
    }
    
    // Content Offset X에 위치하는 Content View의 Index 반환
    fileprivate func indexOfContentView(atConentOffset: CGPoint) -> Int {
        let contentWith = self.bounds.width
        let offsetX = atConentOffset.x
        let indexOfRotationQueue = offsetX / contentWith
        let contentView: UIView = self.rotationQueue[Int.init(indexOfRotationQueue)]
        let contentViewTag = contentView.tag
        let indexOfContentView = contentViewTag - DEFAULT_CONTENTVIEW_TAG
        
        return indexOfContentView
    }
    
    // Scroll 이벤트가 발생될때 마다 호출되는 Delegate 호출
    fileprivate func performDelegateForScrollViewDidScroll(_ scrollView: UIScrollView) {
        let convertedOffsetX = self.convertedContentOffsetXForDidScroll(scrollView)
        
        self.delegate?.didScroll?(atContentOffsetX: convertedOffsetX)
    }
    
    // Scroll 시작전 호출 되는 Delegate 호출
    fileprivate func performDelegateForScrollViewWillBeginDraging(_ scrollView: UIScrollView) {
        let isRightScrolling = self.isRightScrollingInScrollView(scrollView)
        let lastIndex = self.contentQueue.count - 1
        var nextIndex = 0
        if isRightScrolling {
            nextIndex = self.indexOfContentView(atConentOffset: scrollView.contentOffset) - 1
            if nextIndex < 0 {
                nextIndex = lastIndex
            }
            let contentObject = self.contentQueue[nextIndex]
            
            self.delegate?.willScrollToPreviousView?(atIndex: nextIndex)
            self.delegate?.willScrollToPreviousView?(atIndex: nextIndex, contentObject: contentObject)
        } else {
            nextIndex = self.indexOfContentView(atConentOffset: scrollView.contentOffset) + 1
            if nextIndex > lastIndex {
                nextIndex = 0
            }
            let contentObject = self.contentQueue[nextIndex]
            
            self.delegate?.willScrollToNextView?(atIndex: nextIndex)
            self.delegate?.willScrollToNextView?(atIndex: nextIndex, contentObject: contentObject)
        }
    }
    
    // Scroll 종료후 호출 되는 Delegate 호출
    fileprivate func performDelegateForScrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let isRightScrolling = self.isRightScrollingInScrollView(scrollView)
        let index = self.indexOfContentView(atConentOffset: scrollView.contentOffset)
        let contentObject = self.contentQueue[index]
        
        if isRightScrolling {
            self.delegate?.didScrollToPreviousView?(atIndex: index)
            self.delegate?.didScrollToPreviousView?(atIndex: index, contentObject: contentObject)
        } else {
            self.delegate?.didScrollToNextView?(atIndex: index)
            self.delegate?.didScrollToNextView?(atIndex: index, contentObject: contentObject)
        }
    }
    
    // fromIndex를 시작으로 하는 새로운 Rotation Queue 생성
    fileprivate func newRotationQueue(fromIndex: Int) -> [UIView] {
        var newRotationQueue: [UIView] = Array()
        let lastIndex = self.contentQueue.endIndex - 1
        
        // 이동 시킬 ContentView의 Index이자 새로운 Rotation Queue의 시작 Index
        var targetIndex = fromIndex
        
        // ContentView Index
        var contentViewIndex = 0
        
        // Rotation Queue 카운트(3)만큼 순환 하며
        // targetIndex를 시작으로 순차적으로 다음 ContentView를 가져 온다.
        for index in 0..<ROTATION_QUEUE_COUNT {
            contentViewIndex = targetIndex + index
            
            // Content View Index가 마지막 Index보다 크면
            // 즉, 마지막 ContentView 다음으로 첫번째 ContentView를 가져오기 위해
            // targetIndex와 contentViewIndex를 각각 아래와 같이 변경 한다.
            if contentViewIndex > lastIndex {
                targetIndex = -1
                contentViewIndex = 0
            }
            
            // 순차적으로 새로운 Rotation Queue에 ContentView 저장
            let contentObject = self.contentQueue[contentViewIndex]
            if let view = contentObject as? UIView {
                newRotationQueue.append(view)
            } else {
                let vc = contentObject as! UIViewController
                newRotationQueue.append(vc.view)
            }
        }
        
        return newRotationQueue
    }
    
    // ScrollView에서 Rotation Queue에 있는 모든 ContentView 삭제
    fileprivate func removeAllrotationQueue() {
        for contentView in self.rotationQueue {
            contentView.removeFromSuperview()
        }
    }
    
    // Index에 해당하는 ContentOffset.x 이동
    fileprivate func moveContentOffsetX(toIndex: Int) {
        // 해당 동작이 비동기 처리는 아니지만, 외부에서 동시에 에니메이션이 발생 할때,
        // 외부 에니메이션이 동작 하지 않는 문제가 발생하여 비동기 메인 쓰레드에서 처리함.
        DispatchQueue.main.async {
            self.mainScrollView.contentOffset = CGPoint.init(x: self.bounds.width * CGFloat.init(toIndex), y: 0)
        }
    }
    
    // InfiniteScrollView는 고정된 크기의 ContentSize에서
    // ContentView 좌표 변경을 이용해 순환 처리를 하므로, ContentOffset 값도 순환 한다.
    // 따라서, 각 Index에 해당하는 ContentOffset.x 값의 계산이 필요 하다.
    fileprivate func convertedContentOffsetXForDidScroll(_ scrollView: UIScrollView) -> CGFloat {
        // ContentView의 넒이
        let contentWidth = self.bounds.width
        
        // Scroll하는 시점에 현재 ContentView의 Index
        let currentIndex = self.indexOfContentView(atConentOffset: scrollView.contentOffset)
        
        // ScrollView의 실제 ContentOffset.x
        let originOffsetX = scrollView.contentOffset.x
        
        // Scroll 시작점으로 부터 이동한 ContentOffset.x
        // Index 0에서 스크롤이 시작 될 경우, originOffsetX 값이 이동한 거리이며,
        // Index 1(originOffsetX > contentWidth)이상 부터 이동한 originOffsetX 에서 contentWidth 차감한 값이 이동 거리이다.
        let movedOffsetX = (originOffsetX > contentWidth) ? (originOffsetX - contentWidth) : originOffsetX
        
        // Index에 해당하는 ContentOffset.x (Delegate에 전달할 Offset.x)
        var convertedOffsetX: CGFloat = 0.0
        
        // 계산식 1 : (현재 Index * ContentView의 넓이) + 이동한 Offset.x
        // ex.) ContentView 넓이가 100, 현재 Index 1 ContentView에서 다음 ContentView(Index 2) 스크롤
        //      = (1 * 100) + 10, (1 * 100) + 15, (1 * 100) + 35, (1 * 100) + 45...... (1 * 100) + 100
        convertedOffsetX = CGFloat.init(currentIndex) * contentWidth + movedOffsetX
        
        // '계산식 1'의해 movedOffsetX값이 최대 일때, convertedOffsetX 이미 다음 Index의 Offset.x를 가리키고 있으나,
        // Scroll 종료 직전(ex. Index 1 -> Index 2) originOffsetX을 기준으로 계산된 Index값에 의해 이미 currentIndex 값이 +1 증가한다.
        // 'currentIndex + 1'의해 결과적으로 '정상 convertedOffsetX + contentWidth' 처리 된다.
        // 사전에 증가한 currentIndex값을 보정하기 위해 최종 convertedOffsetX 값이 'currentIndex + 1' 값으로 계산된 경우인지 판단하여
        // 증가한 currentIndex * contentWidth 즉, 다음 Index의 ContentOffset.x를 별도로 계산 처리 한다.
        if convertedOffsetX == (CGFloat.init(currentIndex) * contentWidth + contentWidth) {
            convertedOffsetX = CGFloat.init(currentIndex) * contentWidth
        }
        
        //        print("currentIndex : \(currentIndex), originOffsetX : \(originOffsetX), convertedOffsetX : \(convertedOffsetX), movedOffsetX : \(movedOffsetX)")
        
        return convertedOffsetX
    }
    
    // ContentQueue에서 'contentView'의 Index 반환
    fileprivate func indexOfCurrentViewInContentQueue(contentView: UIView) -> Int{
        var result: Int = 0
        for (index, obj) in self.contentQueue.enumerated() {
            if let viewController = obj as? UIViewController {
                if viewController.view.isEqual(contentView) {
                    result = index
                    break
                }
            } else {
                let viewInQueue = obj as! UIView
                if contentView.isEqual(viewInQueue) {
                    result = index
                    break
                }
            }
        }
        
        return result
    }
    
    // MARK: - Deprecated
    // UIViewController를 전달 받은 경우, ViewController로 부터 View 객체만 리턴하며,
    // UIView는 그대로 해당 배열을 리턴
    fileprivate func views(_ fromContentObjects: [Any]) -> [UIView] {
        var result: [UIView] = Array()
        var contentView: UIView!
        for (index,object) in fromContentObjects.enumerated() {
            if object is UIViewController {
                let viewController = object as! UIViewController
                contentView = viewController.view
            } else {
                contentView = object as! UIView
            }
            
            contentView.tag = DEFAULT_CONTENTVIEW_TAG + index
            result.append(contentView)
        }
        
        return result
    }
}

