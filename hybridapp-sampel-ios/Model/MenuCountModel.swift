import Foundation

enum MenuCountModel {
    
    struct MenuCount: Codable {
        var myTicketCnt: Int
        var myCondoCnt: Int
        var myGolfCnt: Int
        
        init() {
            myTicketCnt = 0
            myCondoCnt = 0
            myGolfCnt = 0
        }
    }
}
