
import Foundation
import Alamofire

protocol ApiRouter: URLRequestConvertible {
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: Parameters? { get }
}

extension ApiRouter {
    
    // MARK: URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        let url = APIConstants.baseURL.appendingPathComponent(path)

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue

        // Common Headers
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        // Encode body
        urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)

        print("[\(path)] requestData: \(parameters ?? [:])")
        
        return urlRequest
    }
    
}

