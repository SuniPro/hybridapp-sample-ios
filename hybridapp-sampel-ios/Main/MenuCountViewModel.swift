//
//  MenuCountViewModel.swift
//  Belleforet
//
//  Created by Klim Solution on 2023/02/01.
//

import Foundation
import RxCocoa
import RxSwift

protocol MenuCountViewModelType {
    var inputs: MenuCountViewModelInputs { get }
    var outputs: MenuCountViewModelOutputs { get }
}

protocol MenuCountViewModelInputs {
    func requestMenuCount()
}

protocol MenuCountViewModelOutputs {
    var menuCount: PublishSubject<MenuCountModel.MenuCount> { get }
    var error: PublishRelay<Error> { get }
}

class MenuCountViewModel: MenuCountViewModelType, MenuCountViewModelInputs, MenuCountViewModelOutputs {
    
    var inputs: MenuCountViewModelInputs { self }
    var outputs: MenuCountViewModelOutputs { self }
    
    let disposeBag = DisposeBag()
    
    var menuCount = PublishSubject<MenuCountModel.MenuCount>()
    var error: PublishRelay<Error> = .init()
    
    func requestMenuCount() {
        ApiService().getMenuCount()
            .catchAndReturn(MenuCountModel.MenuCount())
            .subscribe(
                onNext: { [weak self] model in
                    self?.menuCount.onNext(model)
                },
                onError: { [weak self] error in
                    self?.error.accept(error)
                }
            ).disposed(by: disposeBag)
    }
}
