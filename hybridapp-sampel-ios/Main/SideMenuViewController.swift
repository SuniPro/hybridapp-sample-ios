//
//  SideMenuViewController.swift
//  Belleforet
//
//  Created by Klim mac on 2022/02/22.
//

import UIKit
import RxCocoa
import RxSwift
import SwiftUI

struct ExpandableNames {
    
    var isExpanded: Bool
    let titleMenu: SideMenuModel.SideMenu
    let subMenu: [SideMenuModel.SideMenu]
    
}

class SideMenuViewController: UIViewController {

    @IBAction func closeBtnAction(_ sender: Any) {
        guard let completion = self.slideCompletion else { return }
        completion("close")
    }
    
    @IBAction func loginBtnAction(_ sender: UIButton) {
        guard let completion = self.slideCompletion else { return }

        if userInfo.isLogin {
            completion(APIConstants.myPage)
        } else {
            completion(APIConstants.loginURL)
        }
        
    }
    
    @IBAction func ticketBtnAction(_ sender: UIButton) {
        guard let completion = self.slideCompletion else { return }
        
        switch sender.tag {
        case 0:
            // 골프예약
            completion(APIConstants.golfReservation)
            break
        case 1:
            // 콘도예약
            completion(APIConstants.condoReservation)
            break
        case 2:
            // 마이티켓
            completion(APIConstants.ticketReservation)
            
        default:
            break
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sideTableView: UITableView!
    
    @IBOutlet weak var loginInfoLabel: UILabel! 
    @IBOutlet weak var loginGradeLabel: UILabel!
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    
    @IBOutlet weak var wetherImageView: UIImageView!
    @IBOutlet weak var windImageView: UIImageView!
    
    @IBOutlet weak var countGolfView: UIView!
    @IBOutlet weak var golfLabel: UILabel!
    
    @IBOutlet weak var countCondoView: UIView!
    @IBOutlet weak var condoLabel: UILabel!
    
    @IBOutlet weak var mypageLabel: UILabel!
    @IBOutlet weak var mypageLabelLeftConst: NSLayoutConstraint!
    
    var slideCompletion : ((String) -> Void)?
    private let viewModel: SideMenuViewModel = SideMenuViewModel()
    var disposeBag = DisposeBag()
    
    var sideMenuArray = [ExpandableNames]()
    var arrowImageArr = [UIImageView]()
    var wetherInfo = WetherInfo()
    
    let userInfo = UserInfoData.shared
    
    var selectedMemus: [SideMenuModel.SideMenu] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
        
        if #available(iOS 15, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    func requestSideMenu() {
        viewModel.requestSideMenu()
        setUserinfo()
    }
    
    func setUserinfo() {
        
        if userInfo.isLogin {
            setUserGrade()
            loginGradeLabel.isHidden = false
            mypageLabel.isHidden = false
            mypageLabel.text = "마이페이지"
            mypageLabelLeftConst.constant = 30
            
            loginInfoLabel.attributedText = NSAttributedString(string: "\(userInfo.userName)님",
                                                               attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])

        } else {
            loginGradeLabel.isHidden = true
            mypageLabel.isHidden = true
            mypageLabel.text = ""
            mypageLabelLeftConst.constant = 0
            
            loginInfoLabel.attributedText = NSAttributedString(string: "로그인 해주세요.",
                                                               attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
        }
    }
    
    func setUserGrade() {
        
        let redColor = UIColor(red: 173/255.0, green: 20/255.0, blue: 16/255.0, alpha: 1.0)
        let greenColor = UIColor(red: 0/255.0, green: 104/255.0, blue: 85/255.0, alpha: 1.0)
        let normalColor = UIColor(red: 0/255.0, green: 169/255.0, blue: 183/255.0, alpha: 1.0)
        
        let levelStr = userInfo.userMembershipLV
        
        var currentColor = normalColor
        if levelStr == "콘도레드회원" {
            currentColor = redColor
        } else if levelStr == "콘도그린회원" {
            currentColor = greenColor
        }
        
        let fullText = "회원님의 현재 등급은 \(levelStr)입니다."
        let attribtuedString = NSMutableAttributedString(string: fullText)
        let range = (fullText as NSString).range(of: levelStr)
        attribtuedString.addAttributes([.font: UIFont.boldSystemFont(ofSize: 14),
                                        .foregroundColor: currentColor],
                                       range: range)
        loginGradeLabel.attributedText = attribtuedString
    }
    
    @objc func handleExpandClose(button: UIButton) {
        let section = button.tag
        
        // we'll try to close the section first by deleting the rows
        
        let subMenu = sideMenuArray[section].subMenu
        
        if subMenu.count > 0 {
            var indexPaths = [IndexPath]()
            for row in subMenu.indices {
                let indexPath = IndexPath(row: row, section: section)
                indexPaths.append(indexPath)
            }

            let isExpanded = sideMenuArray[section].isExpanded
            sideMenuArray[section].isExpanded = !isExpanded
            
            let arrowImgView = arrowImageArr[section]

            if isExpanded {
                tableView.deleteRows(at: indexPaths, with: .fade)
                arrowImgView.image = UIImage(named: "iconArrow")
            } else {
                tableView.insertRows(at: indexPaths, with: .fade)
                arrowImgView.image = UIImage(named: "iconArrow2")
            }
        } else {
            let menuTitle = sideMenuArray[section]
            
            guard let completion = self.slideCompletion else { return }
            if let selectedMenuUrl = menuTitle.titleMenu.menuUrl {
                completion(selectedMenuUrl)
            }
        }
        
    }
    
    @objc func moveMenuTitle(button: UIButton) {
        let section = button.tag
        
        let titleMenu = sideMenuArray[section]
        
        if let menuUrl = titleMenu.titleMenu.menuUrl {
            print(menuUrl)
        } else {
            print("aaaaa")
        }
    }
    
    func setWetherInfo() {
        
        tempLabel.text = wetherInfo.temp + " °C"
        windSpeedLabel.text = ("\(String(format: "%.1f", wetherInfo.windSpeed)) m/s")
        windLabel.text = wetherInfo.windKor
        
        var wfIconName = "Clearly"
        if wetherInfo.wfKor == "맑음" {
            wfIconName = "Clearly"
        } else if wetherInfo.wfKor == "구름 조금" {
            wfIconName = "Partly Cloud"
        } else if wetherInfo.wfKor == "구름 많음" {
            wfIconName = "Mostly Cloud"
        } else if wetherInfo.wfKor == "흐림" {
            wfIconName = "Cloud"
        } else if wetherInfo.wfKor == "비" {
            wfIconName = "Rainy"
        } else if wetherInfo.wfKor == "눈" {
            wfIconName = "Snow_night"
        } else if wetherInfo.wfKor == "눈/비" {
            wfIconName = "SnowRain"
        }
        
        wetherImageView.image = UIImage(named: wfIconName)
    }
}

extension SideMenuViewController {
    
