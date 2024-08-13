//
//  CourtFinderApp.swift
//  CourtFinder
//
//  Created by Rajat Khare on 7/9/24.
//


import GoogleSignIn
import SwiftUI
import Firebase
import GoogleMaps

@main
struct CourtFinderApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var sessionStore = SessionStore()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if sessionStore.isUserLoggedIn {
                HomePageView()
            } else {
                LoginView()
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let apiKey = dict["GMSApiKey"] as? String {
            GMSServices.provideAPIKey(apiKey)
        }
        return true
    }
}


