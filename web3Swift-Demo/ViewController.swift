//
//  ViewController.swift
//  web3Swift-Demo
//
//  Created by Petr Korolev on 11/12/2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import UIKit
import CryptoSwift
import BigInt
import AwaitKit
import PromiseKit
import web3swift
import Foundation

class ViewController: UIViewController {

    @IBOutlet var addressTextField: UITextField!
    @IBOutlet var resultTextView: UITextView!
    @IBAction func request(_ sender: Any) {
//        resultTextView.text = ABIManager.getABI(address: self.addressTextField)
    }
    
    
    @IBAction func paste() {
        let pb: UIPasteboard = UIPasteboard.general
        addressTextField.text = pb.string
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let jsonString = "[{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\"}],\"name\":\"approveAndCall\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"remaining\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"inputs\":[{\"name\":\"_initialAmount\",\"type\":\"uint256\"},{\"name\":\"_tokenName\",\"type\":\"string\"},{\"name\":\"_decimalUnits\",\"type\":\"uint8\"},{\"name\":\"_tokenSymbol\",\"type\":\"string\"}],\"type\":\"constructor\"},{\"payable\":false,\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},]"
            async {
                do {
                    let constractAddress = EthereumAddress("0x45245bc59219eeaaf6cd3f382e078a461ff9de7b")
                    var options = Web3Options()
                    options.gas = BigUInt(250000)
                    options.gasPrice = BigUInt(25000000000)
                    options.from = EthereumAddress("0xE6877A4d8806e9A9F12eB2e8561EA6c1db19978d")
                    let parameters = [] as [AnyObject]
                    let web3main = Web3.InfuraMainnetWeb3()
                    let contract = web3main.contract(jsonString, at: constractAddress)
                    let intermediate = contract?.method("name", parameters:parameters,  options: options)
                    let result = try await((intermediate?.call(options: options))!)
                    print(result)
                    let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                    let keystoreManager = try KeystoreManagerV3(userDir + "/keystore")
                    var ks: EthereumKeystoreV3?
                    if (keystoreManager?.wallets.keys.count == 0) {
                        ks = try EthereumKeystoreV3(password: "BANKEXFOUNDATION")
                        let keydata = try JSONEncoder().encode(ks!.keystoreParams)
                        try FileManager.default.createFile(atPath: userDir + "/keystore"+"/key.json", contents: keydata, attributes: nil)
                    } else {
                        ks = keystoreManager?.wallets[(keystoreManager?.knownAddresses[0])!]
                    }
                    guard let sender = ks?.address else {return}
//                    let coldWalletABI = "[{\"payable\":true,\"type\":\"fallback\"}]"
//                    let coldWalletAddress = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")
//                    let coldWalletContract = web3.contract(coldWalletABI, at: coldWalletAddress)
//                    options = Web3Options.defaultOptions()
//                    options.gas = BigUInt(21000)
//                    options.from = ks?.address!
//                    options.value = BigUInt(1000000000000000)
//                    options.to = coldWalletAddress
//                    var intermediateSend = coldWalletContract?.method(options: options)
//                    let nonce = try await(web3.getNonce(sender, network: .Rinkeby))
//                    try intermediateSend?.setNonce(nonce!, network: .Rinkeby)
//                    let gasPrice = try await((intermediateSend?.estimateGas(options, network: .Rinkeby))!)
//                    print(gasPrice)
//                    intermediateSend = try ks!.signIntermediate(intermediate: intermediateSend!, password: "BANKEXFOUNDATION", network: .Rinkeby)
//                    let derivedSender = intermediateSend?.transaction.sender
//                    if (derivedSender?.address != sender.address) {
//                        print(derivedSender!.address)
//                        print(sender.address)
//                        print("Address mismatch")
////                        return
//                    }
//                    let res = try await((intermediateSend?.send(network: .Rinkeby))!)
//                    print(res)
                    let web3 = Web3.InfuraRinkebyWeb3()
                    let coldWalletABI = "[{\"payable\":true,\"type\":\"fallback\"}]"
                    let coldWalletAddress = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")
                    options = Web3Options.defaultOptions()
                    options.gas = BigUInt(21000)
                    options.from = ks?.address!
                    options.value = BigUInt(1000000000000000)
                    let gasPrice = try await((web3.contract(coldWalletABI, at: coldWalletAddress)?.method(options: options)?.estimateGas(options: nil))!)
                    let nonce = try await(web3.eth.getTransactionCount(address: sender))
                    var intermediateSend = web3.contract(coldWalletABI, at: coldWalletAddress)?.method(options: options)
                    try intermediateSend?.setNonce(nonce!)
                    intermediateSend = try ks!.signIntermediate(intermediate: intermediateSend!, password: "BANKEXFOUNDATION")
                    let derivedSender = intermediateSend?.transaction.sender
                    if (derivedSender?.address != sender.address) {
                        print(derivedSender!.address)
                        print(sender.address)
                        print("Address mismatch")
                        //                        return
                    }
                    let res = try await((intermediateSend?.send())!)
                    print(res)
                }
                catch{
                    print(error)
                }
            }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

