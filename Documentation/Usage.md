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
func createWalletWithPrivateKey(withName: String?,
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
func addWalletWithPrivateKey(withName: String?,
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
let contractAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901", ignoreChecksum: true)
```
Ethereum addresses are checksum checked if they are not lowercased or uppercased and always length checked

### Get Balance

#### Getting ETH balance

```swift
let address = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
let web3Main = Web3.InfuraMainnetWeb3()
let balanceResult = web3Main.eth.getBalance(address)
guard case .success(let balance) = balanceResult else {return}
```

#### Getting ERC20 token balance
```swift
let contractAddress = EthereumAddress("0x8932404A197D84Ec3Ea55971AADE11cdA1dddff1")! // w3s token on Ethereum mainnet
let contract = web3.contract(Web3.Utils.erc20ABI, at: contractAddress, abiVersion: 2)! // utilize precompiled ERC20 ABI for your concenience
guard let w3sBalanceResult = contract.method(
                                             "balanceOf",
					     parameters: [coldWalletAddress] as [AnyObject],
					     options: options
					     )?.call(options: nil)
					     else {return} // encode parameters for transaction
guard case .success(let w3sBalance) = w3sBalanceResult, let bal = w3sBalance["0"] as? BigUInt else {return} // w3sBalance is [String: Any], and parameters are enumerated as "0", "1", etc in order of being returned. If returned parameter has a name in ABI, it is also duplicated
print("w3s token balance = " + String(bal))
```

## Transactions Operations

### Prepare Transaction

#### Getting Contract By Address 

```swift
func contract(for address: String, web3: web3) -> web3.web3contract? {
    guard let ethAddress = EthereumAddress(address) else {
        return nil
    }
    return web3.contract(Web3.Utils.erc20ABI, at: ethAddress)
}
```

#### Preparing Transaction For Sending Ether

```swift
func prepareTransactionForSendingEther(destinationAddressString: String,
                                                  amountString: String,
                                                  gasLimit: BigUInt,
                                                  completion: @escaping (Result<TransactionIntermediate>) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
        guard let destinationEthAddress = EthereumAddress(destinationAddressString) else {
    	    DispatchQueue.main.async {
	        completion(Result.Error(SendErrors.invalidDestinationAddress))
	    }
	    return
    	}
        guard let amount = Web3.Utils.parseToBigUInt(amountString, units: .eth) else {
	    DispatchQueue.main.async {
	        completion(Result.Error(SendErrors.invalidAmountFormat))
	    }
	    return
        }
        guard let selectedKey = KeysService().selectedWallet()?.address else {
	    DispatchQueue.main.async {
	        completion(Result.Error(SendErrors.noAvailableKeys))
	    }
	    return
        }

        let web3 = web3swift.web3(provider: InfuraProvider(Networks.Mainnet)!) //or any other network
        web3.addKeystoreManager(KeysService().keystoreManager())

        let ethAddressFrom = EthereumAddress(selectedKey)
        var options = Web3Options.defaultOptions()
        options.from = ethAddressFrom
        options.value = BigUInt(amount)
	
        guard let contract = web3.contract(Web3.Utils.coldWalletABI, at: destinationEthAddress) else {
	    DispatchQueue.main.async {
	        completion(Result.Error(SendErrors.contractLoadingError))
	    }
	    return
        }

        guard let estimatedGas = contract.method(options: options)?.estimateGas(options: nil).value else {
	    DispatchQueue.main.async {
	        completion(Result.Error(SendErrors.retrievingEstimatedGasError))
	    }
	    return
        }
        options.gasLimit = estimatedGas
	
        guard let gasPrice = web3.eth.getGasPrice().value else {
	    DispatchQueue.main.async {
	        completion(Result.Error(SendErrors.retrievingGasPriceError))
	    }
	    return
        }
        options.gasPrice = gasPrice
	
        guard let transaction = contract.method(options: options) else {
	    DispatchQueue.main.async {
	        completion(Result.Error(SendErrors.createTransactionIssue))
	    }
	    return
        }

        DispatchQueue.main.async {
	    completion(Result.Success(transaction))
        }

    }
}
```

#### Preparing Transaction For Sending ERC-20 Tokens

```swift
func prepareTransactionForSendingERC(destinationAddressString: String,
                                            amountString: String,
                                            gasLimit: BigUInt,
                                            tokenAddress token: String,
                                            completion: @escaping (Result<TransactionIntermediate>) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
        guard let destinationEthAddress = EthereumAddress(destinationAddressString) else {
            DispatchQueue.main.async {
                completion(Result.Error(SendErrors.invalidDestinationAddress))
            }
            return
        }
        guard let amount = Web3.Utils.parseToBigUInt(amountString, units: .eth) else {
            DispatchQueue.main.async {
                completion(Result.Error(SendErrors.invalidAmountFormat))
            }
            return
        }
        
        let web3 = web3swift.web3(provider: InfuraProvider(Networks.Mainnet)!) //or any other network
        web3.addKeystoreManager(KeysService().keystoreManager())
        
        let contract = self.contract(for: token, web3: web3)
        var options = Web3Options.defaultOptions()
        
        guard let tokenAddress = EthereumAddress(token),
            let fromAddress = Web3SwiftService.currentAddress,
            let intermediate = web3.eth.sendERC20tokensWithNaturalUnits(
                tokenAddress: tokenAddress,
                from: fromAddress,
                to: destinationEthAddress,
                amount: amountString) else {
                    DispatchQueue.main.async {
                        completion(Result.Error(SendErrors.createTransactionIssue))
                    }
                    return
        }
        DispatchQueue.main.async {
            completion(Result.Success(intermediate))
        }
        
        //MARK: - Just to check that everything is all right
        guard let _ = contract?.method(options: options)?.estimateGas(options: options).value else {
            DispatchQueue.main.async {
                completion(Result.Error(SendErrors.retrievingEstimatedGasError))
            }
            return
        }
        guard let gasPrice = web3.eth.getGasPrice().value else {
            DispatchQueue.main.async {
                completion(Result.Error(SendErrors.retrievingGasPriceError))
            }
            return
        }
        
        options.from = Web3SwiftService.currentAddress
        options.gasPrice = gasPrice
        //options.gasLimit = estimatedGas
        options.value = 0
        options.to = EthereumAddress(token)
        let parameters = [destinationEthAddress,
                          amount] as [Any]
        guard let transaction = contract?.method("transfer",
                                                 parameters: parameters as [AnyObject],
                                                 options: options) else {
                                                    DispatchQueue.main.async {
                                                        completion(Result.Error(SendErrors.createTransactionIssue))
                                                    }
                                                    
                                                    return
        }
        DispatchQueue.main.async {
            completion(Result.Success(transaction))
        }
        
        return
    }
}
```

#### Preparing Transaction For Sending To Some Contract

```swift
func prepareTransactionToContract(data: [AnyObject],
                                         contractAbi: String,
                                         contractAddress: String,
                                         method: String,
                                         predefinedOptions: Web3Options? = nil,
                                         completion: @escaping (Result<TransactionIntermediate>) -> Void) {
    let wallet = TransactionsService.keyservice.selectedWallet()
    guard let address = wallet?.address else { return }
    let ethAddressFrom = EthereumAddress(address)
    let ethContractAddress = EthereumAddress(contractAddress)!
    
    let web3 = Web3.InfuraMainnetWeb3() //or any other web
    web3.addKeystoreManager(TransactionsService.keyservice.keystoreManager())
    var options = predefinedOptions ?? Web3Options.defaultOptions()
    options.from = ethAddressFrom
    options.to = ethContractAddress
    options.value = options.value ?? 0
    guard let contract = web3.contract(contractAbi,
                                       at: ethContractAddress,
                                       abiVersion: 2) else {
                                        return
                                            DispatchQueue.main.async {
                                                completion(Result.Error(TransactionErrors.init(rawValue: "Can not create a contract with given abi and address.")!))
                                        }
    }
    guard let gasPrice = web3.eth.getGasPrice().value else { return }
    options.gasPrice = predefinedOptions?.gasPrice ?? gasPrice
    guard let transaction = contract.method(method,
                                            parameters: data,
                                            options: options) else { return }
    guard case .success(let estimate) = transaction.estimateGas(options: options) else {
        DispatchQueue.main.async {
            completion(Result.Error(TransactionErrors.PreparingError))
        }
        return
    }
    print("estimated cost: \(estimate)")
    DispatchQueue.main.async {
        completion(Result.Success(transaction))
    }
}
```

### Send Transaction 

#### Sending Tokens

```swift
func sendToken(transaction: TransactionIntermediate,
                      with password: String? = "YOURPASSWORD",
                      options: Web3Options? = nil,
                      completion: @escaping (Result<TransactionSendingResult>) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
        let result = transaction.send(password: password ?? "YOURPASSWORD",
                                      options: options)
        if let error = result.error {
            DispatchQueue.main.async {
                completion(Result.Error(error))
            }
            return
        }
        guard let value = result.value else {
            DispatchQueue.main.async {
                completion(Result.Error(SendErrors.emptyResult))
            }
            return
        }
        DispatchQueue.main.async {
            completion(Result.Success(value))
        }
    }
}
```

#### Sending To Contract
```swift
func sendToContract(transaction: TransactionIntermediate,
                           with password: String? = "YOURPASSWORD",
                           options: Web3Options? = nil,
                           completion: @escaping (Result<TransactionSendingResult>) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
        let result = transaction.send(password: password ?? "YOURPASSWORD",
                                      options: transaction.options)
        if let error = result.error {
            DispatchQueue.main.async {
                completion(Result.Error(error))
            }
            return
        }
        guard let value = result.value else {
            DispatchQueue.main.async {
                completion(Result.Error(SendErrors.emptyResult))
            }
            return
        }
        DispatchQueue.main.async {
            completion(Result.Success(value))
        }
    }
}
```

## Chain state

### Get Block number

```swift
func getBlockNumber(completion: @escaping (String?) -> Void) {
    DispatchQueue.global().async {
        let web3 = WalletWeb3Factory.web3()
        let res = web3.eth.getBlockNumber()
        switch res {
        case .failure(let error):
            print(error)
            DispatchQueue.main.async {
                completion(nil)
            }
        case .success(let number):
            DispatchQueue.main.async {
                completion(number.description)
            }
        }
    }
}
```
