//
//  SceneDelegate.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 7/6/2564 BE.
//

import UIKit
import LocalAuthentication
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
//        print("comming EnterForeground \(scene)")
//        guard let windowScene = (scene as? UIWindowScene) else { return }
//        let window = UIWindow(windowScene: windowScene)
//        self.window = window
//        print("start scene sceneWillResignActive")
//        let storyboard = UIStoryboard(name: "User", bundle: nil)
//        let initialViewController: UIViewController? = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
//        let navigationController = UINavigationController(rootViewController: initialViewController!)
//        self.window?.rootViewController = navigationController
//        self.window?.makeKeyAndVisible()
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
                let window = UIWindow(windowScene: windowScene)
                self.window = window
        
        let userFlow = UserDefaults.standard.string(forKey: "Navigate_Flow")
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
        {
            switch userFlow {
            case "REGISTER_USER_SUCCESS":
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController: UIViewController? = storyboard.instantiateViewController(withIdentifier: "RegisterOTPViewController")
                let navigationController = UINavigationController(rootViewController: initialViewController!)
                self.window?.rootViewController = navigationController
                self.window?.makeKeyAndVisible()
            case "RECOVERY_CHECK":
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController: UIViewController? = storyboard.instantiateViewController(withIdentifier: "RestoreViewController")
                let navigationController = UINavigationController(rootViewController: initialViewController!)
                self.window?.rootViewController = navigationController
                self.window?.makeKeyAndVisible()
            case "REGISTER_VERIFY_SUCCESS":
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController: UIViewController? = storyboard.instantiateViewController(withIdentifier: "CheckDopaViewController")
                let navigationController = UINavigationController(rootViewController: initialViewController!)
                self.window?.rootViewController = navigationController
                self.window?.makeKeyAndVisible()
            case "REGISTER_DID_SUCCESS":
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController: UIViewController? = storyboard.instantiateViewController(withIdentifier: "CheckDopaViewController")
                let navigationController = UINavigationController(rootViewController: initialViewController!)
                self.window?.rootViewController = navigationController
                self.window?.makeKeyAndVisible()
            case "BYPASS":
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController: UIViewController? = storyboard.instantiateViewController(withIdentifier: "CheckDopaViewController")
                let navigationController = UINavigationController(rootViewController: initialViewController!)
                self.window?.rootViewController = navigationController
                self.window?.makeKeyAndVisible()
            case "REGISTER_SUCCESS":
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController: UIViewController? = storyboard.instantiateViewController(withIdentifier: "SummaryRegisterViewController")
                let navigationController = UINavigationController(rootViewController: initialViewController!)
                self.window?.rootViewController = navigationController
                self.window?.makeKeyAndVisible()
            case "RESTORE_SUCCESS":
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController: UIViewController? = storyboard.instantiateViewController(withIdentifier: "SummaryRegisterViewController")
                let navigationController = UINavigationController(rootViewController: initialViewController!)
                self.window?.rootViewController = navigationController
                self.window?.makeKeyAndVisible()
            case "Create_Wallet_Success":
                let storyboard = UIStoryboard(name: "Passcode", bundle: nil)
                let initialViewController: UIViewController? = storyboard.instantiateViewController(withIdentifier: "PinCodeRegisterViewController")
                let navigationController = UINavigationController(rootViewController: initialViewController!)
                self.window?.rootViewController = navigationController
                self.window?.makeKeyAndVisible()
            case "FINISH_SETPASS_FLOW":
                let storyboard = UIStoryboard(name: "PinLogin", bundle: nil)
                let initialViewController: UIViewController? = storyboard.instantiateViewController(withIdentifier: "UserLoginViewController")
                let navigationController = UINavigationController(rootViewController: initialViewController!)
                self.window?.rootViewController = navigationController
                self.window?.makeKeyAndVisible()
            default:
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController: UIViewController? = storyboard.instantiateViewController(withIdentifier: "MainViewController")
                let navigationController = UINavigationController(rootViewController: initialViewController!)
                self.window?.rootViewController = navigationController
                self.window?.makeKeyAndVisible()
            }
        } else {
                 
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController: UIViewController? = storyboard.instantiateViewController(withIdentifier: "SetDeviceViewController")
            let navigationController = UINavigationController(rootViewController: initialViewController!)
            self.window?.rootViewController = navigationController
            self.window?.makeKeyAndVisible()
            
        }
 
        
        
        
        
//                if  UserDefaults.standard.string(forKey: "Navigate_Flow") == "FINISH_SETPASS_FLOW" {
//                    let storyboard = UIStoryboard(name: "PinLogin", bundle: nil)
//                    let initialViewController: UIViewController? = storyboard.instantiateViewController(withIdentifier: "UserLoginViewController")
//                    let navigationController = UINavigationController(rootViewController: initialViewController!)
//                    self.window?.rootViewController = navigationController
//                    self.window?.makeKeyAndVisible()
//                } else {
//                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                    let initialViewController: UIViewController? = storyboard.instantiateViewController(withIdentifier: "MainViewController")
//                    let navigationController = UINavigationController(rootViewController: initialViewController!)
//                    self.window?.rootViewController = navigationController
//                    self.window?.makeKeyAndVisible()
//                }
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}

