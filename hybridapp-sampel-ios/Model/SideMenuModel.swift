import Foundation

enum SideMenuModel {
    
    struct SideMenuList: Codable {
        var menuList: [SideMenu]?
        
        init() {
            menuList = nil
        }
    }
    
    struct SideMenu: Codable {
        var menuCd: String
        var menuNm: String
        var menuUrl: String?
        var menuLvl: String
        var menuParntsCd: String?
        
        init() {
            menuCd = ""
            menuNm = ""
            menuUrl = ""
            menuLvl = ""
            menuParntsCd = ""
        }
    }
}
