# Usage

## Account Management

### Create Account

```swift
    // Create keystore and account with password.
    
	let keystore = try! EthereumKeystoreV3(password: "changeme"); // generates a private key internally if node "privateKey" parameter supplied
        let account = keystore!.addresses![0]
        print(account)
	
        let data = try! keystore!.serialize() // internally serializes to JSON
        print(try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue:0)))
        let key = try! keystore!.UNSAFE_getPrivateKeyData(password: "changeme", account: account) // you should rarely use this and expose a key manually	
```

### Import Account


### Manage Keystore

#### Save keystore to the memory

```swift
//First you need a `KeystoreManager` instance:
guard let userDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
    let keystoreManager = KeystoreManager.managerForPath(userDirectory + "/keystore")
else {
    fatalError("Couldn't create a KeystoreManager.")
}

//Next you create a new Keystore:

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
