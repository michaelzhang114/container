//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the container project authors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//===----------------------------------------------------------------------===//

import Containerization
import Darwin
import Testing

@testable import ContainerAPIClient

struct ClientProcessTests {
    @Test(arguments: [
        (SIGINT, "INT"),
        (SIGTERM, "TERM"),
        (SIGKILL, "KILL"),
        (SIGWINCH, "WINCH"),
        (SIGUSR1, "USR1"),
        (SIGUSR2, "USR2"),
    ])
    func testSignalName(signal: Int32, expected: String) throws {
        #expect(ClientProcessImpl.signalName(signal) == expected)
    }

    // macOS numbers SIGUSR1/SIGUSR2 as 30/31, but Linux uses 10/12. Linux 30 and 31
    // are SIGPWR and SIGSYS, so sending the raw host number would deliver the wrong signal.
    // Numbers with no macOS name are passed through and parsed as Linux numbers.
    @Test(arguments: [
        (SIGUSR1, Int32(10)),
        (SIGUSR2, Int32(12)),
        (Int32(63), Int32(63)),
    ])
    func testSignalNameMapsToLinuxNumber(signal: Int32, linuxNumber: Int32) throws {
        let name = ClientProcessImpl.signalName(signal)
        #expect(try Signal(name).rawValue == linuxNumber)
    }

    // Numbers with no macOS name (e.g. Linux real-time signals) are passed through
    // unchanged and interpreted as Linux signal numbers.
    @Test(arguments: [
        (Int32(34), "34"),
        (Int32(63), "63"),
        (Int32(100), "100"),
    ])
    func testUnnamedSignalPassesThroughAsNumber(signal: Int32, expected: String) throws {
        #expect(ClientProcessImpl.signalName(signal) == expected)
    }
}
