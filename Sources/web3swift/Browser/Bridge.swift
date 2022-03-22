//
//  Bridge.swift
//  JSBridge
//
//  Created by SunJiangting on 2017/5/27.
//  Copyright © 2017 Samaritan. All rights reserved.
//

import WebKit

/// Bridge for WKWebView and JavaScript
open class Bridge: NSObject {

    static let name: String = "pacific"

    fileprivate static let callbackEventName = "PacificDidReceiveNativeCallback"
    fileprivate static let postEventName = "PacificDidReceiveNativeBroadcast"

    fileprivate enum MessageKey {
        static let action = "action"
        static let parameters = "parameters"
        static let callback = "callback"
        static let printable = "print"
    }

    public struct JSError {
        public let code: Int
        public let description: String

        public init(code: Int, description: String) {
            self.code = code
            self.description = description
        }
    }

    /// Used to callback to webpage whether a message from webpage was handled successful or encountered an error.
    ///
    /// - success: The result of message was successful
    ///
    /// - failure: Unable to handle the message, notify js with error by **Object Error** { code: Int, description: String}
    ///
    public enum Results {

        case success([String: Any]?)

        case failure(JSError)
    }

    /// Bridge Callback to webpage
    /// - Parameter results: Value pass to webpage
    public typealias Callback = (_ results: Results) -> Void

    /// Closure when js send message to native
    /// - Parameter parameters: js parameters
    /// - Parameter callback: callback func
    public typealias Handler = (_ parameters: [String: Any]?, _ callback: @escaping Callback) -> Void

    public typealias DefaultHandler = (_ name: String, _ parameters: [String: Any]?, _ callback: @escaping Callback) -> Void

    private(set) var handlers = [String: Handler]()

    public var defaultHandler: DefaultHandler?

    fileprivate let configuration: WKWebViewConfiguration
    fileprivate weak var webView: WKWebView?

    /// Print message body from webpage automatically.
    public var printScriptMessageAutomatically = false

    deinit {
        configuration.removeObserver(self, forKeyPath: #keyPath(WKWebViewConfiguration.userContentController))
        configuration.userContentController.removeScriptMessageHandler(forName: Bridge.name)
    }

    fileprivate init(webView: WKWebView) {
        self.webView = webView
        self.configuration = webView.configuration
        super.init()
        configuration.addObserver(self, forKeyPath: #keyPath(WKWebViewConfiguration.userContentController), options: [.new, .old], context: nil)
        configuration.userContentController.add(self, name: Bridge.name)
    }

    /// Register to handle action
    /// - Parameter handler: closure when handle message from webpage
    /// - parameter action: name of action
    ///
    /// - SeeAlso: `Handler`
    ///
    /// ```javascript
    /// // Post Event With Action Name
    /// window.bridge.post('print', {message: 'Hello, world'})
    /// // Post Event With Callback
    /// window.bridge.post('print', {message: 'Hello, world'}, (parameters, error) => { Handler Parameters Or Error})
    /// ```
    public func register(_ handler: @escaping Handler, for action: String) {
        handlers[action] = handler
    }

    /// Unregister an action
    /// - Parameters action: name of action
    public func unregister(for action: String) {
        handlers[action] = nil
    }

    /// send action to webpage
    /// - Parameter action: action listened by js `window.bridge.on(**action**, handler)`
    /// - Parameter parameters: parameters pass to js
    ///
    /// ```javascript
    /// // listen native login action
    /// window.bridge.on('login', (parameters)=> {console.log('User Did Login')})
    /// ```
    public func post(action: String, parameters: [String: Any]?) {
        guard let webView = webView else { return }
        webView.st_dispatchBridgeEvent(Bridge.postEventName, parameters: ["name": action], results: .success(parameters), completionHandler: nil)
    }

    /// Evaluates the given JavaScript string.
    /// - Parameter javaScriptString:  The JavaScript string to evaluate.
    /// - Parameter completion: A block to invoke when script evaluation completes or fails.
    public func evaluate(_ javaScriptString: String, completion: ((Any?, Error?) -> Void)? = nil) {
        guard let webView = webView else { return }
        webView.evaluateJavaScript(javaScriptString, completionHandler: completion)
    }

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if let obj = object as? WKWebViewConfiguration, let kp = keyPath, obj == configuration && kp == #keyPath(WKWebViewConfiguration.userContentController) {
            if let change = change {
                if let oldContentController = change[.oldKey] as? WKUserContentController {
                    oldContentController.removeScriptMessageHandler(forName: Bridge.name)
                }
                if let newContentController = change[.newKey] as? WKUserContentController {
                    newContentController.add(self, name: Bridge.name)
                }
            }
        }
    }
}

