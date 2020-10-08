//
//  Loggable+System.swift
//  Calculate
//
//  Created by Jeffrey Bergier on 2020/09/12.
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

import XCGLogger

/// Use this file to make any Type in the system loggable

extension String: LoggableProtocol {}

// Can't extend a protocol to inherit another protocol
extension Error /*: LoggableProtocol */ {
    public func log(in log: XCGLogger? = Loggable.default,
                    as level: XCGLogger.Level = .error,
                    functionName: StaticString = #function,
                    fileName: StaticString = #file,
                    lineNumber: Int = #line,
                    userInfo: [String: Any] = [:])
    {
        LoggableProtocolImp(on: self,
                            in: log,
                            as: level,
                            functionName: functionName,
                            fileName: fileName,
                            lineNumber: lineNumber,
                            userInfo: userInfo)
    }
}
