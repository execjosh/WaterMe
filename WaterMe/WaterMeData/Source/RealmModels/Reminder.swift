//
//  Reminder.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/31/17.
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

import Result
import RealmSwift
import Foundation

public class Reminder: Object {

    public enum Section: Int, CaseIterable {
        case late, today, tomorrow, thisWeek, later
    }
    
    public static let minimumInterval: Int = 1
    public static let maximumInterval: Int = 180
    public static let defaultInterval: Int = 7
    
    public enum Kind: Hashable {
        case water, fertilize, trim, mist, move(location: String?), other(description: String?)
        public static let count = 6
    }
    
    // MARK: Public Interface
    public var kind: Kind {
        get { return self.kindValue }
        set { self.update(with: newValue) }
    }
    @objc public private(set) dynamic var uuid = UUID().uuidString
    @objc public internal(set) dynamic var interval = Reminder.defaultInterval
    @objc public internal(set) dynamic var note: String?
    @objc public internal(set) dynamic var nextPerformDate: Date?
    public let performed = List<ReminderPerform>()
    public var vessel: ReminderVessel? { return self.vessels.first }
    
    // MARK: Implementation Details
    @objc internal dynamic var kindString: String = Reminder.kCaseWaterValue
    @objc internal dynamic var descriptionString: String?
    @objc internal dynamic var bloop = false
    internal let vessels = LinkingObjects(fromType: ReminderVessel.self, property: "reminders") //#keyPath(ReminderVessel.reminders)

    public override class func primaryKey() -> String {
        return #keyPath(Reminder.uuid)
    }

    internal func recalculateNextPerformDate(comparisonPerform: ReminderPerform? = nil) {
        if let lastPerform = comparisonPerform ?? self.performed.last {
            self.nextPerformDate = lastPerform.date + TimeInterval(self.interval * 24 * 60 * 60)
        } else {
            self.nextPerformDate = nil
        }
    }
}

public class ReminderPerform: Object {
    @objc public internal(set) dynamic var date = Date()
    @objc internal dynamic var bloop = false
}

fileprivate extension Reminder {
    
    fileprivate static let kCaseWaterValue = "kReminderKindCaseWaterValue"
    fileprivate static let kCaseTrimValue = "kReminderKindCaseTrimValue"
    fileprivate static let kCaseMistValue = "kReminderKindCaseMistValue"
    fileprivate static let kCaseFertilizeValue = "kReminderKindCaseFertilizeValue"
    fileprivate static let kCaseMoveValue = "kReminderKindCaseMoveValue"
    fileprivate static let kCaseOtherValue = "kReminderKindCaseOtherValue"
    
    fileprivate func update(with kind: Reminder.Kind) {
        switch kind {
        case .water:
            self.kindString = type(of: self).kCaseWaterValue
        case .fertilize:
            self.kindString = type(of: self).kCaseFertilizeValue
        case .trim:
            self.kindString = type(of: self).kCaseTrimValue
        case .mist:
            self.kindString = type(of: self).kCaseMistValue
        case .move(let location):
            self.kindString = type(of: self).kCaseMoveValue
            self.descriptionString = location?.nonEmptyString
        case .other(let description):
            self.kindString = type(of: self).kCaseOtherValue
            self.descriptionString = description?.nonEmptyString
        }
    }
    
    fileprivate var kindValue: Reminder.Kind {
        switch self.kindString {
        case type(of: self).kCaseWaterValue:
            return .water
        case type(of: self).kCaseFertilizeValue:
            return .fertilize
        case type(of: self).kCaseTrimValue:
            return .trim
        case type(of: self).kCaseMistValue:
            return .mist
        case type(of: self).kCaseMoveValue:
            let description = self.descriptionString?.nonEmptyString
            return .move(location: description)
        case type(of: self).kCaseOtherValue:
            let description = self.descriptionString?.nonEmptyString
            return .other(description: description)
        default:
            fatalError("Reminder.Kind: Invalid Case String Key")
        }
    }
}

extension Reminder: ModelCompleteCheckable {

    public var isModelComplete: ModelCompleteError? {
        switch self.kind {
        case .fertilize, .water, .trim, .mist:
            return nil
        case .move(let description):
            return description?.nonEmptyString == nil ?
                ModelCompleteError(_actions: [.reminderMissingMoveLocation, .cancel, .saveAnyway])
                : nil
        case .other(let description):
            return description?.nonEmptyString == nil ?
                ModelCompleteError(_actions: [.reminderMissingOtherDescription, .cancel, .saveAnyway])
                : nil
        }
    }
}

public extension Reminder {
    public struct Identifier: UUIDRepresentable, Hashable {
        public var reminderIdentifier: String
        public init(reminder: Reminder) {
            self.reminderIdentifier = reminder.uuid
        }
        public init(rawValue: String) {
            self.reminderIdentifier = rawValue
        }
        public var uuid: String { return self.reminderIdentifier }
    }
}

public extension Reminder {
    public enum SortOrder {
        case nextPerformDate, interval, kind, note

        internal var keyPath: String {
            switch self {
            case .interval:
                return #keyPath(Reminder.interval)
            case .kind:
                return #keyPath(Reminder.kindString)
            case .nextPerformDate:
                return #keyPath(Reminder.nextPerformDate)
            case .note:
                return #keyPath(Reminder.note)
            }
        }
    }
}
