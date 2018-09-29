//
//  Font.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/20/18.
//  Copyright © 2018 Saturday Apps.
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

enum Font {
    case sectionHeaderBold(Reminder.Section)
    case sectionHeaderRegular(Reminder.Section)
    case selectableTableViewCell
    case selectableTableViewCellDisabled
    case selectableTableViewCellHelper
    case readOnlyTableViewCell
    case textInputTableViewCell
    case migratorTitle
    case migratorSubtitle
    case migratorBody
    case migratorBodySmall
    case migratorPrimaryButton
    case migratorSecondaryButton
    case reminderSummaryCancelButton
    case reminderSummaryActionButton
    case reminderSummaryPrimaryLabel
    case reminderSummaryPrimaryLabelValueNIL
    case reminderSummarySublabel
    case tableHeaderActionButton
    case emojiSuperSmall
    case emojiSmall(accessibilityFontSizeEnabled: Bool)
    case emojiLarge(accessibilityFontSizeEnabled: Bool)
    case reminderVesselDragPreviewViewPrimary
    case reminderVesselDragPreviewViewPrimaryDisabled
    case reminderVesselDragPreviewViewSecondary
    case reminderVesselCollectionViewCellPrimary(UIColor?)
    case reminderVesselCollectionViewCellPrimaryDisabled
    case reminderVesselCollectionViewCellSecondary
    case dragInstructionalText(UIColor)
}

extension Font {
    static let centerStyle: NSParagraphStyle = {
        // swiftlint:disable:next force_cast
        let p = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        p.alignment = .center
        p.lineBreakMode = .byTruncatingMiddle
        // swiftlint:disable:next force_cast
        return p.copy() as! NSParagraphStyle
    }()

    static let truncateMiddleStyle: NSParagraphStyle = {
        // swiftlint:disable:next force_cast
        let p = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        p.lineBreakMode = .byTruncatingMiddle
        // swiftlint:disable:next force_cast
        return p.copy() as! NSParagraphStyle
    }()
}

extension Font {
    var attributes: [NSAttributedStringKey : Any] {
        switch self {
        case .reminderSummaryCancelButton:
            return [
                .font : Font.bodyPlusBold,
                .foregroundColor : Color.tint,
                .paragraphStyle : type(of: self).centerStyle
            ]
        case .reminderSummaryActionButton:
            return [
                .font : Font.bodyPlus,
                .foregroundColor : Color.tint,
                .paragraphStyle : type(of: self).centerStyle
            ]
        case .reminderSummaryPrimaryLabel:
            return [
                .font : Font.body,
                .foregroundColor : Color.textPrimary
            ]
        case .reminderSummaryPrimaryLabelValueNIL:
            return [
                .font : Font.body,
                .foregroundColor : Color.textSecondary
            ]
        case .reminderSummarySublabel:
            return [
                .font : Font.bodyMinusBold,
                .foregroundColor : Color.textSecondary
            ]
        case .migratorTitle:
            return [
                .font : Font.bodyPlusPlusPlus,
                .foregroundColor : Color.textPrimary,
                .paragraphStyle : type(of: self).centerStyle
            ]
        case .migratorSubtitle:
            return [
                .font : Font.bodyPlusBold,
                .foregroundColor : Color.textPrimary,
                .paragraphStyle : type(of: self).centerStyle
            ]
        case .migratorBody:
            return [
                .font : Font.body,
                .foregroundColor : Color.textPrimary
            ]
        case .migratorBodySmall:
            return [
                .font : Font.bodyMinus,
                .foregroundColor : Color.textPrimary
            ]
        case .migratorPrimaryButton:
            return [
                .font : Font.bodyPlusPlus
            ]
        case .migratorSecondaryButton:
            return [
                .font : Font.body
            ]
        case .tableHeaderActionButton:
            return [
                .font : Font.bodyBold,
                .foregroundColor : Color.tint // fixes bug where button is not getting colored automatically
            ]
        case .dragInstructionalText(let color):
            return [
                .font : Font.bodyPlusPlus,
                .foregroundColor : color,
                .paragraphStyle : type(of: self).centerStyle
            ]
        case .reminderVesselCollectionViewCellPrimary(let color):
            return [
                .font : Font.bodyPlus,
                .foregroundColor : color ?? Color.textPrimary,
                .paragraphStyle : type(of: self).centerStyle
            ]
        case .reminderVesselCollectionViewCellPrimaryDisabled:
            return [
                .font : Font.bodyPlus,
                .foregroundColor : Color.textSecondary,
                .paragraphStyle : type(of: self).centerStyle
            ]
        case .reminderVesselDragPreviewViewPrimary:
            return [
                .font : Font.bodyIgnoringDynamicType,
                .foregroundColor : Color.textPrimary
            ]
        case .reminderVesselDragPreviewViewPrimaryDisabled:
            return [
                .font : Font.bodyIgnoringDynamicType,
                .foregroundColor : Color.textSecondary
            ]
        case .emojiSuperSmall:
            return [
                .font : UIFont.systemFont(ofSize: 20)
            ]
        case .emojiSmall(let accessibilityFontSizeEnabled):
            return [
                .font : Font.emojiFont(ofSize: accessibilityFontSizeEnabled ? 50 : 36),
                .baselineOffset : NSNumber(value: accessibilityFontSizeEnabled ? -8 : -4)
            ]
        case .emojiLarge(let accessibilityFontSizeEnabled):
            return [
                .font : Font.emojiFont(ofSize: accessibilityFontSizeEnabled ? 120 : 60),
                .baselineOffset : NSNumber(value: accessibilityFontSizeEnabled ? -10 : -5)
            ]
        case .textInputTableViewCell:
            return [
                .font : Font.body,
                .foregroundColor : Color.textPrimary
            ]
        case .readOnlyTableViewCell:
            return [
                .font : Font.bodyMinus,
                .foregroundColor : Color.textSecondary
            ]
        case .selectableTableViewCell:
            return [
                .font : Font.bodyMinus,
                .foregroundColor : Color.textPrimary
            ]
        case .selectableTableViewCellDisabled:
            return [
                .font : Font.bodyMinus,
                .foregroundColor : Color.textSecondary
            ]
        case .selectableTableViewCellHelper:
            return [
                .font : Font.bodyMinusBold,
                .foregroundColor : Color.textSecondary
            ]
        case .reminderVesselCollectionViewCellSecondary:
            var x = type(of: self).selectableTableViewCell.attributes
            x[.paragraphStyle] = type(of: self).centerStyle
            return x
        case .reminderVesselDragPreviewViewSecondary:
            return [
                .font : Font.bodyMinusIgnoringDynamicType,
                .foregroundColor : Color.textPrimary
            ]
        case .sectionHeaderBold(let section):
            return [
                .font : Font.bodyBold,
                .foregroundColor : Color.color(for: section),
                .paragraphStyle : type(of: self).truncateMiddleStyle
            ]
        case .sectionHeaderRegular(let section):
            return [
                .font : Font.body,
                .foregroundColor : Color.color(for: section),
                .paragraphStyle : type(of: self).truncateMiddleStyle
            ]
        }
    }
}
