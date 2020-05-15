//
//  ReminderVesselCollection.swift
//  Datum
//
//  Created by Jeffrey Bergier on 2020/05/09.
//  Copyright © 2020 Saturday Apps.
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

import RealmSwift

public class ReminderVesselCollection {
    private let collection: DatumCollection<ReminderVesselWrapper, ReminderVessel, AnyRealmCollection<ReminderVessel>>
    internal init(_ collection: AnyRealmCollection<ReminderVessel>,
                  transform: @escaping (ReminderVessel) -> ReminderVesselWrapper)
    {
        self.collection = .init(collection, transform: transform)
    }
    
    public var count: Int { return self.collection.collection.count }
    public var isInvalidated: Bool { return self.collection.collection.isInvalidated }
    public subscript(index: Int) -> ReminderVesselWrapper { self.collection[index] }
    public func compactMap<E>(_ transform: (ReminderVesselWrapper) throws -> E?) rethrows -> [E] {
        return try self.collection.compactMap(transform)
    }
    public func index(matching predicateFormat: String, _ args: Any...) -> Int? {
        return self.collection.collection.index(matching: predicateFormat, args)
    }
}

public protocol ReminderVesselQuery {
    func observe(_: @escaping (ReminderVesselCollectionChange) -> Void) -> ObservationToken
}

internal class ReminderVesselQueryImp: ReminderVesselQuery {
    private let collection: AnyRealmCollection<ReminderVessel>
    init(_ collection: AnyRealmCollection<ReminderVessel>) {
        self.collection = collection
    }
    func observe(_ block: @escaping (ReminderVesselCollectionChange) -> Void) -> ObservationToken {
        return self.collection.observe { realmChange in
            switch realmChange {
            case .initial(let data):
                block(.initial(data: .init(data, transform: { .init($0) })))
            case .update(_, let deletions, let insertions, let modifications):
                block(.update(insertions: insertions, deletions: deletions, modifications: modifications))
            case .error(let error):
                block(.error(error: error))
            }
        }
    }
}

public enum ReminderVesselChange {
    case error(Error)
    case change(changedDisplayName: Bool, changedIconEmoji: Bool, changedReminders: Bool, changedPointlessBloop: Bool)
    case deleted
}

public enum ReminderVesselCollectionChange {
    case initial(data: ReminderVesselCollection)
    case update(insertions: [Int], deletions: [Int], modifications: [Int])
    case error(error: Error)
}

public protocol ReminderVesselObservable {
    func datum_observe(_ block: @escaping (ReminderVesselChange) -> Void) -> ObservationToken
    func datum_observeReminders(_ block: @escaping (ReminderCollectionChange) -> Void) -> ObservationToken
}

extension ReminderVesselWrapper: ReminderVesselObservable {
    public func datum_observe(_ block: @escaping (ReminderVesselChange) -> Void) -> ObservationToken {
        return self.wrappedObject.observe { realmChange in
            switch realmChange {
            case .error(let error):
                block(.error(error))
            case .change(let properties):
                let changedDisplayName = ReminderVessel.propertyChangesContainDisplayName(properties)
                let changedIconEmoji = ReminderVessel.propertyChangesContainIconEmoji(properties)
                let changedReminders = ReminderVessel.propertyChangesContainReminders(properties)
                let changedPointlessBloop = ReminderVessel.propertyChangesContainPointlessBloop(properties)
                block(.change(changedDisplayName: changedDisplayName,
                              changedIconEmoji: changedIconEmoji,
                              changedReminders: changedReminders,
                              changedPointlessBloop: changedPointlessBloop))
            case .deleted:
                block(.deleted)
            }
        }
    }
    
    public func datum_observeReminders(_ block: @escaping (ReminderCollectionChange) -> Void) -> ObservationToken {
        return self.wrappedObject.reminders.observe { realmChange in
            switch realmChange {
            case .initial(let data):
                block(.initial(data: .init(AnyRealmCollection(data), transform: { ReminderWrapper($0) })))
            case .update(_, let deletions, let insertions, let modifications):
                block(.update(insertions: insertions, deletions: deletions, modifications: modifications))
            case .error(let error):
                block(.error(error: error))
            }
        }
    }
}
