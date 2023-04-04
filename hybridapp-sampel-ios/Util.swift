import Foundation

public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    
    #if DEBUG || DEBUG_ip || DEBUG_do
    
    #if true
    let output = items.map { "\($0)" }.joined(separator: separator)
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale.current
    dateFormatter.dateFormat = "yyyy.MM.dd KK:mm:ss.SSS"
    let timeStr = dateFormatter.string(from: Date())
    let fullMessage : String = "\(timeStr): " +  output
    
    #if true
    logMessage(fullMessage)
    #endif
    
    #else
    let fullMessage = items.map { "\($0)" }.joined(separator: separator)
    #endif
    
    Swift.print(fullMessage, terminator: terminator)
    #endif
}

public func logMessage(_ log : String, terminator: String = "\n") {
    
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    if let documentsPath = paths.first {
        let logPath = documentsPath.appending("/" + "console.log")
        let fm = FileManager.default
        if fm.fileExists(atPath: logPath) {
            do {
                let att = try fm.attributesOfItem(atPath: logPath)
                let data = att[FileAttributeKey.modificationDate] as! Date
                let interval = Swift.abs(data.timeIntervalSinceNow)
                if 5 * 3600 * 24 < interval {
                    try fm.removeItem(atPath: logPath)
                }
            } catch let error as NSError {
                print("\(#function) error: \(error)")
            }
        }
        
        do {
            var fh = FileHandle(forWritingAtPath: logPath)
            if fh == nil {
                fm.createFile(atPath: logPath, contents: nil, attributes: nil)
                fh = FileHandle(forWritingAtPath: logPath)
            }
            
            fh?.seekToEndOfFile()
            
            if let data = (log + terminator).data(using: .utf8) {
                fh?.write(data)
            }
            
            try fh?.close()
        } catch let error as NSError {
            print("\(#function) error: \(error)")
        }
    }
}

enum VersionCheckType {
    case APP_VERSION_SAME
    case APP_VERSION_LOW_MAJOR
    case APP_VERSION_LOW_MINOR
    case APP_VERSION_LOW_PATCH
}
