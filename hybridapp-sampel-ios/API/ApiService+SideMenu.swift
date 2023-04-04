import Foundation
import RxSwift

extension ApiService {
    
    func getSideMenu() -> Observable<SideMenuModel.SideMenuList> {
        return sendRequest(endpoint: SideMenu.getSideMenu)
    }
    
}
