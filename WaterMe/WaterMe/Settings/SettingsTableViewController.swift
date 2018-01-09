//
//  SettingsTableViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/1/18.
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

import UIKit

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(SimpleLabelTableViewCell.self, forCellReuseIdentifier: SimpleLabelTableViewCell.reuseID)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Sections(rawValue: section) else { assertionFailure("Wrong Section"); return 0 }
        switch section {
        case .settings:
            return SettingsRows.count
        case .tipJar:
            return TipJarRows.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let (_, row) = Sections.sectionsAndRows(from: indexPath) else { fatalError("Wrong Section/Row") }
        switch row {
        case .left(let row):
            let cell = tableView.dequeueReusableCell(withIdentifier: SimpleLabelTableViewCell.reuseID, for: indexPath)
            if let cell = cell as? SimpleLabelTableViewCell {
                cell.label.attributedText = NSAttributedString(string: row.localizedTitle, style: .selectableTableViewCell)
            }
            return cell
        case .right(let row):
            let cell = tableView.dequeueReusableCell(withIdentifier: SimpleLabelTableViewCell.reuseID, for: indexPath)
            if let cell = cell as? SimpleLabelTableViewCell {
                cell.label.attributedText = NSAttributedString(string: "Hi There", style: .selectableTableViewCell)
            }
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Sections(rawValue: section) else { assertionFailure("Wrong Section"); return nil; }
        return section.localizedTitle
    }

    private enum Sections: Int {
        static let count = 2
        case settings, tipJar
        var localizedTitle: String {
            switch self {
            case .settings:
                return SettingsMainViewController.LocalizedString.title
            case .tipJar:
                return SettingsMainViewController.LocalizedString.sectionTitleTipJar
            }
        }
        static func sectionsAndRows(from indexPath: IndexPath) -> (Sections, Either<SettingsRows, TipJarRows>)? {
            guard let section = Sections(rawValue: indexPath.section) else { assertionFailure("Wrong Section"); return nil; }
            switch section {
            case .settings:
                guard let rows = SettingsRows(rawValue: indexPath.row) else { assertionFailure("Wrong Rows"); return nil; }
                return (section, .left(rows))
            case .tipJar:
                guard let rows = TipJarRows(rawValue: indexPath.row) else { assertionFailure("Wrong Rows"); return nil; }
                return (section, .right(rows))
            }
        }
    }

    private enum SettingsRows: Int {
        static let count = 2
        case openSettings, emailDeveloper
        var localizedTitle: String {
            switch self {
            case .openSettings:
                return SettingsMainViewController.LocalizedString.cellTitleOpenSettings
            case .emailDeveloper:
                return SettingsMainViewController.LocalizedString.cellTitleEmailDeveloper
            }
        }
    }

    private enum TipJarRows: Int {
        static let count = 4
        case free, small, medium, large
    }
}
