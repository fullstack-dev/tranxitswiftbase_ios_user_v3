//
//  CouponView.swift
//  User
//
//  Created by CSS on 17/09/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class CouponView: UIView {
    
    //MARK:- IBOutlets
    
    @IBOutlet private weak var pageControl : UIPageControl!
    @IBOutlet private weak var collectionView : UICollectionView!
    
    //MARK:- Local Variable
    
    private var minSpacing = 20
    private var selected : PromocodeEntity?
    
    var applyCouponAction : ((PromocodeEntity?)->Void)?
    private var datasource  = [PromocodeEntity]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialLoads()
    }
}

//MARK: Local Methods

extension CouponView {
    
    private func initialLoads() {
        self.pageControl.numberOfPages = 0
        self.pageControl.currentPage = 0
        self.pageControl.pageIndicatorTintColor = .lightGray
        self.pageControl.currentPageIndicatorTintColor = .secondary
        self.pageControl.addTarget(self, action: #selector(self.pageControlAction(sender:)), for: UIControl.Event.valueChanged)
        self.collectionView.register(UINib(nibName: XIB.Names.CouponCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: XIB.Names.CouponCollectionViewCell)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.allowsSelection = false
    }
    
    func set(values : [PromocodeEntity], selected : PromocodeEntity?) {
        
        self.pageControl.numberOfPages = values.count
        self.datasource = values
        self.selected = selected
        self.collectionView.reloadData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.pageControl.currentPage = Int(scrollView.contentOffset.x)/self.datasource.count
    }
    
    // PageControl Action
    
    @IBAction private func pageControlAction(sender : UIPageControl) {
        collectionView.scrollToItem(at: IndexPath(item: sender.currentPage, section: 0), at: .centeredHorizontally, animated: true)
    }
}

//MARK :- UICollectionViewDelegate

extension CouponView : UICollectionViewDelegate {
    
}

//MARK :- UICollectionViewDelegate

extension CouponView : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width-40, height: collectionView.frame.height)
    }
}

//MARK :- UICollectionViewDataSource

extension CouponView :  UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: XIB.Names.CouponCollectionViewCell, for: indexPath) as? CouponCollectionViewCell, self.datasource.count > indexPath.item {
            collectionViewCell.addDashedLine()
            collectionViewCell.isSelected = (self.datasource[indexPath.item].id == self.selected?.id)
            collectionViewCell.set(values: self.datasource[indexPath.item])
            collectionViewCell.onClickApply = { [weak self] (selectedCode) in
                self?.selected = self?.selected?.id == selectedCode.id ? nil : selectedCode // if newly selected Apply coupon either remove it 
                self?.applyCouponAction?(self?.selected)
            }
            return collectionViewCell
        }
        
        return UICollectionViewCell()
    }
}
