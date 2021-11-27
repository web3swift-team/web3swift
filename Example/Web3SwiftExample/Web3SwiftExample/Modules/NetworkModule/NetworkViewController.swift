//
//  NetworkViewController.swift
//  Web3SwiftExample
//
//  Created by Максим Алексеев  on 05.11.2021.
//

import UIKit

struct NetworkItem {
    let name: String
    let imageName: String
}

class NetworkViewController: UIViewController {
    private let dataSource: [NetworkItem] = [.init(name: "Rinkeby", imageName: "rinkebyImage"), .init(name: "Ropsten", imageName: "ropstenImage"), .init(name: "Kovan", imageName: "kovanImage")]
    
    // MARK: - Views
    
//    @IBOutlet weak var networksTableView: UITableView!
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        Bundle.main.loadNibNamed("NetworkViewController", owner: self, options: nil)
    }
    
    // MARK: - Setups
    private func setupTableView() {
//        networksTableView.delegate = self
//        networksTableView.dataSource = self
    }
}

extension NetworkViewController: UITableViewDelegate {
    
}

extension NetworkViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkViewControllerCellId", for: indexPath)
        cell.imageView?.image = UIImage(named: dataSource[indexPath.row].imageName)
        cell.textLabel?.text = dataSource[indexPath.row].name
        return cell
    }   
}
