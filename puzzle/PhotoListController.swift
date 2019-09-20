//
//  PhotoListController.swift
//  Interior
//
//  Created by Petr Gusakov on 27/07/2019.
//  Copyright © 2019 Petr Gusakov. All rights reserved.
//

import UIKit
import Photos

protocol PhotoListControllerDelegate: class {
    func didSelectPhotoName(localIdentifier: String)
}

class PhotoListController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, PHPhotoLibraryChangeObserver {//}, SelectPhotoOfAlbumDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var collectionLayout: UICollectionViewFlowLayout!

    weak var delegate: PhotoListControllerDelegate? = nil
    
    let documentUrl = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)

    var fetchResult: PHFetchResult<AnyObject>!
    var selectList : Array<Bool>!
    var selectNameList : [Int: String] = [:]
    var isScreenAlbum = false
    
    let languageCode = Locale.current.languageCode
    
    var isMultiSelect = false
    var allCountImage = 0
    let maxCountImage = 10

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("\nviewDidAppear")
        let width = (self.view.bounds.width - 3) / 3
        collectionLayout.itemSize = CGSize(width: width, height: width)

        photoAuthorization()
    }
    
    func photoAuthorization() {print("photoAuthorization")
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            print("Photo Auth Ok")

            PHPhotoLibrary.shared().register(self)
            self.loadImages()
        case .restricted, .denied:
            // закрыт
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: {enabled in
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            })
        case .notDetermined:
            // не определен
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    print("Photo Auth Ok")
                    self.loadImages()
                case .restricted, .denied:
                    print("Клиент запретил сдуру - добавить функцию!!!!!!")
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                case .notDetermined: break
                @unknown default:
                    fatalError()
                }
            }
        @unknown default:
            fatalError()
        }
    }

    // MARK: Данные
    func loadImages() {//print("loadImages")
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions) as? PHFetchResult<AnyObject>

        if fetchResult.count > 0 {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        self.selectList = Array(repeating: false, count: fetchResult.count)
    }

    // MARK: PHPhotoLibraryChangeObserver
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        //print("photoLibraryDidChange")
        loadImages()
    }

    // MARK: IBAction
    @IBAction func cameraAction(_ sender: Any) {
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - UICollection delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (fetchResult != nil) {
            return fetchResult.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let name = self.fetchResult[indexPath.row].value(forKey: "localIdentifier") as! String
        self.delegate?.didSelectPhotoName(localIdentifier: name)
        self.navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : PhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        let requestOptions = PHImageRequestOptions()
        PHImageManager.default().requestImage(for: fetchResult.object(at: indexPath.row) as! PHAsset, targetSize: collectionLayout.itemSize, contentMode: PHImageContentMode.aspectFill, options: requestOptions) {
            (image, _) in
                cell.imageView.image = image
        }
        
        return cell
    }
    
    // MARK: - Navigation
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    */
}
