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
            _ = CommunityManager.shared
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
                                _ = CommunityManager.shared
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
            loadingVC.view.backgroundColor = .systemBackground // Use white to seamlessly blend the image's background
            
            let imageView = UIImageView()
            imageView.image = UIImage(named: "safe_space_girls")
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            loadingVC.view.addSubview(imageView)
            
            let titleLabel = UILabel()
            titleLabel.text = "HerHub"
            titleLabel.textColor = UIColor(red: 0.6, green: 0.4, blue: 0.8, alpha: 1.0) // Deep pastel purple
            titleLabel.font = .systemFont(ofSize: 36, weight: .heavy)
            titleLabel.textAlignment = .center
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            loadingVC.view.addSubview(titleLabel)
            
            let subtitleLabel = UILabel()
            subtitleLabel.text = "Your safe space."
            subtitleLabel.textColor = .secondaryLabel
            subtitleLabel.font = .systemFont(ofSize: 18, weight: .medium)
            subtitleLabel.textAlignment = .center
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            loadingVC.view.addSubview(subtitleLabel)
            
            NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: loadingVC.view.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: loadingVC.view.centerYAnchor, constant: -60),
                imageView.widthAnchor.constraint(equalToConstant: 250),
                imageView.heightAnchor.constraint(equalToConstant: 250),
                
                titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 24),
                titleLabel.centerXAnchor.constraint(equalTo: loadingVC.view.centerXAnchor),
                
                subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
                subtitleLabel.centerXAnchor.constraint(equalTo: loadingVC.view.centerXAnchor)
            ])
            
            // Modern iOS "Breathing" Animation
            imageView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            titleLabel.alpha = 0
            subtitleLabel.alpha = 0
            
            UIView.animate(withDuration: 1.2, delay: 0, options: [.curveEaseInOut, .repeat, .autoreverse], animations: {
                imageView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            }, completion: nil)
            
            UIView.animate(withDuration: 0.8, delay: 0.3, options: .curveEaseOut, animations: {
                titleLabel.alpha = 1
                subtitleLabel.alpha = 1
            }, completion: nil)
            
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
            _ = CommunityManager.shared
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


