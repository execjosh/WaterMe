//
//  StyleExtensions.swift
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

import WaterMeData
import UIKit

extension UIButton {
    func style_reminderVesselIconButton() {
        self.titleLabel?.style_emojiDisplayLabel()
        self.setTitle(nil, for: .normal)
        self.isUserInteractionEnabled = false
    }
}

extension UILabel {
    func style_reminderVesselNameLabel() {
        self.adjustsFontForContentSizeCategory = true
        self.font = UIFont.preferredFont(forTextStyle: .title3)
    }
    func style_emojiDisplayLabel() {
        self.font = UIFont.systemFont(ofSize: 60)
        self.lineBreakMode = .byClipping
        self.clipsToBounds = true
    }
}

extension UITextField {
    func style_bodyFontTextField() {
        self.adjustsFontForContentSizeCategory = true
        self.font = UIFont.preferredFont(forTextStyle: .body)
    }
}
