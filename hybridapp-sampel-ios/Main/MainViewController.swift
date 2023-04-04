//
//  MainViewController.swift
//  Belleforet
//
//  Created by Klim mac on 2022/02/22.
//

import UIKit
import WebKit
import RxCocoa
import RxSwift

enum WetherDataType: String {
    case temp = "temp"
    case wfKor = "wfKor"
    case windEN = "wdEn"
    case windKor = "wdKor"
    case windSpeed = "ws"
    case none = ""
}

class WetherInfo {
    var temp: String = ""
    var wfKor: String = ""
    var windEN: String = ""
    var windKor: String = ""
    var windSpeed: Double = 0.0
}

class MainViewController: UIViewController {
    
    @IBAction func homeBtnAction(_ sender: UIButton) {
        
        setBottomBtnNormal()
        requestUrl()
        
    }
    
    // 햄버거
    @IBAction func menuBtnAction(_ sender: UIButton) {
        
        if sender.isSelected {
            // 백
            if webView.canGoBack {
                webView.goBack()
            }
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.leftConstant.constant = 0
                self.rightConstant.constant = 0
                self.view.layoutIfNeeded()
                
                self.sideMenuViewController.requestSideMenu()
                
                self.sideMenuViewController.counterMethod()
            }, completion: { state in
                
                
            })
        }
        
    }
    
    //장바구니
    @IBAction func shoppingBasketBtnAcion(_ sender: UIButton) {
        
        self.requestUrl(APIConstants.shoppingBasket)
    }
    
    // 마이티켓
    @IBAction func ticketBtnAction(_ sender: UIButton) {
        setBottomBtnNormal()
        
        sender.isSelected = true
        setMenuButtonState(idx: sender.tag)
    }
    
    // 대기열
    @IBAction func waitingBtnAction(_ sender: UIButton) {
        
        let urlRequest = URLRequest(url: APIConstants.baseURL.appendingPathComponent(APIConstants.waitingURL))
        fullWebView.load(urlRequest)
        fullBgView.isHidden = false
    }
    
    // 전체화면 닫기
    @IBAction func fullCloseBtnAction(_ sender: UIButton) {
        fullBgView.isHidden = true
    }
    
    @IBOutlet var ticketButtons: [UIButton]!
    
    @IBOutlet weak var buyTicketImageView: UIImageView!
    @IBOutlet weak var myTicketImageView: UIImageView!
    
    @IBOutlet weak var buyTicketLabel: UILabel!
    @IBOutlet weak var myTicketLabel: UILabel!
    
    
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var leftConstant: NSLayoutConstraint!
    @IBOutlet weak var rightConstant: NSLayoutConstraint!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var titleBgView: UIView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var basketLabel: UILabel!
    @IBOutlet weak var ticketLabel: UILabel!
    
    @IBOutlet weak var bgView: UIView!
    var popupWebView: WKWebView!
    
    @IBOutlet weak var fullBgView: UIView!
    @IBOutlet weak var fullWebView: WKWebView!
    @IBOutlet weak var fullTitleLabel: UILabel!
    
    @IBOutlet weak var countBgView: UIView!
    @IBOutlet weak var countTicketView: UIView!
    
    var sideMenuViewController = SideMenuViewController()
    var parser = XMLParser()
    var isLock = false
    var wetherType: WetherDataType = .none
    
    var wetherInfo = WetherInfo()
    
    var userContentController = WKUserContentController.init()
    
    private let viewModel: MainViewModel = MainViewModel()
    var disposeBag = DisposeBag()
    
    let selectedColor = UIColor(red: 0/255.0, green: 169/255.0, blue: 183/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        initWebView()
        initFullWebView()
        
        viewModel.requestUserInfo()
        requestWetherInfo()
        
        leftConstant.constant = -self.view.frame.size.width
        rightConstant.constant = -self.view.frame.size.width
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sideMenuSegue" {
            sideMenuViewController = segue.destination as! SideMenuViewController
            
            sideMenuViewController.slideCompletion = { responseData in
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                    self.leftConstant.constant = -self.view.frame.size.width
                    self.rightConstant.constant = -self.view.frame.size.width
                    self.view.layoutIfNeeded()
                }, completion: { state in
                    
                    if responseData != "close" {
                        print("select URI : \(responseData)")
                        self.requestUrl(responseData)
                    } else {
                        print("select URI : ")
                    }
                })
                
            }
        }
        
    }
    
    func bindViewModel() {
        viewModel.outputs.userInfo
            .subscribe(
                onNext: { [weak self] responseData in
                    print(responseData)
                    self?.isLock = true
                }
            )
            .disposed(by: disposeBag)
    }
    
    func initWebView() {
        
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        webView.uiDelegate = self
        webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        let contentController = webView.configuration.userContentController
        contentController.add(self, name: "callbakHandler")
        webView.configuration.userContentController = contentController
        
        
        
        requestUrl()
    }
    
    func initFullWebView() {
        fullWebView.navigationDelegate = self
        fullWebView.uiDelegate = self
        fullWebView.scrollView.delegate = self
        fullWebView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
    }
    
    func requestUrl(_ path: String = "") {
        
        let urlRequest = URLRequest(url: URL(string: APIConstants.baseURL.absoluteString + path.trimmingCharacters(in: .whitespaces))!)
        //        let urlRequest = URLRequest(url: APIConstants.baseURL )
        
        webView.load(urlRequest)
    }
    
    func setBottomBtnNormal() {
        let normalColor = UIColor(red: 64/255.0, green: 71/255.0, blue: 69/255.0, alpha: 1.0)
        
        buyTicketLabel.textColor = normalColor
        buyTicketImageView.isHighlighted = false
        
        myTicketLabel.textColor = normalColor
        myTicketImageView.isHighlighted = false
        
        for unselectIndex in ticketButtons.indices {
            ticketButtons[unselectIndex].isSelected = false
        }
    }
    
    func requestWetherInfo() {
        let url:String = "https://www.kma.go.kr/wid/queryDFSRSS.jsp?zone=4374525000"
        let urlToSend = URL(string: url)!
        // Parse the XML
        parser = XMLParser(contentsOf: urlToSend)!
        parser.delegate = self
        let success:Bool = parser.parse()
        if success {
            print("parse success!")
            sideMenuViewController.wetherInfo = wetherInfo
            sideMenuViewController.setWetherInfo()
        } else {
            print("parse failure!")
            
        }
    }
    
    func setButtonState(urlStr: String) {
        
        setBottomBtnNormal()
        
        if urlStr == APIConstants.myTicket {
            myTicketLabel.textColor = selectedColor
            myTicketImageView.isHighlighted = true
        } else if urlStr == APIConstants.buyTicket {
            buyTicketLabel.textColor = selectedColor
            buyTicketImageView.isHighlighted = true
        }
        
    }
    
    func setMenuButtonState(idx: Int) {
        
        switch idx {
        case 0:
            buyTicketLabel.textColor = selectedColor
            buyTicketImageView.isHighlighted = true
            self.requestUrl(APIConstants.buyTicket)
            
            break
            
        case 1:
            myTicketLabel.textColor = selectedColor
            myTicketImageView.isHighlighted = true
            self.requestUrl(APIConstants.myTicket)
            
            break
        default:
            break
        }
    }
    
    func showToast(message : String, font: UIFont = UIFont.systemFont(ofSize: 14.0)) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 3.0, delay: 0, options: .curveEaseIn, animations: {
            toastLabel.alpha = 0.0
            
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
            
        })
        
    }
    
    //    Receive json method (json을 활용한 http 통신 함수입니다.)
    //    Http request response json protocol (해당 함수는 http 통신을 함께 구현한 형태이며, 분석하여 새로운 클래스 혹은 로직을 만드셔도 됩니다.)
    func counterMethod() {
        
        self.ticketLabel.isHidden = true
        self.countTicketView.isHidden = true
        
        // json struct key:value match(json의 값을 swift 형태로 받기 위한 struct입니다. json을 swift로 받기 위해선 Codable을 반드시 선언해야합니다.)
        struct CountValue: Codable {
            let myCondoCnt: Int
            let myGolfCnt: Int
            let myTicketCnt: Int
        }
        
        //APIConstants count url Injection (http 통신을 위한 url을 주입하기 위해 apiconstants 클래스에 menucounturl 함수를 생성, 주입받습니다.)
        if let url = URL(string: "\(APIConstants.menuCountUrl)") {
            var request = URLRequest.init(url: url)
            
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                guard let data = data else { return }
                
                //json decode logic (json 변환을 위한 로직입니다.)
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(CountValue.self, from: data) {
                    let ticketCnt:Int = json.myTicketCnt
                    
                    //Thread custom logic (쓰레스 활동 시점을 위한 함수입니다. 해당 로직을 수행하지 않았을때 쓰레드 오류로 앱에 크러시가 발생합니다.)
                    OperationQueue.main.addOperation {
                        //ticketlabel data Injection
                        
                        if ticketCnt != 0 {
                            self.ticketLabel.isHidden = false
                            self.countTicketView.isHidden = false
                            self.ticketLabel.text = "\(ticketCnt)"
                        }
                    }
                }
            }.resume()
        }
    }
}

