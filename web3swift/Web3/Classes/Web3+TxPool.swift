//
//  Web3+TxPool.swift
//  web3swift-iOS
//
//  Created by Jun Park on 09/10/2018.
//  Copyright © 2018 The Matter Inc. All rights reserved.
//

import Foundation
import Result
import BigInt


extension web3.TxPool {
    public func getInspect() -> Result<[String:[String:[String:String]]], Web3Error> {
        do {
            let result = try self.getInspectPromise().wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(err: error))
        }
    }
    
    public func getStatus() -> Result<TxPoolStatus, Web3Error> {
        do {
            let result = try self.getStatusPromise().wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(err: error))
        }
    }
    
    public func getContent() -> Result<TxPoolContent, Web3Error> {
        do {
            let result = try self.getContentPromise().wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(err: error))
        }
    }
}
