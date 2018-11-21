
# web3swift 2.0 Migration Guide

web3swift 2.0 is the latest major release of web3swift by Matter, Swift implementation of web3.js functionality for iOS and macOS. Following Semantic Versioning conventions, 2.0 introduces major release API-breaking changes.

This guide is provided in order to ease the transition of existing applications using web3swift 1.x to the latest APIs, as well as explain the design and structure of new and updated functionality.

- [Requirements](#requirements)
- [Benefits of Upgrading](#benefits-of-upgrading)
- [Breaking API Changes](#breaking-api-changes)

## Requirements

- iOS 9.0+, macOS 10.11.0+
- Xcode 10.0+
- Swift 4.0+

## Benefits of Upgrading

- **Complete Swift 4 Compatibility:** includes the full adoption of the new [API Design Guidelines](https://swift.org/documentation/api-design-guidelines/).
- **New class: TransactionOptions:** "Web3Options" is no longer used, instead new class introduced: "TransactionOptions" used to specify gas price, limit, nonce policy, value.
- **New classes: Write Transaction & Read Transaction:** "TransactionIntermediate" is no longer used, instead two new classes introduced: "ReadTransaction" and "WriteTransaction", that have a variable "transactionOptions" used to specify gas price, limit, nonce policy, value
- **WKWebView with injected "web3" provider:** create a simple DApps' browser with "web3" provider onboard.
- **Add or remove "middleware":** that intercepts, modifies and even cancel transaction workflow on stages "before assembly" (before obtaining nonce, gas price, etc), "after assembly" (when nonce and gas price is set for transaction) and "before submission" (right before transaction is either signed locally and is sent as raw, or just send to remote node).
- **Hooks and event loops functionality:** easy monitor properties in web3.
- **New errors handling:** more 'try-catch' less optionals for errors handling.
- **Removed "Result" framework:** usage of "Result" framework was removed due to large amount if name conflicts, now functions throw instead of returning "Result" wrapper.

---

## Breaking API Changes

web3swift 2.0 has fully adopted all the new Swift 4 changes and conventions, including the new [API Design Guidelines](https://swift.org/documentation/api-design-guidelines/). Because of this, almost every API in web3swift has been modified in some way. We can't possibly document every single change, so we're going to attempt to identify the most common APIs and how they have changed to help you through those sometimes less than helpful compiler errors.

