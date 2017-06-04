//
//  EmojiPhotoAlertController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/3/17.
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

import Photos
import UIKit

extension UIAlertController {
    
    enum EmojiPhotoChoice {
        case photos, camera, emoji
    }
    
    static let emojiLocalizedString = "Emoji"
    
    class var photosLocalizedString: String {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized, .notDetermined:
            return "Photos"
        case .denied, .restricted:
            return "Photos 🔒"
        }
    }
    
    class var cameraLocalizedString: String {
        switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
        case .authorized, .notDetermined:
            return "Camera"
        case .denied, .restricted:
            return "Camera 🔒"
        }
    }
    
    class func emojiPhotoActionSheet(completionHandler: @escaping (EmojiPhotoChoice) -> Void) -> UIAlertController {
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let emoji = UIAlertAction(title: self.emojiLocalizedString, style: .default) { _ in completionHandler(.emoji) }
        let photo = UIAlertAction(title: self.photosLocalizedString, style: .default) { _ in completionHandler(.photos) }
        let camera = UIAlertAction(title: self.cameraLocalizedString, style: .default) { _ in completionHandler(.camera) }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertVC.addAction(emoji)
        alertVC.addAction(photo)
        alertVC.addAction(camera)
        alertVC.addAction(cancel)
        return alertVC
    }
}
