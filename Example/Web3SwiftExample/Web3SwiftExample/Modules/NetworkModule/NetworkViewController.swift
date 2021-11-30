//
//  NetworkViewController.swift
//  Web3SwiftExample
//
//  Created by Максим Алексеев  on 05.11.2021.
//

import UIKit

protocol NetworkViewControllerDelegate: AnyObject {
    func networkSelected(networkId: Int)
}

struct NetworkItem {
    let name: String
    let id: Int
}

class NetworkViewController: UIViewController {
    // MARK: - Dependencies
    var web3Service: Web3SwiftService! 
    
    // MARK: - Properties
    private var dataSource: [NetworkItem] = [
        .init(name: "Mainnet", id: 1),
        .init(name: "Ropsten", id: 3),
        .init(name: "Kovan", id: 42),
        .init(name: "Rinkeby", id: 4)
    ]
    
    private let cellId = "NetworkViewControllerCellId"
    
    weak var delegate: NetworkViewControllerDelegate? 
    
    // MARK: - Views
    private lazy var networksTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonSelected))
    }
    
    // MARK: - Setups
    private func setupTableView() {
        view.addSubview(networksTableView)
        NSLayoutConstraint.activate([
            networksTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            networksTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            networksTableView.topAnchor.constraint(equalTo: view.topAnchor),
            networksTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    // MARK: - Selectors
    @objc private func addButtonSelected() {
        let alertViewController = UIAlertController(title: "Add your custom network", message: nil, preferredStyle: .alert)
        
        alertViewController.addTextField { textField in
            textField.placeholder = "Custom network name"
        }
        
        alertViewController.addTextField { textField in
            textField.placeholder = "Custom network id"
            textField.keyboardType = .numberPad
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            if let nameTextField = alertViewController.textFields?[0],
               let idTextField  = alertViewController.textFields?[1] {
                guard let idText = idTextField.text,
                      let id = Int(idText),
                      let name = nameTextField.text
                else { return }
                
                self.saveNetwork(name: name, with: id)
            }
        }
        alertViewController.addAction(saveAction)
        present(alertViewController, animated: true)
    }
    
    // MARK: - Private
    private func saveNetwork(name: String, with chainId: Int) {
        web3Service.changeCurrentNetwork(chainId: chainId)
        let customNetwork = NetworkItem(name: name, id: chainId)
        dataSource.append(customNetwork)
        networksTableView.reloadData()
    }
}

// MARK: - UITableViewDelegate
extension NetworkViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.networkSelected(networkId: dataSource[indexPath.row].id)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension NetworkViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkViewControllerCellId", for: indexPath)
        let network = dataSource[indexPath.row]
        cell.textLabel?.text = "\(network.name) - \(network.id)"
        return cell
    }   
}
