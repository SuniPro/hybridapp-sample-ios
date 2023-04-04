import Foundation
import Alamofire


enum Intro {
    case getAppVersion
}

extension Intro: ApiRouter {

    var method: HTTPMethod {
        switch self {
        case .getAppVersion:
            return .get
        }
    }

    var path: String {
        switch self {
        case .getAppVersion:
            return "/api/update_check/ios.ajax"
        }
    }

    var parameters: Parameters? {
        switch self {
        case .getAppVersion:
            return nil
        }

    }

}
