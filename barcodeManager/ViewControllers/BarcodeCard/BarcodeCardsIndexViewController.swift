//
//  BarcodeCardsIndexViewController
//  barcodeManager
//
//  Created by Kenneth Vaczi on 1/27/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import UIKit
import RSBarcodes
import MGSwipeTableCell
import AVFoundation
import FontAwesome_swift
import SwiftReorder

class BarcodeCardsIndexViewController: UITableViewController {
    
    // Variables to get swiftReorder to work with variable heights
    var spacerIndexPath: IndexPath? = nil

    let ShowBarcodeCardSegueIdentifier = "ShowBarcodeCardSegue"
    let EditBarcodeCardSegueIdentifier = "EditBarcodeCardSegue"
    
    private let editIcon = UIImage(cgImage: UIImage.fontAwesomeIcon(
                                        name: .edit,
                                        style: .solid,
                                        textColor: .white,
                                        size: CGSize(width: 100, height: 100)
                                        ).addCircleBackground(ofColor: .blue,
                                                              ofSize: CGSize(width: 140,
                                                                             height: 140)).cgImage!,
                                     scale: 2.0,
                                     orientation: .up)
    
    private let deleteIcon = UIImage(cgImage: UIImage.fontAwesomeIcon(
                                        name: .trashAlt,
                                        style: .solid,
                                        textColor: .white,
                                        size: CGSize(width: 100, height: 100)
                                        ).addCircleBackground(ofColor: .red,
                                                              ofSize: CGSize(width: 140,
                                                                             height: 140)).cgImage!,
                                    scale: 2.0,
                                    orientation: .up)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarButtons()
        
        // Required for reorder pod implementation
        tableView.reorder.delegate = self
        tableView.reorder.cellScale = 1.05
        tableView.reorder.shadowOpacity = 0
        tableView.reorder.cellOpacity = 0.8
        
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if BarcodeCards.instance.list().count > 0 {
            self.tableView.reloadData()
        } else {
            BarcodeCards.instance.loadFromFile() { didLoad in
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if  segue.identifier == ShowBarcodeCardSegueIdentifier,
            let destination = segue.destination as? ShowBarcodeCardViewController,
            let cardIndex = tableView.indexPathForSelectedRow?.row {
            destination.barcodeCard = BarcodeCards.instance.list()[cardIndex]
        }
        
        if  segue.identifier == EditBarcodeCardSegueIdentifier,
            let destination = segue.destination as? EditBarcodeCardViewController,
            let cardToEdit = sender as? BarcodeCard {
            destination.barcodeCard = cardToEdit
        }
        
    }

}


// MARK: - UITableViewDataSource
extension BarcodeCardsIndexViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BarcodeCards.instance.list().count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 20))
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let barcodeCard = BarcodeCards.instance.list()[indexPath.row]
        if  let photoSize = barcodeCard.photoSize {
            let cellWidth = self.tableView.bounds.width + 40
            return (photoSize.height / photoSize.width) * (cellWidth)
        }
        return 50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /// Required for reorder pod implementation
        let isSpacerCell = tableView.reorder.spacerCell(for: indexPath) != nil
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BarcodeCell",
                                                 for: indexPath) as! BarcodeCardTableViewCell
        
        let barcodeCard = BarcodeCards.instance.list()[indexPath.row]
        
        if  let photoSize = barcodeCard.photoSize {
            let imageWidth = cell.cardPhotoImageView.bounds.size.width
            cell.cardPhotoImageHeightConstraint.constant = (photoSize.height / photoSize.width) * (imageWidth)
        }
    
        if isSpacerCell {
            cell.cardPhotoImageView.image = nil
        } else {
            cell.cardPhotoImageView.image = barcodeCard.photo
            cell.cardPhotoImageView.layer.cornerRadius = 25
            cell.cardPhotoImageView.clipsToBounds = true
            self.addSwipeButtonsTo(cell, for: barcodeCard)
        }
        
        return cell
    }
    
}

// MARK: - TableViewReorderDelegate
extension BarcodeCardsIndexViewController: TableViewReorderDelegate {
    
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {
        UIImpactFeedbackGenerator().impactOccurred()
        BarcodeCards.instance.moveCard(fromPosition: sourceIndexPath.row,
                                       toPosition: destinationIndexPath.row, save: false)
    }
    
    func tableViewDidBeginReordering(_ tableView: UITableView, at indexPath: IndexPath) {
        UIImpactFeedbackGenerator().impactOccurred()
    }
    
    func tableViewDidFinishReordering(_ tableView: UITableView, from initialSourceIndexPath: IndexPath,
                                      to finalDestinationIndexPath: IndexPath) {
        UIImpactFeedbackGenerator().impactOccurred()
        BarcodeCards.instance.saveToFile()
    }
    
}

// MARK: - Custom Functions
extension BarcodeCardsIndexViewController {
    
    func setupNavigationBarButtons() {
        
        let setupIcon = UIImage.fontAwesomeIcon(name: .cog,
                                                style: .solid,
                                                textColor: .white,
                                                size: CGSize(width: 30, height: 30))
        self.navigationItem.leftBarButtonItem?.image = setupIcon
        self.navigationItem.leftBarButtonItem?.title = nil
        
        let newIcon = UIImage.fontAwesomeIcon(name: .plusCircle,
                                                style: .solid,
                                                textColor: .white,
                                                size: CGSize(width: 30, height: 30))
        self.navigationItem.rightBarButtonItem?.image = newIcon
        self.navigationItem.rightBarButtonItem?.title = nil
        
    }
    
    func addSwipeButtonsTo(_ cell: MGSwipeTableCell, for barcodeCard: BarcodeCard) {
        
        let deleteSwipeButton = MGSwipeButton(title: "", icon: deleteIcon,
                                              backgroundColor: .clear,
                                              insets: .init(top: 0, left: 0, bottom: 0, right: 35),
                                              callback: { _ in
                                                
            UIImpactFeedbackGenerator().impactOccurred()
            let titleDisplay = (barcodeCard.title != nil) ? barcodeCard.title! : "this code"
            let alert = UIAlertController(title: "Are you sure?", message: "Delete \(titleDisplay)?",
                preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
                BarcodeCards.instance.remove(barcodeCard)
                self.tableView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
            return true
                                                
        })
        
        let eI = UIImage(cgImage: self.editIcon.cgImage!, scale: 2, orientation: .up)
        
        let editSwipeButton = MGSwipeButton(title: "", icon: eI, backgroundColor: .clear,
                                            insets: .init(top: 0, left: 0, bottom: 0, right: 0),
                                            callback: { _ in
                                                
            UIImpactFeedbackGenerator().impactOccurred()
            self.performSegue(withIdentifier: self.EditBarcodeCardSegueIdentifier, sender: barcodeCard)
            return true
                                                
        })
        
        cell.rightButtons = [deleteSwipeButton, editSwipeButton]
        cell.rightSwipeSettings.transition = .drag
        
    }
    
}
