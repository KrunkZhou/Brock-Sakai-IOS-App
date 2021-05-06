//
//  SettingsViewController.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 1/3/19.
//  Modified by Krunk
//

import UIKit
import SafariServices
import MessageUI

class SettingsViewController: UITableViewController {

    private let aboutURL = URL(string: "https://")
    private let privacyURL = URL(string: "https://")
    private let appID = 1529380859
    private lazy var rateUrl = "https://apps.apple.com/ca/app/id1529380859?mt=8&action=write-review"
    private let developerEmail = "webmaster@krunk.cn"
    private let testflightURL = URL(string: "https://krunkzhou.github.io/LmsApp/more/testflight.html")

    @IBOutlet weak var tableHeader: UIView!
    @IBOutlet weak var imageHeader: UIImageView!
    @IBOutlet weak var tableFooter: UIView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var logoCreditLabel: UILabel!

    let infoArr = AppSettings.allCases

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "设置"
        tableView.register(SiteCell.self,
                           forCellReuseIdentifier: SiteCell.reuseIdentifier)
        view.backgroundColor = Palette.main.primaryBackgroundColor
        tableHeader.backgroundColor = Palette.main.primaryBackgroundColor
        tableFooter.backgroundColor = Palette.main.primaryBackgroundColor

        imageHeader.backgroundColor = Palette.main.primaryBackgroundColor
        logoCreditLabel.backgroundColor = Palette.main.primaryBackgroundColor
        logoCreditLabel.textColor = Palette.main.secondaryTextColor

        logoutButton.round()
        logoutButton.tintColor = Palette.main.primaryTextColor
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoArr.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: SiteCell.reuseIdentifier, for: indexPath)
                as? SiteCell else {
            return UITableViewCell()
        }
        let info = infoArr[indexPath.row]
        cell.iconLabel.font = UIFont(name: AppIcons.generalIconFont, size: 25.0)
        cell.titleLabel.text = info.description
        cell.iconLabel.text = info.icon
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = infoArr[indexPath.row]
        switch item {
        case .testflight:
            presentSafariController(url: testflightURL)
//        case .privacy:
//            presentSafariController(url: privacyURL)
        case .thanks:
            let storyboard = UIStoryboard(name: "SettingsView", bundle: nil)
            let creditsController = storyboard.instantiateViewController(withIdentifier: "credits")
            navigationController?.pushViewController(creditsController, animated: true)
//        case .contact:
//            if !MFMailComposeViewController.canSendMail() {
//                presentErrorAlert(string: "我们的邮箱： \(developerEmail)")
//            } else {
//                let composeVC = MFMailComposeViewController()
//                composeVC.mailComposeDelegate = self
//
//                // Configure the fields of the interface.
//                composeVC.setToRecipients([developerEmail])
//                composeVC.setSubject("Feedback")
//
//                tabBarController?.present(composeVC, animated: true, completion: nil)
//            }
//            tableView.deselectRow(at: indexPath, animated: true)
//        case .rate:
//            if let url = URL(string: rateUrl), UIApplication.shared.canOpenURL(url) {
//                UIApplication.shared.open(
//                    url,
//                    options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil
//                )
//            } else {
//                presentErrorAlert(string: "Cannot leave rating at this time. Please go directly to the App Store")
//            }
//            tableView.deselectRow(at: indexPath, animated: true)
        case .autologin:
            let alertController = UIAlertController(title: "配置自动登录",
                                message: "保存后将会在登陆过期时自动进行登录", preferredStyle: .alert)
            alertController.addTextField { (textField: UITextField!) -> Void in
                textField.placeholder = "ab12cd@brocku.ca"
            }
            alertController.addTextField { (textField: UITextField!) -> Void in
                textField.placeholder = "密码"
                textField.isSecureTextEntry = true
            }
            let cancelAction = UIAlertAction(title: "删除自动登录", style: .cancel, handler: { action in
                
                //提示删除
                let alertController = UIAlertController(title: "删除自动登录", message: "清除后将不会在登陆时自动填充", preferredStyle: .actionSheet)
                let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                let deleteAction = UIAlertAction(title: "删除", style: .destructive, handler: { action in
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
            let okAction = UIAlertAction(title: "保存", style: .default, handler: { action in
                let login = alertController.textFields!.first!
                let password = alertController.textFields!.last!
                UserDefaults.standard.set(String(describing: login.text.unsafelyUnwrapped), forKey: "Sakai-Username")
                UserDefaults.standard.set(String(describing: password.text.unsafelyUnwrapped), forKey: "Sakai-Password")
                UserDefaults.standard.set(true, forKey: "Sakai-Submit")
                
                //提示成功
                let alertController = UIAlertController(title: "成功", message: "已配置自动登录",
                    preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "好的", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                
            })
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    private func presentSafariController(url: URL?) {
        guard let url = url else {
            return
        }
        let safariController = SFSafariViewController.defaultSafariController(url: url)
        tabBarController?.present(safariController, animated: true, completion: nil)
    }

    @IBAction func logout(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "Sakai-Submit")
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.logout()
    }

}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        tabBarController?.dismiss(animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(
    _ input: [String: Any]
) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(
        uniqueKeysWithValues: input.map { key, value in
            (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)
        }
    )
}
