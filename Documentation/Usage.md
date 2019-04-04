# Usage

# Account

## Account Management

#### Preffered keys Wallet Model

```swift
struct WalletModel {
    let address: String
    let data: Data?
    let name: String
    let isHD: Bool

    static func fromCoreData(crModel: Wallet) -> WalletModel {
        let model = KeyWalletModel(address: crModel.address ?? "",
				   				   data: crModel.data,
				                   name: crModel.name ?? "",
				                   isHD: crModel.isHD)
		return model
    }
}

extension WalletModel: Equatable {
    static func == (lhs: WalletModel, rhs: WalletModel) -> Bool {
        return lhs.address == rhs.address
    }
}

struct HDKey {
    let name: String?
    let address: String
}
```

#### Preffered ERC-20 Model
```swift
class ERC20TokenModel {
    var name: String
    var address: String
    var decimals: String
    var symbol: String

    init(token: ERC20Token) {
        self.name = token.name ?? ""
        self.address = token.address ?? ""
        self.decimals = token.decimals ?? ""
        self.symbol = token.symbol ?? ""
    }

    init(name: String,
         address: String,
         decimals: String,
         symbol: String) {
        self.name = name
        self.address = address
        self.decimals = decimals
        self.symbol = symbol
    }

    init(isEther: Bool) {
        self.name = isEther ? "Ether" : ""
        self.address = isEther ? "" : ""
        self.decimals = isEther ? "18" : "18"
        self.symbol = isEther ? "Eth" : ""
    }

    static func fromCoreData(crModel: ERC20Token) -> ERC20TokenModel {
        let model = ERC20TokenModel(name: crModel.name ?? "",
        							address: crModel.address ?? "",
               					    decimals: crModel.decimals ?? "",
                					symbol: crModel.symbol ?? "")
        return model
    }
}

extension ERC20TokenModel: Equatable {
    public static func ==(lhs: ERC20TokenModel, rhs: ERC20TokenModel) -> Bool {
        return lhs.name == rhs.name &&
            lhs.address == rhs.address &&
            lhs.decimals == rhs.decimals &&
            lhs.symbol == rhs.symbol
    }
}
```

### Create Account

#### Create Account With Private Key
```swift
func createWallet(name: String?,
		     	  password: String) throws -> WalletModel {
	guard let newWallet = try? EthereumKeystoreV3(password: password) else {
		throw Errors.StorageErrors.cantCreateWallet
	}
	guard let wallet = newWallet, wallet.addresses?.count == 1 else {
		throw Errors.StorageErrors.cantCreateWallet
	}
	guard let keyData = try? JSONEncoder().encode(wallet.keystoreParams) else {
		throw Errors.StorageErrors.cantCreateWallet
	}
	guard let address = wallet.addresses?.first?.address else {
		throw Errors.StorageErrors.cantCreateWallet
	}
	let walletModel = WalletModel(address: address, data: keyData, name: name ?? "", isHD: false)
	return walletModel
}	
```

#### Create Account With Mnemonics Phrase
```swift
func generateMnemonics(bitsOfEntropy: Int) throws -> String {
	guard let mnemonics = try? BIP39.generateMnemonics(bitsOfEntropy: bitsOfEntropy),
		let unwrapped = mnemonics else {
			throw Web3Error.keystoreError(err: .noEntropyError)
	}
	return unwrapped
}

func createHDWallet(name: String?,
				    password: String,
                    mnemonics: String) throws -> WalletModel {
	guard let keystore = try? BIP32Keystore(mnemonics: mnemonics,
											password: password,
											mnemonicsPassword: "",
											language: .english), let wallet = keystore else {
		throw Errors.StorageErrors.cantCreateWallet
	}
	guard let address = wallet.addresses?.first?.address else {
		throw Errors.StorageErrors.cantCreateWallet
	}
	guard let keyData = try? JSONEncoder().encode(wallet.keystoreParams) else {
		throw Errors.StorageErrors.cantCreateWallet
	}
	let walletModel = WalletModel(address: address, data: keyData, name: name ?? "", isHD: false)
	return walletModel
}	
```

### Import Account

