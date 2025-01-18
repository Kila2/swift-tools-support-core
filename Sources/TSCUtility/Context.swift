/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2020 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See http://swift.org/LICENSE.txt for license information
 See http://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

import Foundation
import _Concurrency


public struct Context {
    private var backing: [ObjectIdentifier: Any] = [:]

    public init(dictionaryLiteral keyValuePairs: (ObjectIdentifier, Sendable)...) {
        self.backing = Dictionary(uniqueKeysWithValues: keyValuePairs)
    }

    public subscript<Value>(key: ObjectIdentifier, as type: Value.Type = Value.self) -> Value? where Value: Sendable {
        get {
            return self.backing[key] as? Value
        }
        set {
            self.backing[key] = newValue
        }
    }
}

extension Context {
    public func get<T: Sendable>(_ type: T.Type = T.self) -> T {
        guard let value = self.getOptional(type) else {
            fatalError("no type \(T.self) in context")
        }
        return value
    }

    /// Get the value for the given type, if present.
    public func getOptional<T: Sendable>(_ type: T.Type = T.self) -> T? {
        return self[ObjectIdentifier(T.self)]
    }

    public mutating func set<Value: Sendable>(_ value: Value) {
        self[ObjectIdentifier(Value.self)] = value
    }
}
