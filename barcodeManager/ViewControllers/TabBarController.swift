//
//  TabBarController.swift
//  barcodeManager
//
//  Created by Kenneth Vaczi on 2/3/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import UIKit
import FontAwesome_swift

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeTabs()
        // Do any additional setup after loading the view.
    }
    
    func customizeTabs() {
        guard let tabBarItems = self.tabBar.items else { return }
        tabBarItems[0].image = UIImage.fontAwesomeIcon(name: .home,
                                                       style: .solid,
                                                       textColor: .black,
                                                       size: CGSize(width: 30, height: 30))
        tabBarItems[1].image = UIImage.fontAwesomeIcon(name: .plusCircle,
                                                       style: .solid,
                                                       textColor: .black,
                                                       size: CGSize(width: 30, height: 30))
        tabBarItems[2].image = UIImage.fontAwesomeIcon(name: .cog,
                                                       style: .solid,
                                                       textColor: .black,
                                                       size: CGSize(width: 30, height: 30))
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
