//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Online Training on 4/16/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {

    let testData = ["Dog", "Cat", "Horse", "Elephant"]
    
    @IBOutlet weak var logoutBbi: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dropPinBbi: UIBarButtonItem!
    @IBOutlet weak var refreshBbi: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func logoutBbiPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func dropPinBbiPressed(_ sender: Any) {
    }
    @IBOutlet weak var refreshBbiPressed: UIBarButtonItem!
}

extension ListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCellID", for: indexPath)
        
        cell.textLabel?.text = testData[indexPath.row]
        return cell
    }
}
