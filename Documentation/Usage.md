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
let coldWalletAddress = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")!
let contractAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901", ignoreChecksum: true)!
```
Ethereum addresses are checksum checked if they are not lowercased or uppercased and always length checked

### Get Balance

#### Getting ETH balance

```swift
let address = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
let web3Main = Web3.InfuraMainnetWeb3()
let balance = try web3.eth.getBalance(address: address)
let balanceString = Web3.Utils.formatToEthereumUnits(balance, toUnits: .eth, decimals: 3)
```

#### Getting ERC20 token balance
```swift
let contractAddress = EthereumAddress("0x8932404A197D84Ec3Ea55971AADE11cdA1dddff1")! // w3s token on Ethereum mainnet
let contract = web3.contract(Web3.Utils.erc20ABI, at: contractAddress, abiVersion: 2) // utilize precompiled ERC20 ABI for your concenience
let userAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
guard let readTX = contract?.read("balanceOf", parameters: [addressOfUser] as [AnyObject]) else {return}
readTX.transactionOptions.from = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
let tokenBalance = try readTX.callPromise().wait()
guard let balance = tokenBalance["0"] as? BigUInt else {return}
```

## Transactions Operations

### Prepare Transaction

#### Preparing Transaction For Sending Ether

```swift
func prepareTransactionForSendingEther(destinationAddressString: String,
                                                  amountString: String,
                                                  gasLimit: BigUInt) throws -> WriteTransaction {
    DispatchQueue.global(qos: .userInitiated).async {
        guard let destinationEthAddress = EthereumAddress(destinationAddressString) else {throw SendErrors.invalidDestinationAddress}
        guard let amount = Web3.Utils.parseToBigUInt(amountString, units: .eth) else {throw SendErrors.invalidAmountFormat}
        guard let selectedKey = KeysService().selectedWallet()?.address else {throw SendErrors.noAvailableKeys}
        let web3 = Web3.InfuraMainnetWeb3() //or any other network
        web3.addKeystoreManager(KeysService().keystoreManager())
        guard let ethAddressFrom = EthereumAddress(selectedKey) else {throw SendErrors.invalidKey}
	guard let contract = web3.contract(Web3.Utils.coldWalletABI, at: destinationEthAddress, abiVersion: 2) else {throw SendErrors.invalidDestinationAddress}
	guard let writeTX = contract.write("fallback") else {throw SendErrors.invalidContract}
        writeTX.transactionOptions.from = ethAddressFrom
        writeTX.transactionOptions.value = value
	return writeTX
    }
}
```

#### Preparing Transaction For Sending ERC-20 Tokens

```swift
func prepareTransactionForSendingERC(contractAddressString: String,
                                            amountString: String,
                                            gasLimit: BigUInt,
                                            tokenAddress token: String) throws -> WriteTransaction {
    DispatchQueue.global(qos: .userInitiated).async {
        guard let contractAddress = EthereumAddress(contractAddressString) else {throw SendErrors.invalidContractAddress}
        guard let amount = Web3.Utils.parseToBigUInt(amountString, units: .eth) else {throw SendErrors.invalidAmountFormat}
        guard let selectedKey = KeysService().selectedWallet()?.address else {throw SendErrors.noAvailableKeys}
        let web3 = Web3.InfuraMainnetWeb3() //or any other network
        web3.addKeystoreManager(KeysService().keystoreManager())
        guard let ethAddressFrom = EthereumAddress(selectedKey) else {throw SendErrors.invalidKey}
	guard let contract = web3.contract(Web3.Utils.erc20ABI, at: contractAddress, abiVersion: 2) else {throw SendErrors.invalidDestinationAddress}
	guard let writeTX = contract.write("transfer") else {throw SendErrors.invalidContract}
        writeTX.transactionOptions.from = ethAddressFrom
        writeTX.transactionOptions.value = value
	return writeTX
    }
}
```

#### Preparing Transaction For Sending To Some Contract and use its method

```swift
func prepareTransactionToContract(parameters: [AnyObject],
                                         data: Data, 
					 amountString: String,
                                         contractAbi: String,
                                         contractAddress: String,
                                         method: String,
                                         predefinedOptions: TransactionOptions? = nil) -> WriteTransaction {
    guard let contractAddress = EthereumAddress(contractAddressString) else {throw SendErrors.invalidContractAddress}
    guard let amount = Web3.Utils.parseToBigUInt(amountString, units: .eth) else {throw SendErrors.invalidAmountFormat}
    guard let selectedKey = KeysService().selectedWallet()?.address else {throw SendErrors.noAvailableKeys}
    let web3 = Web3.InfuraMainnetWeb3() //or any other network
    web3.addKeystoreManager(KeysService().keystoreManager())
    guard let ethAddressFrom = EthereumAddress(selectedKey) else {throw SendErrors.invalidKey}
    guard let contract = web3.contract(contractAbi, at: contractAddress, abiVersion: 2) else {throw SendErrors.invalidDestinationAddress}
    guard let writeTX = contract.write(method,
                                       parameters: parameters,
				       extraData: data,
				       transactionOptions: predefinedOptions) else {throw SendErrors.invalidContract}
    writeTX.transactionOptions.from = ethAddressFrom
    writeTX.transactionOptions.value = value
    return writeTX
}
```

### Send Transaction 

#### Writing

```swift
public func writeTx(transaction: WriteTransaction,
                    options: TransactionOptions? = nil,
                    password: String? = nil) throws -> TransactionSendingResult {
    let options = options ?? transaction.transactionOptions
    guard let result = password == nil ?
        try? transaction.send() :
        try? transaction.send(password: password!, transactionOptions: options) else {throw SendErrors.wrongPassword}
    return result
}
```

#### Calling
  
```swift
public func callTxPlasma(transaction: ReadTransaction,
		         options: TransactionOptions? = nil) throws -> [String: Any] {
    let options = options ?? transaction.transactionOptions
    guard let result = try? transaction.call(transactionOptions: options) else {throw SendErrors.wrongPassword}
    return result
}
```

## Chain state

### Get Block number

```swift
func getBlockNumber(_ web3: web3) {
    do {
	let blockNumber = try web3.eth.getBlockNumber()
	print("Block number = " + String(blockNumber))
    } catch {
	print(error)
    }
}
```
