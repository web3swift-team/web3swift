//
//  MainViewController.swift
//  Web3SwiftExample
//
//  Created by Максим Алексеев  on 27.11.2021.
//

import UIKit
import web3swift

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
    private let examples = ["ENS", "Wallet", "Balance"]
    private let cellId = "MainViewControllerCellId"
    
    private let web3service = Web3SwiftService()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(settingsSelected))
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
    
    // MARK: - Selectors
    @objc private func settingsSelected() {
        let networkViewController = NetworkViewController()
        networkViewController.delegate = self
        networkViewController.title = "Network"
        networkViewController.web3Service = web3service
        navigationController?.pushViewController(networkViewController, animated: true)
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let ensViewController = ENSViewController()
            ensViewController.web3Service = web3service
            ensViewController.title = "ENS"
            navigationController?.pushViewController(ensViewController, animated: true)
        case 1:
            let walletViewController = WalletViewController()
            walletViewController.web3Service = web3service
            walletViewController.title = "Wallet"
            navigationController?.pushViewController(walletViewController, animated: true)
        case 2:
            let balanceViewController = BalanceViewController()
            balanceViewController.web3Service = web3service
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
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = examples[indexPath.row]
        return cell
    }
}

extension MainViewController: NetworkViewControllerDelegate {
    func networkSelected(networkId: Int) {
        web3service.changeCurrentNetwork(chainId: networkId)
    }
}
