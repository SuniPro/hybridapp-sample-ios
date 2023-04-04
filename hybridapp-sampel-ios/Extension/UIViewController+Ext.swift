import Foundation
import UIKit

let SCREEN_WIDTH = UIScreen.main.bounds.width
let SCREEN_HEIGHT = UIScreen.main.bounds.height


extension UIViewController {
    
    
    func show(title: String, message: String, buttonNames: String..., complete: ((AlertButtonStyle) -> Void)? = nil ) {
        DispatchQueue.main.async {
            
            //그림자 생성
            let dimView = UIView()
            dimView.backgroundColor = .rgba(red: 0, green: 0, blue: 0, alpha: 0.5)
//            dimView.isUserInteractionEnabled = true
//            dimView.contentMode = .scaleToFill
            
            //메인 하얀 뷰 생성
            let backgroundView = UIView()
            backgroundView.layer.cornerRadius = 10
            backgroundView.backgroundColor = .white
            
            //그림자를 지우면 한번에 다 사라질 수 있도록 해준다.
            self.view.addSubview(dimView)
            dimView.addSubview(backgroundView)
            
            if title != "" {
                //제목이 있습니다
                //제목이 있을 경우 레이아웃이 달라진다.
                let titleLabel = UILabel()
                titleLabel.textAlignment = .center
                titleLabel.font = .systemFont(ofSize: 24, weight: .medium)
                titleLabel.text = title
                titleLabel.textColor = .sameRGB(rgb: 51)
                
                backgroundView.addSubview(titleLabel)
//                backgroundView.addSubview(graylineView)
                
                //제목 사이즈
                backgroundView.addConstraintsWithFormat("H:|[v0]|", views: titleLabel)
                backgroundView.addConstraintsWithFormat("V:|-54-[v0(30)]", views: titleLabel)

            }
            
            //중앙 메세지 영역
            let messageLabel = UILabel()
            messageLabel.text = message
            messageLabel.font = .systemFont(ofSize: 16, weight: .regular)
            messageLabel.textAlignment = .center
            messageLabel.numberOfLines = 0
            messageLabel.textColor = .sameRGB(rgb: 51)
            
            //미리 메세지를 붙여준다.
            backgroundView.addSubview(messageLabel)
            
            //가로 레이아웃을 미리 조절하고
            backgroundView.addConstraintsWithFormat("H:|-16-[v0]-16-|", views: messageLabel)
            if backgroundView.subviews.count != 1 {
                //제목이 있다는 뜻. 현재 하얀 뷰에 붙어있는 회색 선에 레이아웃을 붙여준다
                backgroundView.addConstraintsWithFormat("V:[v0]-26-[v1]", views: backgroundView.subviews[0], messageLabel)
            } else {
                //제목이 없다는 뜻. 최상단에 레이아웃을 붙여준다
                backgroundView.addConstraintsWithFormat("V:|-23-[v0]", views: messageLabel)
            }
            
            //기본 버튼이 될 leftButton
            let leftButton = UIButton()
            leftButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)

            if buttonNames.count == 1 {
                //버튼 한개 (default)
                //버튼이름에 값이 없을경우 확인버튼으로 대체
                leftButton.setTitle(buttonNames[0] == "" ? "확인" : buttonNames[0], for: .normal)
                leftButton.setTitleColor(.white, for: .normal)
                leftButton.backgroundColor = .rgba(red: 0, green: 169, blue: 183, alpha: 1)
                leftButton.layer.cornerRadius = 8
                leftButton.addAction {
                    //버튼 액션에 Closure를 달아 처리한다. extension이기 때문에 처리하는 방법은 비동기로 선택했다.
                    dimView.removeFromSuperview()
                    if complete != nil {
                        complete!(.CENTER_ACTION)
                    }
                }

                backgroundView.addSubview(leftButton)

                backgroundView.addConstraintsWithFormat("H:|-23-[v0]-23-|", views: leftButton)
                backgroundView.addConstraintsWithFormat("V:[v0]-64-[v1(50)]-23-|", views: messageLabel, leftButton)
                
            } else {
                //버튼 두개
                //버튼이름에 값이 없을경우 취소버튼으로 대체
                leftButton.setTitle(buttonNames[0] == "" ? "취소" : buttonNames[0], for: .normal)
                leftButton.setTitleColor(.rgba(red: 0, green: 169, blue: 183, alpha: 1), for: .normal)
                leftButton.layer.cornerRadius = 8
                
                let borderColor: UIColor = .rgba(red: 0, green: 169, blue: 183, alpha: 1)
                leftButton.layer.borderColor = borderColor.cgColor
                leftButton.layer.borderWidth = 1
                                                     
                leftButton.addAction {
                    //상단 버튼처리와 동문
                    dimView.removeFromSuperview()
                    if complete != nil {
                        complete!(.LEFT_ACTION)
                    }
                }

                let rightButton = UIButton()
                rightButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
                //버튼이름에 값이 없을경우 확인버튼으로 대체
                rightButton.setTitle(buttonNames[1] == "" ? "확인" : buttonNames[1], for: .normal)
                rightButton.setTitleColor(.white, for: .normal)
                rightButton.backgroundColor = .rgba(red: 0, green: 169, blue: 183, alpha: 1)
                rightButton.layer.cornerRadius = 8
                rightButton.addAction {
                    //상단 버튼처리와 동문
                    dimView.removeFromSuperview()
                    if complete != nil {
                        complete!(.RIGHT_ACTION)
                    }
                }

                backgroundView.addSubview(leftButton)
                backgroundView.addSubview(rightButton)
                
                let buttonWidthSize = self.view.bounds.size.width - 56 - 64

                backgroundView.addConstraintsWithFormat("H:|-23-[v0(\(buttonWidthSize/2))]-10-[v1]", views: leftButton, rightButton)
                backgroundView.addConstraintsWithFormat("V:[v0]-64-[v1(50)]-23-|", views: messageLabel, leftButton)

                backgroundView.addConstraintsWithFormat("H:[v0(\(buttonWidthSize/2))]-23-|", views: rightButton)
                backgroundView.addConstraintsWithFormat("V:[v0(50)]-23-|", views: rightButton)
            }
            
            //그림자 위에있을 하얀 뷰의 레이아웃
            dimView.addConstraintsWithFormat("H:|-32-[v0]-32-|", views: backgroundView)
            dimView.addConstraintsWithFormat("V:[v0]", views: backgroundView)
                    
            self.view.addConstraintsWithFormat("H:|[v0]|", views: dimView)
            self.view.addConstraintsWithFormat("V:|[v0]|", views: dimView)

            NSLayoutConstraint.activate([
                backgroundView.centerYAnchor.constraint(equalTo: dimView.centerYAnchor),
                backgroundView.centerXAnchor.constraint(equalTo: dimView.centerXAnchor)
            ])
        }
    }
    
    func showMessage(msg: String) {
        
        var message = msg
        if message.isEmpty {
            message = "알 수 없는 오류"
        }
        
        self.show(title: "", message: message, buttonNames: "확인")
        
    }
    
    func showMessage(msg: String, complete: (() -> Void)? = nil ) {
        
        var message = msg
        if message.isEmpty {
            message = "알 수 없는 오류"
        }
        
        self.show(title: "", message: message, buttonNames: "확인") {_ in
            complete!()
        }
        
    }
    
    func initLoading() {
        let loading = UIImageView()
        loading.tag = 7689120376891203
        
        var imageArr = [UIImage]()
        for count in 1...15 {
            imageArr.append(UIImage(named: "charge_loading_img_\(count)")!)
        }
        loading.animationImages = imageArr
        loading.animationDuration = 0.9
        loading.image = loading.animationImages?.first
        loading.startAnimating()
            
        
        let bgView = UIView()
        bgView.tag = 7689120376891205
        bgView.frame = self.view.bounds
        bgView.backgroundColor = .clear
        bgView.addSubview(loading)
        self.view.addSubview(bgView)
        loading.isHidden = true
        bgView.isHidden = true
        
        loading.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            loading.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            loading.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
    }
    
    func showLoading() {
        if self.view.viewWithTag(7689120376891203) == nil {
            initLoading()
        }
        
        self.view.bringSubviewToFront(self.view.viewWithTag(7689120376891205)!)
        self.view.bringSubviewToFront(self.view.viewWithTag(7689120376891203)!)
        
        self.view.viewWithTag(7689120376891205)?.isHidden = false
        self.view.viewWithTag(7689120376891203)?.isHidden = false

    }
    
    func removeLoading() {
        DispatchQueue.main.async {
            if self.view.viewWithTag(7689120376891203) == nil {
                return
            }
            
            self.view.viewWithTag(7689120376891205)?.isHidden = true
            self.view.viewWithTag(7689120376891203)?.isHidden = true
        }
    }
    
    var previousViewController: UIViewController? {
        if let controllersOnNavStack = self.navigationController?.viewControllers {
            
            let count = controllersOnNavStack.count
            
            // if self is still on Navigation stack
            if controllersOnNavStack.last === self, count > 1 {
                return controllersOnNavStack[count - 2]
            } else if count > 0 {
                return controllersOnNavStack[count - 1]
            }
        }
        return nil
    }
}

public enum AlertButtonStyle {
    case LEFT_ACTION
    case RIGHT_ACTION
    case CENTER_ACTION
}

/*
 let storyBoard: UIStoryboard = UIStoryboard(name: "AddCard", bundle: nil)
 let vc = storyBoard.instantiateViewController(withIdentifier: "AddCardViewController")
 self.navigationController?.pushViewController(vc, animated: true)
 */

