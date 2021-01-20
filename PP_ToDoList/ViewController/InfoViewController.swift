//
//  InfoViewController.swift
//  PP_ToDoList
//
//  Created by Kevin Lee on 1/11/21.
//

import UIKit
import RealmSwift

class InfoViewController: UIViewController {

    public var item: ToDoListItem?
    public var deletionHandler: (() -> Void)?
    private let realm = try! Realm()
    
    @IBOutlet var itemLabel: UILabel!
    @IBOutlet var memoLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        itemLabel.text = item?.item
        memoLabel.text = item?.memo
        dateLabel.text = Self.dateFormatter.string(from: item!.date)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(didTapEdit))
    }
    
    @objc private func didTapEdit() {
        guard let vc = storyboard?.instantiateViewController(identifier: "edit") as? EditViewController else {
            return
        }
        
        vc.item = item
        vc.title = item?.item
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func didTapDelete() {
        guard let thisItem = self.item else {
            return
        }
        
        realm.beginWrite()
        realm.delete(thisItem)
        try! realm.commitWrite()
        
        deletionHandler?()
        
        navigationController?.popToRootViewController(animated: true)
    }

}
