//
//  ReminderVesselEditViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/2/17.
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
//  along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit

class ReminderVesselEditViewController: UIViewController {
    
    class func newVC() -> UIViewController {
        let sb = UIStoryboard(name: "ReminderVesselEdit", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let navVC = sb.instantiateInitialViewController() as! UINavigationController
        // swiftlint:disable:next force_cast
        _ = navVC.viewControllers.first as! ReminderVesselEditViewController
        return navVC
    }
    
    /*@IBOutlet*/ private weak var tableViewController: ReminderVesselEditTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "New Plant"
        
        self.tableViewController = self.childViewControllers.first()
        self.tableViewController?.choosePhotoTapped = { [weak self] in self?.presentEmojiPhotoActionSheet() }
        self.tableViewController?.displayNameChanged = { [unowned self] newValue in
            log.debug(newValue)
        }
    }
    
    @IBAction private func cancelButtonTapped(_ sender: NSObject?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func saveButtonTapped(_ sender: NSObject?) {
        log.debug()
    }
    
    private func presentEmojiPhotoActionSheet() {
        let vc = UIAlertController.emojiPhotoActionSheet() { choice in
            switch choice {
            case .camera:
                break
            case .photos:
                let vc = UIImagePickerController()
                self.present(vc, animated: true, completion: nil)
            case .emoji:
                let vc = EmojiPickerViewController.newVC() { emoji, vc in
                    vc.dismiss(animated: true, completion: nil)
                    guard let emoji = emoji else { return }
                    self.tableViewController?.editable.icon = .emoji(emoji)
                    self.tableViewController?.tableView.reloadData()
                }
                self.present(vc, animated: true, completion: nil)
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    deinit {
        log.debug()
    }
}

import Photos

extension UIImagePickerController {
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
    
    
}

extension UIAlertController {
    
    enum EmojiPhotoChoice {
        case photos, camera, emoji
    }
    
    class func emojiPhotoActionSheet(completionHandler: @escaping (EmojiPhotoChoice) -> Void) -> UIAlertController {
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let emoji = UIAlertAction(title: "Emoji", style: .default) { _ in completionHandler(.emoji) }
        let photo = UIAlertAction(title: UIImagePickerController.photosLocalizedString, style: .default) { _ in completionHandler(.photos) }
        let camera = UIAlertAction(title: UIImagePickerController.cameraLocalizedString, style: .default) { _ in completionHandler(.camera) }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertVC.addAction(emoji)
        alertVC.addAction(photo)
        alertVC.addAction(camera)
        alertVC.addAction(cancel)
        return alertVC
    }
}
