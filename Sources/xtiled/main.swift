//
//  main.swift
//  Pelota
//
//  Created on 11/05/2018.
//

import TerminalKit
import Cocoa
import SpriteKit
import TiledKit
import Pelota

var availableCommands = [Command]()

#if os(macOS)
availableCommands.append(
    BlockCommand(name: "test",
                 description: "Tests the specified level",
                 options: [],
                 parameters: [
                    StandardParameter.init("filename", Specification.string(Required.one))
                ]){ (options, parameters) -> ExitCode in        
                    launchMacApp(with: AppDelegate(test: parameters["filename"]![0]))
                    return ExitCode.success
                }
)
#endif

availableCommands.append(InstallCommand())

do {
    try Tool(version: "0.0.1", description: "Tiled ", commands: availableCommands).run([String](CommandLine.arguments.dropFirst()))
} catch ParameterError.notEnough(let of, let expected) {
    print("Expected \(expected) for \(of)")
    exit(EXIT_FAILURE)
} catch {
    print("\(error.localizedDescription)")
}