    func bindViewModel() {
        
        viewModel.outputs.sideMenuList
            .subscribe(
                onNext: { [weak self] responseData in
                    guard let menuList = responseData.menuList else { return }
                    self?.setSideMenu(menuList: menuList)
                }
            )
            .disposed(by: disposeBag)

    }
    
}

extension SideMenuViewController {
    
    func setSideMenu(menuList: [SideMenuModel.SideMenu]) {
        var titleMenu = SideMenuModel.SideMenu()
        var subMenu = [SideMenuModel.SideMenu]()
        sideMenuArray.removeAll()
        
        for item in menuList {
            
            if titleMenu.menuCd != "" && item.menuCd != titleMenu.menuCd && item.menuLvl == "1" {
                sideMenuArray.append(ExpandableNames(isExpanded: false, titleMenu: titleMenu, subMenu: subMenu))
                titleMenu = SideMenuModel.SideMenu()
                subMenu.removeAll()
            }

            if item.menuLvl == "1" {
                titleMenu = item
            } else if item.menuLvl == "2", item.menuCd.contains(titleMenu.menuCd) {
                subMenu.append(item)
            }
            
            if item.menuCd == menuList.last?.menuCd {
                sideMenuArray.append(ExpandableNames(isExpanded: false, titleMenu: titleMenu, subMenu: subMenu))
            }
            
        }
        sideTableView.reloadData()
        selectTopMemu(tag: 0)

    }
}

extension SideMenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count = 0
        
