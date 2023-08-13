//
//  ViewController.swift
//  DrawingApp
//
//  Created by Tikhon Bazar on 12.08.23.
//

import UIKit
import PencilKit
import PhotosUI

class ViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver {

    @IBOutlet weak var pencilButton: UIBarButtonItem!
    @IBOutlet weak var canvasView: PKCanvasView!
    
    let canvasWidth: CGFloat = 768
    let canvasHight: CGFloat = 500
    
    var drawing = PKDrawing()
    let toolPicker = PKToolPicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Drawing"
        
        canvasView.delegate = self
        canvasView.drawing = drawing
        
        canvasView.alwaysBounceVertical = true
        canvasView.drawingPolicy = .anyInput
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.toolPicker.setVisible(true, forFirstResponder: canvasView)
        self.toolPicker.addObserver(canvasView)
        
        canvasView.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let canvasScale = canvasView.bounds.width / canvasWidth
        canvasView.minimumZoomScale = canvasScale
        canvasView.maximumZoomScale = canvasScale
        canvasView.zoomScale = canvasScale
        updateContentSize()
        canvasView.contentOffset = CGPoint(x: 0, y: -canvasView.adjustedContentInset.top)
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        updateContentSize()
    }
    
    func updateContentSize() {
        let drawing = canvasView.drawing
        let contentHeight: CGFloat
        
        if !drawing.bounds.isNull {
            contentHeight = max(canvasView.bounds.height, (drawing.bounds.maxY+self.canvasHight)*canvasView.zoomScale)
        }else{
            contentHeight = canvasView.bounds.height
        }
        
        canvasView.contentSize = CGSize(width: canvasWidth*canvasView.zoomScale, height: contentHeight)
    }
    
    @IBAction func drawOrScroll(_ sender: Any) {
        if pencilButton.image == UIImage(systemName: "hand.raised.fingers.spread") {
            canvasView.drawingPolicy = .anyInput
            pencilButton.image = UIImage(systemName: "pencil")
        }else{
            canvasView.drawingPolicy = .pencilOnly
            pencilButton.image = UIImage(systemName: "hand.raised.fingers.spread")
        }
    }
    
    @IBAction func screenshot(_ sender: Any) {
        UIGraphicsBeginImageContextWithOptions(canvasView.bounds.size, false, UIScreen.main.scale)
        canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if image != nil {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image!)
            })
        }
    }
    
}

