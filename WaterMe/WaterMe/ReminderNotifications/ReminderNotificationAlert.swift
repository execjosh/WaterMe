//
//  ReminderNotificationAlert.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/1/18.
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
import UIKit

extension UIAlertController {

    enum PermissionSelection {
        case denied, allowed, cancel
    }

    convenience init?(newPermissionAlertIfNeededPresentedFrom sender: Either<UIBarButtonItem, UIView>?,
                      selectionCompletionHandler selection: ((PermissionSelection) -> Void)?)
    {
        let nc = UNUserNotificationCenter.current()
        let ud = UserDefaults.standard
        let authorizationStatus = nc.settings.authorizationStatus
        let userAskedToBeAsked = ud.userHasRequestedToBeAskedAboutNotificationPermissions
        let style: UIAlertControllerStyle = sender != nil ? .actionSheet : .alert
        switch (authorizationStatus, userAskedToBeAsked) {
        case (.notDetermined, true):
            self.init(newRequestPermissionAlertWithStyle: style, selectionCompletionHandler: selection)
        case (.denied, true):
            self.init(newPermissionDeniedAlertWithStyle: style, selectionCompletionHandler: selection)
        default:
            return nil
        }
        guard let sender = sender else { return }
        switch sender {
        case .left(let bbi):
            self.popoverPresentationController?.barButtonItem = bbi
        case .right(let view):
            self.popoverPresentationController?.sourceView = view
            self.popoverPresentationController?.sourceRect = type(of: self).sourceRect(from: view)
            self.popoverPresentationController?.permittedArrowDirections = [.up, .down]
        }
    }

    private convenience init(newRequestPermissionAlertWithStyle style: UIAlertControllerStyle,
                             selectionCompletionHandler selection: ((PermissionSelection) -> Void)?)
    {
        self.init(title: LocalizedString.newPermissionTitle,
                  message: LocalizedString.newPermissionMessage,
                  preferredStyle: style)
        let yes = UIAlertAction(title: LocalizedString.newPermissionButtonTitleSendNotifications, style: .default) { _ in
            UserDefaults.standard.userHasRequestedToBeAskedAboutNotificationPermissions = true
            UNUserNotificationCenter.current().requestAuthorizationIfNeeded() { permitted in
                switch permitted {
                case true: selection?(.allowed)
                case false: selection?(.denied)
                }
            }
        }
        let no = UIAlertAction(title: LocalizedString.newPermissionButtonTitleDontSendNotifications, style: .destructive) { _ in
            UserDefaults.standard.userHasRequestedToBeAskedAboutNotificationPermissions = false
            selection?(.denied)
        }
        let cancel = UIAlertAction(title: LocalizedString.buttonTitleDismiss, style: .cancel) { _ in
            UserDefaults.standard.userHasRequestedToBeAskedAboutNotificationPermissions = true
            selection?(.cancel)
        }
        self.addAction(yes)
        self.addAction(no)
        self.addAction(cancel)
    }
    private convenience init(newPermissionDeniedAlertWithStyle style: UIAlertControllerStyle,
                             selectionCompletionHandler selection: ((PermissionSelection) -> Void)?)
    {
        self.init(title: LocalizedString.permissionDeniedAlertTitle,
                  message: LocalizedString.permissionDeniedAlertMessage,
                  preferredStyle: style)
        let settings = UIAlertAction(title: LocalizedString.buttonTitleSettings, style: .default) { _ in
            UserDefaults.standard.userHasRequestedToBeAskedAboutNotificationPermissions = true
            UIApplication.shared.openSettings() { _ in
                selection?(.cancel)
            }
        }
        let dontAsk = UIAlertAction(title: LocalizedString.permissionDeniedButtonTitleDontAskAgain, style: .destructive) { _ in
            UserDefaults.standard.userHasRequestedToBeAskedAboutNotificationPermissions = false
            selection?(.denied)
        }
        let cancel = UIAlertAction(title: LocalizedString.buttonTitleDismiss, style: .cancel) { _ in
            UserDefaults.standard.userHasRequestedToBeAskedAboutNotificationPermissions = true
            selection?(.cancel)
        }
        self.addAction(settings)
        self.addAction(dontAsk)
        self.addAction(cancel)
    }
}
