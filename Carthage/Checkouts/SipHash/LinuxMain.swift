import XCTest
@testable import SipHashTests
@testable import PrimitiveTypeTests
@testable import SipHashableTests

XCTMain([
          testCase(SipHashTests.allTests),
          testCase(PrimitiveTypeTests.allTests),
          testCase(SipHashableTests.allTests),
])
