//
//  WalkThroughViewController.swift
//  User
//
//  Created by CSS on 27/04/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class WalkThroughViewController: UIPageViewController {
    
    
    private var walkThroughControllers = [UIViewController]()
    
    private let walkThroughData = [(Constants.string.welcome, Constants.string.walkthroughWelcome),(Constants.string.schedule, Constants.string.walkthroughDrive),(Constants.string.drivers, Constants.string.walkthroughEarn)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialLoads()
        self.dataSource = self
        self.delegate = self
    }
}
//MARK:- Local Methods

extension WalkThroughViewController {
    
    private func initialLoads(){
        
        for i in 0..<walkThroughData.count{
            
            if let viewCtrl = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.WalkThroughPreviewController) as? WalkThroughPreviewController {
                viewCtrl.set(image: UIImage(named: "walkthrough\(i)"), title: walkThroughData[i].0, description: walkThroughData[i].1)
                self.walkThroughControllers.append(viewCtrl)
            }
            
        }
        self.setViewControllers([walkThroughControllers[0]], direction: .forward, animated: true, completion: nil)
        //        self.pageControl.currentPage = 1
        //        self.pageControl.tintColor = UIColor.black
        //        self.pageControl.backgroundColor = .black
        //        self.pageControl.pageIndicatorTintColor = UIColor.gray
        //        self.pageControl.currentPageIndicatorTintColor = UIColor.black
        //        self.pageControl.numberOfPages = walkThroughControllers.count
        //        self.pageControl.backgroundColor = .white
        //        self.view.addSubview(pageControl)
        //        vieww.backgroundColor = .clear
        //        self.view.addSubview(vieww)
        //        self.vieww.translatesAutoresizingMaskIntoConstraints = false
        //        self.vieww.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        //        self.vieww.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        //        self.vieww.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        //        self.vieww.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
}

//MARK:- UIPageViewControllerDelegate

extension WalkThroughViewController : UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = walkThroughControllers.index(of: viewController), index > 0 else {
            return nil
        }
        print(#function,index)
        return walkThroughControllers[index-1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let index = walkThroughControllers.index(of: viewController), index<self.walkThroughControllers.count-1 else {
            return nil
        }
        print(#function,index)
        return walkThroughControllers[index+1]
        
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        
        
        return self.walkThroughControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        
        return 0
    }
    
}

