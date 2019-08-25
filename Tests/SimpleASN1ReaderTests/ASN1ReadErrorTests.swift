//
//  ASN1ReadErrorTests.swift
//  simple-asn1-reader-writer
//
//  Created by nextincrement on 27/07/2019.
//  Copyright © 2019 nextincrement
//

import XCTest
import SimpleASN1Reader

class ASN1ReadErrorTests: XCTestCase {

  func testErrorDescription_invalidIdentifier() {
    let error = ASN1ReadError.invalidIdentifier(
      expectedIdentifier: 0x30,
      actualIdentifier: 0x02,
      atPosition: 2,
      ofEncoding: [0x30, 0x03, 0x02, 0x01, 0x07]
    )

    let errorDescription = error.errorDescription

    XCTAssertEqual("""
      Invalid identifier: expectedIdentifier: 30, actualIdentifier: 02, atPosition: 2, \
      ofEncoding: 30 03 02 01 07 \

      """, errorDescription
    )
  }

  func testErrorDescription_invalidBytes() {
    let error = ASN1ReadError.invalidBytes(
      expectedBytes: [0x05, 0x00],
      actualBytes: [0x02, 0x01, 0x07],
      atPosition: 2,
      ofEncoding: [0x30, 0x03, 0x02, 0x01, 0x07]
    )

    let errorDescription = error.errorDescription

    XCTAssertEqual("""
      Invalid bytes: expectedBytes: 05 00 , actualBytes: 02 01 07 , atPosition: 2, \
      ofEncoding: 30 03 02 01 07 \

      """, errorDescription
    )
  }

  func testErrorDescription_invalidLength() {
    let error = ASN1ReadError.invalidLength(
      minimumRemainingBytes: 1,
      forReading: "Content bytes",
      actualRemainingBytes: 0,
      atPosition: 1,
      ofEncoding: [0x30, 0x01]
    )

    let errorDescription = error.errorDescription

    XCTAssertEqual("""
      Invalid length: minimumRemainingBytes: 1, actualRemainingBytes: 0, \
      forReading: Content bytes, atPosition: 1, ofEncoding: 30 01 \

      """, errorDescription
    )
  }

  func testErrorDescription_unsupportedFirstContentsByte() {
    let error = ASN1ReadError.unsupportedFirstContentsByte(
      actualByte: 0x06,
      atPosition: 2,
      ofEncoding: [0x03, 0x04, 0x06, 0x6e, 0x5d, 0xc0]
    )

    let errorDescription = error.errorDescription

    XCTAssertEqual("""
    Unsupported first contents byte: expectedByte: 00, actualByte: 06, atPosition: 2, \
    ofEncoding: 03 04 06 6e 5d c0 \

    """, errorDescription
    )
  }

  func testErrorDescription_indefiniteLengthNotSupported() {
    let error = ASN1ReadError.indefiniteLengthNotSupported(atPosition: 1)
    let errorDescription = error.errorDescription

    XCTAssertEqual("Indefinite length not supported: atPosition: 1", errorDescription)
  }

  static var allTests = [
    ("testErrorDescription_invalidIdentifier", testErrorDescription_invalidIdentifier),
    ("testErrorDescription_invalidBytes", testErrorDescription_invalidBytes),
    ("testErrorDescription_unsupportedFirstContentsByte",
      testErrorDescription_unsupportedFirstContentsByte),
    ("testErrorDescription_invalidLength", testErrorDescription_invalidLength),
    ("testErrorDescription_indefiniteLengthNotSupported",
      testErrorDescription_indefiniteLengthNotSupported
    ),
  ]
}
