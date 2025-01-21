//
//  DashboardViewController.swift
//  myWeb3Wallet
//
//  Created by Ravi Ranjan on 22/10/21.
//

import UIKit

class DashboardViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        UIView.animate(withDuration: 0.9) {
            self.logoImageView.center.y = self.view.center.y

        }
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
