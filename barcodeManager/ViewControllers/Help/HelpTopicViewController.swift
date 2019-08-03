//
//  HelpTopicViewController.swift
//  barcodeManager
//
//  Created by Kenneth Vaczi on 8/2/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import UIKit
import SwiftGifOrigin

/// Displays a help video (gif animation)
class HelpTopicViewController: UIViewController {

    /// This is where help video gif animation is showed
    @IBOutlet weak var helpVideoImageView: UIImageView!
    /// Loading indicator to pop up while animation is loading
    @IBOutlet weak var loadingIndicatorView: UIView!
    
    /// Which help section are we displaying a video for
    var helpSection: HelpSection? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = helpSection?.title
        showLoadingIndicator()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        playHelpVideo()
    }
    
    /// Display loading indicator
    func showLoadingIndicator() {
        let spinnerView = UIView.init(frame: loadingIndicatorView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            self.loadingIndicatorView.addSubview(spinnerView)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10) {
            ai.stopAnimating()
        }
    }
    
    /// Load gif animation and display in image view
    func playHelpVideo() {
        guard let helpSection = helpSection else { return }
        helpVideoImageView.loadGif(asset: helpSection.videoAssetName)
    }

}
