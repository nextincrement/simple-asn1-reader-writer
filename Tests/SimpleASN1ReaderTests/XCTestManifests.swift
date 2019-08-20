//
//  XCTestManifests.swift
//  simple-asn1-reader-writer
//
//  Created by nextincrement on 27/07/2019.
//  Copyright © 2019 nextincrement
//

import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
  return [
    testCase(ASN1ReadErrorTests.allTests),
    testCase(SimpleASN1ReaderTests.allTests),
  ]
}
#endif
