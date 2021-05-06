//
//  AppDelegate.swift
//  Modified by Krunk
//

import UIKit
import CoreData
import StoreKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private let counterKey = "counter"

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()

        UIApplication.shared.setMinimumBackgroundFetchInterval(900)

        // Inject the loginService into the HomeController so it can perform
        // a login flow if necessary
        let root = window?.rootViewController as? UITabBarController
        root?.children.forEach { child in
            let nav = child as? UINavigationController
            if let home = nav?.viewControllers.first as? HomeViewController {
                home.loginService = RequestManager.shared
            }
        }

        return true
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
          .requestAuthorization(
            options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            print("Permission granted: \(granted)")
            guard granted else { return }
            self?.getNotificationSettings()
          }
    }
    
    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        print("Notification settings: \(settings)")
        guard settings.authorizationStatus == .authorized else { return }
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
        }
      }
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Free up documents and url cache to keep app footprint light
        URLCache.shared.removeAllCachedResponses()
        //clearDocumentsDirectory()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Since the cookies will expire after a certain amount of time,
        // they should be checked to see if they are still valid every time
        // the app comes onto the screen
        RequestManager.shared.validateLoggedInStatus(
            onSuccess: {
            RequestManager.shared.loadCookiesIntoUserDefaults()
        }, onFailure: { [weak self] _ in
            if RequestManager.shared.isLoggedIn {
                self?.logout()
            }
        })

        var counter = UserDefaults.standard.integer(forKey: counterKey)
        if counter % 20 == 0 && counter != 0 {
            SKStoreReviewController.requestReview()
        }
        counter += 1
        UserDefaults.standard.set(counter, forKey: counterKey)
    }

    func applicationWillTerminate(_ application: UIApplication) {

    }
    
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .all
        }

        // If any ViewControllers conform to Rotatable, they will be allowed
        // to rotate
        if self.topViewControllerForRoot(window?.rootViewController) as? Rotatable != nil {
            return .allButUpsideDown
        }
        // Only allow portrait (standard behaviour)
        return .portrait
    }

    /// Recursively retrieve the top level view controller that is presented
    /// on the screen. This means that neither a UITabBarController or
    /// UINavigationController can be a top level controller. Any view
    /// controller that is presenting another controller also is not a top
    /// level controller
    ///
    /// - Parameter rootViewController: the root view controller
    /// - Returns: the current top-level controller for the root
    private func topViewControllerForRoot(_ rootViewController: UIViewController?)
        -> UIViewController? {
        if rootViewController == nil { return nil }
        if let selected = (rootViewController as? UITabBarController)?.selectedViewController {
            return topViewControllerForRoot(selected)
        } else if
            let visible = (rootViewController as? UINavigationController)?.visibleViewController {
            return topViewControllerForRoot(visible)
        } else if let presented = rootViewController?.presentedViewController {
            return topViewControllerForRoot(presented)
        }
        return rootViewController
    }

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are
         legitimate error conditions that could cause the creation of the
         store to fail.
         */
        let container = NSPersistentContainer(name: "Temp")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                print(error)
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func application(
        _ application: UIApplication,
        performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Refresh the cookies if they are available and load them into
        // User Defaults to keep the session alive
        if RequestManager.shared.loadCookiesFromUserDefaults() {
            RequestManager.shared.validateLoggedInStatus(onSuccess: {
                RequestManager.shared.refreshCookies()
                completionHandler(.newData)
            }, onFailure: { _ in
                UserDefaults.standard.set(nil, forKey: RequestManager.savedCookiesKey)
                completionHandler(.failed)
            })
        } else {
            completionHandler(.noData)
        }
    }

    func logout() {
        RequestManager.shared.reset()
        SakaiService.shared.reset()

        // The root controller is guaranteed to be a UITabBarController
        let rootController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController
        rootController?.dismiss(animated: false, completion: nil)
        rootController?.selectedIndex = 0

        let navigationControllers = rootController?.viewControllers as? [UINavigationController]
        navigationControllers?.forEach { nav in
            nav.popToRootViewController(animated: false)
        }

        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        guard
            let navController = storyboard
                .instantiateViewController(withIdentifier: "loginNavigation") as? UINavigationController,
            let loginController = navController.viewControllers.first as? LoginViewController
            else {
                return
        }
        loginController.onLogin = {
            DispatchQueue.main.async {
                rootController?.dismiss(animated: true, completion: nil)
                // Reload the HomeController because the source of truth
                // needs to be reset in the app
                let action = ReloadActions.reloadHome.rawValue
                NotificationCenter.default.post(
                    name: NSNotification.Name(rawValue: action),
                    object: nil,
                    userInfo: nil
                )
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            rootController?.present(navController, animated: true, completion: nil)
        })
    }

    /// Flush the documents directory of downloaded documents and files to keep
    /// app footprint light
    private func clearDocumentsDirectory() {
        do {
            guard
                let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                else {
                    return
            }
            let documentDirectory = try FileManager.default.contentsOfDirectory(atPath: documentsUrl.path)
            try documentDirectory.forEach { file in
                let fileUrl = documentsUrl.appendingPathComponent(file)
                try FileManager.default.removeItem(atPath: fileUrl.path)
            }
        } catch let err {
            print(err)
            return
        }
    }
    
    func application(
      _ application: UIApplication,
      didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
      let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
      let token = tokenParts.joined()
      print("Device Token: \(token)")
      UserDefaults.standard.set(String(describing: token), forKey: "Sakai-pushToken")
    }
    
    func application(
      _ application: UIApplication,
      didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
      print("Failed to register: \(error)")
    }
    
    func application(
      _ application: UIApplication,
      didReceiveRemoteNotification userInfo: [AnyHashable: Any],
      fetchCompletionHandler completionHandler:
      @escaping (UIBackgroundFetchResult) -> Void
    ) {
      guard let aps = userInfo["aps"] as? [String: AnyObject] else {
        completionHandler(.failed)
        return
      }
        print("noti received")
        let alertController = UIAlertController(title: "收到一条新通知", message: "请前往Sakai网站查看",
            preferredStyle: .alert)
            let okAction = UIAlertAction(title: "好的", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    
}
