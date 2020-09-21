import Foundation
import HomeKit
#if !PMKCocoaPods
import PromiseKit
#endif

#if !os(tvOS) && !os(watchOS)

extension HMActionSet {

    @available(iOS 8.0, *)
    public func addAction(_ action: HMAction) -> Promise<Void> {
        return Promise { seal in
            self.addAction(action, completionHandler: seal.resolve)
        }
    }

    @available(iOS 8.0, *)
    public func updateName(_ name: String) -> Promise<Void> {
        return Promise { seal in
            self.updateName(name, completionHandler: seal.resolve)
        }
    }
}

#endif
