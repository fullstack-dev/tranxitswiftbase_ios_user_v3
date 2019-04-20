//
//  NotificationsViewController.swift
//  Provider
//
//  Created by Sravani on 08/01/19.
//  Copyright © 2019 Appoets. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController {
    
    //MARK:- IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var NotificationsTextLabel: UILabel!
    
    var dataSource : [NotificationManagerModel]?
    var selectedIndexPath: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.SetNavigationcontroller()
        self.presenter?.get(api: .notificationManager, parameters: nil)
        self.tableView.estimatedRowHeight = 120
    }
}

//MARK:- LocalMethod

extension NotificationsViewController {
    
    func SetNavigationcontroller() {
        
        if #available(iOS 11.0, *) {
            self.navigationController?.isNavigationBarHidden = false
            self.navigationController?.navigationBar.prefersLargeTitles = false
            self.navigationController?.navigationBar.barTintColor = UIColor.white
        } else {
            // Fallback on earlier versions
        }
        
        title = Constants.string.notifications.localize()
        
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back-icon").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.backBarButtonTapped(button:)))
    }
    
    @objc func backBarButtonTapped(button: UINavigationItem){
        self.popOrDismiss(animation: true)
    }
}

//MARK:- UITableViewDataSource

extension NotificationsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if dataSource?.count != 0 {
            self.tableView.isHidden = false
            NotificationsTextLabel.text = ""
        }
        else {
            self.tableView.isHidden = true
            NotificationsTextLabel.text = Constants.string.noNotifications.localize()
            return 0
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return dataSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: XIB.Names.NotificationTableViewCell, for: indexPath) as! NotificationTableViewCell
        cell.selectionStyle = .none
        cell.notifHeaderLbl.text = self.dataSource?[indexPath.row].notify_type
        cell.notifContentLbl.text = self.dataSource?[indexPath.row].description
        cell.NotifImage.setImage(with: self.dataSource?[indexPath.row].image, placeHolder: #imageLiteral(resourceName: "CarplaceHolder"))
        cell.readMoreButton.addTarget(self, action: #selector(expandCell(sender:)), for: UIControl.Event.touchUpInside)
        
        if self.selectedIndexPath == indexPath.row {
            cell.readMoreButton.setTitle(Constants().readLess, for: .normal)
        }
        else {
            cell.readMoreButton.setTitle(Constants().readMore, for: .normal)
        }
        return cell
    }
    
    @objc func expandCell(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tableView)
        if let indexPath = self.tableView.indexPathForRow(at:buttonPosition) {
            if self.selectedIndexPath == indexPath.row {
                self.selectedIndexPath = -1
            }
            else {
                self.selectedIndexPath = indexPath.row
            }
            self.tableView.reloadData()
            //            self.tableView.beginUpdates()
            //            self.tableView.endUpdates()
        }
    }
}

//MARK:- UITableViewDelegate

extension NotificationsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.selectedIndexPath == indexPath.row {
            return UITableView.automaticDimension
        }
        else {
            return 120
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

//MARK:- PostViewProtocol

extension NotificationsViewController: PostViewProtocol {
    
    func onError(api: Base, message: String, statusCode code: Int) {
        print(message)
    }
    
    func getNotificationsMangerList(api: Base, data: [NotificationManagerModel]?) {
        
        if api == .notificationManager {
            print(data as Any)
            dataSource = data
            self.tableView.reloadData()
        }
    }
}

