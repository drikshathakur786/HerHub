//
//  SceneDelegate.swift
//  HerHub
//
//  Created by Nihar Sandhu on 28/10/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        // Auto-login: Create/login test user
        Task {
//            await autoLoginTestUser()
        }
    }
    
//    private func autoLoginTestUser() async {
//        do {
//            let testEmail = "beth@herhub.com"
//            
//            // Try to load existing session first
//            try await SessionManager.shared.loadSession()
//            
//            if let currentUser = SessionManager.shared.currentUser {
//                if currentUser.email == testEmail {
//                    print("✅ Existing session loaded for \(testEmail)")
//                    return
//                } else {
//                    print("   Session email mismatch (Found: \(currentUser.email ?? "nil"), Expected: \(testEmail)). Logging out...")
//                    SessionManager.shared.logout()
//                }
//            }
//            
//            // No existing session - try to fetch or create test user
//            if let existingUser = try await UserController.shared.fetchUser(byEmail: testEmail) {
//                // Login existing test user
//                SessionManager.shared.login(user: existingUser)
//                print("✅ Logged in existing test user: \(testEmail)")
//            } else {
//                // Create new test user
//                let newUser = User(
//                    email: testEmail,
//                    phoneNumber: nil,
//                    password: "test123",
//                    userName: "Test User",
//                    userPicture: nil
//                )
//                try await UserController.shared.registerUser(newUser)
//                SessionManager.shared.login(user: newUser)
//                print("✅ Created and logged in new test user: \(testEmail)")
//            }
//        } catch {
//            print("  Auto-login failed: \(error.localizedDescription)")
//        }
//    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
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
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

