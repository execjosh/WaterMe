//
//  FrameworkExtensions.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/25/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//


extension Sequence {
    func first<T>(of type: T.Type? = nil) -> T? {
        return self.first(where: { $0 is T }) as? T
    }
}
