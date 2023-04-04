import Foundation
import RxSwift

extension ApiService {
    
    func getAppVersion() -> Observable<IntroModel.Appversion> {
        return sendRequest(endpoint: Intro.getAppVersion)
    }
    
}
