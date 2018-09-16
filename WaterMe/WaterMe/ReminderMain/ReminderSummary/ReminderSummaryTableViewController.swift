//
//  ReminderSummaryTableViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/4/18.
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

import UIKit
import WaterMeData
import RealmSwift
import Result

protocol ReminderSummaryTableViewControllerDelegate: class {
    var reminderResult: Result<Reminder, RealmError>! { get }
    var isPresentedAsPopover: Bool { get }
    func userChose(action: ReminderSummaryViewController.Action, within: ReminderSummaryTableViewController)
    func userChose(toViewImage image: UIImage, rowDeselectionHandler: @escaping () -> Void, within: ReminderSummaryTableViewController)
}

class ReminderSummaryTableViewController: UITableViewController {

    weak var delegate: ReminderSummaryTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(TransparentTableViewHeaderFooterView.self,
                                forHeaderFooterViewReuseIdentifier: TransparentTableViewHeaderFooterView.reuseID)
        self.tableView.contentInsetAdjustmentBehavior = .always
        self.tableView.tableFooterView = UIView()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.numberOfSections(withNote: self.reminderHasNote)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Sections.numberOfRows(inSection: section, withNote: self.reminderHasNote)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        default:
            return ReminderSummaryViewController.style_tableViewSectionGap
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: TransparentTableViewHeaderFooterView.reuseID)
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let idxPath = self.tableView(tableView, willSelectRowAt: indexPath)
        return idxPath != nil ? true : false
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let section = Sections(indexPath, withNote: self.reminderHasNote)
        switch section {
        case .note, .info:
            return nil
        case .imageEmoji:
            return self.delegate?.reminderResult?.value?.vessel?.icon?.image != nil ? indexPath : nil
        case .actions, .cancel:
            return indexPath
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = Sections(indexPath, withNote: self.reminderHasNote)
        switch section {
        case .note, .info:
            assertionFailure()
        case .imageEmoji:
            __super_hack_dispatchClosureToSolveTableViewSelectionBug() {
                let deselect = {
                    tableView.deselectRow(at: indexPath, animated: true)
                }
                guard let image = self.delegate?.reminderResult?.value?.vessel?.icon?.image else {
                    deselect()
                    return
                }
                self.delegate?.userChose(toViewImage: image, rowDeselectionHandler: deselect, within: self)
            }
        case .actions(let row):
            __super_hack_dispatchClosureToSolveTableViewSelectionBug() {
                switch row {
                case .editReminder:
                    self.delegate?.userChose(action: .editReminder, within: self)
                case .editReminderVessel:
                    self.delegate?.userChose(action: .editReminderVessel, within: self)
                case .performReminder:
                    self.delegate?.userChose(action: .performReminder, within: self)
                }
            }
        case .cancel:
            __super_hack_dispatchClosureToSolveTableViewSelectionBug() {
                self.delegate?.userChose(action: .cancel, within: self)
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = Sections(indexPath, withNote: self.reminderHasNote)
        switch section {
        case .imageEmoji:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReminderVesselIconTableViewCell.reuseID, for: indexPath)
            (cell as? ReminderVesselIconTableViewCell)?.configure(with: self.delegate?.reminderResult.value?.vessel?.icon)
            return cell
        case .info:
            let cell = tableView.dequeueReusableCell(withIdentifier: InfoTableViewCell.reuseIDInfoCell, for: indexPath)
            (cell as? InfoTableViewCell)?.configure(with: self.delegate?.reminderResult?.value)
            return cell
        case .note:
            let cell = tableView.dequeueReusableCell(withIdentifier: InfoTableViewCell.reuseIDNoteCell, for: indexPath)
            (cell as? InfoTableViewCell)?.configure(withNoteString: self.delegate?.reminderResult.value?.note)
            return cell
        case .actions(let row):
            let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.reuseIDActionCell, for: indexPath)
            (cell as? ButtonTableViewCell)?.configure(for: row)
            return cell
        case .cancel:
            let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.reuseIDCancelCell, for: indexPath)
            (cell as? ButtonTableViewCell)?.configureAsCancelButton()
            return cell
        }
    }

    // TODO: Fix super hack - Maybe file a radar?
    private func __super_hack_dispatchClosureToSolveTableViewSelectionBug(_ closure: @escaping () -> Void) {
        DispatchQueue.main.async(execute: closure)
    }
}

extension ReminderSummaryTableViewController {

    var reminderHasNote: Bool {
        return self.delegate?.reminderResult.value?.note != nil
    }

    enum Sections {
        case imageEmoji
        case info
        case note
        case actions(ActionRows)
        case cancel

        static func numberOfSections(withNote: Bool) -> Int {
            return withNote ? 5 : 4
        }
        static func numberOfRows(inSection section: Int, withNote: Bool) -> Int {
            let value = Sections(IndexPath(row: 0, section: section), withNote: withNote)
            switch value {
            case .imageEmoji, .note, .cancel, .info:
                return 1
            case .actions(let rows):
                return type(of: rows).allCases.count
            }
        }

        // swiftlint:disable:next cyclomatic_complexity
        init(_ indexPath: IndexPath, withNote: Bool) {
            if withNote {
                switch (indexPath.section, indexPath.row) {
                case (0, _):
                    self = .imageEmoji
                case (1, _):
                    self = .info
                case (2, _):
                    self = .note
                case (3, _):
                    self = .actions(ActionRows(rawValue: indexPath.row)!)
                case (4, _):
                    self = .cancel
                default:
                    fatalError()
                }
            } else {
                switch (indexPath.section, indexPath.row) {
                case (0, _):
                    self = .imageEmoji
                case (1, _):
                    self = .info
                case (2, _):
                    self = .actions(ActionRows(rawValue: indexPath.row)!)
                case (3, _):
                    self = .cancel
                default:
                    fatalError()
                }
            }
        }
    }

    enum ActionRows: Int, CaseIterable {
        case performReminder, editReminder, editReminderVessel
    }

    enum InfoRows: Int, CaseIterable {
        case reminderVesselName, reminderKind, lastPerformedDate, nextPerformDate
    }
}
