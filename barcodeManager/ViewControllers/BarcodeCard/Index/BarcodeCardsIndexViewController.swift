//
//  BarcodeCardsIndexViewController
//  barcodeManager
//
//  Created by Kenneth Vaczi on 1/27/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import UIKit
import RSBarcodes_Swift
import MGSwipeTableCell
import AVFoundation
import FontAwesome_swift
import SwiftReorder

class BarcodeCardsIndexViewController: UITableViewController {

    let ShowBarcodeCardSegueIdentifier = "ShowBarcodeCardSegue"
    let EditBarcodeCardSegueIdentifier = "EditBarcodeCardSegue"
    
    private let editIcon = UIImage(cgImage: UIImage.fontAwesomeIcon(
                                        name: .edit,
                                        style: .solid,
                                        textColor: .white,
                                        size: CGSize(width: 200, height: 200)
                                        ).addCircleBackground(ofColor: .lightGray,
                                                              ofSize: CGSize(width: 280,
                                                                             height: 280)).cgImage!,
                                     scale: 4.0,
                                     orientation: .up)
    
    private let deleteIcon = UIImage(cgImage: UIImage.fontAwesomeIcon(
                                        name: .trashAlt,
                                        style: .solid,
                                        textColor: .white,
                                        size: CGSize(width: 200, height: 200)
                                        ).addCircleBackground(ofColor: .red,
                                                              ofSize: CGSize(width: 280,
                                                                             height: 280)).cgImage!,
                                    scale: 4.0,
                                    orientation: .up)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BarcodeCards.instance.loadCardsIndex()
        
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
        self.tableView.reloadData()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if  segue.identifier == ShowBarcodeCardSegueIdentifier,
            let destination = segue.destination as? ShowBarcodeCardViewController,
            let cardToShow = sender as? BarcodeCard {
            
            destination.barcodeCard = cardToShow
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

    // Sections Setup
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BarcodeCards.instance.numberOfSavedCards()
    }
    
    // Header Setup
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
    
    // Body Setup
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard   let barcodeCard = BarcodeCards.instance.loadCard(withIndex: indexPath.row),
                let photoSize = barcodeCard.photoSize else { return 50 }
        let cellWidth = self.tableView.bounds.width + 40
        return (photoSize.height / photoSize.width) * (cellWidth)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /// Required for reorder pod implementation
        let isSpacerCell = tableView.reorder.spacerCell(for: indexPath) != nil

        let cell = tableView.dequeueReusableCell(withIdentifier: "BarcodeCell",
                                                 for: indexPath) as! BarcodeCardTableViewCell
        
        guard let barcodeCard = BarcodeCards.instance.loadCard(withIndex: indexPath.row) else {
            return cell            
        }
        
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let barcodeToShow = BarcodeCards.instance.loadCard(withIndex: indexPath.row) {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: self.ShowBarcodeCardSegueIdentifier,
                                  sender: barcodeToShow)
            }
        }
    }
    
}

// MARK: - MGSwipeTableCellDelegate
extension BarcodeCardsIndexViewController: MGSwipeTableCellDelegate {
    
    func swipeTableCell(_ cell: MGSwipeTableCell, didChange state: MGSwipeState, gestureIsActive: Bool) {
        // Prevent cell reordering while cell is swiped
        switch state {
        case .swipingRightToLeft:
            self.tableView.reorder.isEnabled = false
        default:
            self.tableView.reorder.isEnabled = true
        }
    }
    
}

// MARK: - TableViewReorderDelegate
extension BarcodeCardsIndexViewController: TableViewReorderDelegate {
    
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {
        UIImpactFeedbackGenerator().impactOccurred()
        BarcodeCards.instance.moveCard(fromPosition: sourceIndexPath.row,
                                       toPosition: destinationIndexPath.row)        
    }
    
    func tableViewDidBeginReordering(_ tableView: UITableView, at indexPath: IndexPath) {
        UIImpactFeedbackGenerator().impactOccurred()
    }
    
    func tableViewDidFinishReordering(_ tableView: UITableView, from initialSourceIndexPath: IndexPath,
                                      to finalDestinationIndexPath: IndexPath) {
        UIImpactFeedbackGenerator().impactOccurred()
    }
    
}

// MARK: - Custom Functions
extension BarcodeCardsIndexViewController {
    
    func setupNavigationBarButtons() {
                
        let logoImage = UIImage.init(named: "logoTop")
        let logoImageView = UIImageView.init(image: logoImage)
        logoImageView.frame = CGRect(x: -40, y: 0, width: 150, height: 25)
        logoImageView.contentMode = .scaleAspectFit
        let imageItem = UIBarButtonItem.init(customView: logoImageView)
        let widthConstraint = logoImageView.widthAnchor.constraint(equalToConstant: 60)
        widthConstraint.isActive = true
        navigationItem.leftBarButtonItem = imageItem
        
        let setupIcon = UIImage.fontAwesomeIcon(name: .cog,
                                                style: .solid,
                                                textColor: .white,
                                                size: CGSize(width: 30, height: 30))
        self.navigationItem.rightBarButtonItems?[0].image = setupIcon
        self.navigationItem.rightBarButtonItems?[0].title = nil
        
        let newIcon = UIImage.fontAwesomeIcon(name: .plusCircle,
                                                style: .solid,
                                                textColor: .white,
                                                size: CGSize(width: 30, height: 30))
        self.navigationItem.rightBarButtonItems?[1].image = newIcon
        self.navigationItem.rightBarButtonItems?[1].title = nil
        
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
                BarcodeCards.instance.removeCardWith(uid: barcodeCard.uid, callBack: { didRemove in
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                })
                
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
            return true
                                                
        })
        
        let editSwipeButton = MGSwipeButton(title: "", icon: editIcon, backgroundColor: .clear,
                                            insets: .init(top: 0, left: 0, bottom: 0, right: 0),
                                            callback: { _ in
                                                
            UIImpactFeedbackGenerator().impactOccurred()
            self.performSegue(withIdentifier: self.EditBarcodeCardSegueIdentifier, sender: barcodeCard)
            return true
                                                
        })
        
        cell.rightButtons = [deleteSwipeButton, editSwipeButton]
        cell.rightSwipeSettings.transition = .drag
        cell.delegate = self
    }
    
}
