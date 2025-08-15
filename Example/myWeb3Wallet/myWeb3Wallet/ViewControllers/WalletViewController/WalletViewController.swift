//
//  WalletViewController.swift
//  myWeb3Wallet
//
//  Created by 6od9i on 15/01/25.
//

import UIKit
import Web3Core
import BigInt

final class WalletViewController: UIViewController {
    private let walletManager: WalletManager

    private let sendButton: UIButton = {
        let button = UIButton()
        button.setTitle("Send", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        return button
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(TokenCell.self, forCellReuseIdentifier: "TokenCell")
        tableView.register(WalletCell.self, forCellReuseIdentifier: "WalletCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.allowsSelection = false
        tableView.refreshControl = UIRefreshControl()
        return tableView
    }()

    init(walletManager: WalletManager) {
        self.walletManager = walletManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        [tableView, sendButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        tableView.bottomAnchor.constraint(equalTo: sendButton.topAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        sendButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                           constant: -16).isActive = true
        sendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3).isActive = true

        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl?.addTarget(self, action: #selector(loadBalances), for: .valueChanged)
        loadBalances()

        sendButton.addTarget(self, action: #selector(send), for: .touchUpInside)
    }

    @objc func send() {
        selectChain()
    }
    func selectChain() {
        let alertController = UIAlertController(title: "Select chain", message: "", preferredStyle: .actionSheet)
        for network in walletManager.networks {
            let action = UIAlertAction(title: network.network.name, style: .default) { [weak self] _ in
                self?.selectToken(network: network)
            }
            alertController.addAction(action)
        }

        let action = UIAlertAction.init(title: "Cancel", style: .destructive)
        alertController.addAction(action)

        self.present(alertController, animated: true)
    }

    func selectToken(network: Web3Network) {
        let alertController = UIAlertController(title: "Select token", message: "", preferredStyle: .actionSheet)
        for token in network.network.tokens {
            let action = UIAlertAction(title: token.symbol, style: .default) { [weak self] _ in
                self?.sendToken(token, from: network)
            }
            alertController.addAction(action)
        }

        let action = UIAlertAction.init(title: "Cancel", style: .destructive)
        alertController.addAction(action)

        self.present(alertController, animated: true)
    }

    func sendToken(_ token: Token, from network: Web3Network) {
        let sendVC = SendViewController(walletManager: walletManager, network: network, token: token)
        navigationController?.pushViewController(sendVC, animated: true)
    }
}

extension WalletViewController {
    @objc func loadBalances() {
        Task { @MainActor in
            await walletManager.loadBalances()
            tableView.refreshControl?.endRefreshing()
            tableView.reloadData()
        }
    }
}

extension WalletViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        walletManager.networks.count + 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        return walletManager.networks[section - 1].network.tokens.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "WalletCell", for: indexPath) as? WalletCell
            else { fatalError() }
            cell.address = walletManager.address.address
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TokenCell", for: indexPath) as? TokenCell
            else { fatalError() }
            let network = walletManager.networks[indexPath.section - 1]
            let token = network.network.tokens[indexPath.row]
            cell.network = network.network.name
            cell.name = token.symbol

            if let balance = network.tokensBalances[token.symbol] {
                let doubleString = Utilities.formatToPrecision(balance, units: .custom(token.decimals),
                                                               formattingDecimals: 10)
                cell.balance = doubleString
            } else {
                cell.balance = "Loading..."
            }
            return cell
        }

    }
}
