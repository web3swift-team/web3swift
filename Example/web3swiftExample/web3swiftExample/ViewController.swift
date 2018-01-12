//
//  ViewController.swift
//  web3swiftExample
//
//  Created by Alexander Vlasov on 22.12.2017.
//  Copyright © 2017 Alexander Vlasov. All rights reserved.
//

import UIKit
import BigInt
import AwaitKit
import PromiseKit
import web3swift
import Foundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let jsonString = "[{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\"}],\"name\":\"approveAndCall\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"remaining\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"inputs\":[{\"name\":\"_initialAmount\",\"type\":\"uint256\"},{\"name\":\"_tokenName\",\"type\":\"string\"},{\"name\":\"_decimalUnits\",\"type\":\"uint8\"},{\"name\":\"_tokenSymbol\",\"type\":\"string\"}],\"type\":\"constructor\"},{\"payable\":false,\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},]"
        async {
            do {
                let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let keystoreManager = KeystoreManager.managerForPath(userDir + "/keystore")
                var ks: EthereumKeystoreV3?
                if (keystoreManager?.wallets.keys.count == 0) {
                    ks = try EthereumKeystoreV3(password: "BANKEXFOUNDATION")
                    let keydata = try JSONEncoder().encode(ks!.keystoreParams)
                    FileManager.default.createFile(atPath: userDir + "/keystore"+"/key.json", contents: keydata, attributes: nil)
                } else {
                    ks = keystoreManager?.wallets[(keystoreManager?.knownAddresses[0])!]
                }
                guard let sender = ks?.addresses?.first else {return}
                print(sender)
                
                // BKX TOKEN
                
                let constractAddress = EthereumAddress("0x45245bc59219eeaaf6cd3f382e078a461ff9de7b")
                var options = Web3Options()
                options.gas = BigUInt(250000)
                options.gasPrice = BigUInt(25000000000)
                options.from = EthereumAddress("0xE6877A4d8806e9A9F12eB2e8561EA6c1db19978d")
                let parameters = [] as [AnyObject]
                let web3Main = Web3.InfuraMainnetWeb3()
                web3Main.addKeystoreManager(keystoreManager)
                let contract = web3Main.contract(jsonString, at: constractAddress)
                let intermediate = contract?.method("name", parameters:parameters,  options: options)
                var res = intermediate?.call(options: options)
                guard let result = res else {return}
                print("BKX token name = " + (result["0"] as! String))
                
                let erc20receipt = web3Main.eth.getTransactionReceipt("0x76bb19c0b7e2590f724871960599d28db99cd587506fdfea94062f9c8d61eb30")
                for l in (erc20receipt?.logs)! {
                    guard let result = contract?.parseEvent(l), let name = result.eventName, let data = result.eventData else {continue}
                    print("Parsed event " + name)
                    print("Parsed content")
                    print(data)
                }
                // Block number on Main
                
                let blockNumber = web3Main.eth.getBlockNumber()
                print("Block number = " + String(blockNumber!))
                
                
                let gasPrice = web3Main.eth.getGasPrice()
                print("Gas price = " + String(gasPrice!))
                
                
                //Send on Rinkeby
                
                let web3Rinkeby = Web3.InfuraRinkebyWeb3()
                web3Rinkeby.addKeystoreManager(keystoreManager)
                let coldWalletABI = "[{\"payable\":true,\"type\":\"fallback\"}]"
                let coldWalletAddress = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")
                options = Web3Options.defaultOptions()
                options.gas = BigUInt(21000)
                options.from = ks?.addresses?.first!
                options.value = BigUInt(1000000000000000)
                options.from = sender
                let estimatedGas = web3Rinkeby.contract(coldWalletABI, at: coldWalletAddress)?.method(options: options)?.estimateGas(options: nil)
                options.gas = estimatedGas
                let intermediateSend = web3Rinkeby.contract(coldWalletABI, at: coldWalletAddress)?.method(options: options)
                res = intermediateSend?.send(password: "BANKEXFOUNDATION")
                let derivedSender = intermediateSend?.transaction.sender
                if (derivedSender?.address != sender.address) {
                    print(derivedSender!.address)
                    print(sender.address)
                    print("Address mismatch")
                }
                let txid = res!["txhash"] as? String
                print("On Rinkeby TXid = " + txid!)
                
                //Balance on Rinkeby
                let balance = web3Rinkeby.eth.getBalance(address: coldWalletAddress)
                print("Balance of " + coldWalletAddress.address + " = " + String(balance!))
                
                
                //get TX details
                
                let details = web3Rinkeby.eth.getTransactionDetails("0x8ef43236af52e344353590c54089d5948e2182c231751ac1fb370409fdd0c76a")
                
                print(details)
                var receipt = web3Rinkeby.eth.getTransactionReceipt("0x8ef43236af52e344353590c54089d5948e2182c231751ac1fb370409fdd0c76a")
                print(receipt)
                receipt =  web3Rinkeby.eth.getTransactionReceipt("0x5f36355eae23e164003753f6e794567f963a658effab922620bb64459f130e1e")
                print(receipt)
                
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

