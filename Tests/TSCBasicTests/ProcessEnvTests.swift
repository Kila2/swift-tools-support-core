/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2014 - 2017 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See http://swift.org/LICENSE.txt for license information
 See http://swift.org/CONTRIBUTORS.txt for Swift project authors
 */

import Foundation
import XCTest

import TSCBasic
import TSCTestSupport

class ProcessEnvTests: XCTestCase {
    func testEnvVars() throws {
        let key: ProcessEnvironmentKey = "SWIFTPM_TEST_FOO"
        XCTAssertEqual(ProcessEnv.block[key], nil)
        try ProcessEnv.setVar(key.value, value: "BAR")
        XCTAssertEqual(ProcessEnv.block[key], "BAR")
        try ProcessEnv.unsetVar(key.value)
        XCTAssertEqual(ProcessEnv.block[key], nil)
    }

    func testChdir() throws {
        try testWithTemporaryDirectory { tmpdir in
            let path = try resolveSymlinks(tmpdir)
            try ProcessEnv.chdir(path)
            XCTAssertEqual(ProcessEnv.cwd, path)
        }
    }

    func testWithCustomEnv() throws {
        enum CustomEnvError: Swift.Error {
            case someError
        }

        let key: ProcessEnvironmentKey = "XCTEST_TEST"
        let value = "TEST"
        XCTAssertNil(ProcessEnv.block[key])
        try withCustomEnv([key: value]) {
            XCTAssertEqual(value, ProcessEnv.block[key])
        }
        XCTAssertNil(ProcessEnv.block[key])
        do {
            try withCustomEnv([key: value]) {
                XCTAssertEqual(value, ProcessEnv.block[key])
                throw CustomEnvError.someError
            }
        } catch CustomEnvError.someError {
        } catch {
            XCTFail("Incorrect error thrown")
        }
        XCTAssertNil(ProcessEnv.block[key])
    }

    func testEnvironmentKeys() throws {
        XCTAssertEqual(ProcessEnvironmentKey("Key"), "Key")
        #if os(Windows)
        XCTAssertEqual(ProcessEnvironmentKey("Key"), "KEY")
        #else
        XCTAssertNotEqual(ProcessEnvironmentKey("Key"), "KEY")
        #endif
    }

    func testEnvironmentKeysCodable() throws {
        let encoder = JSONEncoder()
        let json = try encoder.encode(ProcessEnvironmentKey("foo"))
        XCTAssertEqual(String(decoding: json, as: UTF8.self), #""foo""#)

        let decoder = JSONDecoder()
        let result = try decoder.decode(ProcessEnvironmentKey.self, from: json)
        XCTAssertEqual(result, ProcessEnvironmentKey("foo"))
    }
}
