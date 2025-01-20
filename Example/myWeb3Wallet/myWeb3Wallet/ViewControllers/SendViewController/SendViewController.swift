//
//  SendViewController.swift
//  myWeb3Wallet
//
//  Created by 6od9i on 15/01/25.
//

import UIKit
import Web3Core
import web3swift
import BigInt

final class SendViewController: UIViewController {
    private let walletManager: WalletManager
    private let network: Web3Network
    private let token: Token

    private let sendButton: UIButton = {
        let button = UIButton()
        button.setTitle("Send", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        return button
    }()

    private let closeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        return button
    }()

    var address: EthereumAddress? {
        didSet {
            sendButton.isEnabled = amount != nil && address != nil
        }
    }

    var amount: BigUInt? {
        didSet {
            sendButton.isEnabled = amount != nil && address != nil
        }
    }

    let addressField: UITextField = {
        let field = UITextField()
        field.placeholder = "Address"
        field.borderStyle = .roundedRect
        return field
    }()

    let amountField: UITextField = {
        let field = UITextField()
        field.placeholder = "Amount"
        field.borderStyle = .roundedRect
        field.keyboardType = .decimalPad
        return field
    }()

    init(walletManager: WalletManager, network: Web3Network, token: Token) {
        self.walletManager = walletManager
        self.network = network
        self.token = token
        super.init(nibName: nil, bundle: nil)
        sendButton.isEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        [closeButton, addressField, amountField, sendButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true

        addressField.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 16).isActive = true
        addressField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        addressField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true

        amountField.topAnchor.constraint(equalTo: addressField.bottomAnchor, constant: 16).isActive = true
        amountField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        amountField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true

        sendButton.topAnchor.constraint(equalTo: amountField.bottomAnchor,
                                        constant: 24).isActive = true
        sendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3).isActive = true

        [addressField, amountField].forEach {
            $0.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        }

        sendButton.addTarget(self, action: #selector(send), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    }

    @objc func close() {
        navigationController?.popViewController(animated: true)
    }

    @objc func textChanged() {
        let address = addressField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let amount = amountField.text?.trimmingCharacters(in: .whitespacesAndNewlines)

        self.address = if let address { EthereumAddress(address) } else { nil }
        self.amount = if let amount,
                         let amountBigInt = Utilities.parseToBigUInt(amount, decimals: token.decimals) {
            amountBigInt
        } else {
            nil
        }
    }

    @objc func send() {
        Task { @MainActor in
            do {
                try await sendToken()
            } catch {
                let alertController = UIAlertController(title: "Error", message: error.localizedDescription,
                                                        preferredStyle: .alert)
                let action = UIAlertAction.init(title: "Cancel", style: .destructive)
                alertController.addAction(action)
                self.present(alertController, animated: true)
            }
        }
    }

    func sendToken() async throws {
        guard let address, let amount else { return }

        var transaction: CodableTransaction = .emptyTransaction
        /// from = address of your wallet for sending
        transaction.from = walletManager.address
        transaction.gasPrice = try await network.web3.eth.gasPrice()

        var writeOperation: WriteOperation

        if token.isNative {
            transaction.to = address
            transaction.value = amount /// for native token use token amount here

            /// for native token could be created "fallback" transaction from coldWalletABI
            /// in this case address for contract is your address, because native tokens not used contracts and stored on your native wallet

            let contract = network.web3.contract(Web3.Utils.coldWalletABI, at: address, abiVersion: 2)

            transaction.gasPrice = nil
            transaction.gasLimit = 0
            contract?.transaction = transaction

            /// have no parameters in this function
            guard let nativeOperation = contract?.createWriteOperation("fallback", parameters: []) else {
                throw NSError(domain: "Unknown", code: 400)
            }
            writeOperation = nativeOperation
        } else {
            guard let tokenAddress = EthereumAddress(token.address) else {
                throw NSError(domain: "Unknown", code: 400)
            }

            transaction.to = tokenAddress /// Address of token contract for call transfer
            transaction.value = 0 /// Value is value of native token, when call contract for transfer - should be 0

            /// Tokens in EVM used erc20 should be sended with "transfer" metnod
            /// it should be called on contract by address of token, ! not owner address and not target address !
            let contract = network.web3.contract(Web3.Utils.erc20ABI, at: EthereumAddress(token.address),
                                                 abiVersion: 2)

            transaction.gasPrice = nil
            transaction.gasLimit = 0
            contract?.transaction = transaction

            /// Write operation of "transfer" for estimate gas should be created with 2 params - target address and amount of token
            guard let tokenOperation = contract?.createWriteOperation(
                "transfer",
                parameters: [address as AnyObject, amount as AnyObject]) else {
                throw NSError(domain: "Unknown", code: 400)
            }
            writeOperation = tokenOperation
        }

        transaction.gasLimit = try await network.web3.eth.estimateGas(for: writeOperation.transaction)
        transaction.gasPrice = try await network.web3.eth.gasPrice()

        let policies = Policies(noncePolicy: .latest,
                                gasLimitPolicy: .manual(transaction.gasLimit),
                                gasPricePolicy: .manual(transaction.gasPrice ?? 0),
                                maxFeePerGasPolicy: .automatic,
                                maxPriorityFeePerGasPolicy: .automatic)

        let hash = try await writeOperation.writeToChain(password: WalletManager.keystorePassword,
                                                         policies: policies).hash
        print(hash)
        try await checkTransaction(hash: hash)
    }

    func checkTransaction(hash: String) async throws {
        var txStatus = TransactionReceipt.TXStatus.notYetProcessed
        while txStatus == .notYetProcessed {
            sleep(1)
            guard let receipt = try? await network.web3.eth.transactionReceipt(Data(hex: hash)) else { continue }
            txStatus = receipt.status
        }

        let alertController = UIAlertController(title: txStatus == .ok ? "Complete" : "Failed",
                                                message: "TX Hash: \(hash)",
                                                preferredStyle: .alert)
        let copyAction = UIAlertAction.init(title: "Copy hash and close", style: .default) { _ in
            UIPasteboard.general.string = hash
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(copyAction)

        let action = UIAlertAction.init(title: "Close", style: .destructive) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(action)
        self.present(alertController, animated: true)
    }
}
