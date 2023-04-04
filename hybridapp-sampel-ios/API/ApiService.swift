import Alamofire
import RxSwift

class ApiService {
    
    let session = Alamofire.Session.default
    
//    init() {
//        session.session.configuration.timeoutIntervalForRequest = 3
//    }
    
    
//    var session: Session {
//        get {
//            let aa = Alamofire.Session.default
//            aa.session.configuration.timeoutIntervalForRequest = 3
//            return aa
//        }
//    }
    
    func sendRequest<T: Codable>(endpoint: URLRequestConvertible) -> Observable<T> {
        return Observable<T>.create { observer in
            let request = self.session.request(endpoint)
                .validate()
                .responseJSON { response in
                    print(response)
                    switch response.result {
                    case .success:
                        do {
                            let model = try JSONDecoder().decode(T.self, from: response.data!)
                            observer.onNext(model)
                        
                        } catch {
//                            observer.onError(response.error!)
                        }
                    case .failure:
                        observer.onError(response.error!)
                        
                    }
            }
            return Disposables.create {
                request.cancel()
            }
        }.observe(on: MainScheduler.instance)
    }

}
