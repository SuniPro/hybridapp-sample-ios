import Foundation

enum IntroModel {
    
    struct Appversion: Codable {
        var device: String
        var version: String
        var force_update: Bool
        
        init() {
            device = ""
            version = ""
            force_update = true
        }
    }
}