extension MainViewController: WKNavigationDelegate, WKUIDelegate {
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = webView.url {
            webView.getCookies(for: url.host) { data in
                print("=========================================")
                print("\(url.absoluteString)")
                //                print(data)
            }
        }
        
        //        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { (cookies) in
        //            for cookie in cookies{
        //                print("@@@ cookie ==> \(cookie.name) : \(cookie.value)")
        //                if cookie.name == "JSESSIONID" {
        //                    UserDefaults.standard.set(cookie.value, forKey:"JSESSIONID")
        //                    print("@@@ PHPSESSID 저장하기: \(cookie.value)")
        //
        //                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
        //                        self.fullWebView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie, completionHandler: nil)
        //                    }
        //
        //                }
        //
        //            }
        //
        //        }
        //
        
        
        //        let storage = WKWebsiteDataStore.default().httpCookieStore
        //
        //        storage.getAllCookies { cookies in
        //            print(cookies)
        //        }
        
        
        
        guard let requestURL = navigationAction.request.url else { return }
        let urlStr = requestURL.absoluteString
        //        print(requestURL)
        print("decidePolicyFor url: \(urlStr)")
        
        if urlStr.contains("itunes.apple.com") ||
            urlStr.contains("www.instagram.com") ||
            urlStr.contains("blog.naver.com") {
            UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
            
            decisionHandler(WKNavigationActionPolicy.cancel)
            return
        }
        
