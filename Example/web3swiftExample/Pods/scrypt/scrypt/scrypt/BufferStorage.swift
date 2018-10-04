//
//  BufferStorage.swift
//  web3swift
//
//  Created by Alexander Vlasov on 10.08.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
import Foundation

final class BufferStorage<T>{
    
    typealias Index = Int
    typealias Indices = CountableRange<Int>
    typealias Element = T
    
    struct refCountedPtr {
        var ptr: UnsafeMutablePointer<Element>
        var refCount: Int
    }
    
    private var ptr: refCountedPtr
    private let capacity: Int
    
    public var count : Int {
        return self.capacity
    }
    
    init(ptr: refCountedPtr, capacity: Int) {
        self.ptr = refCountedPtr(ptr: ptr.ptr, refCount: 0)
        self.capacity = capacity
    }
    
    init(capacity: Int) {
        let ptr = UnsafeMutablePointer<Element>.allocate(capacity: capacity)
        self.ptr = refCountedPtr(ptr: ptr, refCount: 1)
        self.capacity = capacity
    }
    
    // copy with pointer being strong referenced
    init(array: Array<Element>) {
        self.capacity = array.count
        let ptr = UnsafeMutablePointer<Element>.allocate(capacity: capacity)
        self.ptr = refCountedPtr(ptr: ptr, refCount: 1)
        for i in 0..<self.capacity {
            self.ptr.ptr.advanced(by: i).pointee = array[i]
        }
    }
    
    // copy with pointer being strong referenced
    init(repeating: Element, count: Int) {
        self.capacity = count
        let ptr = UnsafeMutablePointer<Element>.allocate(capacity: capacity)
        self.ptr = refCountedPtr(ptr: ptr, refCount: 1)
        for i in 0..<count {
            self.ptr.ptr.advanced(by: i).pointee = repeating
        }
    }
    
    // copy with pointer being strong referenced
    static func copy(buffer: BufferStorage<Element>, count: Int) ->  BufferStorage<Element> {
        let storage = BufferStorage<Element>(capacity: buffer.capacity)
        storage.ptr.ptr.initialize(from: buffer.ptr.ptr, count: count)
        return storage
    }
    
    func copy(to: BufferStorage<Element>, count: Int) {
        precondition(to.capacity >= count)
        to.ptr.ptr.initialize(from: self.ptr.ptr, count: count)
    }
    
    // provide weak view
    subscript(bounds: Range<Index>) -> BufferStorage<T> {
        precondition(bounds.lowerBound < self.capacity)
        let shiftedPtr = self.ptr.ptr.advanced(by: bounds.lowerBound)
        let reducedCapacity = bounds.count
        return BufferStorage<T>(ptr: refCountedPtr(ptr: shiftedPtr, refCount: 0), capacity: reducedCapacity)
    }
    
    // provide weak view
    subscript(bounds: CountablePartialRangeFrom<Index>) -> BufferStorage<T> {
        precondition(bounds.lowerBound < self.capacity)
        let shiftedPtr = self.ptr.ptr.advanced(by: bounds.lowerBound)
        let reducedCapacity = self.capacity - bounds.lowerBound
        return BufferStorage<T>(ptr: refCountedPtr(ptr: shiftedPtr, refCount: 0), capacity: reducedCapacity)
    }
    
    subscript(_ at: Index) -> T {
        get {
            if at < self.capacity {
                return self.ptr.ptr.advanced(by: at).pointee
            } else {
                preconditionFailure("Index beyond end of queue")
            }
        }
        set (newValue) {
            if at < self.capacity {
                self.ptr.ptr.advanced(by: at).pointee = newValue
            } else {
                preconditionFailure("Index beyond end of queue")
            }
        }
    }
    
    func replace(_ at: Index, with: T) {
        if at < self.capacity {
            self.ptr.ptr.advanced(by: at).pointee = with
        } else {
            preconditionFailure("Index beyond end of queue")
        }
    }
    
    func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C: Collection, C.Iterator.Element == T {
        precondition(subrange.lowerBound >= 0, "Subrange lowerBound is negative")
        precondition(subrange.upperBound < self.capacity, "Subrange upper bound is out of range")
        for (offset, element) in newElements.enumerated() {
            let at = subrange.lowerBound.advanced(by: offset)
            self.ptr.ptr.advanced(by: at).pointee = element
        }
    }
    
    func replaceSubrange(_ subrange: Range<Int>, with newElements: BufferStorage<T>) {
        precondition(subrange.lowerBound >= 0, "Subrange lowerBound is negative")
        precondition(subrange.upperBound <= self.capacity, "Subrange upper bound is out of range")
        precondition(subrange.count <= newElements.capacity)
        self.ptr.ptr.advanced(by: subrange.lowerBound).initialize(from: newElements.ptr.ptr, count: subrange.count) // copy assign
    }
    
//    func replaceSubrange(_ subrange: CountableRange<Int>, with newElements: BufferStorage<T>) {
//        precondition(subrange.lowerBound >= 0, "Subrange lowerBound is negative")
//        precondition(subrange.upperBound <= self.capacity, "Subrange upper bound is out of range")
//        precondition(subrange.count <= newElements.capacity)
//        self.ptr.ptr.advanced(by: subrange.lowerBound).initialize(from: newElements.ptr.ptr, count: subrange.count) // copy assign
//    }
    
    func replaceSubrange(_ at: Index, with: T) {
        if at < self.capacity {
            self.ptr.ptr.advanced(by: at).pointee = with
        } else {
            preconditionFailure("Index beyond end of queue")
        }
    }
    
    func toArray() -> Array<T> {
        var result = Array<T>()
        result.reserveCapacity(self.count)
        for i in 0 ..< self.count {
            result.append(self.ptr.ptr.advanced(by: i).pointee)
        }
        return result
    }
    
    deinit {
        if self.ptr.refCount == 1 {
//            print("Strong deinit")
            self.ptr.ptr.deallocate()
        }
    }
}
