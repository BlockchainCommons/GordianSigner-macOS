//
//  Utilities.swift
//  GordianSigner-macOS
//
//  Created by Peter on 10/15/20.
//  Copyright © 2020 Blockchain Commons. All rights reserved.
//

import Foundation
import Cocoa

public extension Data {
    init<T>(value: T) {
        self = withUnsafePointer(to: value) { (ptr: UnsafePointer<T>) -> Data in
            return Data(buffer: UnsafeBufferPointer(start: ptr, count: 1))
        }
    }

    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.load(as: T.self) }
    }
}

public func setSimpleAlert(message: String, info: String, buttonLabel: String) {
    DispatchQueue.main.async {
        let a = NSAlert()
        a.messageText = message
        a.informativeText = info
        a.addButton(withTitle: buttonLabel)
        a.runModal()
    }
}

public func actionAlert(message: String, info: String, result: @escaping (Bool) -> Void) {
    DispatchQueue.main.async {
        let a = NSAlert()
        a.messageText = message
        a.informativeText = info
        a.addButton(withTitle: "Yes")
        a.addButton(withTitle: "No")
        let response = a.runModal()
        if response == .alertFirstButtonReturn {
            result((true))
        } else {
            result((false))
        }
    }
}

public extension String {
    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
}

extension String {
    var utf8: Data {
        return data(using: .utf8)!
    }
}

extension Data {
    static func random(_ len: Int) -> Data {
        let values = (0 ..< len).map { _ in UInt8.random(in: 0 ... 255) }
        return Data(values)
    }

    var utf8: String {
        String(data: self, encoding: .utf8)!
    }

    var bytes: [UInt8] {
        var b: [UInt8] = []
        b.append(contentsOf: self)
        return b
    }
}

extension Array where Element == UInt8 {
    var data: Data {
        Data(self)
    }
}

extension Notification.Name {
    public static let refreshSigners = Notification.Name(rawValue: "refreshSigners")
}
