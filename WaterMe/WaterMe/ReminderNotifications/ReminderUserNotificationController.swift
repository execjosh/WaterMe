//
//  ReminderUserNotificationController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 03/11/17.
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

import UserNotifications

class ReminderUserNotificationController {

    private let taskName = String(describing: ReminderUserNotificationController.self) + "_SerialQueue_" + UUID().uuidString
    private lazy var queue = DispatchQueue(label: taskName, qos: .utility)
    private var backgroundTaskID: UIBackgroundTaskIdentifier?

    func perform(with values: [ReminderAndVesselValue]) {
        // make sure there isn't already a background task in progress
        guard self.backgroundTaskID == nil else {
            Analytics.log(event: Analytics.NotificationPermission.scheduleAlreadyInProgress)
            return
        }
        // tell the OS I'm running a background task
        self.backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: self.taskName,
                                                                         expirationHandler: nil)
        // hop on a background queue to do the processing
        self.queue.async {
            // clear out all the old stuff before making new stuff
            let center = UNUserNotificationCenter.current()
            center.removeAllDeliveredNotifications()
            center.removeAllPendingNotificationRequests()

            // make sure we have data to work with before continuing
            guard values.isEmpty == false else {
                log.debug("Reminder array was empty")
                return
            }

            // make sure we're authorized to send notifications
            guard center.notificationAuthorizationStatus.boolValue else {
                log.info("User has turned System notification toggle off")
                Analytics.log(event: Analytics.NotificationPermission.scheduleDeniedBySystem)
                return
            }
            // generate notification object requests
            let requests = type(of: self).notificationRequests(from: values)
            Analytics.log(event: Analytics.NotificationPermission.scheduleSucceeded,
                          extras: Analytics.NotificationPermission.extras(forCount: requests.count))
            guard requests.isEmpty == false else {
                log.debug("No notifications to schedule")
                return
            }
            // ask the notification center to schedule the notifications
            for request in requests {
                center.add(request) { error in
                    guard let error = error else { return }
                    log.error(error)
                    Analytics.log(error: error)
                }
            }
            log.debug("Scheduled Notifications: \(requests.count)")

            // tell the OS I'm done with the background task
            guard let id = self.backgroundTaskID else { return }
            self.backgroundTaskID = nil
            UIApplication.shared.endBackgroundTask(id)
        }
    }

    private class func notificationRequests(from values: [ReminderAndVesselValue]) -> [UNNotificationRequest] {
        // make sure we have data to work with
        guard values.isEmpty == false else { return [] }

        // get preference values for reminder time and number of days to remind for
        let reminderHour = UserDefaults.standard.reminderHour
        let reminderDays = UserDefaults.standard.reminderDays

        // get some constants we'll use throughout
        let calendar = Calendar.current
        let now = Date()

        // find the last reminder time and how many days away it is
        let numberOfDaysToLastReminder = values.last?.reminder.nextPerformDate.map() { endDate -> Int in
            return calendar.numberOfDaysBetween(startDate: now, endDate: endDate)
        }
        // add that to the number of extra days the user requested
        let totalReminderDays = (numberOfDaysToLastReminder ?? 0) + reminderDays

        // loop through the number of days the user wants to be reminded for
        // get all reminders that happened on or before the end of the day of `futureReminderTime`
        let matches = (0 ..< totalReminderDays).compactMap() { i -> (Date, [ReminderAndVesselValue])? in
            let testDate = calendar.date(byAdding: .day, value: i, to: now)!
            let endOfDayInTestDate = calendar.endOfDay(for: testDate)
            let matches = values.filter() { value -> Bool in
                let endOfDayInNextPerformDate = calendar.endOfDay(for: value.reminder.nextPerformDate ?? now)
                return endOfDayInNextPerformDate <= endOfDayInTestDate
            }
            guard matches.isEmpty == false else { return nil }
            let reminderTimeInSameDayAsTestDate = calendar.dateWithExact(hour: reminderHour, onSameDayAs: testDate)
            return (reminderTimeInSameDayAsTestDate, matches)
        }

        // convert the matches into one notification each
        // this makes it so the user only gets 1 notification per day at the time they requested
        let reminders = matches.compactMap() { reminderTime, matches -> UNNotificationRequest? in
            // if the interval is less 0 or less, we don't want to schedule a notification
            // all that needs to happen in this case is the badge icon get updated, and that can be done elsewhere
            let interval = reminderTime.timeIntervalSince(now)
            guard interval > 0 else { return nil }

            // construct the notification
            let _content = UNMutableNotificationContent()
            let dateComponents = calendar.userNotificationCompatibleDateComponents(with: reminderTime)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

            // crash in debug if this doesn't match my expectations
            assert(trigger.nextTriggerDate() == reminderTime)

            // shuffle the names so that different plant names show in the notifications
            let plantNames = ReminderAndVesselValue.uniqueParentPlantNames(from: matches).shuffled()

            // only set the body if there is a trigger. this way a notification won't be shown to the user
            // only the badge will update.
            _content.body = ReminderUserNotificationController.LocalizedString.localizedNotificationBody(from: plantNames)
            _content.sound = .default()
            _content.badge = NSNumber(value: matches.count)

            // swiftlint:disable:next force_cast
            let content = _content.copy() as! UNNotificationContent
            let request = UNNotificationRequest(identifier: reminderTime.description, content: content, trigger: trigger)

            return request
        }

        // done!
        return reminders
    }
}

import WaterMeData

fileprivate extension ReminderUserNotificationController.LocalizedString {
    fileprivate static func localizedNotificationBody(from items: [String?]) -> String {
        switch items.count {
        case 1:
            let item1 = items[0] ?? ReminderVessel.LocalizedString.untitledPlant
            let string = String(format: self.bodyOneItem, item1)
            return string
        case 2:
            let item1 = items[0] ?? ReminderVessel.LocalizedString.untitledPlant
            let item2 = items[1] ?? ReminderVessel.LocalizedString.untitledPlant
            let string = String(format: self.bodyTwoItems, item1, item2)
            return string
        default:
            let item1 = items[0] ?? ReminderVessel.LocalizedString.untitledPlant
            let string = String(format: self.bodyManyItems, item1, items.count - 1)
            return string
        }
    }
}