        //        ticketvalue
        
        
        
        let components = URLComponents(string: urlStr)
        let items = components?.queryItems ?? []
        
        
        
        
        
        if webView == self.webView {
            titleBgView.isHidden = false
            titleLabel.text = ""
            
            menuButton.isSelected = false
            titleLabel.text = ""
            titleBgView.isHidden = false
            
            if urlStr.hasPrefix("niceipin2") {
                UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
                
                decisionHandler(WKNavigationActionPolicy.cancel)
                return
            } else if urlStr.hasPrefix("belleforetapp://login") {
                
                let userInfo = UserInfoData.shared
                
                for item in items {
                    
                    if let value = item.value {
                        if item.name == "name" {
                            userInfo.userName = value
                        } else if item.name == "id" {
                            userInfo.userId = value
                        } else if item.name == "membershipLevel" {
                            userInfo.userMembershipLV = value
                        } else if item.name == "resno" {
                            userInfo.resno = value
                        }
                    }
                    
                }
                
                userInfo.isLogin = true
                
                if let url = webView.url {
                    fullWebView.load(URLRequest(url: url))
                }
                
                decisionHandler(WKNavigationActionPolicy.cancel)
                return
                
            } else if urlStr.hasPrefix("belleforetapp://logout") {
                let userInfo = UserInfoData.shared
                userInfo.userName = ""
                userInfo.userId = ""
                userInfo.userMembershipLV = ""
                userInfo.resno = ""
                userInfo.isLogin = false
                
                decisionHandler(WKNavigationActionPolicy.cancel)
                return
            } else if urlStr.hasPrefix("belleforetapp://?") {
                
                for item in items {
                    
                    // Ticket Counting logic
                    counterMethod()
                    
                    if let value = item.value {
                        if item.name == "menu" {
                            if value == "ham" {
                                self.menuButton.isSelected = false
                            } else {
                                self.menuButton.isSelected = true
                            }
                            
                        } else if item.name == "title" {
                            if value == "logo" {
                                titleLabel.text = ""
                                titleBgView.isHidden = false
                            } else {
                                titleLabel.text = value
                                titleBgView.isHidden = true
                            }
                            
                        } else if item.name == "basket" {
                            if value != "0" && !value.isEmpty {
                                self.basketLabel.isHidden = false
                                self.countBgView.isHidden = false
                                basketLabel.text = value
                            } else {
                                self.basketLabel.isHidden = true
                                self.countBgView.isHidden = true
                                
                            }
                        }
                        
                    }
                    
                }
                
                decisionHandler(WKNavigationActionPolicy.cancel)
                return
            } else if urlStr.hasPrefix(APIConstants.baseURL.absoluteString) {
                
                for item in items {
                    if let value = item.value {
                        if item.name == "is_full" {
                            if value == "y" {
                                
                                fullWebView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                                    for cookie in cookies {
                                        print(cookie)
                                    }
                                }
                                
                                
                                fullWebView.load(URLRequest(url: URL(string: urlStr)!))
                                fullBgView.isHidden = false
                                decisionHandler(WKNavigationActionPolicy.cancel)
                                return
                            }
                        }
                    }
                }
                
                setButtonState(urlStr: requestURL.path)
            }
            
        } else if webView == fullWebView {
            if urlStr.hasPrefix("https://itunes.apple.com") || urlStr.hasPrefix("http://itunes.apple.com"){
                UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
                decisionHandler(WKNavigationActionPolicy.cancel)
                return
            } else {
                if !urlStr.hasPrefix("http") || !urlStr.hasPrefix("https") {
                    if urlStr.hasPrefix("belleforetapp://?") {
                        
                        let isFullClose = items.contains { $0.name == "type" && $0.value == "fullScreenClose"}
                        
                        if isFullClose {
                            for item in items {
                                if let value = item.value {
                                    if item.name == "url" {
                                        
                                        if !value.isEmpty {
                                            requestUrl(urlStr)
                                        }
                                        
                                    }
                                }
                            }
                            
                            fullBgView.isHidden = true
                        } else {
                            for item in items {
                                if let value = item.value {
                                    if item.name == "title" {
                                        fullTitleLabel.text = value
                                    }
                                }
                            }
                        }
                        
                        
                        decisionHandler(WKNavigationActionPolicy.cancel)
                        return
                    } else {
                        if UIApplication.shared.canOpenURL(requestURL) {
                            UIApplication.shared.open(requestURL)
                            decisionHandler(WKNavigationActionPolicy.cancel)
                            return
                        }
                    }
                }
            }
        }
        
        decisionHandler(WKNavigationActionPolicy.allow)
        
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo) async {
        print("")
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo) async -> Bool {
        print("")
        return true
    }
    
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        //Window.open으로 호출할경우
        popupWebView = WKWebView(frame: self.bgView.frame, configuration: configuration)
        popupWebView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        popupWebView?.navigationDelegate = self
        popupWebView?.uiDelegate = self
        
        self.view.addSubview(popupWebView!)
        return popupWebView!
        
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        webView.removeFromSuperview()
        popupWebView = nil
    }
    
    
    //    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    //        let loadedSessid = UserDefaults.standard.value(forKey: "JSESSIONID") as! String?
    //        if let temp = loadedSessid{ print("@@@ PHPSESSID 불러오기~~: \(temp)") // 이게 정상동작하는듯.. 자동로그인 됨
    //            let cookieString : String = "document.cookie='JSESSIONID=\(temp);path=/;domain=\(APIConstants.baseURL.absoluteString);'"
    //            webView.evaluateJavaScript(cookieString)
    //
    //        }
    //
    //    }
    
}



