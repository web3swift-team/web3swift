//
//  MainViewController.swift
//  Web3SwiftExample
//
//  Created by Максим Алексеев  on 27.11.2021.
//

import UIKit

class MainViewController: UIViewController {
    // MARK: - View
    lazy private var exampleTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Properties
    private let examples = ["ENS", "Wallet", "Network", "Balance"]
    private let cellId = "MainViewControllerCellId"
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
    }
    
    // MARK: - Setup
    private func setupLayout() {
        view.addSubview(exampleTableView)
        NSLayoutConstraint.activate([
            exampleTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            exampleTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            exampleTableView.topAnchor.constraint(equalTo: view.topAnchor),
            exampleTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let ensViewController = ENSViewController()
            ensViewController.title = "ENS"
            navigationController?.pushViewController(ensViewController, animated: true)
        case 1:
            let walletViewController = WalletViewController()
            walletViewController.title = "Wallet"
            navigationController?.pushViewController(walletViewController, animated: true)
        case 2:
            let networkViewController = NetworkViewController()
            networkViewController.title = "Network"
            navigationController?.pushViewController(networkViewController, animated: true)
        case 3:
            let balanceViewController = BalanceViewController()
            balanceViewController.title = "Balance"
            navigationController?.pushViewController(balanceViewController, animated: true)
        default:
            break 
        }
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examples.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.text = examples[indexPath.row]
        return cell
    }
}
