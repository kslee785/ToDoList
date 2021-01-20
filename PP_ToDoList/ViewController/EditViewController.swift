//
//  AddViewController.swift
//  PP_ToDoList
//
//  Created by Kevin Lee on 1/11/21.
//

import UIKit
import RealmSwift
import UserNotifications

class EditViewController: UIViewController, UITextFieldDelegate {
    
    public var item: ToDoListItem?
    private let realm = try! Realm()

    @IBOutlet var textField: UITextField!
    @IBOutlet var memo: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var alert: UIDatePicker!
    @IBOutlet var reminder: UILabel!
    @IBOutlet var check: UISwitch!
    
    public var completionHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textField.text = item!.item
        memo.text = item!.memo
        datePicker.setDate(item!.date, animated: true)
        alert.setDate(item!.alert, animated: true)
        
        if item!.alert != item!.alert_backup {
            check.isOn = true
        }else {
            check.isOn = false
        }
        
        if check.isOn {
            alert.isHidden = false
        }else {
            alert.isHidden = true
        }
        
        textField.becomeFirstResponder()
        textField.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSave))
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    @objc func didTapSave() {
        if let text = textField.text, !text.isEmpty {
            let date = datePicker.date
            
            realm.beginWrite()
            
            if check.isOn {
                let center = UNUserNotificationCenter.current()
                center.removeDeliveredNotifications(withIdentifiers: ["TDL\(item!.item)"])
                let content = UNMutableNotificationContent()
                content.title = "To Do List"
                content.body = text
                let alert_date = alert.date
                let dateComponent = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: alert_date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
                let request = UNNotificationRequest(identifier: "TDL\(item!.item)", content: content, trigger: trigger)
                    
                center.add(request) { (error) in
                    //error adding
                }
                item?.alert = alert.date
                item?.alert_backup = Date()
            }
            
            item?.date = date
            item?.item = text
            item?.memo = memo.text!
            
            try! realm.commitWrite()
            completionHandler?()
            navigationController?.popToRootViewController(animated: true)
        }else {
            print("Blank")
        }
    }
    
    @IBAction func didTapSwitch(_ sender: UISwitch) {
        if sender.isOn {
            alert.isHidden = false
        }else {
            alert.isHidden = true
            alert.date = datePicker.date
            realm.beginWrite()
            item?.alert = item!.date
            item?.alert_backup = item!.date
            try! realm.commitWrite()
            let center = UNUserNotificationCenter.current()
            center.removeDeliveredNotifications(withIdentifiers: ["TDL\(item!.item)"])
        }
    }
}
