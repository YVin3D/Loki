//
//  SharedBuffer.swift
//  Loki-Sample
//
//  Created by Youssef Kamal Victor on 11/17/17.
//  Copyright © 2017 Youssef Victor. All rights reserved.
//

import Foundation
import Metal


class SharedBuffer <T>  {
    // Data Alignment
    private let alignment  : Int = 0x4000
    
    // Buffer Size
    var count  : Int
    
    // The actual Buffer that stores the data
    var data : MTLBuffer?
    
    // Raw Pointer to the memory address of the first element
    private var memory:UnsafeMutableRawPointer? = nil
    
    // Pointer to the starting Element
    private var voidPtr: OpaquePointer!
    
    // Pointer to the starting Element
    private var startPtr: UnsafeMutablePointer<T>!
    
    // Pointer to the buffer -- Used to Index in
    private var bufferPtr: UnsafeMutableBufferPointer<T>!
    
    // Creates the Buffer
    init (count: Int, with device: MTLDevice, containing contents : [T] = []) {
        self.count = count
        
        var memoryByteSize  = count * MemoryLayout<T>.size.self
        let remainder = memoryByteSize % self.alignment
        memoryByteSize  = memoryByteSize + self.alignment - remainder
        
        // Assign Memory
        let error_code = posix_memalign(&memory, alignment, memoryByteSize)
        if error_code != 0 {
            fatalError("init() error: posix_memalign could not allocate memory for SharedBuffer<\(T.self)>")
        }
        
        // Setup Pointers
        self.voidPtr = OpaquePointer(memory)
        self.startPtr    = UnsafeMutablePointer<T>(voidPtr)
        self.bufferPtr   = UnsafeMutableBufferPointer(start: startPtr, count: self.count)
        
        // Actually Create The T Buffer
        self.data = device.makeBuffer(bytesNoCopy: memory!,
                                                 length: memoryByteSize,
                                                 options: .storageModeShared,
                                                 deallocator: nil)
        
        for i in 0..<contents.count {
            self.bufferPtr[i] = contents[i]
        }
        
        if self.data == nil {
            fatalError("init() error: makeBuffer could not create SharedBuffer<\(T.self)> with length: \(memoryByteSize)")
        }
    }
    
    public subscript(i: Int) -> T {
        get {
            return self.bufferPtr[i]
        }
        set (newValue) {
            self.bufferPtr[i] = newValue
        }
    }
    
    public func resize(count: Int, with device: MTLDevice) {
        // Free old memory
        free(memory)
    
        // Update Count
        self.count = count
    
        // Realign MemoryByteSize (Round up to neares multiple)
        var memoryByteSize = count * MemoryLayout<T>.size.self
        let remainder      = memoryByteSize % self.alignment
        memoryByteSize     = memoryByteSize + self.alignment - remainder
    
        // Assign Memory
        let error_code = posix_memalign(&memory, alignment, memoryByteSize)
        if error_code != 0 {
            fatalError("resize() error: makeBuffer could not create SharedBuffer<\(T.self)> with length: \(memoryByteSize)")
        }
        
        
        // Setup The T Buffer Again
        self.voidPtr     = OpaquePointer(memory)
        self.startPtr    = UnsafeMutablePointer<T>(voidPtr)
        self.bufferPtr   = UnsafeMutableBufferPointer(start: startPtr, count: self.count)
        
        // Actually Create The T Buffer
        self.data = device.makeBuffer(bytesNoCopy: memory!,
                                            length: memoryByteSize,
                                            options: .storageModeShared,
                                            deallocator: nil)
    }
    
    deinit {
        free(memory)
    }
}
