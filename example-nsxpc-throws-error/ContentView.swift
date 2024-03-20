// SPDX-FileCopyrightText: 2024 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

import SwiftUI

struct ContentView: View {
    @State var errorResult: String = "Waiting…"
    @State var nserrorResult: String = "Waiting…"

    var body: some View {
        Form {
            Section("Run XPC Call which throws an error defined by enum") {
                Button("Run…") {
                    Task {
                        let service = NSXPCConnection(serviceName: "net.mtgto.example-nsxpc-throws-error.ExampleXpc")
                        service.remoteObjectInterface = NSXPCInterface(with: ExampleXpcProtocol.self)
                        service.resume()
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
                    Task {
                        let service = NSXPCConnection(serviceName: "net.mtgto.example-nsxpc-throws-error.ExampleXpc")
                        service.remoteObjectInterface = NSXPCInterface(with: ExampleXpcProtocol.self)
                        service.resume()
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
