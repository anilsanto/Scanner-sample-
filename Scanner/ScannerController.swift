//
//  ScannerController.swift
//  Scanner
//
//  Created by Anil Santo on 06/11/18.
//  Copyright © 2018 Anil Santo. All rights reserved.
//

import UIKit
import AVFoundation

class ScannerController: UIViewController {

    var captureSession: AVCaptureSession?
    var vedioPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                              AVMetadataObject.ObjectType.code39,
                              AVMetadataObject.ObjectType.code39Mod43,
                              AVMetadataObject.ObjectType.code93,
                              AVMetadataObject.ObjectType.code128,
                              AVMetadataObject.ObjectType.ean8,
                              AVMetadataObject.ObjectType.ean13,
                              AVMetadataObject.ObjectType.aztec,
                              AVMetadataObject.ObjectType.pdf417,
                              AVMetadataObject.ObjectType.qr]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpScannerView()
    }
    
    fileprivate func setUpScannerView(){
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else{ return }
        
        do{
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            vedioPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            vedioPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            vedioPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(vedioPreviewLayer!)
            
            captureSession?.startRunning()
            
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.red.cgColor
                qrCodeFrameView.layer.borderWidth = 3
                
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }
        }
        catch {
            print(error)
            return
        }
    }
}

extension ScannerController : AVCaptureMetadataOutputObjectsDelegate{
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count  == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
//        let barCodeObject = vedioPreviewLayer?.transformedMetadataObject(for: metadataObj)
        
        if let barcodeData = metadataObj.stringValue {
            guard let session = captureSession
                else {
                    return
            }
            session.stopRunning()
            captureSession = nil
            let alert = UIAlertController(title: "BarcodeDate", message: barcodeData, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertAction.Style.default) { (item) in
                self.setUpScannerView()
            })
            self.present(alert, animated: true, completion: nil)
            print("BarcodeDate=======")
            print(barcodeData)
        }
    }
}
