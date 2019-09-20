//
//  PlayController.swift
//  puzzle
//
//  Created by Petr Gusakov on 09/09/2019.
//  Copyright © 2019 Petr Gusakov. All rights reserved.
//

import UIKit
import AudioToolbox

class PlayController: UIViewController {

    //@IBOutlet var imageView: UIImageView!
    @IBOutlet var mainView: UIView!
    @IBOutlet var originalShowButton: UIBarButtonItem!
    
    var image : UIImage!
   // var startRect : CGRect!
    var dividion = 3
    var divButton =  UIButton(type: .custom)
    
    var showOriginalTimer = Timer()

    //var drawLayer = CALayer()
    
    var partLayerList : Array<CALayer> = Array()
    var isLayerActive = false
    var isPlay = false
    var sizePuzzle : CGSize!
    var indexActiveLayer = -1
    let inset : CGFloat = 30 // точность пальца - для точной установки квадратика
    var zPosition : CGFloat = 0
    
    var messageLayer = CATextLayer()
    
    var positionRectList : Array<CGRect> = Array()
    var positionPartWin : Array<CGPoint> = Array()
    var positionPartCurrent : Array<CGPoint> = Array()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.imageView.image = self.image
        //self.navigationItem.title = String(format: "%i x %i", dividion, dividion)
        
        //UserDefaults.standard.set(localIdentifier, forKey: "lastPhoto")
        self.dividion = UserDefaults.standard.integer(forKey: "dividion")
        if self.dividion == 0 {
            self.dividion = 3
            UserDefaults.standard.set(self.dividion, forKey: "dividion")
        }
        
