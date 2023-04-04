import Foundation
import Alamofire


enum SideMenu {
    case getSideMenu
}

extension SideMenu: ApiRouter {

    var method: HTTPMethod {
        switch self {
        case .getSideMenu:
            return .get
        }
    }

    var path: String {
        switch self {
        case .getSideMenu:
            return "/user/menu/menuList.ajax"
        }
    }

    var parameters: Parameters? {
        switch self {
        case .getSideMenu:
            return nil
        }

    }

}
