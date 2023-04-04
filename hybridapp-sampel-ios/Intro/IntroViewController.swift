import UIKit
import RxCocoa
import RxSwift

class IntroViewController: UIViewController {

    private let viewModel: IntroViewModel = IntroViewModel()
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
        requestAppVersion()
        
//        var aa = IntroModel.Appversion.init()
//        aa.version = "1.0.4"
//        aa.force_update = true
//        checkVersion(versionInfo: aa)
    }

    func bindViewModel() {
        viewModel.outputs.appVersion
            .subscribe(
                onNext: { [weak self] responseData in
                    print(responseData)
//                    let state = self?.checkVersionState(serverVersion: responseData.version)
//                    self?.showVersionState(state: state ?? .APP_VERSION_SAME)
                    
                    self?.checkVersion(versionInfo: responseData)
                },
                onError: { errorData in
                    print(errorData)
                    
                }
            )
            .disposed(by: disposeBag)
        
        
        viewModel.outputs.error
            .subscribe(
                onNext: { [weak self] responseData in
                    self?.moveMain()
                }
            )
            .disposed(by: disposeBag)
    }
    
    func requestAppVersion() {
        viewModel.inputs.requestAppVersion()
    }
    
    func checkVersion(versionInfo: IntroModel.Appversion) {
        
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        
        let currentServerVersion = Int(versionInfo.version.components(separatedBy: ["."]).joined()) ?? 0
        let currentAppVersion = Int(appVersion.components(separatedBy: ["."]).joined()) ?? 0
        
        if currentServerVersion != 0 && currentServerVersion > currentAppVersion {
            
            if versionInfo.force_update {
                showVersionPopup(state: .APP_VERSION_LOW_MAJOR)
            } else {
                showVersionPopup(state: .APP_VERSION_LOW_MINOR)
            }
        } else {
            moveMain()
        }
        
    }
    
    func showVersionPopup(state: VersionCheckType) {
        
        switch state {
        case .APP_VERSION_LOW_MAJOR:
            self.show(title: "업데이트 알림", message: "더 좋아진 벨포레 앱을 사용하시기\n위해서는 업데이트가 필요합니다.", buttonNames: "업데이트") {_ in
                //앱스토어 이동
                self.openAppStore()
            }
            break
            
        case .APP_VERSION_LOW_MINOR:
            self.show(title: "업데이트 알림", message: "앱의 최신버전이 등록되었습니다.\n최신버전으로\n업데이트 하시겠습니까?", buttonNames: "나중에", "업데이트") { btnState in
                switch btnState {
                case .LEFT_ACTION:
                    //홈 이동
                    self.moveMain()
                    break
                    
                case .RIGHT_ACTION:
                    //앱스토어 이동
                    self.openAppStore()
                    break
                    
                default:
                    break
                }
            }
            break
            
        case .APP_VERSION_LOW_PATCH, .APP_VERSION_SAME:
            // 홈 이동
            self.moveMain()
            break
            
        default:
            break
        }
        
    }
    func openAppStore() {
        let url = "itms-apps://itunes.apple.com/app/id1617767124";
        if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func moveMain() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "MainViewController")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
