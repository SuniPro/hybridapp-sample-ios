import Foundation
import RxSwift

extension ApiService {
    
    func getUserInfo() -> Observable<UserInfoMoel.UserInfo> {
        return sendRequest(endpoint: UserInfo.getUserInfo)
    }
    
}