        if tableView == self.tableView {
            count = selectedMemus.count
        } else if tableView == sideTableView {
            count = sideMenuArray.count
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuCell", for: indexPath) as! SideMenuCell
            let item = selectedMemus[indexPath.row]
    
            cell.titleLabel.text = item.menuNm
    
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopMenuCell", for: indexPath) as! TopMenuCell
            let item = sideMenuArray[indexPath.row]
    
            cell.topMenuButton.tag = indexPath.row
            cell.topMenuButton.setTitle(item.titleMenu.menuNm, for: .normal)
            cell.topMenuButton.addTarget(self, action: #selector(topMenuClickAction(_:)), for: .touchUpInside)
    
            cell.topMenuButton.backgroundColor = .rgba(red: 245, green: 245, blue: 245, alpha: 1)
            cell.topMenuButton.setTitleColor(.rgba(red: 119, green: 119, blue: 119, alpha: 1), for: .normal)
            cell.topMenuButton.titleLabel?.font = .systemFont(ofSize: 16)
            if item.isExpanded {
                cell.topMenuButton.backgroundColor = .white
                cell.topMenuButton.setTitleColor(.rgba(red: 0, green: 169, blue: 183, alpha: 1), for: .normal)
                cell.topMenuButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = selectedMemus[indexPath.row]

        guard let completion = self.slideCompletion else { return }
        guard let menuUrl = item.menuUrl else {
            completion("close")
            return
        }
        completion(menuUrl)
    }
    
    @objc func topMenuClickAction(_ sender: UIButton) {
        
        selectTopMemu(tag: sender.tag)
        
    }
    
    func selectTopMemu(tag: Int) {
        
        for idx in sideMenuArray.indices {
            sideMenuArray[idx].isExpanded = false
        }
        
        let isExpanded = sideMenuArray[tag].isExpanded
        sideMenuArray[tag].isExpanded = !isExpanded
        sideTableView.reloadData()
        
        let item = sideMenuArray[tag]
        selectedMemus = item.subMenu
        tableView.reloadData()
        
        if selectedMemus.count == 0 {
            let menuTitle = sideMenuArray[tag]
            
            guard let completion = self.slideCompletion else { return }
            if let selectedMenuUrl = menuTitle.titleMenu.menuUrl {
                completion(selectedMenuUrl)
            }
        }

    }
    
    //    Receive json method (json을 활용한 http 통신 함수입니다.)
    //        Http request response json protocol (해당 함수는 http 통신을 함께 구현한 형태이며, 분석하여 새로운 클래스 혹은 로직을 만드셔도 됩니다.)
    func counterMethod() {
    // json struct key:value match(json의 값을 swift 형태로 받기 위한 struct입니다. json을 swift로 받기 위해선 Codable을 반드시 선언해야합니다.)
        golfLabel.isHidden = true
        condoLabel.isHidden = true
        countGolfView.isHidden = true
        countCondoView.isHidden = true
        
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
                    let golfCnt:Int = json.myGolfCnt
                    let condoCnt:Int = json.myCondoCnt
                    
                    //Thread custom logic (쓰레스 활동 시점을 위한 함수입니다. 해당 로직을 수행하지 않았을때 쓰레드 오류로 앱에 크러시가 발생합니다.)
                    OperationQueue.main.addOperation {
                        
                        //golfLabel data Injection
                        if golfCnt != 0 {
                            self.golfLabel.isHidden = false
                            self.countGolfView.isHidden = false
                            self.golfLabel.text = "\(golfCnt)"
                        }
                        if condoCnt != 0 {
                            self.condoLabel.isHidden = false
                            self.countCondoView.isHidden = false
                            self.condoLabel.text = "\(condoCnt)"
                        }
                    }
                }
            }.resume()
        }
}
    
}



