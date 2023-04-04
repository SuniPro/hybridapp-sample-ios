import Foundation
import RxCocoa
import RxSwift

protocol IntroViewModelType {
    var inputs: IntroViewModelInputs { get }
    var outputs: IntroViewModelOutputs { get }
}

protocol IntroViewModelInputs {
    func requestAppVersion()
}

protocol IntroViewModelOutputs {
    var appVersion: PublishSubject<IntroModel.Appversion> { get }
    var error: PublishRelay<Error> { get }
}

class IntroViewModel: IntroViewModelType, IntroViewModelInputs, IntroViewModelOutputs {
    
    var inputs: IntroViewModelInputs { self }
    var outputs: IntroViewModelOutputs { self }
    
    let disposeBag = DisposeBag()
    
    var appVersion = PublishSubject<IntroModel.Appversion>()
    var error: PublishRelay<Error> = .init()
    
    func requestAppVersion() {
        ApiService().getAppVersion()
            .catchAndReturn(IntroModel.Appversion())
            .subscribe(
                onNext: { [weak self] model in
                    self?.appVersion.onNext(model)
                },
                onError: { [weak self] error in
                    
                    self?.error.accept(error)
                }
            ).disposed(by: disposeBag)
    }
    
    
}
