# Usage

## Account Management

#### Preffered Key Wallet Model

```swift
    struct KeyWalletModel {
        let address: String
        let data: Data?
        let name: String
        let isHD: Bool

        static func fromCoreData(crModel: KeyWallet) -> KeyWalletModel {
    	    let model = KeyWalletModel(address: crModel.address ?? "",
				       data: crModel.data,
				       name: crModel.name ?? "",
				       isHD: crModel.isHD)
	    return model
        }
    }

    extension KeyWalletModel: Equatable {
        static func == (lhs: KeyWalletModel, rhs: KeyWalletModel) -> Bool {
	    return lhs.address == rhs.address
        }
    }

    struct HDKey {
        let name: String?
        let address: String
    }
```

### Create Account

#### Create Account With Private Key
```swift
    public func createWalletWithPrivateKey(withName: String?,
                                           password: String,
                                           completion: @escaping (KeyWalletModel?, Error?) -> Void)
    {
        guard let newWallet = try? EthereumKeystoreV3(password: password) else {
            completion(nil, WalletSavingError.couldNotCreateKeystore)
            return
        }
        guard let wallet = newWallet, wallet.addresses?.count == 1 else {
            completion(nil, WalletSavingError.couldNotCreateWalletWithAddress)
            return
        }
        guard let keyData = try? JSONEncoder().encode(wallet.keystoreParams) else {
            completion(nil, WalletSavingError.couldNotGetKeyData)
            return
        }
        guard let address = wallet.addresses?.first?.address else {
            completion(nil, WalletSavingError.couldNotCreateAddress)
            return
        }
        let walletModel = KeyWalletModel(address: address,
	                                 data: keyData,
					 name: withName ?? "",
					 isHD: false)
        completion(walletModel, nil)
    }
    	
```

#### Create Account With Mnemonics Phrase
```swift
    func generateMnemonics(bitsOfEntropy: Int) -> String? {
        guard let mnemonics = try? BIP39.generateMnemonics(bitsOfEntropy: bitsOfEntropy),
            let unwrapped = mnemonics else {
                return nil
        }
        return unwrapped
    }
    
    func createHDWallet(withName name: String?,
                        password: String,
			completion: @escaping (KeyWalletModel?, Error?) -> Void)
    {
    
    	guard let mnemonics = keysService.generateMnemonics(bitsOfEntropy: 128) else {
	    completion(nil, WalletSavingError.couldNotGenerateMnemonics)
            return
	}
	
	guard let keystore = try? BIP32Keystore(
	                                        mnemonics: mnemonics,
                                                password: password,
                                                mnemonicsPassword: "",
                                                language: .english
						),
						let wallet = keystore else { 
	    completion(nil, WalletSavingError.couldNotCreateKeystore)
	    return 
	}
        guard let address = wallet.addresses?.first?.address else {
            completion(nil, WalletSavingError.couldNotCreateAddress)
            return
        }
        guard let keyData = try? JSONEncoder().encode(wallet.keystoreParams) else {
            completion(nil, WalletSavingError.couldNotGetKeyData)
            return
        }
        let walletModel = KeyWalletModel(address: address,
					 data: keyData,
					 name: name ?? "",
					 isHD: true)
        completion(walletModel, nil)
    }	
```

### Import Account

#### Import Account With Private Key
```swift
    public func addWalletWithPrivateKey(withName: String?,
                                           key: String,
                                    	   password: String,
                                    	   completion: @escaping (KeyWalletModel?, Error?) -> Void)
    {
        let text = key.trimmingCharacters(in: .whitespacesAndNewlines)
	
        guard let data = Data.fromHex(text) else {
            completion(nil, WalletSavingError.wrongKey)
            return
        }
        
        guard let newWallet = try? EthereumKeystoreV3(privateKey: data, password: password) else {
            completion(nil, WalletSavingError.couldNotSaveTheWallet)
            return
        }
        
        guard let wallet = newWallet, wallet.addresses?.count == 1 else {
            completion(nil, WalletSavingError.couldNotCreateWalletWithAddress)
            return
        }
        guard let keyData = try? JSONEncoder().encode(wallet.keystoreParams) else {
            completion(nil, WalletSavingError.couldNotGetKeyData)
            return
        }
        guard let address = newWallet?.addresses?.first?.address else {
            completion(nil, WalletSavingError.couldNotCreateAddress)
            return
        }
        let walletModel = KeyWalletModel(address: address,
					 data: keyData,
					 name: withName ?? "",
					 isHD: false)
        completion(walletModel, nil)
    }
    	
```

