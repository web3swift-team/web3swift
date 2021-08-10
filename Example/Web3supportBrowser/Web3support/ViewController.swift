//
//  ViewController.swift
//  Web3support
//
//  Created by Ravi Ranjan on 09/08/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var featureTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.conrollerInit()
        
    }


    func conrollerInit() {
        self.featureTableView.delegate = self
        self.featureTableView.dataSource = self
        
    }
    
    fileprivate func featureOptions() -> [String] {
        return ["dAPp"]
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return featureOptions().count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let featureCell = tableView.dequeueReusableCell(withIdentifier: "FeatureTableViewCell") as? FeatureTableViewCell else {
            return UITableViewCell()
        }
        featureCell.textLabel?.text = featureOptions()[indexPath.row]
        return featureCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            guard let dAppScreen = self.storyboard?.instantiateViewController(withIdentifier: "DappViewController") as? DappViewController else {
                return
            }
            self.navigationController?.pushViewController(dAppScreen, animated: true)
        default:
            return
        }
    }
}
