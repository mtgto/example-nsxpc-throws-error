// SPDX-FileCopyrightText: 2024 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

import Foundation

/// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
class ExampleXpc: NSObject, ExampleXpcProtocol {
    @objc func performNothing() {}

    @objc func performCallback(with reply: @escaping () -> Void) {
        reply()
    }

    /// This implements the example protocol. Replace the body of this class with the implementation of this service's protocol.
    @objc func performCalculation(firstNumber: Int, secondNumber: Int, with reply: @escaping (Int) -> Void) {
        let response = firstNumber + secondNumber
        reply(response)
    }

    @objc func performCalculationAsync(firstNumber: Int, secondNumber: Int) async -> Int {
        return firstNumber + secondNumber
    }

    /// Throws enum Error
    @objc func performThrowsError() async throws {
        throw ExampleXpcError.example
    }

    /// Throws ExampleXpcNSError
    @objc func performThrowsNSError() async throws {
        throw NSError(domain: "net.mtgto.example-nsxpc-throws-error.ExampleXpc", code: 0, userInfo: nil)
    }
}
