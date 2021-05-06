//
//  AppSettings.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 1/12/19.
//  Modified by Krunk
//

import Foundation

enum AppSettings: CaseIterable {
    case thanks, testflight, autologin
    //case privacy, thanks, contact, rate, testflight, autologin

    var description: String {
        switch self {
//        case .privacy:
//            return "  隐私协议"
        case .thanks:
            return "  由衷感谢"
//        case .contact:
//            return "  联系我们"
//        case .rate:
//            return "  写个评价"
        case .testflight:
            return "  加入内测"
        case .autologin:
            return "  自动登录"
        }
    }

    var icon: String? {
        switch self {
//        case .privacy:
//            return AppIcons.privacyIcon
        case .thanks:
            return AppIcons.thanksIcon
//        case .contact:
//            return AppIcons.contactIcon
//        case .rate:
//            return AppIcons.rateIcon
        case .autologin:
            return AppIcons.chatIcon
        case .testflight:
            return AppIcons.attachmentIcon
        }
    }
}
