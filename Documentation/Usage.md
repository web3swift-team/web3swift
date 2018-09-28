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

#### Web3Options

```swift
/// A web3 instance bound to provider. All further functionality is provided under web.*. namespaces.
public class web3: Web3OptionsInheritable {
    public var provider : Web3Provider
    public var options : Web3Options = Web3Options.defaultOptions()
    public var defaultBlock = "latest"
    public var requestDispatcher: JSONRPCrequestDispatcher
    
    /// Add a provider request to the dispatch queue.
    public func dispatch(_ request: JSONRPCrequest) -> Promise<JSONRPCresponse> {
        return self.requestDispatcher.addToQueue(request: request)
    }

    /// Raw initializer using a Web3Provider protocol object, dispatch queue and request dispatcher.
    public init(provider prov: Web3Provider, queue: OperationQueue? = nil, requestDispatcher: JSONRPCrequestDispatcher? = nil) {
        provider = prov        
        if requestDispatcher == nil {
            self.requestDispatcher = JSONRPCrequestDispatcher(provider: provider, queue: DispatchQueue.global(qos: .userInteractive), policy: .Batch(32))
        } else {
            self.requestDispatcher = requestDispatcher!
        }
    }
    
    /// Keystore manager can be bound to Web3 instance. If some manager is bound all further account related functions, such
    /// as account listing, transaction signing, etc. are done locally using private keys and accounts found in a manager.
    public func addKeystoreManager(_ manager: KeystoreManager?) {
        self.provider.attachedKeystoreManager = manager
    }
    
    var ethInstance: web3.Eth?
    
    /// Public web3.eth.* namespace.
    public var eth: web3.Eth {
        if (self.ethInstance != nil) {
            return self.ethInstance!
        }
        self.ethInstance = web3.Eth(provider : self.provider, web3: self)
        return self.ethInstance!
    }
    
    public class Eth:Web3OptionsInheritable {
        var provider:Web3Provider
//        weak var web3: web3?
        var web3: web3
        public var options: Web3Options {
            return self.web3.options
        }
        public init(provider prov: Web3Provider, web3 web3instance: web3) {
            provider = prov
            web3 = web3instance
        }
    }
    
    var personalInstance: web3.Personal?
    
    /// Public web3.personal.* namespace.
    public var personal: web3.Personal {
        if (self.personalInstance != nil) {
            return self.personalInstance!
        }
        self.personalInstance = web3.Personal(provider : self.provider, web3: self)
        return self.personalInstance!
    }
    
    public class Personal:Web3OptionsInheritable {
        var provider:Web3Provider
        //        weak var web3: web3?
        var web3: web3
        public var options: Web3Options {
            return self.web3.options
        }
        public init(provider prov: Web3Provider, web3 web3instance: web3) {
            provider = prov
            web3 = web3instance
        }
    }

    var walletInstance: web3.Web3Wallet?
    
    /// Public web3.wallet.* namespace.
    public var wallet: web3.Web3Wallet {
        if (self.walletInstance != nil) {
            return self.walletInstance!
        }
        self.walletInstance = web3.Web3Wallet(provider : self.provider, web3: self)
        return self.walletInstance!
    }
    
    public class Web3Wallet {
        var provider:Web3Provider
//        weak var web3: web3?
        var web3: web3
        public init(provider prov: Web3Provider, web3 web3instance: web3) {
            provider = prov
            web3 = web3instance
        }
    }
    
    var browserFunctionsInstance: web3.BrowserFunctions?
    
    /// Public web3.browserFunctions.* namespace.
    public var browserFunctions: web3.BrowserFunctions {
        if (self.browserFunctionsInstance != nil) {
            return self.browserFunctionsInstance!
        }
        self.browserFunctionsInstance = web3.BrowserFunctions(provider : self.provider, web3: self)
        return self.browserFunctionsInstance!
    }
    
    public class BrowserFunctions:Web3OptionsInheritable {
        var provider:Web3Provider
        //        weak var web3: web3?
        var web3: web3
        public var options: Web3Options {
            return self.web3.options
        }
        public init(provider prov: Web3Provider, web3 web3instance: web3) {
            provider = prov
            web3 = web3instance
        }
    }
    
    var erc721Instance: web3.ERC721?
    
    /// Public web3.browserFunctions.* namespace.
    public var erc721: web3.ERC721 {
        if (self.erc721Instance != nil) {
            return self.erc721Instance!
        }
        self.erc721Instance = web3.ERC721(provider : self.provider, web3: self)
        return self.erc721Instance!
    }
    
    public class ERC721: Web3OptionsInheritable {
        var provider:Web3Provider
        //        weak var web3: web3?
        var web3: web3
        public var options: Web3Options {
            return self.web3.options
        }
        public init(provider prov: Web3Provider, web3 web3instance: web3) {
            provider = prov
            web3 = web3instance
        }
    }
}
```

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

#### Preparing Transaction For Sending Ether

```swift
public func prepareTransactionForSendingEther(destinationAddressString: String,
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


        let web3 = web3swift.web3(provider: InfuraProvider(CurrentNetwork.currentNetwork ?? Networks.Mainnet)!)
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

#### Preparing Transaction For Sending ERC-20 tokens

```swift
public func prepareTransactionForSendingERC(destinationAddressString: String,
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
        
        let web3 = web3swift.web3(provider: InfuraProvider(CurrentNetwork.currentNetwork ?? Networks.Mainnet)!)
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
public func prepareTransactionToContract(data: [AnyObject],
                                         contractAbi: String,
                                         contractAddress: String,
                                         method: String,
                                         predefinedOptions: Web3Options? = nil,
                                         completion: @escaping (Result<TransactionIntermediate>) -> Void) {
    let wallet = TransactionsService.keyservice.selectedWallet()
    guard let address = wallet?.address else { return }
    let ethAddressFrom = EthereumAddress(address)
    let ethContractAddress = EthereumAddress(contractAddress)!
    
    let web3 = CurrentWeb.currentWeb ?? Web3.InfuraMainnetWeb3()
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
