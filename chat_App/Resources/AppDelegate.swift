//
//  AppDelegate.swift
//  chat_App
//
//  Created by JoSoJeong on 2021/02/05.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
          
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )

        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self
        return true
    }
          
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {

        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        return GIDSignIn.sharedInstance().handle(url)

    }

    //google signin
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            if let error = error {
                print("failed to sign in with google : \(error)")
            }
        return
        }
        guard let user = user else {
            return
        }
        print("did sign in with google : \(user)")
        
        guard let  email = user.profile.email,
              let firstName = user.profile.givenName,
              let lastName = user.profile.familyName else {
            return
        }
        UserDefaults.standard.set(email, forKey: "email")
        
        DatabaseManager.shared.userExits(with: email, completion: { exists in
            if !exists {
                //insert to database
                DatabaseManager.shared.insertUSer(with: chatAppUSer(firstName: firstName, lastName: lastName, emailAddress: email), completion: {success in
                    if success {
                        print("app image load")
                    }
                })
            }
        })
        
        guard let authentication = user.authentication else {
            print("missing auth object off of google user")
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
         
        FirebaseAuth.Auth.auth().signIn(with: credential, completion: {authResult, error in
            guard authResult != nil, error == nil else{
                print("failed to log in with google credential")
                return
            }
            print("successfully signed in with Google cred")
            NotificationCenter.default.post(name: .didLogInNotification, object: nil)
        })
        
        
    }
    
    
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("google user was disconnected")
    }
    
    
}
    