extension Bridge: WKScriptMessageHandler {

    /*! @abstract Invoked when a script message is received from a webpage.
     @param userContentController The user content controller invoking the
     delegate method.
     @param message The script message received.
     */
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any], let name = body[MessageKey.action] as? String else {
            return
        }
        if (body[MessageKey.printable] as? NSNumber)?.boolValue ?? printScriptMessageAutomatically {
            print(body)
        }
        guard let handler = handlers[name] else {
            guard let defaultHandler = self.defaultHandler else {
                return
            }
            if let callbackID = (body[MessageKey.callback] as? NSNumber) {
                defaultHandler(name, body[MessageKey.parameters] as? [String: Any]) { [weak self] (results) in
                    guard let strongSelf = self else {
                        return
                    }
                    // Do Nothing
                    guard let webView = strongSelf.webView else { return }
                    webView.st_dispatchBridgeEvent(Bridge.callbackEventName, parameters: ["id": callbackID], results: results, completionHandler: nil)
                }
            } else {
                defaultHandler(name, body[MessageKey.parameters] as? [String: Any]) { (results) in
                    // Do Nothing
                }
            }
            return
        }

        if let callbackID = (body[MessageKey.callback] as? NSNumber) {
            handler(body[MessageKey.parameters] as? [String: Any]) { [weak self] (results) in
                guard let strongSelf = self else {
                    return
                }
                // Do Nothing
                guard let webView = strongSelf.webView else { return }
                webView.st_dispatchBridgeEvent(Bridge.callbackEventName, parameters: ["id": callbackID], results: results, completionHandler: nil)
            }
        } else {
            handler(body[MessageKey.parameters] as? [String: Any]) { (results) in
                // Do Nothing
            }
        }
    }
}

public extension WKWebView {

    private struct STPrivateStatic {
        fileprivate static var bridgeKey = "STPrivateStatic.bridgeKey"
    }

    /// Bridge for WKWebView and JavaScript. Initialize `lazy`
    var bridge: Bridge {
        if let bridge = objc_getAssociatedObject(self, &STPrivateStatic.bridgeKey) as? Bridge {
            return bridge
        }
        let bridge = Bridge(webView: self)
        objc_setAssociatedObject(self, &STPrivateStatic.bridgeKey, bridge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return bridge
    }

    /// Remove Bridge And Reset, All the handlers will be removed
    func removeBridge() {
        if let bridge = objc_getAssociatedObject(self, &STPrivateStatic.bridgeKey) as? Bridge {
            let userContentController = bridge.configuration.userContentController
            userContentController.removeScriptMessageHandler(forName: Bridge.name)
        }
        objc_setAssociatedObject(self, &STPrivateStatic.bridgeKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

fileprivate extension WKWebView {

    func st_dispatchBridgeEvent(_ eventName: String,
                                            parameters: [String: Any],
                                            results: Bridge.Results,
                                            completionHandler: ((Any?, Error?) -> Void)? = nil) {

        var eventDetail: [String: Any] = parameters
        switch results {
        case .failure(let error):
            eventDetail["error"] = ["code": error.code, "description": error.description]
        case .success(let callbackParameters):
            eventDetail["parameters"] = callbackParameters ?? [:]
        }
        let eventBody: [String: Any] = ["detail": eventDetail]
        let jsString: String
        if
            let _data = try? JSONSerialization.data(withJSONObject: eventBody, options: JSONSerialization.WritingOptions()),
            let eventString = String(data: _data, encoding: .utf8) {

            jsString = "(function() { var event = new CustomEvent('\(eventName)', \(eventString)); document.dispatchEvent(event)}());"
        } else {
            // When JSON Not Serializable, Invoke with Default Parameters
            switch results {
            case .success(_):
                jsString = "(function() { var event = new CustomEvent('\(eventName)', {'detail': {'parameters': {}}}); document.dispatchEvent(event)}());"
            case .failure(let error):
                jsString = "(function() { var event = new CustomEvent('\(eventName)', {'detail': {'error': {'code': \(error.code), 'description': '\(error.description)'}}}); document.dispatchEvent(event)}());"
            }
        }
        evaluateJavaScript(jsString, completionHandler: completionHandler)
    }
}
