//
//  ViewController.swift
//  PP_ToDoList
//
//  Created by Kevin Lee on 1/11/21.
//

import UIKit
import RealmSwift
import UserNotifications

class ToDoListItem: Object {
    
    @objc dynamic var item: String = ""
    @objc dynamic var memo: String = ""
    @objc dynamic var date: Date = Date()
    @objc dynamic var alert: Date = Date()
    @objc dynamic var alert_backup: Date = Date()
    
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var table: UITableView!
    
    private var data = [ToDoListItem]()
    private let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            //if not granted
        }
        
        data = realm.objects(ToDoListItem.self).map( {$0} )
        
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.delegate = self
        table.dataSource = self
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row].item
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = data[indexPath.row]
        guard let vc = storyboard?.instantiateViewController(identifier: "info") as? InfoViewController else {
            return
        }
        
        vc.item = item
        vc.deletionHandler = { [weak self] in
            self?.refresh()
        }
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.title = item.item
        navigationController?.pushViewController(vc, animated: true)
    }
 
    @IBAction func didTapAdd() {
        guard let vc = storyboard?.instantiateViewController(identifier: "add") as? AddViewController else {
            return
        }
        vc.completionHandler = { [weak self] in
            self?.refresh()
        }
        vc.title = "New Item"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }

    func refresh() {
        data = realm.objects(ToDoListItem.self).map( {$0} )
        table.reloadData()
    }
}

