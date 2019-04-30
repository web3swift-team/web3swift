//
//  EKEventStore+Promise.swift
//  PromiseKit
//
//  Created by Lammert Westerhoff on 16/02/16.
//  Copyright © 2016 Max Howell. All rights reserved.
//

import EventKit
#if !PMKCocoaPods
import PromiseKit
#endif

/**
 To import `EKEventStore`:

     pod "PromiseKit/EventKit"

 And then in your sources:

     import PromiseKit
 */
extension EKEventStore {

    /**
     Requests access to the event store.

     - Returns: A promise that fulfills with the resulting EKAuthorizationStatus.
     */
    public func requestAccess(to entityType: EKEntityType) -> Promise<EKAuthorizationStatus> {
        return Promise { seal in
            requestAccess(to: entityType) { granted, error in
                if let error = error {
                    seal.reject(error)
                } else {
                    seal.fulfill(EKEventStore.authorizationStatus(for: entityType))
                }
            }
        }
    }
}