#### Import Account With Mnemonics Phrase
```swift
    func addHDWallet(withName name: String?,
    		           password: String,
			   mnemonics: String,
			   completion: @escaping (KeyWalletModel?, Error?) -> Void)
    {
        guard let keystore = try? BIP32Keystore(
	                                        mnemonics: mnemonics,
                                                password: password,
                                                mnemonicsPassword: "",
                                                language: .english
						),
						let wallet = keystore else { 
	    completion(nil, WalletSavingError.couldNotCreateKeystore)
	    return 
	}
        guard let address = wallet.addresses?.first?.address else {
            completion(nil, WalletSavingError.couldNotCreateAddress)
            return
        }
        guard let keyData = try? JSONEncoder().encode(wallet.keystoreParams) else {
            completion(nil, WalletSavingError.couldNotGetKeyData)
            return
        }
        let walletModel = KeyWalletModel(address: address,
					 data: keyData,
					 name: name ?? "",
					 isHD: true)
        completion(walletModel, nil)
    }	
```

### Manage Keystore

#### Save keystore to the memory

```swift
    //First you need a `KeystoreManager` instance:
    guard let userDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
        let keystoreManager = KeystoreManager.managerForPath(userDirectory + "/keystore")
    else {
        fatalError("Couldn't create a KeystoreManager.")
    }

    // Next you create a new Keystore:

    let newKeystore = try? EthereumKeystoreV3(password: "YOUR_PASSWORD")

    // Then you save the created keystore to the file system:

    let newKeystoreJSON = try? JSONEncoder().encode(newKeystore.keystoreParams)
    FileManager.default.createFile(atPath: "\(keystoreManager.path)/keystore.json", contents: newKeystoreJSON, attributes: nil)

    // Later you can retreive it:

    if let address = keystoreManager.addresses?.first,
    let retrievedKeystore = keystoreManager.walletForAddress(address) as? EthereumKeystoreV3 {
        return retrievedKeystore
    }
```

#### Get Keysore Manager

```swift

    func getWallet() -> KeyWalletModel? {
        let requestWallet: NSFetchRequest<KeyWallet> = KeyWallet.fetchRequest()
        requestWallet.predicate = NSPredicate(format: "isSelected = %@", NSNumber(value: true))
        do {
            let results = try mainContext.fetch(requestWallet)
            guard let result = results.first else { return nil }
            return KeyWalletModel.fromCoreData(crModel: result)
            
        } catch {
            print(error)
            return nil
        }
        
    }

    func keystoreManager() -> KeystoreManager {
	// Firstly you need to get 
        guard let selectedWallet = getWallet(),
	      let data = selectedWallet.data else {
            return KeystoreManager.defaultManager!
        }
        if selectedWallet.isHD {
            return KeystoreManager([BIP32Keystore(data)!])
        } else {
            return KeystoreManager([EthereumKeystoreV3(data)!])
        }
    }
```

#### Get private key data

```swift
   func getPrivateKey(forWallet wallet: KeyWalletModel, password: String) -> String? {
        do {
            guard let ethereumAddress = EthereumAddress(wallet.address) else { return nil }
            let pkData = try keystoreManager().UNSAFE_getPrivateKeyData(password: password, account: ethereumAddress)
            return pkData.toHexString()
        } catch {
            print(error)
            return nil
        }
    }
```

### Ethereum Address

#### Initializing Ethereum Address

```swift
let coldWalletAddress = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")
let constractAddress = EthereumAddress("0x45245bc59219eeaaf6cd3f382e078a461ff9de7b", ignoreChecksum: true)
```
Ethereum addresses are checksum checked if they are not lowercased or uppercased and always length checked

