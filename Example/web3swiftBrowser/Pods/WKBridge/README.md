# WKBridge

[![CI Status](http://img.shields.io/travis/lovesunstar@sina.com/WKBridge.svg?style=flat)](https://travis-ci.org/lovesunstar@sina.com/WKBridge)
[![Version](https://img.shields.io/cocoapods/v/WKBridge.svg?style=flat)](http://cocoapods.org/pods/WKBridge)
[![License](https://img.shields.io/cocoapods/l/WKBridge.svg?style=flat)](http://cocoapods.org/pods/WKBridge)
[![Platform](https://img.shields.io/cocoapods/p/WKBridge.svg?style=flat)](http://cocoapods.org/pods/WKBridge)

`WKScriptMessageHandler` greatly simplifies the message handler from javascript running in a webpage. WKScript provides a more efficiently way for both sending and receiving messages through `WKScriptMessageHandler`.

## Features

- [x] Send / Receive Messages
- [x] Bind Events In JavaScript
- [x] Callback Event

## Usage

#### Native Handle Event

```swift
webView.bridge.register({ (parameters, completion) in
    print("print - ", parameters?["message"] ?? "")
}, for: "print")

webView.bridge.register({ (parameters, completion) in
    print("print - ", parameters?["message"] ?? "")
    completion(.success(["key": "value"]))
}, for: "some_event_need_callback")

```

#### Native Call JS
```swift
webView.evaluateJavaScript("some_method();", completionHandler: { (results, error) in
    print(results ?? "")
})

webView.bridge.evaluate("some_method()", completion: { (results, error) in
    print(results ?? "")
})
```

#### JS Send Event
```javascript
window.bridge.post('print', {message: 'Hello, world'})
// Post Event With Callback
window.bridge.post('print', {message: 'Hello, world'}, (parameters, error) => { <# Handler Parameters Or Error #>})
```

#### JS Register Native Event
```javascript
var unregisterHandler = window.bridge.on('login', (parameters)=> {console.log('User Did Login')})
// To Remove Listener, call `unregisterHandler()`, Or Remove All Listener window.bridge.off('login')
```

#### Native Send Event To JS
```swift
webView.bridge.post(action: "login", parameters: nil)
```

You can include `wk.bridge.min.js` to your own html, or you can inject it to your html using `WKUserScript`.

You can [Download](https://gist.github.com/lovesunstar/efec08f8d2655ad432ab9dcb7d172536) full source-code of `wk.bridge.min.js` 

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

iOS 8.0 +

## Installation

WKBridge is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "WKBridge"
```

## Author

lovesunstar@sina.com

## License

WKBridge is available under the MIT license. See the LICENSE file for more info.