extension MainViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if(message.name == "callbakHandler"){
            
            if let body = message.body as? String, body == "getVersion" {
                let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
                
                webView.evaluateJavaScript("setVersion(\"\(appVersion)\");") { result, error in
                    if let anError = error {
                        print("* evaluateJavaScript infoUpdate Error \(anError.localizedDescription)")
                    }
                    print("* evaluateJavaScript infoUpdate Result \(result ?? "")")
                }
            }
        }
        
        print("")
    }
}

extension MainViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = true
    }
    
}

extension MainViewController: XMLParserDelegate {
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        if elementName == "data" {
            if attributeDict["seq"] == "0" {
                isLock = true
            }
        } else if elementName == WetherDataType.temp.rawValue {
            wetherType = .temp
        } else if elementName == WetherDataType.wfKor.rawValue {
            wetherType = .wfKor
        } else if elementName == WetherDataType.windEN.rawValue {
            wetherType = .windEN
        } else if elementName == WetherDataType.windKor.rawValue {
            wetherType = .windKor
        } else if elementName == WetherDataType.windSpeed.rawValue {
            wetherType = .windSpeed
        } else {
            wetherType = .none
        }
        
        
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "data" {
            isLock = false
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        let trimString = string.trimmingCharacters(in: .whitespaces)
        
        if isLock && trimString.count > 0 && trimString != "\n"{
            switch wetherType {
            case .temp:
                wetherInfo.temp = string
                break
            case .wfKor:
                wetherInfo.wfKor = string
                break
            case .windEN:
                wetherInfo.windEN = string
                break
            case .windKor:
                wetherInfo.windKor = string
                break
            case .windSpeed:
                wetherInfo.windSpeed = Double(string) ?? 0
                break
            default:
                break
            }
            
        }
        
    }
    
}