//
//extension SideMenuViewController: UITableViewDelegate, UITableViewDataSource {
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//        let backgroundView = UIView()
//
//        let button = UIButton(type: .custom)
//        button.backgroundColor = .clear
//        button.addTarget(self, action: #selector(handleExpandClose), for: .touchUpInside)
//        button.tag = section
////        button.backgroundColor = .red
//
//        let titleButton = UIButton (type: .custom)
//        titleButton.backgroundColor = .clear
//        titleButton.addTarget(self, action: #selector(moveMenuTitle), for: .touchUpInside)
//        titleButton.tag = section
////        titleButton.backgroundColor = .blue
//
//        let titleLabel = UILabel()
//        titleLabel.text = sideMenuArray[section].titleMenu.menuNm
//        titleLabel.font = .boldSystemFont(ofSize: 14)
//
//        let subMenu = sideMenuArray[section].subMenu
//        let arrowImageView = UIImageView.init(image: subMenu.count > 0 ? UIImage(named: "iconArrow") : nil)
//
//        backgroundView.addSubview(arrowImageView)
//        backgroundView.addSubview(titleLabel)
//        backgroundView.addSubview(button)
////        backgroundView.addSubview(titleButton)
//
//        arrowImageArr.append(arrowImageView)
//
//        backgroundView.addConstraintsWithFormat("H:[v0(24)]-20-|", views: arrowImageView)
//        backgroundView.addConstraintsWithFormat("V:[v0(24)]", views: arrowImageView)
//
//        backgroundView.addConstraintsWithFormat("H:|-20-[v0]", views: titleLabel)
//        backgroundView.addConstraintsWithFormat("V:|[v0]|", views: titleLabel)
//
////        backgroundView.addConstraintsWithFormat("H:[v0(60)]-20-|", views: button)
//        backgroundView.addConstraintsWithFormat("H:|[v0]|", views: button)
//        backgroundView.addConstraintsWithFormat("V:|[v0]|", views: button)
//
////        backgroundView.addConstraintsWithFormat("H:|[v0]-80-|", views: titleButton)
////        backgroundView.addConstraintsWithFormat("V:|[v0]|", views: titleButton)
//
//        NSLayoutConstraint.activate([
//            backgroundView.centerYAnchor.constraint(equalTo: arrowImageView.centerYAnchor)
//        ])
//
//        return backgroundView
//    }
//
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 56
//    }
//
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let backgroundView = UIView()
//
//        let line = UIView()
//
//        line.backgroundColor = UIColor(red: 234/255.0, green: 235/255.0, blue: 236/255.0, alpha: 1.0)
//
//        backgroundView.addSubview(line)
//
//        backgroundView.addConstraintsWithFormat("H:|[v0]|", views: line)
//        backgroundView.addConstraintsWithFormat("V:[v0(1)]|", views: line)
//
//        return backgroundView
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//
//        let isExpanded = sideMenuArray[section].isExpanded
//
//        if isExpanded {
//            return 28
//        } else {
//            return 1
//        }
//
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return sideMenuArray.count
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if !sideMenuArray[section].isExpanded {
//            return 0
//        }
//
//        return sideMenuArray[section].subMenu.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuCell", for: indexPath) as! SideMenuCell
//        let item = sideMenuArray[indexPath.section].subMenu[indexPath.row]
//
//        cell.titleLabel.text = item.menuNm
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let item = sideMenuArray[indexPath.section].subMenu[indexPath.row]
//
//        guard let completion = self.slideCompletion else { return }
//        guard let menuUrl = item.menuUrl else {
//            completion("close")
//            return
//        }
//        completion(menuUrl)
//    }
//
//}
