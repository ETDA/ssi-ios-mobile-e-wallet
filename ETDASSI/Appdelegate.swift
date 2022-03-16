//
//  Appdelegate.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 7/6/2564 BE.
//

import UIKit
import Firebase
import SwiftyJSON
import UserNotifications
import Sentry

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
    
    var fcmToken = ""
    let gcmMessageIDKey = "gcm.message_id"
    var notiList: [[AnyHashable : Any]] = []
    
//    func applicationDidFinishLaunching(_ application: UIApplication) {
//    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        SentrySDK.start { options in
                options.dsn = "https://0678a583c41e449ebbd05c12dc76d2ce@o1045119.ingest.sentry.io/6020398"
                options.debug = true // Enabled debug when first installing is always helpful

                // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
                // We recommend adjusting this value in production.
                options.tracesSampleRate = 1.0
        }
        
        if let uuid = UserDefaults.standard.string(forKey: "uuid") {
            print("uuid \(uuid)")
        } else {
            UserDefaults.standard.set(UUID().uuidString, forKey: "uuid")
        }
        
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("_noti_","***********didFailToRegisterForRemoteNotificationsWithError")
    
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        self.fcmToken = fcmToken ?? ""
        
        UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
        
        let dataDict:[String: String] = ["token": self.fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
          print("Device Token: \(deviceToken)")
      Messaging.messaging().apnsToken = deviceToken
    }

    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.

        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
            let json = JSON(userInfo)
            NotificationDocument.add(json: json)
     
        }

        // Print full message.
        print(userInfo)
      }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)
        print("_noti_status","ok")
      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
        print("_noti_message",messageID)
          
        print("Message ID: \(messageID)")

        let json = JSON(userInfo)
        NotificationDocument.add(json: json)
          
          print("_noti_json",json.rawValue)
      }

      // Print full message.
      print(userInfo)

      completionHandler(UIBackgroundFetchResult.newData)
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // Print message ID.
    print("App in foreground")
    
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID: \(messageID)")
        let json = JSON(userInfo)
        //NotificationDocument.add(json: json)  //remove , because it will shows  multiple same notification message
        
        print("_noti_","fourground....")
    }

    // Print full message.
    print(userInfo)

    // Change this to your preferred presentation option
    //completionHandler([[.alert, .sound]])
    completionHandler([[.list, .banner, .sound]])
    self.notiList.append(userInfo)
    NotificationCenter.default.post(name: Notification.Name("receiveNoti"), object: nil, userInfo: nil)
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    // Print message ID.
    print("noti tapped")
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID: \(messageID)")
    }

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // Print full message.
    print(userInfo)
    completionHandler()
    self.notiList.append(userInfo)
  }
}
