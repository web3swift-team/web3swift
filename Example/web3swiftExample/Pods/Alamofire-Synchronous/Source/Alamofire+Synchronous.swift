//
//  Alamofire+Synchronous.swift
//  Alamofire-Synchronous
//
//  Created by Luda Zhuang on 15/11/8.
//  Copyright © 2015年 Luda Zhuang. All rights reserved.
//

import Foundation
import Alamofire

extension DataRequest {
    
    
    /**
     Wait for the request to finish then return the response value.
     
     - returns: The response.
     */
    public func response() -> DefaultDataResponse {
        
        let semaphore = DispatchSemaphore(value: 0)
        var result: DefaultDataResponse!
        
        self.response(queue: DispatchQueue.global(qos: .default)) { response in
            
            result = response
            semaphore.signal()
            
        }
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return result
    }
    
    /**
     Wait for the request to finish then return the response value.
     
     - parameter responseSerializer: The response serializer responsible for serializing the request, response,
     and data.
     - returns: The response.
     */
    public func response<T: DataResponseSerializerProtocol>(responseSerializer: T) -> DataResponse<T.SerializedObject> {
        
        let semaphore = DispatchSemaphore(value: 0)
        var result: DataResponse<T.SerializedObject>!
        
        self.response(queue: DispatchQueue.global(qos: .default), responseSerializer: responseSerializer) { response in
            
            result = response
            semaphore.signal()
            
        }
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return result
    }
    
    
    /**
     Wait for the request to finish then return the response value.
     
     - returns: The response.
     */
    public func responseData() -> DataResponse<Data> {
        return response(responseSerializer: DataRequest.dataResponseSerializer())
    }
    
    
    /**
     Wait for the request to finish then return the response value.
     
     - parameter options: The JSON serialization reading options. `.AllowFragments` by default.
     
     - returns: The response.
     */
    public func responseJSON(options: JSONSerialization.ReadingOptions = .allowFragments) -> DataResponse<Any> {
        return response(responseSerializer: DataRequest.jsonResponseSerializer(options: options))
    }
    
    
    /**
     Wait for the request to finish then return the response value.
     
     - parameter encoding: The string encoding. If `nil`, the string encoding will be determined from the
     server response, falling back to the default HTTP default character set,
     ISO-8859-1.
     
     - returns: The response.
     */
    public func responseString(encoding: String.Encoding? = nil) -> DataResponse<String> {
        return response(responseSerializer: DataRequest.stringResponseSerializer(encoding: encoding))
    }
    
    
    /**
     Wait for the request to finish then return the response value.
     
     - parameter options: The property list reading options. Defaults to `[]`.
     
     - returns: The response.
     */
    public func responsePropertyList(options: PropertyListSerialization.ReadOptions = PropertyListSerialization.ReadOptions()) -> DataResponse<Any> {
        return response(responseSerializer: DataRequest.propertyListResponseSerializer(options: options))
    }
}


extension DownloadRequest {
    /**
     Wait for the request to finish then return the response value.
     
     - returns: The response.
     */
    public func response() -> DefaultDownloadResponse {
        
        let semaphore = DispatchSemaphore(value: 0)
        var result: DefaultDownloadResponse!
        
        self.response(queue: DispatchQueue.global(qos: .default)) { response in
            
            result = response
            semaphore.signal()
            
        }
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return result
    }
    
    
    /**
     Wait for the request to finish then return the response value.
     
     - parameter responseSerializer: The response serializer responsible for serializing the request, response,
     and data.
     - returns: The response.
     */
    public func response<T: DownloadResponseSerializerProtocol>(responseSerializer: T) -> DownloadResponse<T.SerializedObject> {
        
        let semaphore = DispatchSemaphore(value: 0)
        var result: DownloadResponse<T.SerializedObject>!
        
        self.response(queue: DispatchQueue.global(qos: .background), responseSerializer: responseSerializer) { response in
            
            result = response
            semaphore.signal()
            
        }
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return result
    }
    
    
    /**
     Wait for the request to finish then return the response value.
     
     - returns: The response.
     */
    public func responseData() -> DownloadResponse<Data> {
        return response(responseSerializer: DownloadRequest.dataResponseSerializer())
    }
    
    /**
     Wait for the request to finish then return the response value.
     
     - parameter options: The JSON serialization reading options. `.AllowFragments` by default.
     
     - returns: The response.
     */
    public func responseJSON(options: JSONSerialization.ReadingOptions = .allowFragments) -> DownloadResponse<Any> {
        return response(responseSerializer: DownloadRequest.jsonResponseSerializer(options: options))
    }
    
    /**
     Wait for the request to finish then return the response value.
     
     - parameter encoding: The string encoding. If `nil`, the string encoding will be determined from the
     server response, falling back to the default HTTP default character set,
     ISO-8859-1.
     
     - returns: The response.
     */
    public func responseString(encoding: String.Encoding? = nil) -> DownloadResponse<String> {
        return response(responseSerializer: DownloadRequest.stringResponseSerializer(encoding: encoding))
    }
    
    /**
     Wait for the request to finish then return the response value.
     
     - parameter options: The property list reading options. Defaults to `[]`.
     
     - returns: The response.
     */
    public func responsePropertyList(options: PropertyListSerialization.ReadOptions = PropertyListSerialization.ReadOptions()) -> DownloadResponse<Any> {
        return response(responseSerializer: DownloadRequest.propertyListResponseSerializer(options: options))
    }
}
