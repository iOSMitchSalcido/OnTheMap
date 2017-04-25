//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Online Training on 4/16/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About ListViewController.swift:
 */

import UIKit

class ListViewController: UIViewController {
    
    @IBOutlet weak var logoutBbi: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dropPinBbi: UIBarButtonItem!
    @IBOutlet weak var refreshBbi: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    @IBAction func logoutBbiPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dropPinBbiPressed(_ sender: Any) {
        
        let controller = storyboard?.instantiateViewController(withIdentifier: "PostLocationNavControllerID") as! UINavigationController
        
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func refreshBbiPressed(_ sender: Any) {    
    }
}

extension ListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentsOnTheMap.shared.udacionCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCellID", for: indexPath)
        
        let student = StudentsOnTheMap.shared.udacionAtIndex(indexPath.row)
        cell.textLabel?.text = student.firstName + " " + student.lastName
        return cell
    }
}
