import Foundation
import HomeKit
#if !PMKCocoaPods
import PromiseKit
#endif

#if !os(tvOS) && !os(watchOS)

@available(iOS 9.0, *)
extension HMEventTrigger {

    @available(iOS 11.0, *)
    public func updateExecuteOnce(_ executeOnce: Bool) -> Promise<Void> {
        return Promise { seal in
            self.updateExecuteOnce(executeOnce, completionHandler: seal.resolve)
        }
    }

}

#endif
