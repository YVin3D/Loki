//
//  Renderer.swift
//  Loki-Sample
//
//  Created by Youssef Kamal Victor on 11/8/17.
//  Copyright © 2017 Youssef Victor. All rights reserved.
//

import Cocoa
import Metal
import MetalKit
import simd

// TODO: Remove This Render Debug Value
var myview: MTKView?

class Renderer: NSObject {
    
    /*****
     **
     **  Iteration Number
     **
     ******/
    private var iteration = 0
    
    let device: MTLDevice
    // Default GPU Library
    private let defaultLibrary: MTLLibrary
    // The command Queue from which we'll obtain command buffers
    private let commandQueue: MTLCommandQueue!
    
    private var ps_ShadeImage: MTLComputePipelineState!;
    private var kern_ShadeImage: MTLFunction!
    
    private var width : Int
    private var height : Int
 
    
    
    /// Initialize with the MetalKit view from which we'll obtain our Metal device.  We'll also use this
    /// mtkView object to set the pixelformat and other properties of our drawable
    init(in mtkView: MTKView) {
        self.device = mtkView.device!;
        self.commandQueue = device.makeCommandQueue();
        self.defaultLibrary = device.makeDefaultLibrary()!
        
        // TODO: delet this:
        // needed for displaying texture for debug views
        myview = mtkView
        
        // Tell the MTKView that we want to use other buffers to draw
        // (needed for displaying from our own texture)
        mtkView.framebufferOnly = false
        
        // Indicate we would like to use the RGBAPisle format.
        mtkView.colorPixelFormat = .bgra8Unorm
        
        //Some Other Stuff
        mtkView.sampleCount = 1
        mtkView.preferredFramesPerSecond = 60
        
        self.width = Int(mtkView.frame.width)
        self.height = Int(mtkView.frame.height)
        
        super.init()
        
        // Sets up the Compute Pipeline that we'll be working with
        self.setupComputePipeline()
    }
    
    private func setupComputePipeline() {
        // Create Pipeline State for RayGenereration from Camera
        self.kern_ShadeImage = defaultLibrary.makeFunction(name: "kern_ShadeImage")
        do    { try ps_ShadeImage = device.makeComputePipelineState(function: kern_ShadeImage)}
        catch { fatalError("ShadeImage computePipelineState failed")}
    }
}


extension Renderer {
    fileprivate func dispatchPipelineState(using commandEncoder: MTLComputeCommandEncoder) {
        let w = ps_ShadeImage.threadExecutionWidth
        let h = ps_ShadeImage.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)
        
        let threadgroupsPerGrid =  MTLSize(width:  (self.width + w - 1) / w,
                                             height: (self.height + h - 1) / h,
                                             depth: 1)
        
        commandEncoder.setComputePipelineState(ps_ShadeImage)
        commandEncoder.dispatchThreadgroups(threadgroupsPerGrid,
                                            threadsPerThreadgroup: threadsPerThreadgroup)
    }
    
    fileprivate func update(in view: MTKView) {
        let commandBuffer = self.commandQueue.makeCommandBuffer()
        commandBuffer?.label = "Iteration: \(self.iteration)"
        
        let commandEncoder = commandBuffer?.makeComputeCommandEncoder()
        
        // If the commandEncoder could not be made
        if commandEncoder == nil || commandBuffer == nil {
            return
        }
        
        
        // If drawable is not ready, don't draw
        guard let drawable = view.currentDrawable
        else { // If drawable
            print("Drawable not ready for iteration #\(self.iteration)")
            commandEncoder!.endEncoding()
            commandBuffer!.commit()
            return;
        }
        
        commandEncoder!.setBytes(&self.iteration,  length: MemoryLayout<Int>.size, index: 0)
        commandEncoder!.setTexture(myview!.currentDrawable?.texture , index: 0)
        self.dispatchPipelineState(using: commandEncoder!)
        
        self.iteration += 1

        commandEncoder!.endEncoding()
        commandBuffer!.present(drawable)
        commandBuffer!.commit()
    }
    
}

extension Renderer : MTKViewDelegate {
    
    // Is called on each frame
    func draw(in view: MTKView) {
        self.update(in: view)
    }
    
    // If the window changes
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Update Class Variables
        self.width  = Int(view.drawableSize.width)
        self.height = Int(view.drawableSize.height)
        
        self.iteration = 0
    }
}
