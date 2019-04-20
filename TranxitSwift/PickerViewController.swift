//
//  PickerViewController.swift
//  PickerView
//
//  Created by MAC on 08/03/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class PickerViewController: UIViewController  {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()
    }
    
    func showNormalPicker() {
        let floor_pickerViewContainer = UIView()
        floor_pickerViewContainer.frame = CGRect(x: 0, y: view.bounds.size.height - 180, width: view.bounds.size.width, height: 180)
         floor_pickerViewContainer.layer.cornerRadius = 10
        
        let floor_Picker.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 160)
        floor_Picker.isHidden = false
        floor_Picker.showsSelectionIndicator = true
        floor_Picker.tintColor = pickerColor
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        backgroundView.alpha = 0.4
        backgroundView.backgroundColor = UIColor.black
        self.view.addSubview(backgroundView)

        let  setBtn.addTarget(self, action: #selector(self.setVehicle), for: .touchUpInside)
        setBtn.frame = CGRect(x: 0, y: 140, width: 140, height: 40)
        setBtn.setTitle(Constants.string.select.localize(), for: .normal)
        setBtn.setTitleColor(pickerColor, for: .normal)
        if let aSize = UIFont(name: "Avenir-Heavy", size: 16) {
            setBtn.titleLabel?.font = aSize
        }
        
        cancelPickerBtn.addTarget(self, action: #selector(self.cancelVehicle), for: .touchUpInside)
        
        cancelPickerBtn.frame = CGRect(x: self.view.frame.size.width-140, y: 140, width: 140, height: 40)
        
        cancelPickerBtn.setTitle(Constants.string.Cancel.localize(), for: .normal)
        cancelPickerBtn.setTitleColor(pickerColor, for: .normal)
        if let aSize = UIFont(name: "Avenir-Heavy", size: 16) {
            cancelPickerBtn.titleLabel?.font = aSize
        }
        floor_pickerViewContainer.addSubview(floor_Picker)
        floor_pickerViewContainer.addSubview(cancelPickerBtn)
        floor_pickerViewContainer.addSubview(setBtn)

        self.show(floor_pickerViewContainer, isShow: true)
    }
    
    
    
    @objc func setVehicle() {
        
        if isDatePicker{
            
            if let date_Picker = alert_Controller?.view.viewWithTag(PICKERDATE_TAG) as? UIDatePicker {
                delegate?.finishPassing(string: date_Picker.date, selectedIndex:date_Picker.tag)
            }
           // self.dismiss(animated: true, completion: nil)
           // let df = DateFormatter()
            //fromDate = date_Picker?.date
           // df.dateFormat = "yyyy-MM-dd HH:mm"
           // scheduledDate = df.string(from: fromDate as Date)
            
        }else{
            
            selectedString = pickOption[floor_Picker.selectedRow(inComponent: 0)]
            
           // delegate?.finishPassing(string: selectedString, selectedIndex: floor_Picker.selectedRow(inComponent: 0))
        }
        
        
        
        self.cancelVehicle()
        
    }
    
    
    @objc func cancelVehicle() {
        
        pickerDisplayString = "no"
        
        backgroundView.removeFromSuperview()
        
        self.show(floor_pickerViewContainer, isShow: false)
        self.show((alert_Controller?.view)!, isShow: false)
        
    }
    
    
    func showDatePicker(_ sender : Any) {
        
        alert_Controller = UIAlertController(title: nil, message: "\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        alert_Controller?.view.tintColor = .primary
        let button = sender as? UIButton
        var picker: UIDatePicker?
        picker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 200))
        alert_Controller?.view.bounds = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 300)
        picker?.tintColor = .primary
        picker?.tag = 50
        alert_Controller?.view.addSubview(picker!)
        let tools = UIToolbar(frame: CGRect(x: 8, y: 0, width: (alert_Controller?.view.frame.size.width)! - 40, height: 40))
        let doneButton = UIBarButtonItem(title: Constants.string.Done.localize(), style: .plain, target: self, action:#selector(self.setVehicle))
        doneButton.tag = 1
        doneButton.tintColor = .primary
        doneButton.imageInsets = UIEdgeInsetsMake((alert_Controller?.view.frame.size.width)! - 100, 6, 50, 25)
        let CancelButton = UIBarButtonItem(title: Constants.string.Cancel.localize(), style: .plain, target: self, action: #selector(self.cancelVehicle))
        CancelButton.tintColor = .primary
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let array = [CancelButton, flexSpace, doneButton]
        tools.items = array
        //picker title
        let lblPickerTitle = UILabel(frame: CGRect(x: ((alert_Controller?.view.frame.size.width)! - 130) / 2, y: 8, width: 130, height: 25))
        lblPickerTitle.backgroundColor = UIColor.clear
        lblPickerTitle.textColor = .primary
        lblPickerTitle.textAlignment = .left
        lblPickerTitle.font = UIFont(name: "Avenir-Heavy", size: 14)
        tools.addSubview(lblPickerTitle)
        alert_Controller?.view.addSubview(tools)
        let df = DateFormatter()
        let datemin = Date()
        picker?.minimumDate = datemin

        picker?.datePickerMode = .dateAndTime
        lblPickerTitle.text = Constants.string.scheduleARide.localize()
        df.dateFormat = "yyyy-MM-dd HH:mm"

        let popPresenter: UIPopoverPresentationController? = alert_Controller?.popoverPresentationController
        popPresenter?.sourceView = button
        
        self.present(alert_Controller!, animated: true, completion: nil)

        
    }
    
    
    func show(_ view: UIView, isShow: Bool) {
        if isShow {
            view.isHidden = false
            self.view.bringSubview(toFront: view)
            pushTransition(0.3, view: view, withDirection: 3)
            
        }
        else {
            self.view.sendSubview(toBack: view)
            view.isHidden = true
            pushTransition(0.3, view: view, withDirection: 4)
            
        }
    }
    
    func pushTransition(_ duration: CFTimeInterval, view: UIView, withDirection direction: Int) {
        let animation = CATransition()
        animation.delegate = self
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionPush
        
        if direction == 1 {
            animation.subtype = kCATransitionFromRight
        }
        else if direction == 2 {
            animation.subtype = kCATransitionFromLeft
        }
        else if direction == 3 {
            animation.subtype = kCATransitionFromTop
        }
        else {
            animation.subtype = kCATransitionFromBottom
        }
        
        animation.duration = duration
        view.layer.add(animation, forKey: kCATransitionMoveIn)
        
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return pickOption.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return pickOption[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var labelView = view as? UILabel
        if labelView == nil {
            labelView = UILabel()
            labelView?.textAlignment = .center
            labelView?.numberOfLines = 1
            
            if let aSize = UIFont(name: "Avenir-Heavy", size: 16) {
                labelView?.font = aSize
            }
        }
        labelView?.text = pickOption[row]
        
        return labelView!
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        var animation = CATransition()
        animation = anim as! CATransition
        if(animation.subtype == "fromBottom"){
            
            floor_pickerViewContainer.removeFromSuperview()
            
            let transition2: CATransition = CATransition()
            transition2.duration = 0.35
            transition2.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition2.type = kCATransitionFade
            transition2.subtype = kCATransitionFromBottom
            self.view.window!.layer.add(transition2, forKey: nil)
            self.dismiss(animated: false, completion: nil)
        }
}
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
