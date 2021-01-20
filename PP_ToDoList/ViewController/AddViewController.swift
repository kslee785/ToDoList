//
//  AddViewController.swift
//  PP_ToDoList
//
//  Created by Kevin Lee on 1/11/21.
//

import UIKit
import RealmSwift
import UserNotifications

class AddViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var textField: UITextField!
    @IBOutlet var memo: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var alert: UIDatePicker!
    @IBOutlet var reminder: UILabel!
    @IBOutlet var check: UISwitch!
    
    private let realm = try! Realm()
    public var completionHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textField.becomeFirstResponder()
        textField.delegate = self
        datePicker.setDate(Date(), animated: true)
        alert.setDate(Date(), animated: true)
        check.isOn = false
        
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
            let newItem = ToDoListItem()
            newItem.date = date
            newItem.item = text
            newItem.memo = memo.text!
            
            if check.isOn {
                let center = UNUserNotificationCenter.current()
                let content = UNMutableNotificationContent()
                content.title = "To Do List"
                content.body = text
                let alert_date = alert.date
                let dateComponent = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: alert_date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
                let request = UNNotificationRequest(identifier: "TDL\(text)", content: content, trigger: trigger)
                    
                center.add(request) { (error) in
                    //error adding
                }
                newItem.alert = alert.date
                newItem.alert_backup = Date()
            }
            
            realm.add(newItem)
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
        }
    }
}
