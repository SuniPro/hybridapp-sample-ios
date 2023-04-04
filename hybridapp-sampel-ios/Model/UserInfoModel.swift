import Foundation

enum UserInfoMoel {
    
    struct UserInfo: Codable {
        var birthDay: String
        var email: String
        var seUserNm: String?
        
        init() {
            birthDay = ""
            email = ""
            seUserNm = ""

        }
    }
}
