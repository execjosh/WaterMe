//
//  AppDelegate.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/7/17.
//  Copyright © 2017 Saturday Apps.
//
//  This file is part of WaterMe.  Simple Plant Watering Reminders for iOS.
//
//  WaterMe is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  WaterMe is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with WaterMe.  If not, see <http://www.gnu.org/licenses/>.
//

import WaterMeStore
import WaterMeData
import XCGLogger
import UserNotifications
import AVFoundation
import StoreKit
import UIKit

let log = XCGLogger.default

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // swiftlint:disable:next force_cast
    class var shared: AppDelegate { return UIApplication.shared.delegate as! AppDelegate }

    // swiftlint:disable:next weak_delegate
    private let notificationUIDelegate = ReminderNotificationUIDelegate()
    private(set) var reminderObserver: GlobalReminderObserver?

    let purchaseController = PurchaseController()
    var coreDataMigrator = CoreDataMigrator()
    var window: UIWindow?
    var userDefaultObserverTokens: [NSKeyValueObservation] = []

    private var rootVC: ReminderMainViewController? {
        let navVC = self.window?.rootViewController as? UINavigationController
        let vc = navVC?.viewControllers.first as? ReminderMainViewController
        assert(vc != nil)
        return vc
    }

    override init() {
        super.init()

        // configure logging
        #if DEBUG
        log.setup(level: .debug, showLogIdentifier: false, showFunctionName: true, showThreadName: true, showLevel: true, showFileNames: false, showLineNumbers: false, showDate: true, writeToFile: false, fileLevel: .debug)
        #else
        log.setup(level: .warning, showLogIdentifier: false, showFunctionName: true, showThreadName: true, showLevel: true, showFileNames: false, showLineNumbers: false, showDate: true, writeToFile: false, fileLevel: .warning)
        #endif

        // configure main thread checking
        DispatchQueue.configureMainQueue()
        
        // as early as possible, configure standard defaults
        UserDefaults.standard.configure()

        // make re-usable closures for notifications I'll register for later
        let appearanceChanges = {
            // if the window is not configured yet, bail
            guard let window = self.window else { return }

            // need to rip the view hierarchy out of the window and put it back in
            // in order for the new UIAppearance to take effect
            UIApplication.style_configure()
            let prevVC = window.rootViewController
            window.rootViewController = nil
            window.rootViewController = prevVC
        }
        let notificationChanges = {
            self.reminderObserver?.notificationPermissionsMayHaveChanged()
        }
        // register for notifications about the increase contrast setting
        _ = NotificationCenter.default.addObserver(forName: .UIAccessibilityDarkerSystemColorsStatusDidChange,
                                                   object: nil,
                                                   queue: nil)
        { _ in
            appearanceChanges()
        }
        // register for notifications if user defaults change while the app is running
        let token1 = UserDefaults.standard.observe(\.INCREASE_CONTRAST) { _, _ in
            appearanceChanges()
        }
        let token2 = UserDefaults.standard.observe(\.REMINDER_HOUR) { _, _ in
            notificationChanges()
        }
        let token3 = UserDefaults.standard.observe(\.NUMBER_OF_REMINDER_DAYS) { _, _ in
            notificationChanges()
        }
        let token4 = UserDefaults.standard.observe(\.FIRST_RUN) { _, _ in
            notificationChanges()
        }
        self.userDefaultObserverTokens += [token1, token2, token3, token4]
    }
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {

        // see if there is a new build
        _ = {
            // check the build and see if its new
            let ud = UserDefaults.standard
            let oldBuild = ud.lastBuildNumber
            let currentBuild = Bundle.main.buildNumber
            if oldBuild != currentBuild {
                ud.lastBuildNumber = currentBuild
                ud.requestReviewDate = Date()
            }
        }()

        // Basic Controller error handling closure
        // There is no easy way for my Dynamic Frameworks to be able to use Crashlytics
        // So in the places where they can throw errors, I introduced a static var so we can see them here
        BasicController.errorThrown = { error in
            log.error(error)
            Analytics.log(error: error)
        }

        // configure my notification delegate
        UNUserNotificationCenter.current().delegate = self.notificationUIDelegate

        // style the app with UIAppearance methods
        UIApplication.style_configure()

        // Configure audio so the water video does not pause the users music
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)

        let result = BasicController.new(of: .local)
        let vc = ReminderMainViewController.newVC(basicRCResult: result, proController: nil)
        if case .success(let basicRC) = result {
            self.reminderObserver = GlobalReminderObserver(basicController: basicRC)
        }

        // When a new build is detected, we set a date
        // Two weeks after that date, the user is eligible to be asked for a review
        // Next time they water plants, they will be asked (assuming the system cooperates)
        result.value?.userDidPerformReminder = {
            let now = Date()
            let ud = UserDefaults.standard
            guard
                let reviewDate = ud.requestReviewDate,
                let forwardDate = Calendar.current.date(byAdding: .weekOfMonth,
                                                        value: 2,
                                                        to: reviewDate),
                now >= forwardDate
            else { return }
            log.info("Requested App Review with SKStoreReviewController")
            Analytics.log(event: Analytics.Event.reviewRequested)
            SKStoreReviewController.requestReview()
            ud.requestReviewDate = nil // nil this out so they won't be asked again until next update
        }

        // configure window
        let window = self.window ?? UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = .white
        window.rootViewController = vc

        // show window
        self.window = window
        window.makeKeyAndVisible()
        
        return true
    }

    func application(_ application: UIApplication,
                     willContinueUserActivityWithType userActivityType: String) -> Bool
    {
        guard RawUserActivity(rawValue: userActivityType) != nil else {
            return false
        }
        return true
    }

    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping NSUserActivityContinuedHandler) -> Bool
    {
        let result: UserActivityResult
            = userActivity.restoredUserActivityResult
                .bimap(success: { UserActivityToContinue(activity: $0, completion: restorationHandler) },
                       failure: { UserActivityToFail(error: $0, completion: restorationHandler) })
        self.rootVC?.userActivityResultToContinue += [result]
        let isReady = self.rootVC?.isReady ?? []
        guard isReady.completely else { return true }
        self.rootVC?.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
        return true
    }

    func application(_ application: UIApplication,
                     didFailToContinueUserActivityWithType userActivityType: String,
                     error: Error)
    {
        let error = error as NSError
        guard error.code != NSUserCancelledError else {
            return
        }
        let result: UserActivityResult
            = .failure(UserActivityToFail(error: .continuationFailed, completion: nil))
        self.rootVC?.userActivityResultToContinue += [result]
        let isReady = self.rootVC?.isReady ?? []
        guard isReady.completely else { return }
        self.rootVC?.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
    }
    
    func application(_ application: UIApplication,
                     shouldSaveApplicationState coder: NSCoder) -> Bool
    {
        return true
    }
    
    func application(_ application: UIApplication,
                     shouldRestoreApplicationState coder: NSCoder) -> Bool
    {
        let _savedBuild = coder.decodeObject(forKey: UIApplicationStateRestorationBundleVersionKey) as? String
        let _currentBuild = Bundle(for: type(of: self)).infoDictionary?[kCFBundleVersionKey as String] as? String
        guard
            let savedBuild = _savedBuild,
            let currentBuild = _currentBuild,
            currentBuild == savedBuild
        else { return false }
        return true
    }
}
