//
//  SceneDelegate.swift
//  HerHub
//
//  Created by Nihar Sandhu on 28/10/25.
//

import UIKit
import Supabase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Check authentication state
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        // Check if we have a valid user loaded (not just session exists)
        // currentUser must be loaded AND Supabase session must be valid
        let hasUser = AuthManager.shared.currentUser != nil
        let hasSession = SupabaseManager.shared.isAuthenticated
        
        if hasUser && hasSession {
            // User is fully logged in - go to main app (Tab Bar)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            window.rootViewController = storyboard.instantiateInitialViewController()
        } else if hasSession {
            // Session exists but user not loaded yet - wait and check
            Task {
                // Try to restore session
                if let userID = SupabaseManager.shared.currentUserID {
                    do {
                        if let user = try await SupabaseService.shared.fetchUser(byID: userID) {
                            AuthManager.shared.updateCurrentUser(user)
                            await MainActor.run {
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                window.rootViewController = storyboard.instantiateInitialViewController()
                                window.makeKeyAndVisible()
                            }
                            return
                        }
                    } catch {
                        print("[SceneDelegate] Failed to restore user: \(error)")
                    }
                }
                // Failed to restore - show auth
                await MainActor.run {
                    let storyboard = UIStoryboard(name: "Auth", bundle: nil)
                    window.rootViewController = storyboard.instantiateInitialViewController()
                    window.makeKeyAndVisible()
                }
            }
            // Show loading screen temporarily
            let loadingVC = UIViewController()
            loadingVC.view.backgroundColor = .white
            let loadingLabel = UILabel()
            loadingLabel.text = "Loading..."
            loadingLabel.textColor = .systemPink
            loadingLabel.font = .systemFont(ofSize: 18, weight: .medium)
            loadingLabel.translatesAutoresizingMaskIntoConstraints = false
            loadingVC.view.addSubview(loadingLabel)
            NSLayoutConstraint.activate([
                loadingLabel.centerXAnchor.constraint(equalTo: loadingVC.view.centerXAnchor),
                loadingLabel.centerYAnchor.constraint(equalTo: loadingVC.view.centerYAnchor)
            ])
            window.rootViewController = loadingVC
        } else {
            // User not logged in - show sign in
            let storyboard = UIStoryboard(name: "Auth", bundle: nil)
            window.rootViewController = storyboard.instantiateInitialViewController()
        }
        
        window.makeKeyAndVisible()
    }
    
    // Handle OAuth callback URLs
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        
        // Handle Supabase OAuth callback
        if url.absoluteString.hasPrefix("herhub://") {
            Task {
                do {
                    try await AuthManager.shared.handleOAuthCallback(url: url)
                    // Navigate to main app on success
                    await MainActor.run {
                        self.navigateToMainApp()
                    }
                } catch {
                    print("[SceneDelegate] OAuth callback error: \(error)")
                }
            }
        }
    }
    
    private func navigateToMainApp() {
        guard let window = window else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarVC = storyboard.instantiateInitialViewController() {
            window.rootViewController = tabBarVC
            window.makeKeyAndVisible()
        }
    }


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

