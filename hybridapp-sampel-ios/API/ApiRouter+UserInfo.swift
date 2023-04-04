import Foundation
import Alamofire


enum UserInfo {
    case getUserInfo
}

extension UserInfo: ApiRouter {

    var method: HTTPMethod {
        switch self {
        case .getUserInfo:
            return .get
        }
    }

    var path: String {
        switch self {
        case .getUserInfo:
            return "/user/mypage/myInfoData.ajax"
        }
    }

    var parameters: Parameters? {
        switch self {
        case .getUserInfo:
            return nil
        }

    }

}
