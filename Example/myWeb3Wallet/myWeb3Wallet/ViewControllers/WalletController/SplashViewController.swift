//
//  SplashViewController.swift
//  myWeb3Wallet
//
//  Created by Ravi Ranjan on 22/10/21.
//

import UIKit

class SplashViewController: UIViewController {

    @IBOutlet weak var logoView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(withDuration: 0.9) {
            self.logoView.center.y = self.view.center.y
            Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.moveToWalletView), userInfo: nil, repeats: false)

        }

        // Do any additional setup after loading the view.
    }
    @objc func moveToWalletView() {

        guard let walletScreen = self.storyboard?.instantiateViewController(withIdentifier: "WalletViewController") as? WalletViewController else {
            #if DEBUG
            printContent("Unable to get Wallet controller")
            #endif
            return
        }
        self.navigationController?.pushViewController(walletScreen, animated: true)
    }
}
