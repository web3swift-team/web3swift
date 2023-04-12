//
//  ShellCommandExecutorTest.swift
//
//
//  Created by JeneaVranceanu on 05.04.2023.
//

import Foundation
import XCTest
@testable import Web3Core

final class ShellCommandExecutorTest: XCTestCase {

    func testCommandNotFound() throws {
        let commandName = "some_weird_command"
        do {
            _ = try ShellCommandExecutor().resolve(commandName)
        } catch {
            guard case let .commandNotFound(name) = error as? ShellError else {
                throw error
            }

            XCTAssertEqual(commandName, name)
        }
    }

    func testCommandFound() {
        let commandName = "echo"
        XCTAssertNoThrow(try ShellCommandExecutor().resolve(commandName))
    }

}
