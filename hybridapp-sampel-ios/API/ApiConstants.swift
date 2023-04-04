import Foundation

struct APIConstants {
     // MARK: - Start Endpoint
     static var baseURL: URL {
         #if DEBUG_ip
         return URL(string: "http://localhost:8080")!
         #elseif DEBUG_do
         return URL(string: "https://ser.bsgrcc.com")!
         #else
         return URL(string: "https://mser.blackstonebelleforet.com")!
         #endif
     }
    
    static var loginURL: String {
        return "/login.do"
    }
    
    static var waitingURL: String {
        return "/waiting.do"
    }

    static var myPage: String {
        return "/user/mypage/mypage.do"
    }
    
    static var myTicket: String {
        return "/user/myTicket/myTicket.do"
    }
    
    static var shoppingBasket: String {
        return "/user/mypage/wishList.do"
    }
    
    static var golfReservation: String {
        return "/user/golf/golfResList.do"
    }
    
    static var condoReservation: String {
        return "/user/condo/condoResList.do"
    }
    
    static var ticketReservation: String {
        return "/user/mypage/payMentHistory.do"
    }
    
    static var buyTicket: String {
        return "/ticket.do"
    }
    
    static var mberSecsn: String {
        return "user/mypage/mberSecsn.do"
    }
    
    static var menuCountUrl: String {
        let userInfo = UserInfoData.shared
        return "\(APIConstants.baseURL)/api/user/\(userInfo.userId)/\(userInfo.resno)/menuCount.ajax"
    }
 }

