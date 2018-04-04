//
//  RowAndSectionable.swift
//  WaterMeData
//
//  Created by Jeffrey Bergier on 04/04/2018.
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

import Foundation

public protocol ItemAndSectionable {
    var numberOfSections: Int { get }
    func numberOfItems(inSection: Int) -> Int
}

public enum ItemAndSectionSanityCheckFailureReason {
    
    case sectionCountMismatch(lhsSectionCount: Int, rhsSectionCount: Int)
    case modifiedSectionMismatch(section: Int, lhsCount: Int, rhsCount: Int, insCount: Int, delsCount: Int)
    case unmodifiedSectionMismatch(section: Int, lhsCount: Int, rhsCount: Int)

    // this is an attempt to do the sanity check the collectionview does when doing a batch update
    // before doing the batch up. So that we can bail out and just do reloadData
    // to avoid having an exception thrown
    public static func check(lhs: ItemAndSectionable,
                             rhs: ItemAndSectionable,
                             ins: [IndexPath],
                             dels: [IndexPath]) -> ItemAndSectionSanityCheckFailureReason?
    {
        if let sectionCountMismatch = self.checkSectionMismatch(lhs: lhs, rhs: rhs) {
            return sectionCountMismatch
        }
        if let rowCountMismatch = self.verifyEachSection(lhs: lhs, rhs: rhs, ins: ins, dels: dels) {
            return rowCountMismatch
        }
        return nil
    }

    private static func verifyEachSection(lhs: ItemAndSectionable,
                                          rhs: ItemAndSectionable,
                                          ins: [IndexPath],
                                          dels: [IndexPath]) -> ItemAndSectionSanityCheckFailureReason?
    {
        let insCounts = ins.sectionCountDictionary()
        let delsCounts = dels.sectionCountDictionary()
        for section in 0 ..< lhs.numberOfSections {
            let lhsCount = lhs.numberOfItems(inSection: section)
            let rhsCount = rhs.numberOfItems(inSection: section)
            let insCount = insCounts[section, default: 0]
            let delsCount = delsCounts[section, default: 0]
            if insCount + delsCount > 0 {
                let test = lhsCount + insCount - delsCount == rhsCount
                log.debug("Sanity Check: Modified Section: \(section): \(test)")
                if !test {
                    return .modifiedSectionMismatch(section: section,
                                                    lhsCount: lhsCount,
                                                    rhsCount: rhsCount,
                                                    insCount: insCount,
                                                    delsCount: delsCount)
                }
            } else {
                let test = lhsCount == rhsCount
                log.debug("Sanity Check: Unmodified Section: \(section): \(test)")
                if !test {
                    return .unmodifiedSectionMismatch(section: section,
                                                      lhsCount: lhsCount,
                                                      rhsCount: rhsCount)
                }
            }
        }
        return nil
    }

    private static func checkSectionMismatch(lhs: ItemAndSectionable,
                                             rhs: ItemAndSectionable) -> ItemAndSectionSanityCheckFailureReason?
    {
        let lhsSectionCount = lhs.numberOfSections
        let rhsSectionCount = rhs.numberOfSections
        guard lhsSectionCount != rhsSectionCount else { return nil }
        return .sectionCountMismatch(lhsSectionCount: lhsSectionCount, rhsSectionCount: rhsSectionCount)
    }
}

public extension Sequence where Iterator.Element == IndexPath {
    public func sectionCountDictionary() -> [Int : Int] {
        return self.reduce(into: [Int : Int](), { $0[$1.section, default: 0] += 1 })
    }
}
