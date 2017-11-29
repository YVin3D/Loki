//
//  ViewController.swift
//  Loki-Sample
//
//  Created by Youssef Victor on 11/29/17.
//  Copyright © 2017 Youssef Victor. All rights reserved.
//

import Cocoa
import Metal
import MetalKit

class MetalViewController: NSViewController {

    var metalView : MTKView?
    var renderer  : Renderer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view to use the default device
        self.metalView = self.view as? MTKView
        self.metalView?.device = MTLCreateSystemDefaultDevice();
        
        if(metalView?.device == nil)
        {
            print("Metal Is Not Supported On This Device");
            return;
        }
        
        //Initializes the Renderer
        renderer = Renderer(in: metalView!)
        
        if(renderer == nil)
        {
            print("Renderer failed initialization");
            return;
        }
        
        self.metalView!.delegate = self.renderer;
        
        // Indicate that we would like the view to call our -[AAPLRender drawInMTKView:] 60 times per
        //   second.  This rate is not guaranteed: the view will pick a closest framerate that the
        //   display is capable of refreshing (usually 30 or 60 times per second).  Also if our renderer
        //   spends more than 1/60th of a second in -[AAPLRender drawInMTKView:] the view will skip
        //   further calls until the renderer has returned from that long -[AAPLRender drawInMTKView:]
        //   call.  In other words, the view will drop frames.  So we should set this to a frame rate
        //   that we think our renderer can consistently maintain.
        self.metalView!.preferredFramesPerSecond = 60;
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

