//
//  LoginViewController.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 5/14/18.
//  Modified by Krunk
//

import UIKit
import WebKit
import ReusableSource

/// A view controller allowing users to login to CAS and/or Sakai
class LoginWebViewController: WebViewController {

    /// Callback to execute once user has been authenticated
    var onLogin: (() -> Void)?

    private let loginUrl: String
    private let loginService: LoginService

    init(loginUrl: String, loginService: LoginService, downloadService: DownloadService, webService: WebService) {
        self.loginUrl = loginUrl
        self.loginService = loginService
        super.init(downloadService: downloadService, webService: webService, allowsOptions: false)
    }

    convenience init(loginUrl: String) {
        self.init(loginUrl: loginUrl,
                  loginService: RequestManager.shared,
                  downloadService: RequestManager.shared,
                  webService: RequestManager.shared)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    /// Loads Login URL for CAS Authentication
    override func viewDidLoad() {
        RequestManager.shared.resetCache()
        setURL(url: URL(string: loginUrl))
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /// Captures HTTP Cookies from specific URLs and loads them into Login
    /// service Session. Allows all future requests to be authenticated.
    override func webView(_ webView: WKWebView,
                          decidePolicyFor navigationAction: WKNavigationAction,
                          decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let group = DispatchGroup()
        group.notify(queue: .main) {
            decisionHandler(.allow)
        }
        group.enter()
        if webView.url!.absoluteString == LoginConfiguration.cookieUrl {
            let store = webView.configuration.websiteDataStore.httpCookieStore
            store.getAllCookies { [weak self] cookies in
                for cookie in cookies {
                    HTTPCookieStorage.shared.setCookie(cookie as HTTPCookie)
                    self?.loginService.addCookie(cookie: cookie)
                    if (cookie.name=="SAKAIID"){
                        print(cookie.name)
                        print(cookie.value)
                        UserDefaults.standard.set(cookie.value, forKey: "Sakai-Noti-sakaiid")
                    }
                }
                group.leave()
            }
        } else {
            group.leave()
        }
    }

    override func webView(_ webView: WKWebView,
                          decidePolicyFor navigationResponse: WKNavigationResponse,
                          decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if webView.url!.absoluteString == LoginConfiguration.cookieUrl {
            decisionHandler(.cancel)
            // If navigation request is to the redirect URL for a
            // successful login, the user should have successfully
            // authenticated. Validate the login and execute
            // onLogin callback. Also save authentication cookies. If login
            // validation fails, the webview is reloaded to try again.
            loginService.validateLoggedInStatus(
                onSuccess: { [weak self] in
                    self?.onLogin?()
                    UserDefaults.standard.set(self?.loginService.cookieArray, forKey: RequestManager.savedCookiesKey)
                    UserDefaults.standard.set(true, forKey: "Sakai-Submit")
                    
                    
                    
                    let submitCheck = UserDefaults.standard.bool(forKey: "Sakai-noti")
                    let pushToken = UserDefaults.standard.string(forKey: "Sakai-pushToken") ?? ""
                    let sakaiid = UserDefaults.standard.string(forKey: "Sakai-Noti-sakaiid") ?? ""
                    if (submitCheck){
                        let appDelegate = UIApplication.shared.delegate as? AppDelegate
                        appDelegate?.registerForPushNotifications();
                        //通知系统
                        //let cookieArray = UserDefaults.standard.array(forKey: RequestManager.savedCookiesKey)
                        guard let url = URL(string: "https://ts1.krunk.cn/sakaiNoti/set.php?pushtoken="+pushToken+"&sakaiid="+sakaiid) else { return }
                        //let jsonData = try? JSONSerialization.data(withJSONObject: cookieArray ?? [String]())
                        var request = URLRequest(url: url)
                        request.httpMethod = "POST"
                        request.addValue("application/json", forHTTPHeaderField: "content-type")
                        //request.httpBody = jsonData
                        let task = URLSession.shared.dataTask(with: request)
                        task.resume()
                    }
                    
                },
                onFailure: { [weak self] err in
                    let store = webView.configuration.websiteDataStore.httpCookieStore
                    store.getAllCookies({ cookies in
                        cookies.forEach { cookie in
                            store.delete(cookie, completionHandler: nil)
                        }
                    })
                    self?.loginService.clearCookies()
                    self?.loadWebview()
                }
            )
        } else {
            decisionHandler(.allow)
        }
    }
    override func webView(_ webView: WKWebView, didFinish: WKNavigation!) {
        
        if webView.url!.absoluteString.contains(LoginConfiguration.mfaKeepLogin){
            webView.evaluateJavaScript("document.getElementById('idSIButton9').click()") { (result, error) in
                    if error != nil {
                        print(result ?? "Login Error")
                    }
                }
        }
        
        if webView.url!.absoluteString.contains(LoginConfiguration.mfa)  {
            let username = UserDefaults.standard.string(forKey: "Sakai-Username") ?? ""
            //let submitCheck = UserDefaults.standard.bool(forKey: "Sakai-Submit")
            
            webView.evaluateJavaScript("document.getElementById('i0116').value=\""+username+"\"") { (result, error) in
                if error != nil {
                    print(result ?? "Login Error")
                }
            }
//            if(submitCheck){
//                webView.evaluateJavaScript("document.getElementById('idSIButton9').click()") { (result, error) in
//                    if error != nil {
//                        print(result ?? "Login Error")
//                    }
//                }
//            }
            
        }
        
        if webView.url!.absoluteString.contains(LoginConfiguration.adfsUrl) {
            
//            UserDefaults.standard.set("@brocku.ca", forKey: "Sakai-Username")
//            UserDefaults.standard.set("", forKey: "Sakai-Password")
//            UserDefaults.standard.set(false, forKey: "Sakai-Submit")
            
            let username = UserDefaults.standard.string(forKey: "Sakai-Username") ?? ""
            let password = UserDefaults.standard.string(forKey: "Sakai-Password") ?? ""
            let submitCheck = UserDefaults.standard.bool(forKey: "Sakai-Submit")
            
            //print ("Finish Load Check")
            //print()
            webView.evaluateJavaScript("document.getElementById('userNameInput').value=\""+username+"\"") { (result, error) in
                if error != nil {
                    print(result ?? "Login Error")
                }
            }
            webView.evaluateJavaScript("document.getElementById('passwordInput').value=\""+password+"\"") { (result, error) in
                if error != nil {
                    print(result ?? "Login Error")
                }
            }
            if(submitCheck){
                webView.evaluateJavaScript("document.getElementById('submitButton').click()") { (result, error) in
                    if error != nil {
                        print(result ?? "Login Error")
                    }
                }
            }
        }
    }
}
