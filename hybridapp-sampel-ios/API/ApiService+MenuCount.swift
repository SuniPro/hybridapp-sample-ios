import Foundation
import RxSwift

extension ApiService {
    
    func getMenuCount() -> Observable<MenuCountModel.MenuCount> {
        return sendRequest(endpoint: MenuCount.getMenuCount)
    }
    
}
