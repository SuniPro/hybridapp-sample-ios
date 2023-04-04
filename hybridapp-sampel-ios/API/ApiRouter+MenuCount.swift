import Foundation
import Alamofire


enum MenuCount {
    case getMenuCount
}

//let userInfo = UserInfoData.shared
//var userId = userInfo.userId
//var resno = userInfo.resno

var userId = "dltkdgns0726"
var resno = 9122110700156

extension MenuCount: ApiRouter {
    
    var method: HTTPMethod {
        switch self {
        case .getMenuCount:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .getMenuCount:
            return "/api/user/test_19_0/2019072589801/menuCount.ajax"
//            return "/api/user/\(userId)/\(resno)/menuCount.ajax"
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .getMenuCount:
            return nil
        }
        
    }
    
}
