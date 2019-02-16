//
//  ShowBarcodeCardViewController.swift
//  barcodeManager
//
//  Created by Kenneth Vaczi on 1/30/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import UIKit
import RSBarcodes
import AVFoundation

class ShowBarcodeCardViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var barcodeImageView: UIImageView!
    
    var barcodeCard: BarcodeCard?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
    }
    
    func updateView() {
        guard let barcodeCard = self.barcodeCard else { return }
        self.titleLabel.text = barcodeCard.title
        self.barcodeImageView.image = barcodeCard.barcodeImage
        self.barcodeImageView.contentMode = .scaleAspectFit
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditBarcodeCardSegueIdentifier" {
            guard let destination = segue.destination as? EditBarcodeCardViewController else {
                return
            }
            destination.barcodeCard = self.barcodeCard
        }
    }
 

}