extension WKWebView {
    
    private var httpCookieStore: WKHTTPCookieStore  { return WKWebsiteDataStore.default().httpCookieStore }
    
    func getCookies(for domain: String? = nil, completion: @escaping ([String : Any])->())  {
        var cookieDict = [String : AnyObject]()
        httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                if let domain = domain {
                    if cookie.domain.contains(domain) {
                        cookieDict[cookie.name] = cookie.properties as AnyObject?
                    }
                } else {
                    cookieDict[cookie.name] = cookie.properties as AnyObject?
                }
            }
            completion(cookieDict)
        }
    }
}

extension HTTPCookieStorage {
    
    static func clear(){
        
        if let cookies = HTTPCookieStorage.shared.cookies {
            
            for cookie in cookies {
                
                HTTPCookieStorage.shared.deleteCookie(cookie)
                
            }
            
        }
        
    }
    
    static func save(){
        
        var cookies = [Any]()
        
        if let newCookies = HTTPCookieStorage.shared.cookies {
            
            for newCookie in newCookies {
                
                var cookie = [HTTPCookiePropertyKey : Any]()
                
                cookie[.name] = newCookie.name
                
                cookie[.value] = newCookie.value
                
                cookie[.domain] = newCookie.domain
                
                cookie[.path] = newCookie.path
                
                cookie[.version] = newCookie.version
                
                if let date = newCookie.expiresDate {
                    
                    cookie[.expires] = date
                    
                }
                
                cookies.append(cookie)
                
            }
            
            UserDefaults.standard.setValue(cookies, forKey: "cookies")
            
            UserDefaults.standard.synchronize()
            
        }
        
        
        
    }
    
    static func restore(){
        
        if let cookies = UserDefaults.standard.value(forKey: "cookies") as? [[HTTPCookiePropertyKey : Any]] {
            
            for cookie in cookies {
                
                if let oldCookie = HTTPCookie(properties: cookie) {
                    
                    //                    print("cookie loaded:\(oldCookie)")
                    
                    HTTPCookieStorage.shared.setCookie(oldCookie)
                    
                }
                
            }
            
        }
        
    }
    
}
