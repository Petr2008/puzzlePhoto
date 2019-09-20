//
//  ViewController.swift
//  puzzle
//
//  Created by Petr Gusakov on 09/09/2019.
//  Copyright © 2019 Petr Gusakov. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, PhotoListControllerDelegate {

    @IBOutlet var mainView: PhotoView!
    
    var localIdentifier : String!
    var imageShow : UIImage!
    var imageInput : UIImage!
    var drawLayer: CALayer!
    
    var isStartController = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {print("viewDidAppear")
        super.viewDidAppear(animated)
        if self.isStartController {return}
        loadLastPhoto()
        isStartController = true
    }
    
    // MARK: - Image
    func loadLastPhoto(){print("loadLastPhoto")
        self.localIdentifier = UserDefaults.standard.string(forKey: "lastPhoto")
        
        if self.localIdentifier == nil {
            self.performSegue(withIdentifier: "photo", sender: self)
        } else {
            let requestOptions = PHImageRequestOptions()
            requestOptions.deliveryMode = .highQualityFormat
            requestOptions.isSynchronous = true
            
            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [self.localIdentifier!], options: nil)
            if fetchResult.count != 0 {
                let imageManager = PHImageManager.default()
                imageManager.requestImage(for: fetchResult.object(at: 0) , targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.aspectFit, options: requestOptions) {
                    (image, _) in
                    if image == nil { self.loadLastPhoto() }
                    
                    self.imageInput = image!
                    self.showImage(self.imageInput)
                }
            } else {
                UserDefaults.standard.removeObject(forKey: "lastPhoto")
                loadLastPhoto()
            }
        }
    }

    
    func showImage(_ image: UIImage) {print("showImage")
        self.drawLayer?.sublayers?.forEach({ $0.removeFromSuperlayer() })
        //        print("входящее - \(image.size)")
        
        guard var cgImage = image.cgImage else {
            print("Image has no CGImage backing it!")
            return
        }
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        
        let scaleWidth = self.mainView.bounds.width / width
        let scaleHeight = self.mainView.bounds.height / height
        let scaleRatio = min(scaleWidth, scaleHeight)
        
        let widthScreenImage = width * scaleRatio
        let heightScreenImage = height * scaleRatio
        let size = CGSize(width: widthScreenImage, height: heightScreenImage)
        
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()!
        
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: 0, y: -heightScreenImage)
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: widthScreenImage, height: heightScreenImage))
        cgImage = context.makeImage()!
        UIGraphicsEndImageContext()
        
        var rectToImage = CGRect()
        rectToImage.size = CGSize(width: widthScreenImage, height: heightScreenImage)
        rectToImage.origin = CGPoint(x: (self.mainView.bounds.width - rectToImage.size.width) / 2 , y: (self.mainView.bounds.height - rectToImage.size.height) / 2)
        
        self.imageShow = UIImage(cgImage: cgImage)
        self.mainView.rectToImage = rectToImage
        self.mainView.scaleRatio = scaleRatio
        
        self.mainView.image = self.imageShow
        self.mainView.setNeedsDisplay()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPoint = touches.first!.location(in: self.mainView)
        if self.mainView.frame.contains(touchPoint) {
            self.performSegue(withIdentifier: "play", sender: self)
        }
    }
    
    // MARK: - PhotoListControllerDelegate
    func didSelectPhotoName(localIdentifier: String) {
        //        print(localIdentifier)
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isSynchronous = true
        
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        
        let imageManager = PHImageManager.default()
        imageManager.requestImage(for: fetchResult.object(at: 0) , targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.aspectFit, options: requestOptions) {
            (image, _) in
            
            self.imageInput = image!
            
            UserDefaults.standard.set(localIdentifier, forKey: "lastPhoto")
            self.showImage(self.imageInput)
            
//            DispatchQueue.main.async {
//                //self.imageView.image = self.image
//
//            }
        }
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "photo" {
            let photoListController = segue.destination as! PhotoListController
            photoListController.delegate = self
        }
        if segue.identifier == "play" {
            let playController = segue.destination as! PlayController
            playController.image = self.imageShow
        }
    }

}
// MARK: - class
class PhotoView:UIView{
    var image : UIImage!
    var rectToImage = CGRect()
    var scaleRatio = CGFloat()
    
    override func draw(_ rect: CGRect) {
        //print("PhotoView draw - \(rect)")
        if image == nil || rectToImage.size.width == 0 || rectToImage.size.height == 0 {return}
        
        UIColor.blue.setStroke()
        UIBezierPath(rect: self.bounds).stroke()
        
        image!.draw(in: rectToImage)
    }
}


