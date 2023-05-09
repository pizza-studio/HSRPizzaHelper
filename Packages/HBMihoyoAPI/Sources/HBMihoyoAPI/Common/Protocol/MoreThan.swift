//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/5/9.
//

import Foundation

@propertyWrapper
public struct MoreThan<T: Comparable> {
    // MARK: Lifecycle

    public init(wrappedValue: T, _ moreThan: T) {
        self.projectedValue = wrappedValue
        self.moreThan = moreThan
    }

    // MARK: Public

    public var projectedValue: T

    public let moreThan: T

    public var wrappedValue: T {
        get {
            max(projectedValue, moreThan)
        } set {
            projectedValue = newValue
        }
    }
}
