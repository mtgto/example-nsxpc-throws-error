// SPDX-FileCopyrightText: 2024 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

import Foundation

public enum ExampleXpcError: Error {
    case example
}

public class ExampleXpcNSError: NSError {
}

/// The protocol that this service will vend as its API. This protocol will also need to be visible to the process hosting the service.
@objc protocol ExampleXpcProtocol {
    // No argument, no return value
    func performNothing()
    func performCalculation(firstNumber: Int, secondNumber: Int, with reply: @escaping (Int) -> Void)
    func performCalculation2(firstNumber: Int, secondNumber: Int) async -> Int

    /// Throws enum Error
    func performThrowsError() async throws
    /// Throws NSError
    func performThrowsNSError() async throws
}

/*
 To use the service from an application or other process, use NSXPCConnection to establish a connection to the service by doing something like this:

     connectionToService = NSXPCConnection(serviceName: "net.mtgto.example-nsxpc-throws-error.ExampleXpc")
     connectionToService.remoteObjectInterface = NSXPCInterface(with: ExampleXpcProtocol.self)
     connectionToService.resume()

 Once you have a connection to the service, you can use it like this:

     if let proxy = connectionToService.remoteObjectProxy as? ExampleXpcProtocol {
         proxy.performCalculation(firstNumber: 23, secondNumber: 19) { result in
             NSLog("Result of calculation is: \(result)")
         }
     }

 And, when you are finished with the service, clean up the connection like this:

     connectionToService.invalidate()
*/
