//
//  CouponCollectionViewController.swift
//  User
//
//  Created by CSS on 20/09/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class CouponCollectionViewController: UIViewController {
    
    private var datasource = [PromocodeEntity]()
    private var collectionView : UICollectionView!
    
    private lazy var loader  : UIView = {
        return createActivityIndicator(UIApplication.shared.keyWindow ?? self.view)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialLoads()
    }
}

// MARK:- Local Methods
extension CouponCollectionViewController {
    
    private func initialLoads() {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 5
        flowLayout.itemSize = CGSize(width: self.view.frame.width, height: 200)
        flowLayout.scrollDirection = .vertical
        self.collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        self.collectionView.backgroundColor = .white
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.bounces = true
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.isScrollEnabled = true
        self.view.addSubview(self.collectionView!)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1).isActive = true
         self.collectionView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1).isActive = true
        if #available(iOS 11.0, *) {
            self.collectionView.centerXAnchor.constraint(equalToSystemSpacingAfter: self.view.centerXAnchor, multiplier: 1).isActive = true
            self.collectionView.centerYAnchor.constraint(equalToSystemSpacingBelow: self.view.centerYAnchor, multiplier: 1).isActive = true
        }
        self.collectionView?.register(UINib(nibName: XIB.Names.CouponCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: XIB.Names.CouponCollectionViewCell)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back-icon").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.backButtonClick))
        self.navigationItem.title = Constants.string.coupon.localize()
        self.presenter?.get(api: .promocodes, parameters: nil)
        
    }
    
    //  Empty View
    
    private func checkEmptyView() {
        
        self.collectionView?.backgroundView = {
            
            if (self.datasource.count) == 0 {
                let label = Label(frame: UIScreen.main.bounds)
                label.numberOfLines = 0
                Common.setFont(to: label, isTitle: true)
                label.center = UIApplication.shared.keyWindow?.center ?? .zero
                label.backgroundColor = .clear
                label.textColorId = 2
                label.textAlignment = .center
                label.text = Constants.string.noCoupons.localize()
                return label
            } else {
                return nil
            }
        }()
    }
    
    private func reloadTable() {
        DispatchQueue.main.async {
            self.loader.isHidden = true
            self.checkEmptyView()
            self.collectionView?.reloadData()
        }
    }
    
}

// MARK:- Collection Delegates
extension CouponCollectionViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: XIB.Names.CouponCollectionViewCell, for: indexPath) as? CouponCollectionViewCell, self.datasource.count > indexPath.item {
            collectionViewCell.addDashedLine()
            collectionViewCell.isHideApplyButton = true
            collectionViewCell.set(values: self.datasource[indexPath.item])
            return collectionViewCell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width-10, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.datasource.count
    }
    
}

//MARK:- PostViewProtocol

extension CouponCollectionViewController : PostViewProtocol {
    
    func onError(api: Base, message: String, statusCode code: Int) {
        print(message)
        self.reloadTable()
    }
    
    func getPromocodeList(api: Base, data: [PromocodeEntity]) {
        self.datasource = data
        self.reloadTable()
    }
    
}
