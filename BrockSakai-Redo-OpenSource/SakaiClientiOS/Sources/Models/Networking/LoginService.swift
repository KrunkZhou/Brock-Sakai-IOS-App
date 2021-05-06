//
//  LoginService.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 1/1/19.
//  Modified by Krunk
//

import Foundation

protocol LoginService {

    var cookieArray: [[HTTPCookiePropertyKey: Any]] { get }
    var userId: String? { get }

    func addCookie(cookie: HTTPCookie)
    func clearCookies()

    func loadCookiesFromUserDefaults() -> Bool
    func loadCookiesIntoUserDefaults()

    func validateLoggedInStatus(onSuccess: @escaping () -> Void,
                                onFailure: @escaping (SakaiError?) -> Void)
    
    func validateSiteStatus(onSuccess: @escaping () -> Void,
                            onFailure: @escaping (SakaiError?) -> Void)
}

extension LoginService {
    var isLoggedIn: Bool {
        return userId != nil
    }
}
