import Foundation

class UserInfoData {
    static let shared = UserInfoData()
    
    var userName = ""
    var userId = ""
    var userMembershipLV = ""
    var isLogin = false
    var resno = ""
    
    private init() {}
}
