# Alamofire+Synchronous

Synchronous requests for Alamofire

### Requirements

* iOS 9.0+ / Mac OS X 10.11+ / tvOS 9.0+ / watchOS 2.0+


* Xcode 8.0+
* Swift 3.0+

### Installation

For Alamofire 4.0+:

```ruby
pod 'Alamofire-Synchronous', '~> 4.0'
```

For Alamofire 3.0+:

``` ruby
pod 'Alamofire-Synchronous', '~> 3.0'
```

### Known issues

**If you execute synchronous requests from the main queue:**

The following tasks in the main queue, including UI updates, won't be execute until the synchronous request finished. in Alamofire 4,  methods `downloadProgress` and `uploadProgress` added  a new parameter `queue`, and its default value is  `DispatchQueue.main`.  it's better to reset it as Non-main queue If you execute synchronous requests from the main queue.

example:

```swift
// from the main queue (**not recommended**):
let response = Alamofire.download("https://httpbin.org/stream/100", method: .get, to: destination).downloadProgress { progress in
    	// Codes at here will be delayed before the synchronous request finished running.
    	print("Download Progress: \(progress.fractionCompleted)")
    
    }.response()
    
if let error = response.error {
    print("Failed with error: \(error)")
}else{
    print("Downloaded file successfully")
}
```

```swift
// from the main queue (**not recommended**):
let response = Alamofire.download("https://httpbin.org/stream/100", method: .get, to: destination).downloadProgress(queue: DispatchQueue.global(qos: .default)) { progress in
		// Codes at here will not be delayed
        print("Download Progress: \(progress.fractionCompleted)")
    
        DispatchQueue.main.async {
            // code at here will be delayed before the synchronous finished.
        }
    
    }.response()
    
if let error = response.error {
    print("Failed with error: \(error)")
}else{
    print("Downloaded file successfully")
}
```



### Usage

```swift
import Alamofire
import Alamofire_Synchronous
```

**The usage differences between Alamofire and Alamofire_Synchronous**: Simply remove  parameters: `queue` and  `completionHandler` in response* methods.



Example(For Alamofire 4.0+):

``` swift
//get request and response json
let response = Alamofire.request("https://httpbin.org/get", parameters: ["foo": "bar"]).responseJSON()
if let json = response.result.value {
	print(json)
}

// post request and response json(with default options)
let response = Alamofire.request("https://httpbin.org/post", method: .post, parameters: ["foo": "bar"]).responseJSON(options: .allowFragments)
if let json = response.result.value {
    print(json)
}

// download
let response = Alamofire.download("https://httpbin.org/stream/100", method: .get, to: destination).response()
if let error = response.error {
    print("Failed with error: \(error)")
}else{
    print("Downloaded file successfully")
}
```

For more usage, see [Alamofire's documents](https://github.com/Alamofire/Alamofire#usage).

### License

See LICENSE for details.