#### Import Account With Private Key
```swift
func importWalletWithPrivateKey(name: String?,
							    key: String,
								password: String) throws -> WalletModel {
	let text = key.trimmingCharacters(in: .whitespacesAndNewlines)
	guard let data = Data.fromHex(text) else {
		throw Errors.StorageErrors.cantImportWallet
	}

	guard let newWallet = try? EthereumKeystoreV3(privateKey: data, password: password) else {
		throw Errors.StorageErrors.cantImportWallet
	}

	guard let wallet = newWallet, wallet.addresses?.count == 1 else {
		throw Errors.StorageErrors.cantImportWallet
	}
	guard let keyData = try? JSONEncoder().encode(wallet.keystoreParams) else {
		throw Errors.StorageErrors.cantImportWallet
	}
	guard let address = newWallet?.addresses?.first?.address else {
		throw Errors.StorageErrors.cantImportWallet
	}
	let walletModel = WalletModel(address: address, data: keyData, name: name ?? "", isHD: false)
	return walletModel
}  	
```

#### Import Account With Mnemonics Phrase
```swift
func importHDWallet(name: String?,
				    password: String,
                    mnemonics: String) throws -> WalletModel {
	guard let keystore = try? BIP32Keystore(mnemonics: mnemonics,
											password: password,
											mnemonicsPassword: "",
											language: .english), let wallet = keystore else {
		throw Errors.StorageErrors.cantCreateWallet
	}
	guard let address = wallet.addresses?.first?.address else {
		throw Errors.StorageErrors.cantCreateWallet
	}
	guard let keyData = try? JSONEncoder().encode(wallet.keystoreParams) else {
		throw Errors.StorageErrors.cantCreateWallet
	}
	let walletModel = WalletModel(address: address, data: keyData, name: name ?? "", isHD: false)
	return walletModel
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
// 1st - Get wallet, that is saved in some storage

func getWalletFromStorage() throws -> WalletModel {
	guard let wallet = try? walletsStorage.getSelectedWallet() else {
		throw Errors.StorageErrors.noSelectedWallet
	}
	return wallet
}

// 2nd - Get keystore manager from wallet

func keystoreManager() throws -> KeystoreManager {
	guard let wallet = try? self.getSelectedWallet(),
		let data = wallet.data else {
			if let defaultKeystore = KeystoreManager.defaultManager {
				return defaultKeystore
			} else {
				throw Web3Error.keystoreError(err: .invalidAccountError)
			}
	}
	if wallet.isHD {
		guard let keystore = BIP32Keystore(data) else {
			if let defaultKeystore = KeystoreManager.defaultManager {
				return defaultKeystore
			} else {
				throw Web3Error.keystoreError(err: .invalidAccountError)
			}
		}
		return KeystoreManager([keystore])
	} else {
		guard let keystore = EthereumKeystoreV3(data) else {
			if let defaultKeystore = KeystoreManager.defaultManager {
				return defaultKeystore
			} else {
				throw Web3Error.keystoreError(err: .invalidAccountError)
			}
		}
		return KeystoreManager([keystore])
	}
}
```

#### Get wallet private key

```swift
func getPrivateKey(for wallet: WalletModel, password: String) throws -> String {
	do {
		guard let ethereumAddress = EthereumAddress(wallet.address) else {
			throw Web3Error.walletError
		}
		guard let manager = try? keystoreManager() else {
			throw Web3Error.keystoreError(err: .invalidAccountError)
		}
		let pkData = try manager.UNSAFE_getPrivateKeyData(password: password, account: ethereumAddress)
		return pkData.toHexString()
	} catch let error {
		throw error
	}
}
```

# Web3 and Web2 actions

## web3 instance

Firstly you need to initialize 'web3' instance for almost all further operations:
```swift
// common Http/Https provider
let web3instance = web3(provider: Web3HttpProvider(<http/https provider url>)
// precompiled Infura providers
let web3instance = Web3.InfuraMainnetWeb3() // Mainnet Infura Provider
let web3instance = Web3.InfuraRinkebyWeb3() // Mainnet Rinkeby Provider
let web3instance = Web3.InfuraRopstenWeb3() // Mainnet Ropsten Provider
```

