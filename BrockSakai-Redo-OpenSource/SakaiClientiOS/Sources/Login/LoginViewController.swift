//
//  EmailLoginController.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 9/17/18.
//  Modified by Krunk
//

import Foundation
import UIKit

/// A landing page for login with NetId or with Email
class LoginViewController: UIViewController {

    @IBOutlet private weak var netIdButton: UIButton!
    @IBOutlet private weak var emailButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!

    /// Callback to execute for a successful login
    var onLogin: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.main.primaryBackgroundColor

        netIdButton.round()
        emailButton.round()

        title = "Login"
        
        let submitCheck = UserDefaults.standard.bool(forKey: "Sakai-Submit")
        if(submitCheck){
            loginAction()
        }
    }
    
    func loginAction(){
        let loginController = LoginWebViewController(loginUrl: LoginConfiguration.loginUrl)
        loginController.onLogin = onLogin
        navigationController?.pushViewController(loginController, animated: true)
    }

    @IBAction func loginWithNetId(_ sender: Any) {
        let submitCheck = UserDefaults.standard.bool(forKey: "Sakai-Submit")
        if (submitCheck==false){
            let alertController = UIAlertController(title: "提示", message: "如果遇到经常需要登录建议设置自动登录",
                preferredStyle: .alert)
            let okAction = UIAlertAction(title: "好的", style: .default, handler: {
                action in
                self.loginAction()
            })
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
        }else{
            loginAction()
        }
    }
    
    @IBAction func loginWithEmail(_ sender: Any) {
        let alertController = UIAlertController(title: "配置自动登录",
                            message: "保存后将会在登陆过期时自动进行登录", preferredStyle: .alert)
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "ab12cd@brocku.ca"
        }
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "密码"
            textField.isSecureTextEntry = true
        }
        let cancelAction = UIAlertAction(title: "删除自动登录", style: .cancel, handler: {
            action in
            
            //提示删除
            let alertController = UIAlertController(title: "删除自动登录", message: "清除后将不会在登陆时自动填充",  preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "删除", style: .destructive, handler: {
                action in
                UserDefaults.standard.set("", forKey: "Sakai-Username")
                UserDefaults.standard.set("", forKey: "Sakai-Password")
                UserDefaults.standard.set(false, forKey: "Sakai-Submit")
            })
            let archiveAction = UIAlertAction(title: "保留", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            alertController.addAction(archiveAction)
            self.present(alertController, animated: true, completion: nil)
            
        })
        let okAction = UIAlertAction(title: "保存", style: .default, handler: {
            action in
            let login = alertController.textFields!.first!
            let password = alertController.textFields!.last!
            UserDefaults.standard.set(String(describing: login.text.unsafelyUnwrapped), forKey: "Sakai-Username")
            UserDefaults.standard.set(String(describing: password.text.unsafelyUnwrapped), forKey: "Sakai-Password")
            UserDefaults.standard.set(true, forKey: "Sakai-Submit")
            
            //提示成功
            let alertController = UIAlertController(title: "已配置自动登录", message: "如果登录失败，可以返回回来重新输入",
                preferredStyle: .alert)
            let okAction = UIAlertAction(title: "好的", style: .default, handler: {
                action in
                self.loginAction()
            })
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
//        UserDefaults.standard.set(false, forKey: "Sakai-Submit")
//        let loginController = LoginWebViewController(loginUrl: LoginConfiguration.emailLoginUrl)
//        loginController.onLogin = onLogin
//        navigationController?.pushViewController(loginController, animated: true)
    }
}
