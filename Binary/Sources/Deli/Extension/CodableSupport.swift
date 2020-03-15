//
//  CodableSupport.swift
//  Deli
//
//  Inspired by https://gist.github.com/mikebuss/17142624da4baf9cdcc337861e256533
//

import Foundation

private struct JSONCodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}

extension KeyedDecodingContainer {
    func decode(_ type: [String: Any].Type, forKey key: K) throws -> [String: Any] {
        let container = try nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        return try container.decode(type)
    }

    func decode(_ type: [Any].Type, forKey key: K) throws -> [Any] {
        var container = try nestedUnkeyedContainer(forKey: key)
        return try container.decode(type)
    }

    func decode(_ type: [String: Any].Type) throws -> [String: Any] {
        var dictionary = [String: Any]()

        for key in allKeys {
            if let boolValue = try? decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = boolValue
            } else if let stringValue = try? decode(String.self, forKey: key) {
                dictionary[key.stringValue] = stringValue
            } else if let intValue = try? decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = intValue
            } else if let doubleValue = try? decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = doubleValue
            } else if let nestedDictionary = try? decode([String: Any].self, forKey: key) {
                dictionary[key.stringValue] = nestedDictionary
            } else if let nestedArray = try? decode([Any].self, forKey: key) {
                dictionary[key.stringValue] = nestedArray
            }
        }
        return dictionary
    }

    func decodeIfPresent(_ type: [String: Any].Type, forKey key: K) throws -> [String: Any]? {
        guard contains(key) else { return nil }
        return try decode(type, forKey: key)
    }

    func decodeIfPresent(_ type: [Any].Type, forKey key: K) throws -> [Any]? {
        guard contains(key) else { return nil }
        return try decode(type, forKey: key)
    }
}

extension UnkeyedDecodingContainer {
    mutating func decode(_ type: [Any].Type) throws -> [Any] {
        var array: [Any] = []
        while !isAtEnd {
            if let value = try? decode(Bool.self) {
                array.append(value)
            } else if let value = try? decode(Int.self) {
                array.append(value)
            } else if let value = try? decode(Double.self) {
                array.append(value)
            } else if let value = try? decode(String.self) {
                array.append(value)
            } else if let nestedDictionary = try? decode([String: Any].self) {
                array.append(nestedDictionary)
            } else if let nestedArray = try? decode([Any].self) {
                array.append(nestedArray)
            }
        }
        return array
    }

    mutating func decode(_ type: [String: Any].Type) throws -> [String: Any] {
        let container = try nestedContainer(keyedBy: JSONCodingKeys.self)
        return try container.decode(type)
    }
}

extension KeyedEncodingContainerProtocol where Key == JSONCodingKeys {
    mutating func encodeJSONDictionary(_ value: [String: Any]) throws {
        try value.forEach { (key, value) in
            guard let key = JSONCodingKeys(stringValue: key) else { return }
            switch value {
            case let value as Bool:
                try encode(value, forKey: key)
            case let value as Int:
                try encode(value, forKey: key)
            case let value as String:
                try encode(value, forKey: key)
            case let value as Double:
                try encode(value, forKey: key)
            case let value as [String: Any]:
                try encode(value, forKey: key)
            case let value as [Any]:
                try encode(value, forKey: key)
            case is NSNull:
                try encodeNil(forKey: key)
            case Optional<Any>.none:
                try encodeNil(forKey: key)
            default:
                throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath + [key], debugDescription: "Invalid JSON value"))
            }
        }
    }
}

extension KeyedEncodingContainerProtocol {
    mutating func encode(_ value: [String: Any], forKey key: Key) throws {
        var container = nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        try container.encodeJSONDictionary(value)
    }

    mutating func encode(_ value: [String: Any]?, forKey key: Key) throws {
        guard let value = value else { return }
        var container = nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        try container.encodeJSONDictionary(value)
    }

    mutating func encodeIfPresent(_ value: [String: Any]?, forKey key: Key) throws {
        guard let value = value else { return }
        try encode(value, forKey: key)
    }

    mutating func encode(_ value: [Any], forKey key: Key) throws {
        var container = nestedUnkeyedContainer(forKey: key)
        try container.encodeJSONArray(value)
    }

    mutating func encode(_ value: [Any]?, forKey key: Key) throws {
        guard let value = value else { return }
        var container = nestedUnkeyedContainer(forKey: key)
        try container.encodeJSONArray(value)
    }

    mutating func encodeIfPresent(_ value: [Any]?, forKey key: Key) throws {
        guard let value = value else { return }
        try encode(value, forKey: key)
    }
}

extension UnkeyedEncodingContainer {
    mutating func encode(_ value: [String: Any]) throws {
        var container = nestedContainer(keyedBy: JSONCodingKeys.self)
        try container.encodeJSONDictionary(value)
    }

    mutating func encode(_ value: [Any]) throws {
        var container = nestedUnkeyedContainer()
        try container.encodeJSONArray(value)
    }

    mutating func encodeJSONArray(_ value: [Any]) throws {
        try value.enumerated().forEach { (index, value) in
            switch value {
            case let value as Bool:
                try encode(value)
            case let value as Int:
                try encode(value)
            case let value as String:
                try encode(value)
            case let value as Double:
                try encode(value)
            case let value as [String: Any]:
                try encode(value)
            case let value as [Any]:
                try encode(value)
            case is NSNull:
                try encodeNil()
            case Optional<Any>.none:
                try encodeNil()
            default:
                let keys = JSONCodingKeys(intValue: index).map { [$0] } ?? []
                throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath + keys, debugDescription: "Invalid JSON value"))
            }
        }
    }

    mutating func encodeJSONDictionary(_ value: [String: Any]) throws {
        var container = nestedContainer(keyedBy: JSONCodingKeys.self)
        try container.encodeJSONDictionary(value)
    }
}