Then you will need to attach keystore manager to web3 instance:
```swift
web3.addKeystoreManager(keystoreManager)
```

You can get it from wallet model we've previosly created:
```swift
var keystoreManager: KeystoreManager? {
	if self.isHD {
		guard let keystore = BIP32Keystore(wallet.data) else {
			return nil
		}
		return KeystoreManager([keystore])
	} else {
		guard let keystore = EthereumKeystoreV3(wallet.data) else {
			return nil
		}
		return KeystoreManager([keystore])
	}
}
```

### Ethereum Address

#### Initializing Ethereum Address

```swift
let coldWalletAddress = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")!
let contractAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901", ignoreChecksum: true)!
```
Ethereum addresses are checksum checked if they are not lowercased or uppercased and always length checked

### Get Balance

#### Getting ETH balance

```swift
func getETHbalance(for wallet: WalletModel) throws -> String {
	do {
		guard let walletAddress = EthereumAddress(wallet.address) else {
			throw Web3Error.walletError
		}
		let web3 = web3Instance
		let balanceResult = try web3.eth.getBalance(address: walletAddress)
		guard let balanceString = Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 3) else {
			throw Web3Error.dataError
		}
		return balanceString
	} catch let error {
		throw error
	}
}
```

#### Getting ERC20 token balance
```swift
func getERC20balance(for wallet: WalletModel,
					 token: ERC20TokenModel) throws -> String {
	do {
		guard let walletAddress = EthereumAddress(wallet.address) else {
			throw Web3Error.walletError
		}
		let tx = try self.prepareReadContractTx(contractABI: Web3.Utils.erc20ABI,
												contractAddress: token.address,
												contractMethod: "balanceOf",
												gasLimit: .automatic,
												gasPrice: .automatic,
												parameters: [walletAddress] as [AnyObject],
												extraData: Data())
		let tokenBalance = try self.callTx(transaction: tx)
		guard let balanceResult = tokenBalance["0"] as? BigUInt else {
			throw Web3Error.dataError
		}
		guard let balanceString = Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 3) else {
			throw Web3Error.dataError
		}
		return balanceString
	} catch let error {
		throw error
	}
}
```

## Transactions Operations

### Prepare Transaction

#### Preparing Transaction For Sending Ether

```swift
func prepareSendEthTx(toAddress: String,
					  value: String = "0.0",
					  gasLimit: TransactionOptions.GasLimitPolicy = .automatic,
					  gasPrice: TransactionOptions.GasPricePolicy = .automatic) throws -> WriteTransaction {
	guard let ethAddress = EthereumAddress(toAddress) else {
		throw Web3Error.dataError
	}
	guard let contract = web3Instance.contract(Web3.Utils.coldWalletABI, at: ethAddress, abiVersion: 2) else {
		throw Web3Error.dataError
	}
	let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
	var options = defaultOptions()
	options.value = amount
	options.gasPrice = gasPrice
	options.gasLimit = gasLimit
	guard let tx = contract.write("fallback",
								  parameters: [AnyObject](),
								  extraData: Data(),
								  transactionOptions: options) else {
										throw Web3Error.transactionSerializationError
	}
	return tx
}
```

#### Preparing Transaction For Sending ERC-20 Tokens

```swift
public func prepareSendERC20Tx(tokenAddress: String,
							   toAddress: String,
							   tokenAmount: String = "0.0",
							   gasLimit: TransactionOptions.GasLimitPolicy = .automatic,
							   gasPrice: TransactionOptions.GasPricePolicy = .automatic) throws -> WriteTransaction {
	guard let ethTokenAddress = EthereumAddress(tokenAddress) else {
		throw Web3Error.dataError
	}
	guard let ethToAddress = EthereumAddress(toAddress) else {
		throw Web3Error.dataError
	}
	guard let contract = web3Instance.contract(Web3.Utils.erc20ABI, at: ethTokenAddress, abiVersion: 2) else {
		throw Web3Error.dataError
	}
	let amount = Web3.Utils.parseToBigUInt(tokenAmount, units: .eth)
	var options = defaultOptions()
	options.gasPrice = gasPrice
	options.gasLimit = gasLimit
	guard let tx = contract.write("transfer",
								  parameters: [ethToAddress, amount] as [AnyObject],
								  extraData: Data(),
								  transactionOptions: options) else {
		throw Web3Error.transactionSerializationError
	}
	return tx
}
```

