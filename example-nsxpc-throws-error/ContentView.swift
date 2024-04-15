// SPDX-FileCopyrightText: 2024 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

import SwiftUI

struct ContentView: View {
    let service = NSXPCConnection(serviceName: "net.mtgto.example-nsxpc-throws-error.ExampleXpc")
    @State var nothingResult: String = "Waiting…"
    @State var callbackResult: String = "Waiting…"
    @State var simpleResult: String = "Waiting…"
    @State var simpleAsyncNothingResult: String = "Waiting…"
    @State var simpleAsyncResult: String = "Waiting…"
    @State var errorResult: String = "Waiting…"
    @State var nserrorResult: String = "Waiting…"

    var body: some View {
        Form {
            Section("Run XPC Call with no argument and no return value") {
                Button("Run…") {
                    nothingResult = "Running…"
                    guard let proxy = proxy() else { return }
                    proxy.performNothing()
                    nothingResult = "Done"
                }
                Text(nothingResult)
            }
            Section("Run XPC Call with no argument and no return value using callback") {
                Button("Run…") {
                    callbackResult = "Running…"
                    guard let proxy = proxy() else { return }
                    proxy.performCallback {
                        callbackResult = "Done"
                    }
                }
                Text(callbackResult)
            }
            Section("Run XPC Call with two Int arguments and returns Int by callback closure") {
                Button("Run…") {
                    simpleResult = "Running…"
                    guard let proxy = proxy() else { return }
                    proxy.performCalculation(firstNumber: 100, secondNumber: 200) { sum in
                        simpleResult = "SUM: \(sum)"
                    }
                }
                Text(simpleResult)
            }
            Section("Run async XPC Call with no argument and no return value") {
                Button("Run…") {
                    simpleAsyncNothingResult = "Running…"
                    Task {
                        guard let proxy = proxy() else { return }
                        await proxy.performNothingAsync()
                        simpleAsyncNothingResult = "Done"
                    }
                }
                Text(simpleAsyncNothingResult)
            }
            Section("Run async XPC Call with two Int arguments and returns Int") {
                Button("Run…") {
                    simpleAsyncResult = "Running…"
                    Task {
                        guard let proxy = proxy() else { return }
                        let sum = await proxy.performCalculationAsync(firstNumber: 100, secondNumber: 200)
                        simpleAsyncResult = "SUM: \(sum)"
                    }
                }
                Text(simpleAsyncResult)
            }
            Section("Run XPC Call which throws an error defined by enum") {
                Button("Run…") {
                    errorResult = "Running…"
                    Task {
                        guard let proxy = proxy() else { return }
                        do {
                            try await proxy.performThrowsError()
                        } catch {
                            if let error = error as? ExampleXpcError {
                                errorResult = "ExampleXpcError is throwed"
                            } else {
                                let nserror = error as NSError
                                print("domain = \(nserror.domain), code = \(nserror.code), userInfo = \(nserror.userInfo)")
                                errorResult = "Unknown Error is throwed"
                            }
                        }
                    }
                }
                Text(errorResult)
            }

            Section("Run XPC Call which throws an NSError") {
                Button("Run…") {
                    nserrorResult = "Running…"
                    Task {
                        guard let proxy = proxy() else { return }
                        defer {
                            service.invalidate()
                        }
                        do {
                            try await proxy.performThrowsNSError()
                        } catch {
                            if let error = error as? NSError {
                                nserrorResult = "NSError is throwed"
                            } else {
                                nserrorResult = "Unknown Error is throwed"
                            }
                        }
                    }
                }
                Text(nserrorResult)
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    func proxy() -> ExampleXpcProtocol? {
        service.remoteObjectInterface = NSXPCInterface(with: ExampleXpcProtocol.self)
        service.activate()
        return service.remoteObjectProxyWithErrorHandler { error in
            print("Error: \(error)")
        } as? any ExampleXpcProtocol
    }
}

#Preview {
    ContentView()
}
