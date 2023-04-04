//
//  MainViewModel.swift
//  Belleforet
//
//  Created by Klim mac on 2022/03/10.
//

import Foundation
import RxCocoa
import RxSwift

protocol MainViewModelType {
    var inputs: MainViewModelInputs { get }
    var outputs: MainViewModelOutputs { get }
}

protocol MainViewModelInputs {
    func requestUserInfo()
}

protocol MainViewModelOutputs {
    var userInfo: PublishSubject<UserInfoMoel.UserInfo> { get }
    var error: PublishRelay<Error> { get }
    
}

class MainViewModel: MainViewModelType, MainViewModelInputs, MainViewModelOutputs {
    
    var inputs: MainViewModelInputs { self }
    var outputs: MainViewModelOutputs { self }
    
    let disposeBag = DisposeBag()
    
    var userInfo = PublishSubject<UserInfoMoel.UserInfo>()
    
    var error: PublishRelay<Error> = .init()
    
    func requestUserInfo() {
        ApiService().getUserInfo()
            .subscribe(
                onNext: { [weak self] model in
                    self?.userInfo.onNext(model)
                },
                onError: { [weak self] error in
                    
                    self?.error.accept(error)
                }
            ).disposed(by: disposeBag)
    }
}