#### Preparing Write Transaction for sending to some Contract and use its method

```swift
func prepareWriteContractTx(contractABI: String,
						    contractAddress: String,
						    contractMethod: String,
						    value: String = "0.0",
						    gasLimit: TransactionOptions.GasLimitPolicy = .automatic,
						    gasPrice: TransactionOptions.GasPricePolicy = .automatic,
						    parameters: [AnyObject] = [AnyObject](),
						    extraData: Data = Data()) throws -> WriteTransaction {
	guard let ethContractAddress = EthereumAddress(contractAddress) else {
		throw Web3Error.dataError
	}
	guard let contract = web3Instance.contract(contractABI, at: ethContractAddress, abiVersion: 2) else {
		throw Web3Error.dataError
	}
	let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
	var options = defaultOptions()
	options.gasPrice = gasPrice
	options.gasLimit = gasLimit
	options.value = amount
	guard let tx = contract.write(contractMethod,
								  parameters: parameters,
								  extraData: extraData,
								  transactionOptions: options) else {
									throw Web3Error.transactionSerializationError
	}
	return tx
}
```

#### Preparing Read Transaction to call some Contract method

```swift
func prepareReadContractTx(contractABI: String,
						   contractAddress: String,
						   contractMethod: String,
						   gasLimit: TransactionOptions.GasLimitPolicy = .automatic,
						   gasPrice: TransactionOptions.GasPricePolicy = .automatic,
						   parameters: [AnyObject] = [AnyObject](),
						   extraData: Data = Data()) throws -> ReadTransaction {
	guard let ethContractAddress = EthereumAddress(contractAddress) else {
		throw Web3Error.dataError
	}
	guard let contract = web3Instance.contract(contractABI, at: ethContractAddress, abiVersion: 2) else {
		throw Web3Error.dataError
	}
	var options = defaultOptions()
	options.gasPrice = gasPrice
	options.gasLimit = gasLimit
	guard let tx = contract.read(contractMethod,
								 parameters: parameters,
								 extraData: extraData,
								 transactionOptions: options) else {
									throw Web3Error.transactionSerializationError
	}
	return tx
}
```

### Send Transaction 

#### Writing

```swift
func sendTx(transaction: WriteTransaction,
		    options: TransactionOptions? = nil,
		    password: String) throws -> TransactionSendingResult {
	do {
		let txOptions = options ?? transaction.transactionOptions
		let result = try transaction.send(password: password, transactionOptions: txOptions)
		return result
	} catch let error {
		throw error
	}
}
```

#### Reading
  
```swift
func callTx(transaction: ReadTransaction,
		    options: TransactionOptions? = nil) throws -> [String : Any] {
	do {
		let txOptions = options ?? transaction.transactionOptions
		let result = try transaction.call(transactionOptions: txOptions)
		return result
	} catch let error {
		throw error
	}
}
```

## Chain state

### Get Block number

```swift
func getBlockNumber(_ web3: web3) throws -> BigUInt {
    do {
		let blockNumber = try web3.eth.getBlockNumber()
		return blockNumber
    } catch let error {
		throw error 
    }
}
```

## Infura Websockets

### Subscribe on new pending transactions

```swift
let delegate: Web3SocketDelegate = <some delegate class which will receive messages from endpoint>
let socketProvider = InfuraWebsocketProvider.connectToSocket(.Mainnet, delegate: delegate)
try! socketProvider.subscribeOnNewPendingTransactions()
```

### Get latest new pending transactions

```swift
let delegate: Web3SocketDelegate = <some delegate class which will receive messages from endpoint>
let socketProvider = InfuraWebsocketProvider.connectToSocket(.Mainnet, delegate: delegate)
try! socketProvider.filter(method: .newPendingTransactionFilter)
```
