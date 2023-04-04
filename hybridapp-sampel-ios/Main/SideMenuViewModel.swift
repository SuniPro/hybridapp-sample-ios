//
//  SideMenuViewModel.swift
//  Belleforet
//
//  Created by Klim mac on 2022/02/22.
//

import Foundation
import RxCocoa
import RxSwift


protocol SideMenuViewModelType {
    var inputs: SideMenuViewModelInputs { get }
    var outputs: SideMenuViewModelOutputs { get }
}

protocol SideMenuViewModelInputs {
    func requestSideMenu()
}

protocol SideMenuViewModelOutputs {
    var sideMenuList: PublishSubject<SideMenuModel.SideMenuList> { get }
    var error: PublishRelay<Error> { get }
}

class SideMenuViewModel: SideMenuViewModelType, SideMenuViewModelInputs, SideMenuViewModelOutputs {
    
    var inputs: SideMenuViewModelInputs { self }
    var outputs: SideMenuViewModelOutputs { self }
    
    let disposeBag = DisposeBag()
    
    var sideMenuList = PublishSubject<SideMenuModel.SideMenuList>()
    var error: PublishRelay<Error> = .init()
    
    func requestSideMenu() {
        ApiService().getSideMenu()
            .subscribe(
                onNext: { [weak self] model in
                    self?.sideMenuList.onNext(model)
                },
                onError: { [weak self] error in
                    
                    self?.error.accept(error)
                }
            ).disposed(by: disposeBag)
        
    }
    
    
}
