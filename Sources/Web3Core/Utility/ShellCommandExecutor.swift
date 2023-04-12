//
//  ShellCommandExecutor.swift
//
//  Created by JeneaVranceanu on 05.04.2023.
//

import Foundation

internal typealias ShellCommandExecutor = BashCommandExecutor

internal enum ShellError: Error {
    case commandNotFound(name: String)
}

internal struct BashCommandExecutor {
    func run(commandName: String, arguments: [String] = []) throws -> String {
        var arguments = arguments
        var command = commandName
        if commandName.contains(" ") {
            var args = commandName.trim().split(separator: " ")
            command = String(args.removeFirst())
            arguments.append(contentsOf: args.map { String($0) })
        }
        return try run(resolve(command), with: arguments)
    }

    func run(commandName: String, arguments: [String] = []) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            do {
                continuation.resume(returning: try run(commandName: commandName, arguments: arguments))
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }


    func resolve(_ command: String) throws -> String {
#if os(Windows)
        // TODO: add a check to make sure command exists on Windows
        return command
#else
        let shellCommand = try run("/bin/bash",
                                   with: ["-l", "-c", "which \(command)"])
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !shellCommand.isEmpty else {
            throw ShellError.commandNotFound(name: command)
        }
        return shellCommand
#endif
    }

    func run(_ command: String, with arguments: [String] = []) throws -> String {
        let process = Process()
        process.launchPath = command
        process.arguments = arguments
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        try process.run()
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(bytes: outputData, encoding: .utf8)?.trim() else {
            throw Web3Error.valueError(desc: "Shell command returned bytes that cannot be decoded as UTF-8: \(outputData.toHexString())")
        }
        return output
    }
}