        self.divButton =  UIButton(type: .custom)
        self.divButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        self.divButton.backgroundColor = .clear
        self.divButton.setTitleColor(.black, for: .normal)
        self.divButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 18)
        self.divButton.setTitle(String(format: "%i x %i ▼", dividion, dividion), for: .normal)
        self.divButton.addTarget(self, action: #selector(clickTitleButton), for: .touchUpInside)
        navigationItem.titleView = divButton
    }
    
    @objc func clickTitleButton() {
        if self.dividion < 6 {
            self.dividion += 1
        } else {
            self.dividion = 3
        }
        UserDefaults.standard.set(self.dividion, forKey: "dividion")
        divButton.setTitle(String(format: "%i x %i  ▼", dividion, dividion), for: .normal)
        self.isPlay = false
        viewDidAppear(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {//print("viewDidAppear")
        super.viewDidAppear(animated)
        if isPlay {
            return
        }
        self.isPlay = false
        self.originalShowButton.isEnabled = false

        self.positionPartWin = Array()
        self.positionRectList  = Array()
        for partLayer in self.partLayerList {
            partLayer.removeFromSuperlayer()
        }
        self.messageLayer.removeFromSuperlayer()
        self.partLayerList = Array()
        
        //self.drawLayer.sublayers?.forEach({ $0.removeFromSuperlayer() })
        
        self.sizePuzzle = CGSize(width: self.image.size.width / CGFloat(self.dividion), height: self.image.size.height / CGFloat(self.dividion))
//        print("sizePuzzle -\(sizePuzzle)")
        
        for row in 0..<dividion {
        //let row = 0
            for section in 0..<dividion {
                let origin = CGPoint(x: CGFloat(section) * sizePuzzle.width, y:  CGFloat(row) * sizePuzzle.height)
                let rect = CGRect(origin: origin, size: sizePuzzle)
                let imageCrop = self.image.cgImage?.cropping(to: rect)
                self.zPosition += 1.0
                
                let partLayer = CALayer()
                partLayer.anchorPoint =  CGPoint(x: 0.5, y: 1)
                partLayer.contents = imageCrop
                partLayer.borderColor = UIColor.lightGray.cgColor
                partLayer.borderWidth = 1
                partLayer.bounds = CGRect(x: 0, y: 0, width: sizePuzzle.width, height: sizePuzzle.height)
                partLayer.zPosition = self.zPosition
                
                let position = CGPoint(x: sizePuzzle.width * CGFloat(section) + sizePuzzle.width * partLayer.anchorPoint.x, y: sizePuzzle.height * CGFloat(row) + sizePuzzle.height * partLayer.anchorPoint.y)
                partLayer.position = position
                //print(position)

                self.positionPartWin.append(position)
                
                // для точной установки квадратика
                let centerPartLayer = partLayer.frame.center
                let rectStorePosition = CGRect(x: centerPartLayer.x - self.inset, y: centerPartLayer.y - self.inset, width: self.inset * 2, height: self.inset * 2)
                self.positionRectList.append(rectStorePosition)

                self.mainView.layer.addSublayer(partLayer)
                self.partLayerList.append(partLayer)
            }
        }
        //print("END viewDidAppear")
    }

    func movePuzzle() {
        self.positionPartCurrent = Array()
        for partLayer in self.partLayerList {
            let posX = Int.random(in: Int(self.sizePuzzle.width / 2)...Int(self.view.bounds.size.width))
            let posY = Int.random(in: Int(self.sizePuzzle.height / 2)...Int(self.view.bounds.size.height - self.sizePuzzle.height / 2))

            CATransaction.begin()
            CATransaction.setValue(NSNumber(value: 0.75), forKey: kCATransactionAnimationDuration)
            let position = CGPoint(x: posX, y: posY)
            partLayer.position = position
            CATransaction.commit()
            
            self.positionPartCurrent.append(position)
        }
        self.originalShowButton.isEnabled = true
    }
    
    // MARK: - IBAction
//    @IBAction func rotateAction(_ sender: Any) {
//
//        let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
//        rotation.toValue = Double.pi * 2
//        rotation.duration = 1.5 // or however long you want ...
//        rotation.isCumulative = true
//        rotation.repeatCount = 10
//
//        for partLayer in self.partLayerList {
//            CATransaction.begin()
//            CATransaction.setValue(NSNumber(value: 0.75), forKey: kCATransactionAnimationDuration)
//            partLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
//            partLayer.position = CGPoint(x: partLayer.position.x, y: partLayer.position.y - partLayer.bounds.size.height / 2.0)
//            CATransaction.commit()
//
//            partLayer.add(rotation, forKey: "rotationAnimation")
//        }
//    }
    
    @IBAction func originalShowAction(_ sender: Any) {
        self.originalShow(hide: true)
        //let sleep = DispatchTime.now() + 7 - Double(self.dividion)
        DispatchQueue.main.asyncAfter(deadline:  DispatchTime.now() + 1.5) {
            self.originalShow(hide: false)
        }
    }
    
    func originalShow(hide: Bool)  {
        self.originalShowButton.isEnabled = !hide
        for index in 0..<self.partLayerList.count {
            if hide {
                self.positionPartCurrent[index] = self.partLayerList[index].position
                self.partLayerList[index].position = self.positionPartWin[index]
            } else {
                self.partLayerList[index].position = self.positionPartCurrent[index]
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isPlay {
            isPlay = true
            self.movePuzzle()
            return
        }
        let touchPoint = touches.first!.location(in: self.mainView)
        for index in (0..<self.partLayerList.count).reversed() {
            if self.partLayerList[index].frame.contains(touchPoint) {
                self.zPosition += 1.0
                //print(self.zPosition)
                
                CATransaction.begin()
                CATransaction.setValue(true, forKey: kCATransactionDisableActions)
                self.partLayerList[index].borderColor = UIColor.red.cgColor
                self.partLayerList[index].borderWidth = 3
                self.partLayerList[index].zPosition = self.zPosition
                self.partLayerList[index].position = touchPoint
                CATransaction.commit()

                self.indexActiveLayer = index
                break
            }
        }
        //layer.position = touchPoint
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPoint = touches.first!.location(in: self.mainView)
        //let oldTouch = touches.first!.previousLocation(in: self.view)
        
        if self.indexActiveLayer >= 0 {
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            self.partLayerList[self.indexActiveLayer].position = touchPoint
            CATransaction.commit()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPoint = touches.first!.location(in: self.mainView)
        if self.indexActiveLayer >= 0 {
            self.partLayerList[self.indexActiveLayer].position = touchPoint
            self.partLayerList[self.indexActiveLayer].borderColor = nil
            self.partLayerList[self.indexActiveLayer].borderWidth = 0
//            self.layerList[self.indexActiveLayer].zPosition = 0

            self.correctPosition(indexLayer: indexActiveLayer)
        }
        self.indexActiveLayer = -1
    }
    
    func correctPosition(indexLayer: Int) {
        // сдвинем и проверим
        let centerRect = self.partLayerList[indexLayer].frame.center
        for index in 0..<self.positionRectList.count {
            let rect = self.positionRectList[index]
            if rect.contains(centerRect) {
                self.partLayerList[indexLayer].position = self.positionPartWin[index]
                break
            }
        }
        var positions : Array<CGPoint> = Array()
        for partLayer in self.partLayerList {
            positions.append(partLayer.position)
        }
        
        if positions == self.positionPartWin {
            youWin()
        }
    }
    
    func youWin() {
        AudioServicesPlayAlertSound(SystemSoundID(1304))
        self.originalShowButton.isEnabled = false
      
        let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = Double.pi * 2
        rotation.duration = 1.5 // or however long you want ...
        rotation.isCumulative = true
        rotation.repeatCount = 1

//        let rotationClock = CABasicAnimation(keyPath: "transform.rotation.z")
//        rotationClock.toValue = Double.pi * 2
//        rotationClock.duration = 1.5 // or however long you want ...
//        rotationClock.isCumulative = true
//        rotationClock.repeatCount = 3

        for partLayer in self.partLayerList {
            CATransaction.begin()
            CATransaction.setValue(NSNumber(value: 1.5), forKey: kCATransactionAnimationDuration)
            //CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            partLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            partLayer.position = CGPoint(x: partLayer.position.x, y: partLayer.position.y - partLayer.bounds.size.height / 2.0)
            CATransaction.commit()
            
            partLayer.add(rotation, forKey: "rotationAnimation")
        }
        
//        var rect = CGRect()
//        rect.origin.x = 0
//        rect.origin.y = (self.mainView.bounds.size.height - self.mainView.bounds.size.height / 4.0) / 2.0
//        rect.size.width = self.mainView.bounds.size.width
//        rect.size.height = self.mainView.bounds.size.height / 4.0
//
        //x: self.mainView.bounds.size.height /4 , y: , width: , height: )
//        self.messageLayer.frame = rect
//        self.messageLayer.alignmentMode = .center
//        self.messageLayer.string = "\nY O U   W I N !"
//        self.messageLayer.backgroundColor = UIColor.red.cgColor
//        self.messageLayer.foregroundColor = UIColor.white.cgColor
//        self.messageLayer.fontSize = 50.0
//        self.messageLayer.zPosition = 1000.0
//
//        self.mainView.layer.addSublayer(self.messageLayer)
//        self.messageLayer.add(rotationClock, forKey: "rotationAnimation")
        
        DispatchQueue.main.asyncAfter(deadline:  DispatchTime.now() + 1.5) {
            self.isPlay = false
            self.viewDidAppear(true)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension UIImage {
    func cropImage(toRect rect: CGRect) -> UIImage? {
        if let imageRef = self.cgImage?.cropping(to: rect) {
            return UIImage(cgImage: imageRef)
        }
        return nil
    }
}

extension CGRect {
    var center: CGPoint { return CGPoint(x: midX, y: midY) }
}