### Get Balance

#### Getting ETH balance

```swift
let address = EthereumAddress("0xE6877A4d8806e9A9F12eB2e8561EA6c1db19978d")!
let web3Main = Web3.InfuraMainnetWeb3()
let balanceResult = web3Main.eth.getBalance(address)
guard case .success(let balance) = balanceResult else {return}
```

#### Getting ERC20 token balance
```swift
let contractAddress = EthereumAddress("0x45245bc59219eeaaf6cd3f382e078a461ff9de7b")! // BKX token on Ethereum mainnet
let contract = web3.contract(Web3.Utils.erc20ABI, at: contractAddress, abiVersion: 2)! // utilize precompiled ERC20 ABI for your concenience
guard let bkxBalanceResult = contract.method("balanceOf", parameters: [coldWalletAddress] as [AnyObject], options: options)?.call(options: nil) else {return} // encode parameters for transaction
guard case .success(let bkxBalance) = bkxBalanceResult, let bal = bkxBalance["0"] as? BigUInt else {return} // bkxBalance is [String: Any], and parameters are enumerated as "0", "1", etc in order of being returned. If returned parameter has a name in ABI, it is also duplicated
print("BKX token balance = " + String(bal))
```

## Transactions Operations

### Prepare Transaction

#### Setting Transaction Options

```swift
var options = Web3Options.defaultOptions()
    // public var to: EthereumAddress? = nil - to what address transaction is aimed
    // public var from: EthereumAddress? = nil - form what address it should be sent (either signed locally or on the node)
    // public var gasLimit: BigUInt? = BigUInt(90000) - default gas limit
    // public var gasPrice: BigUInt? = BigUInt(5000000000) - default gas price, quite small
    // public var value: BigUInt? = BigUInt(0) - amount of WEI sent along the transaction
options.gasPrice = gasPrice
options.gasLimit = gasLimit
options.from = EthereumAddress("0xE6877A4d8806e9A9F12eB2e8561EA6c1db19978d")
```

### Send Transaction 

#### Sending ETH

```swift
let web3Rinkeby = Web3.InfuraRinkebyWeb3()
web3Rinkeby.addKeystoreManager(bip32keystoreManager) // attach a keystore if you want to sign locally. Otherwise unsigned request will be sent to remote node
options.from = bip32ks?.addresses?.first! // specify from what address you want to send it
intermediateSend = web3Rinkeby.contract(Web3.Utils.coldWalletABI, at: coldWalletAddress, abiVersion: 2)!.method(options: options)! // an address with a private key attached in not different from any other address, just has very simple ABI
let sendResultBip32 = intermediateSend.send(password: "changeme")
```

#### Sending ERC20
```swift
var convenienceTransferOptions = Web3Options.defaultOptions()
convenienceTransferOptions.gasPrice = gasPriceRinkeby
let convenienceTokenTransfer = web3Rinkeby.eth.sendERC20tokensWithNaturalUnits(tokenAddress: EthereumAddress("0xa407dd0cbc9f9d20cdbd557686625e586c85b20a")!, from: (ks?.addresses?.first!)!, to: EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")!, amount: "0.0001", options: convenienceTransferOptions) // there are also convenience functions to send ETH and ERC20 under the .eth structure
let gasEstimateResult = convenienceTokenTransfer!.estimateGas(options: nil)
guard case .success(let gasEstimate) = gasEstimateResult else {return}
convenienceTransferOptions.gasLimit = gasEstimate
let convenienceTransferResult = convenienceTokenTransfer!.send(password: "changeme", options: convenienceTransferOptions)
switch convenienceTransferResult {
    case .success(let res):
        print("Token transfer successful")
        print(res)
    case .failure(let error):
        print(error)
}
```

### Get Transaction Gas Price

```swift
let web3Main = Web3.InfuraMainnetWeb3()
let gasPriceResult = web3Main.eth.getGasPrice()
guard case .success(let gasPrice) = gasPriceResult else {return}
```

### Serialize And Deserialize transactions


### Get Result


## Chain state

### Get Block number


### Get Block Gas Price
