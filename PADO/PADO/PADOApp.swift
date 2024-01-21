//
//  PADOApp.swift
//  PADO
//
//  Created by 최동호 on 1/2/24.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // MARK: - 사용자에게 알림 권한을 요청하고, 알림 타입(알림, 배지, 소리)을 설정
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in }
            )
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        // MARK: - 원격 알림을 위해 앱을 등록
        application.registerForRemoteNotifications()
        
        // MARK: - firebase Messaging Delegate 설정
        Messaging.messaging().delegate = self // Firebase 메시징 서비스의 대리자(delegate)를 현재의 AppDelegate 객체로 설정
        
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    // MARK: - 디바이스 토큰 등록(APNS로부터 디바이스 토큰을 받고, Firebase 메시징 서비스에 등록)
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}


// MARK: - Firebase 메시징 토큰을 받았을 때 호출, 이 토큰은 Firebase를 통해 특정 디바이스로 푸시 알림을 보낼 때 사용
extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }
}

// MARK: - 앱이 실행 중일 때 알림이 도착했을 때 호출
extension AppDelegate : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        
        print("willPresent: userInfo: ", userInfo)
        
        completionHandler([.banner, .sound, .badge])
        
        // Notification 분기처리
        if userInfo[AnyHashable("PADO")] as? String == "project" {
            print("It is PADO")
        }else {
            print("NOTHING")
        }
        
    }
    
    // MARK: - 사용자가 알림에 응답했을 때 호출, 예를 들어 사용자가 알림을 탭했을 때 이 메소드가 실행
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
         print("didReceive: userInfo: ", userInfo)
        completionHandler()
    }
    
    // MARK: - 원격 알림 수신 처리
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
        return .noData
    }
}

@main
struct PADOApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
