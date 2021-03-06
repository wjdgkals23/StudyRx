//
//  SearchMovieViewModel.swift
//  AllReview
//
//  Created by 정하민 on 2019/11/15.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import WebKit

class SignUpViewModel: ViewModel{
    
    var emailValidSubject:BehaviorSubject<String?>!
    var pwValidSubject:BehaviorSubject<String?>!
    var nickNameValidSubject:BehaviorSubject<String?>!
    
    var emailDriver:Driver<String>!
    var pwDriver:Driver<String>!
    var nickNameDriver:Driver<String>!
    
    var femaleSelected:BehaviorSubject<Bool>!
    var maleSelected:BehaviorSubject<Bool>!
    
    var valFemaleSelected:Observable<Bool>!
    var valMaleSelected:Observable<Bool>!
    
    var signUpDataValid:Driver<Bool>!
    
    init(sceneCoordinator: SceneCoordinator) {
        super.init(sceneCoordinator: sceneCoordinator)
        
        self.emailValidSubject = BehaviorSubject(value: nil)
        self.pwValidSubject = BehaviorSubject(value: nil)
        self.nickNameValidSubject = BehaviorSubject(value: nil)
        
        femaleSelected = BehaviorSubject(value: false)
        maleSelected = BehaviorSubject(value: false)

        self.valFemaleSelected = femaleSelected.distinctUntilChanged().flatMap { value -> Observable<Bool> in
            if (value) { return Observable.just(value) }
            else { return Observable.just(!value) }
        }

        self.valMaleSelected = maleSelected.distinctUntilChanged().flatMap { value -> Observable<Bool> in
            if (value) { return Observable.just(value) }
            else { return Observable.just(!value) }
        }
        
        let genderSelected = Observable.combineLatest(valMaleSelected, valFemaleSelected, resultSelector: { male,female in
            return Observable.just(male^female)
        })
        
        let signUpEnable:Observable<Bool> = Observable.combineLatest(emailValidSubject.asObservable(), pwValidSubject.asObservable(), nickNameValidSubject.asObservable(), resultSelector: { email,pw,nickName in
            var emailValid = false
            if(email != nil && email != "") { emailValid = true }
            var pwValid = false
            if(pw != nil && pw != "") { pwValid = true }
            var nickNameValid = false
            if(nickName != nil && nickName != "") { nickNameValid = true }
            return emailValid&&pwValid&&nickNameValid
        })
        
        self.signUpDataValid = signUpEnable.asDriver(onErrorJustReturn: false)
        
    }
}

extension Bool {
    static func ^ (left: Bool, right: Bool) -> Bool {
        return left != right
    }
}
