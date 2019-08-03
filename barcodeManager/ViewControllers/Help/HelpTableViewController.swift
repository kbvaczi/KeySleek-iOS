//
//  HelpTableViewController.swift
//  barcodeManager
//
//  Created by Kenneth Vaczi on 8/2/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import UIKit

/// View to display a list of help sections the user can select to get more info on
class HelpTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HelpSection.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HelpTopicCell", for: indexPath)
        cell.textLabel?.text = HelpSection.allCases[indexPath.row].rawValue
        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard   let cellText = (sender as? UITableViewCell)?.textLabel?.text,
                let helpSectionSelected = HelpSection.init(rawValue: cellText) else {
                print("unable to find cell")
                return
        }
        
        if let destination = segue.destination as? HelpTopicViewController {
            destination.helpSection = helpSectionSelected
        }
    }


}

/// List of help sections the user can select to get more info on
enum HelpSection: String, CaseIterable {
    case crop = "I want to learn how to crop photos"
    case edit = "I want to edit a saved card"
    case delete = "I want to delete a saved card"
    case reorder = "I want to reorder my cards"
    case scanning = "A barcode reader won't read my card"
    
    /// Title of this help section to be displayed in navbar heading
    var title: String {
        switch self {
        case .crop:
            return "Cropping Photos"
        case .edit:
            return "Editing a Card"
        case .delete:
            return "Deleting a Card"
        case .reorder:
            return "Reordering a Card"
        case .scanning:
            return "Tips to Improve Scanning"
        }
    }
    
    /// Asset name of gif video to display for this help section
    var videoAssetName: String {
        switch self {
        case .crop:
            return "helpVideoCropping"
        case .edit:
            return "helpVideoEditing"
        case .delete:
            return "helpVideoEditing"
        case .reorder:
            return "helpVideoReordering"
        case .scanning:
            return "helpVideoImproveScanning"
        }
    }
}
