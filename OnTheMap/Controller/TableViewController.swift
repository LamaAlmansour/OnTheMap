//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Lama on 19/12/2018.
//  Copyright © 2018 Lama. All rights reserved.
//

import UIKit

class TableViewController: ContainerViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override var locationsData: LocationsData? {
        didSet {
            guard let locationsData = locationsData else { return }
            locations = locationsData.studentLocations
        }
    }
    var locations: [StudentLocation] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
}


    
    // Table View Delegate
    extension TableViewController: UITableViewDelegate {
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LocationCell
            let student = locations[indexPath.row]
            cell.nameLabel?.text = (student.firstName!) + " " + (student.lastName!)
            cell.urlLabel?.text = student.mediaURL
            
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            let student = locations[indexPath.row]
            if let mediaURL = student.mediaURL {
                if let url = URL(string: mediaURL)
                {
                     UIApplication.shared.open(url, options: [:], completionHandler: nil)                }
            }
            
        }
    }
    
    // Table View Data Source
    extension TableViewController: UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return locations.count
        }
    }
    
    
    

