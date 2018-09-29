//
//  UserDefaults.swift
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

import UIKit
import Foundation

extension UserDefaults {
    
    enum Constants {
        static let kFirstRun = "FIRST_RUN"
        static let kReminderHour = "REMINDER_HOUR"
        static let kNumberOfReminderDays = "NUMBER_OF_REMINDER_DAYS"
        static let kIncreaseContrast = "INCREASE_CONTRAST"
        static let kBuildNumberKey = "LAST_BUILD_NUMBER"
        static let kRequestReviewDate = "REQUEST_REVIEW_DATE"
        static let kCheckForUpdatesOnLaunch = "CHECK_FOR_UPDATES"
    }

    var checkForUpdatesOnLaunch: Bool {
        get {
            guard let number = self.object(forKey: Constants.kCheckForUpdatesOnLaunch) as? NSNumber
                else { fatalError("Must call configure() before accessing user defaults") }
            return number.boolValue
        }
        set {
            self.set(NSNumber(value: newValue), forKey: Constants.kCheckForUpdatesOnLaunch)
        }
    }

    var requestReviewDate: Date? {
        get {
            return self.object(forKey: Constants.kRequestReviewDate) as? Date
        }
        set {
            self.set(newValue, forKey: Constants.kRequestReviewDate)
        }
    }

    var lastBuildNumber: Int? {
        get {
            return (self.object(forKey: Constants.kBuildNumberKey) as? NSNumber)?.intValue
        }
        set {
            guard let newValue = newValue else {
                self.set(nil, forKey: Constants.kBuildNumberKey)
                return
            }
            self.set(NSNumber(value: newValue), forKey: Constants.kBuildNumberKey)
        }
    }

    var increaseContrast: Bool {
        get {
            guard let number = self.object(forKey: Constants.kIncreaseContrast) as? NSNumber
                else { fatalError("Must call configure() before accessing user defaults") }
            let systemSetting = UIAccessibilityDarkerSystemColorsEnabled()
            if systemSetting == true {
                return systemSetting
            } else {
                return number.boolValue
            }
        }
        set {
            self.set(NSNumber(value: newValue), forKey: Constants.kIncreaseContrast)
        }
    }
    
    var askForNotifications: Bool {
        get {
            guard let number = self.object(forKey: Constants.kFirstRun) as? NSNumber
                else { fatalError("Must call configure() before accessing user defaults") }
            return number.boolValue
        }
        set {
            self.set(NSNumber(value: newValue), forKey: Constants.kFirstRun)
        }
    }
    
    var reminderHour: Int {
        get {
            guard let number = self.object(forKey: Constants.kReminderHour) as? NSNumber
                else { fatalError("Must call configure() before accessing user defaults") }
            return number.intValue
        }
        set {
            self.set(NSNumber(value: newValue), forKey: Constants.kReminderHour)
        }
    }
    
    var reminderDays: Int {
        get {
            guard let number = self.object(forKey: Constants.kNumberOfReminderDays) as? NSNumber
                else { fatalError("Must call configure() before accessing user defaults") }
            return number.intValue
        }
        set {
            self.set(NSNumber(value: newValue), forKey: Constants.kNumberOfReminderDays)
        }
    }
    
    func configure() {
        self.register(defaults: [
            Constants.kFirstRun : true,
            Constants.kReminderHour : 8,
            Constants.kNumberOfReminderDays : 14,
            Constants.kIncreaseContrast : false,
            Constants.kCheckForUpdatesOnLaunch : true
        ])

        // fix bug where this toggle is always off in v1.0 and it needs to be on in 2.0
        let build = self.lastBuildNumber ?? 0
        if build < 201027 {
            self.askForNotifications = true
        }
    }

    // MARK: For KVO only, do not use
    @objc dynamic var INCREASE_CONTRAST: Any { fatalError() }
    @objc dynamic var NUMBER_OF_REMINDER_DAYS: Any { fatalError() }
    @objc dynamic var REMINDER_HOUR: Any { fatalError() }
    @objc dynamic var FIRST_RUN: Any { fatalError() }
}
