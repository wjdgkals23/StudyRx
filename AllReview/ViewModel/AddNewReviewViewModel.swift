//
//  AddNewReviewViewModel.swift
//  AllReview
//
//  Created by 정하민 on 2019/11/15.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
import WebKit

enum ImageLoadError: Error {
    case imageNotExisting
    case failLoadData
    case unknown
}

class AddNewReviewViewModel: ViewModel{
    
    var imageViewImageSubject: BehaviorSubject<UIImage?> = BehaviorSubject(value: #imageLiteral(resourceName: "title"))
    var reviewTitleTextSubject: BehaviorSubject<String> = BehaviorSubject(value: "")
    var reviewContentTextSubject: BehaviorSubject<String> = BehaviorSubject(value: "")
    var starPointIntSubject: BehaviorSubject<Int> = BehaviorSubject(value: 5)
    
    var movieNameTextDriver: Driver<String>!
    
    var isImageValid: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    var isTitleValid: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    var isContentValid: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    
    var uploadData: [String:Any]!
    private var firstImage: UIImage!
    private var firstImageUrl: String!
    private var movieId: String!
    
    init(sceneCoordinator: SceneCoordinator, initData: [String:String]?) {
        super.init(sceneCoordinator: sceneCoordinator)
        
        if let imageUrl = initData!["posterImage"]?.decodeUrl(), imageUrl != "", let movieName = initData!["movieKorName"]?.decodeUrl(), let movieId = initData!["naverMovieId"] {
            firstImageUrl = imageUrl
            uploadData = ["memberId": self.userLoginSession.getLoginData()?.data?._id, "movieId": movieId, "starPoint": 5, "imageUrl": firstImageUrl, "oneLineReview": "", "detailReview": ""]
            self.movieNameTextDriver = BehaviorSubject(value: movieName).asDriver(onErrorJustReturn: "")
            
            self.request.urlDataLoad(url: URL(string: firstImageUrl)!) { [weak self] (image, err) in
                if let err = err {
                    self?.errorHandleSubject.onNext(err.localizedDescription)
                } else {
                    self?.firstImage = image
                    self?.imageViewImageSubject.onNext(image)
                }
            }
            
        } else {
            uploadData = ["memberId": self.userLoginSession.getLoginData()?.data?._id, "movieId": "", "starPoint": 5, "imageUrl": "", "oneLineReview": "", "detailReview": ""]
            self.movieNameTextDriver = BehaviorSubject(value: "").asDriver(onErrorJustReturn: "")
        }
        
        _ = imageViewImageSubject.distinctUntilChanged()
            .throttle(.milliseconds(100), scheduler: MainScheduler.instance)
            .map({ image in
                return image != #imageLiteral(resourceName: "title")
            }).bind(to: isImageValid)
        
        _ = reviewTitleTextSubject.distinctUntilChanged()
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .map({ title in
                self.uploadData["oneLineReview"] = title
                return title != "" && title.count > 1
            }).bind(to: isTitleValid)
        
        _ = reviewContentTextSubject.distinctUntilChanged()
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .map({ content in
                self.uploadData["detailReview"] = content
                return content != "" && content.count > 1
            }).bind(to: isContentValid)
        
        starPointIntSubject.distinctUntilChanged()
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { point in
                self.uploadData["starPoint"] = point
            }).disposed(by: self.disposeBag)
        
    }
    
    func upload() {
        guard let image = try? self.imageViewImageSubject.value() else {
            return
        }
        if image != self.firstImage {
            self.request.uploadImageToFireBase(userId: (self.userLoginSession.getLoginData()?.data!._id)!, movieId: self.uploadData!["movieId"] as! String, image: image) { [weak self] (url, err) in
                if let err = err {
                    self?.errorHandleSubject.onNext(err.localizedDescription)
                } else {
                    self?.uploadData["imageUrl"] = url?.absoluteString
                    self?.request.uploadReviewData(uploadData: self!.uploadData, completionHandler: { [weak self] (res, err) in
                        if let err = err {
                            self?.errorHandleSubject.onNext(err.localizedDescription)
                        } else {
                            self?.uploadReviewResultCodeParse(resultCode: UploadReviewErrResponse(rawValue: (res?.resultCode)!)!, userData: res!)
                        }
                    })
                }
            }
        } else {
            self.request.uploadReviewData(uploadData: self.uploadData, completionHandler: { [weak self] (res, err) in
                if let err = err {
                    self?.errorHandleSubject.onNext(err.localizedDescription)
                } else {
                    self?.uploadReviewResultCodeParse(resultCode: UploadReviewErrResponse(rawValue: (res?.resultCode)!)!, userData: res!)
                }
            })
        }
    }
    
    private func uploadReviewResultCodeParse(resultCode: UploadReviewErrResponse, userData: UploadReviewResponse) {
        DispatchQueue.main.async {
            switch resultCode {
            case .success:
                let coordinator = SceneCoordinator.init(window: UIApplication.shared.keyWindow!)
                let mainNewVM = MainViewModel(sceneCoordinator: coordinator)
                let mainNewScene = Scene.main(mainNewVM)
                
                self.sceneCoordinator.transition(to: mainNewScene, using: .root, animated: false)
            default:
                self.errorHandleSubject.onNext(userData.resultMsg)
            }
        }
        
    }
    
    private func rootMainView() {
        let coordinator = SceneCoordinator.init(window: UIApplication.shared.keyWindow!)
        let mainNewVM = MainViewModel(sceneCoordinator: coordinator)
        let mainNewScene = Scene.main(mainNewVM)
        
        self.sceneCoordinator.transition(to: mainNewScene, using: .root, animated: false)
    }
    
    
}

extension AddNewReviewViewModel: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
}
