// SPDX-FileCopyrightText: 2024 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

import SwiftUI

struct ContentView: View {
    @State var nothingResult: String = "Waiting…"
    @State var simpleResult: String = "Waiting…"
    @State var simpleAsyncResult: String = "Waiting…"
    @State var errorResult: String = "Waiting…"
    @State var nserrorResult: String = "Waiting…"

    var body: some View {
        Form {
            Section("Run XPC Call with no argument and no return value") {
                Button("Run…") {
                    nothingResult = "Running…"
                    let service = NSXPCConnection(serviceName: "net.mtgto.example-nsxpc-throws-error.ExampleXpc")
                    service.remoteObjectInterface = NSXPCInterface(with: ExampleXpcProtocol.self)
                    service.activate()
                    guard let proxy = service.remoteObjectProxy as? any ExampleXpcProtocol else { return }
                    defer {
                        service.invalidate()
                    }
                    proxy.performNothing()
                    nothingResult = "Done"
                }
                Text(nothingResult)
            }
            Section("Run XPC Call with two Int arguments and returns Int by callback closure") {
                Button("Run…") {
                    simpleResult = "Running…"
                    let service = NSXPCConnection(serviceName: "net.mtgto.example-nsxpc-throws-error.ExampleXpc")
                    service.remoteObjectInterface = NSXPCInterface(with: ExampleXpcProtocol.self)
                    service.activate()
                    guard let proxy = service.remoteObjectProxy as? any ExampleXpcProtocol else { return }
                    defer {
                        service.invalidate()
                    }
                    proxy.performCalculation(firstNumber: 100, secondNumber: 200) { sum in
                        simpleResult = "SUM: \(sum)"
                    }
                }
                Text(simpleResult)
            }
            Section("Run async XPC Call with two Int arguments and returns Int") {
                Button("Run…") {
                    simpleAsyncResult = "Running…"
                    Task {
                        let service = NSXPCConnection(serviceName: "net.mtgto.example-nsxpc-throws-error.ExampleXpc")
                        service.remoteObjectInterface = NSXPCInterface(with: ExampleXpcProtocol.self)
                        service.activate()
                        guard let proxy = service.remoteObjectProxy as? any ExampleXpcProtocol else { return }
                        defer {
                            service.invalidate()
                        }
                        let sum = await proxy.performCalculation2(firstNumber: 100, secondNumber: 200)
                        simpleAsyncResult = "SUM: \(sum)"
                    }
                }
                Text(simpleAsyncResult)
            }
            Section("Run XPC Call which throws an error defined by enum") {
                Button("Run…") {
                    errorResult = "Running…"
                    Task {
                        let service = NSXPCConnection(serviceName: "net.mtgto.example-nsxpc-throws-error.ExampleXpc")
                        service.remoteObjectInterface = NSXPCInterface(with: ExampleXpcProtocol.self)
                        service.activate()
                        guard let proxy = service.remoteObjectProxy as? any ExampleXpcProtocol else { return }
                        defer {
                            service.invalidate()
                        }
                        do {
                            try await proxy.performThrowsError()
                        } catch {
                            if let error = error as? ExampleXpcError {
                                errorResult = "ExampleXpcError is throwed"
                            } else {
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
                        let service = NSXPCConnection(serviceName: "net.mtgto.example-nsxpc-throws-error.ExampleXpc")
                        service.remoteObjectInterface = NSXPCInterface(with: ExampleXpcProtocol.self)
                        service.activate()
                        guard let proxy = service.remoteObjectProxy as? any ExampleXpcProtocol else { return }
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
}

#Preview {
    ContentView()
}
