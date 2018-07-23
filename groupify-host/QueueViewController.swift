//
//  QueueViewController.swift
//  groupify-host
//
//  Created by Noah Rubin on 1/20/18.
//  Copyright © 2018 Noah Rubin. All rights reserved.
//

import UIKit

class QueueViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Queue.instance.queue.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = Queue.instance.queue[indexPath.item]
        cell.textLabel!.text = item.title
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
    
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            Queue.instance.queue.remove(at: indexPath.item)
//        }
//    }
    
    @IBAction func doneTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func clearTapped(_ sender: Any) {
        Queue.instance.queue = []
    }
}
