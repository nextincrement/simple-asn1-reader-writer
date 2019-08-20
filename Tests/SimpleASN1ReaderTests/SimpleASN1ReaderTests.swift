//
//  SimpleASN1ReaderTests.swift
//  simple-asn1-reader-writer
//
//  Created by nextincrement on 27/07/2019.
//  Copyright © 2019 nextincrement
//

import XCTest

import SimpleASN1Reader

class SimpleASN1ReaderTests: XCTestCase {

  private let derEncoding: [UInt8] = [0x30, 0x08, 0x05, 0x00, 0x03, 0x04, 0x00, 0x02, 0x01,
    0x07]

  // BER encoding representing the same data as the DER encoding above (first length byte = 0x81)
  private let berEncoding: [UInt8] = [0x30, 0x81, 0x08, 0x05, 0x00, 0x03, 0x04, 0x00, 0x02, 0x01,
    0x07]

  private let derEncoding_bitString: [UInt8] = [0x03, 0x02, 0x00, 0x01]
  private let derEncoding_noLengthBytes: [UInt8] = [0x03]
  private let derEncoding_noContentsBytes: [UInt8] = [0x03, 0x08, 0x00]
  private let derEncoding_bitStringHasUnexpectedFirstByte: [UInt8] = [0x03, 0x04, 0x01, 0x02, 0x01,
    0x06]
  private let derEncoding_octedString: [UInt8] = [0x04, 0x01, 0x01]
  private let derEncoding_indefiniteLength: [UInt8] = [0x30, 0x80]

  func testCombinedMethodsToReadBitString_derEncoding() throws {

    // Prepare test
    let simpleASN1Reader = SimpleASN1Reader(derEncoding)

    // Call methods under tests
    try simpleASN1Reader.skipIdentifierAndLength(expectedIdentifier: 0x30)
    try simpleASN1Reader.skipBytes(matching: [0x05, 0x00])
    let contents = try simpleASN1Reader.readContentsOfBitString()

    // Check result
    XCTAssertEqual([0x02, 0x01, 0x07], contents)
  }

  func testCombinedMethodsToReadBitString_berEncoding() throws {

    // Prepare test
    let simpleASN1Reader = SimpleASN1Reader(berEncoding)

    // Call methods under test
    try simpleASN1Reader.skipIdentifierAndLength(expectedIdentifier: 0x30)
    try simpleASN1Reader.skipBytes(matching: [0x05, 0x00])
    let contents = try simpleASN1Reader.readContentsOfBitString()

    // Check result
    XCTAssertEqual([0x02, 0x01, 0x07], contents)
  }

  func testGetReaderForContents() throws {

    // Prepare test
    let simpleASN1Reader = SimpleASN1Reader(derEncoding)

    // Call method under test
    let subSimpleASN1Reading: SimpleASN1Reading = try simpleASN1Reader.getReaderForContents()

    // Check result
    try subSimpleASN1Reading.skipBytes(matching: [0x05, 0x00, 0x03, 0x04, 0x00, 0x02, 0x01, 0x07])
  }

  func testGetReaderForContents_identifiedBy() throws {

    // Prepare test
    let simpleASN1Reader = SimpleASN1Reader(derEncoding)

    // Call method under test
    let subSimpleASN1Reading: SimpleASN1Reading = try simpleASN1Reader.getReaderForContents(
      identifiedBy: 0x30
    )

    // Check result
    try subSimpleASN1Reading.skipBytes(matching: [0x05, 0x00, 0x03, 0x04, 0x00, 0x02, 0x01, 0x07])
  }

  func testReadAheadIdentifier() throws {

    // Prepare test
    let simpleASN1Reader = SimpleASN1Reader(derEncoding)

    // Call method under test
    let identifier = try simpleASN1Reader.peek()

    // Check result
    XCTAssertEqual(0x30, identifier)

    // Also verify that the pointer (currentIndex) has not been moved
    try simpleASN1Reader.skipBytes(matching: [0x30, 0x08, 0x05, 0x00, 0x03, 0x04, 0x00, 0x02, 0x01,
      0x07])
  }

  func testReadAheadIdentifier_noMoreComponentsLeft() throws {

    // Prepare test
    let simpleASN1Reader = SimpleASN1Reader(derEncoding)

    try simpleASN1Reader.skipBytes(matching: [0x30, 0x08, 0x05, 0x00, 0x03, 0x04, 0x00, 0x02, 0x01,
      0x07])

    // Call method under test
    let identifier = try simpleASN1Reader.peek()

    // Check result
    XCTAssertEqual(0x00, identifier)
  }

  func testReadContents() throws {

    // Prepare test
    let simpleASN1Reader = SimpleASN1Reader(derEncoding)
    try simpleASN1Reader.skipIdentifierAndLength(expectedIdentifier: 0x30)
    try simpleASN1Reader.skipBytes(matching: [0x05, 0x00])

    // Call method under test
    let contents = try simpleASN1Reader.readContents()

    // Check result
    XCTAssertEqual([0x00, 0x02, 0x01, 0x07], contents)
  }

  func testReadContents_identifiedBy() throws {

    // Prepare test
    let simpleASN1Reader = SimpleASN1Reader(derEncoding)
    try simpleASN1Reader.skipIdentifierAndLength(expectedIdentifier: 0x30)
    try simpleASN1Reader.skipBytes(matching: [0x05, 0x00])

    // Call method under test
    let contents = try simpleASN1Reader.readContents(identifiedBy: 0x03)

    // Check result
    XCTAssertEqual([0x00, 0x02, 0x01, 0x07], contents)
  }

  func testReadContents_zeroBytes() throws {

    // Prepare test
    let simpleASN1Reader = SimpleASN1Reader(derEncoding)
    try simpleASN1Reader.skipIdentifierAndLength(expectedIdentifier: 0x30)

    // Call method under test
    let contents = try simpleASN1Reader.readContents(identifiedBy: 0x05)

    // Check result
    XCTAssertEqual([], contents)
  }

  func testSkipIdentifierAndLength() throws {

    // Prepare test
    let simpleASN1Reader = SimpleASN1Reader(derEncoding)

    // Call method under test
    try simpleASN1Reader.skipIdentifierAndLength()

    // Check result
    try simpleASN1Reader.skipBytes(matching: [0x05, 0x00, 0x03, 0x04, 0x00, 0x02, 0x01, 0x07])
  }

  func testSkipIdentifierAndLength_expectedIdentifier() throws {

    // Prepare test
    let simpleASN1Reader = SimpleASN1Reader(derEncoding)

    // Call method under test
    try simpleASN1Reader.skipIdentifierAndLength(expectedIdentifier: 0x30)

    // Check result
    try simpleASN1Reader.skipBytes(matching: [0x05, 0x00, 0x03, 0x04, 0x00, 0x02, 0x01, 0x07])
  }

  func testSkipComponent() throws {

    // Prepare test
    let simpleASN1Reader = SimpleASN1Reader(derEncoding)
    try simpleASN1Reader.skipIdentifierAndLength(expectedIdentifier: 0x30)

    // Call method under test
    try simpleASN1Reader.skipComponent()

    // Check result
    let contents = try simpleASN1Reader.readContents(identifiedBy: 0x03)

    XCTAssertEqual([0x00, 0x02, 0x01, 0x07], contents)
  }

  func testSkipComponent_identifiedBy() throws {

    // Prepare test
    let simpleASN1Reader = SimpleASN1Reader(derEncoding)
    try simpleASN1Reader.skipIdentifierAndLength(expectedIdentifier: 0x30)

    // Call method under test
    try simpleASN1Reader.skipComponent(identifiedBy: 0x05)

    // Check result
    let contents = try simpleASN1Reader.readContents(identifiedBy: 0x03)

    XCTAssertEqual([0x00, 0x02, 0x01, 0x07], contents)
  }

  func testSkipBytes() throws {

    // Prepare test
    let simpleASN1Reader = SimpleASN1Reader(derEncoding)
    try simpleASN1Reader.skipIdentifierAndLength(expectedIdentifier: 0x30)

    // Call method under test
    try simpleASN1Reader.skipBytes(matching: [0x05, 0x00, 0x03, 0x04, 0x00, 0x02, 0x01, 0x07])

    // Check result
    let identifier = try simpleASN1Reader.peek()

    XCTAssertEqual(0x00, identifier)
  }

  // MARK: - Testing boundary conditions when reading length field

  // Note that tests for boundary conditions when reading the length field are really whitebox tests
  // since it is assumed that all other methods read this field the same way.
  func testReadContents_127_bytes() throws {

    // Prepare test
    let contents127: [UInt8] = Array(repeating: 0x00, count: 127)
    let sequence = insert([0x30, 0x7F], atTheBeginningOf: contents127)
    let simpleASN1Reader = SimpleASN1Reader(sequence)

    // Call method under test
    let contents = try simpleASN1Reader.readContents()

    // Check result
    XCTAssertEqual(contents127, contents)
  }

  func testReadContents_128_bytes() throws {

    // Prepare test
    let contents128: [UInt8] = Array(repeating: 0x00, count: 128)
    let sequence = insert([0x30, 0x81, 0x80], atTheBeginningOf: contents128)
    let simpleASN1Reader = SimpleASN1Reader(sequence)

    // Call method under test
    let contents = try simpleASN1Reader.readContents()

    // Check result
    XCTAssertEqual(contents128, contents)
  }

  // MARK: - Testing errors thrown if unexpected identifier or bytes

  func testGetReaderForContents_invalidIdentifier() throws {

    // Prepare test
    let simpleASN1Reader = SimpleASN1Reader(derEncoding)

    // Run test
    try testInvalidIdentifier (
      try simpleASN1Reader.getReaderForContents(identifiedBy: 0x31)
    )
  }

  func testReadContents_invalidIdentifier() throws {

    // Prepare test
    let simpleASN1Reader = SimpleASN1Reader(derEncoding)

    // Run test
    try testInvalidIdentifier (try simpleASN1Reader.readContents(identifiedBy: 0x31))
  }

  func testReadContentsOfBitString_invalidIdentifier() throws {

    // Prepare test
    let simpleASN1Reader = SimpleASN1Reader(derEncoding_octedString)
    var thrownError: Error?

    // Call method under test
    XCTAssertThrowsError(try simpleASN1Reader.readContentsOfBitString()) { thrownError = $0 }

    // Check thrown error
    XCTAssertTrue(thrownError is ASN1ReadError, "Unexpected error type: \(type(of: thrownError))")

    let expectedError = ASN1ReadError.invalidIdentifier(
      expectedIdentifier: 0x03,
      actualIdentifier: 0x04,
      atPosition: 0,
      ofEncoding: derEncoding_octedString
    )
    XCTAssertEqual(thrownError as? ASN1ReadError, expectedError)
  }

  func testReadContentsOfBitString_unsupportedFirstContentsByte() throws {

    // Prepare test
    let simpleASN1Reader = SimpleASN1Reader(
      derEncoding_bitStringHasUnexpectedFirstByte
    )
    var thrownError: Error?

    // Call method under test
    XCTAssertThrowsError(
      try simpleASN1Reader.readContentsOfBitString()
    ) { thrownError = $0 }

    // Check thrown error
    XCTAssertTrue(thrownError is ASN1ReadError, "Unexpected error type: \(type(of: thrownError))")

    let expectedError = ASN1ReadError.unsupportedFirstContentsByte(
      actualByte: 0x01,
      atPosition: 2,
      ofEncoding: derEncoding_bitStringHasUnexpectedFirstByte
    )

    XCTAssertEqual(thrownError as? ASN1ReadError, expectedError)
  }

  func testSkipIdentifierAndLength_invalidIdentifier() throws {

    // Prepare test
    let simpleASN1Reader = SimpleASN1Reader(derEncoding)

    // Run test
    try testInvalidIdentifier (
      try simpleASN1Reader.skipIdentifierAndLength(expectedIdentifier: 0x31)
    )
  }

  func testSkipComponent_invalidIdentifier() throws {

    // Prepare test
    let simpleASN1Reader = SimpleASN1Reader(derEncoding)

    // Run test
    try testInvalidIdentifier (try simpleASN1Reader.skipComponent(identifiedBy: 0x31))
  }

  func testSkipBytes_invalidBytes() throws {

    // Prepare test
    let simpleASN1Reader = SimpleASN1Reader(derEncoding)
    var thrownError: Error?

    // Call method under test
    XCTAssertThrowsError(
      try simpleASN1Reader.skipBytes(matching: [0x31, 0x08])
    ) { thrownError = $0 }

    // Check thrown error
    XCTAssertTrue(thrownError is ASN1ReadError, "Unexpected error type: \(type(of: thrownError))")

    let expectedError = ASN1ReadError.invalidBytes(
      expectedBytes: [0x31, 0x08],
      actualBytes: [0x30, 0x08],
      atPosition: 0,
      ofEncoding: derEncoding
    )

    XCTAssertEqual(thrownError as? ASN1ReadError, expectedError)
  }

  // MARK: - Testing errors thrown if invalid length

  func testGetReaderForContents_invalidLength_1() throws {

    // Prepare test
    let simpleASN1Reader = SimpleASN1Reader(derEncoding_noLengthBytes)

    // Run test
    try testInvalidLength_noLengthBytes(
      try simpleASN1Reader.getReaderForContents()
    )
  }

  func testGetReaderForContents_invalidLength_2() throws {

    // Prepare test
    let simpleASN1Reader = SimpleASN1Reader(derEncoding_noLengthBytes)

    // Run test
    try testInvalidLength_noLengthBytes(
      try simpleASN1Reader.getReaderForContents(identifiedBy: 0x03)
    )
  }

  func testReadContents_invalidLength_1() throws {

    // Prepare test
    let simpleASN1Reader = SimpleASN1Reader(derEncoding_noLengthBytes)

    // Run test
    try testInvalidLength_noLengthBytes( try simpleASN1Reader.readContents() )
  }

  func testReadContents_invalidLength_2() throws {

    // Prepare test
    let simpleASN1Reader = SimpleASN1Reader(derEncoding_noContentsBytes)

    // Run test
    try testInvalidLength_noContentsBytes(
      try simpleASN1Reader.readContents(identifiedBy: 0x03)
    )
  }

  func testReadContentsOfBitString_invalidLength_1() throws {

    // Prepare test
    let simpleASN1Reader = SimpleASN1Reader(derEncoding_noLengthBytes)

    // Run test
    try testInvalidLength_noLengthBytes(
      try simpleASN1Reader.readContentsOfBitString()
    )
  }

  func testReadContentsOfBitString_invalidLength_2() throws {

    // Prepare test
    let simpleASN1Reader = SimpleASN1Reader(derEncoding_noContentsBytes)
    var thrownError: Error?

    // Call method under test
    XCTAssertThrowsError(try simpleASN1Reader.readContentsOfBitString()) { thrownError = $0 }

    // Check thrown error
    XCTAssertTrue(thrownError is ASN1ReadError, "Unexpected error type: \(type(of: thrownError))")

    let expectedError = ASN1ReadError.invalidLength(
      minimumRemainingBytes: 7,
      forReading: "Contents bytes",
      actualRemainingBytes: 0,
      atPosition: 3,
      ofEncoding: derEncoding_noContentsBytes
    )
    XCTAssertEqual(thrownError as? ASN1ReadError, expectedError)
  }

  func testSkipIdentifierAndLength_invalidLength_1() throws {

    // Prepare test
    let simpleASN1Reader = SimpleASN1Reader(derEncoding_noLengthBytes)

    // Run test
    try testInvalidLength_noLengthBytes(
      try simpleASN1Reader.skipIdentifierAndLength(expectedIdentifier: 0x03)
    )
  }

  func testSkipIdentifierAndLength_invalidLength_2() throws {

    // Prepare test
    let simpleASN1Reader = SimpleASN1Reader(derEncoding_noContentsBytes)

    // Run test
    try testInvalidLength_noContentsBytes(
      try simpleASN1Reader.skipIdentifierAndLength()
    )
  }

  func testSkipComponent_invalidLength_1() throws {

    // Prepare test
    let simpleASN1Reader = SimpleASN1Reader(derEncoding_noLengthBytes)

    // Run test
    try testInvalidLength_noLengthBytes(
      try simpleASN1Reader.skipComponent(identifiedBy: 0x03)
    )
  }

  func testSkipComponent_invalidLength_2() throws {

    // Prepare test
    let simpleASN1Reader = SimpleASN1Reader(derEncoding_noContentsBytes)

    // Run test
    try testInvalidLength_noContentsBytes(
      try simpleASN1Reader.skipComponent()
    )
  }

  func testSkipBytes_invalidLength() throws {
    let simpleASN1Reader = SimpleASN1Reader(derEncoding_noLengthBytes)
    var thrownError: Error?

    // Call method under test
    XCTAssertThrowsError(
      try simpleASN1Reader.skipBytes(matching: [0x30, 0x08])
    ) { thrownError = $0 }

    // Check thrown error
    XCTAssertTrue(thrownError is ASN1ReadError, "Unexpected error type: \(type(of: thrownError))")

    let expectedError = ASN1ReadError.invalidLength(
      minimumRemainingBytes: 2,
      forReading: "Bytes",
      actualRemainingBytes: 1,
      atPosition: 0,
      ofEncoding: derEncoding_noLengthBytes
    )
    XCTAssertEqual(thrownError as? ASN1ReadError, expectedError)
  }

  // MARK: - Tests for indefiniteLengthNotSupported error

  // Note that this is the only test for this generic type of error. This is deemed acurate enough
  // for now since we are dealing with a rather unlikely scenario here.
  func testReadContents_indefiniteLength() throws {
    let simpleASN1Reader = SimpleASN1Reader(derEncoding_indefiniteLength)
    var thrownError: Error?

    // Call method under test
    XCTAssertThrowsError(
      try simpleASN1Reader.readContents(identifiedBy: 0x30)
    ) { thrownError = $0 }

    // Check thrown error
    XCTAssertTrue(thrownError is ASN1ReadError, "Unexpected error type: \(type(of: thrownError))")

    XCTAssertEqual(
      thrownError as? ASN1ReadError,
      ASN1ReadError.indefiniteLengthNotSupported (atPosition: 1)
    )
  }

  // MARK: - Private helper functions

  private func insert(_ addedBytes: [UInt8], atTheBeginningOf bytes: [UInt8]) -> [UInt8] {
    var concatenatedBytes = bytes
    concatenatedBytes.insert(contentsOf: addedBytes, at: 0)
    return concatenatedBytes
  }

  // Tests error if identifier 0x31 is expected at first position of derEncoding
  private func testInvalidIdentifier(_ functionUnderTest:  @autoclosure () throws -> Any) throws {
    var thrownError: Error?

    // Call method under test
    XCTAssertThrowsError(try functionUnderTest()) { thrownError = $0 }

    // Check thrown error
    XCTAssertTrue(thrownError is ASN1ReadError, "Unexpected error type: \(type(of: thrownError))")

    let expectedError = ASN1ReadError.invalidIdentifier(
      expectedIdentifier: 0x31,
      actualIdentifier: 0x30,
      atPosition: 0,
      ofEncoding: derEncoding
    )
    XCTAssertEqual(thrownError as? ASN1ReadError, expectedError)
  }

  // Tests error if length is too short for reading length bytes
  private func testInvalidLength_noLengthBytes(
    _ functionUnderTest:  @autoclosure () throws -> Any
  ) throws {

    var thrownError: Error?

    // Call method under test
    XCTAssertThrowsError(try functionUnderTest()) { thrownError = $0 }

    // Check thrown error
    XCTAssertTrue(thrownError is ASN1ReadError, "Unexpected error type: \(type(of: thrownError))")

    let expectedError = ASN1ReadError.invalidLength(
      minimumRemainingBytes: 1,
      forReading: "First byte of length field",
      actualRemainingBytes: 0,
      atPosition: 1,
      ofEncoding: derEncoding_noLengthBytes
    )
    XCTAssertEqual(thrownError as? ASN1ReadError, expectedError)
  }

  // Tests thrown error if length is too short for reading contents bytes
  private func testInvalidLength_noContentsBytes(
    _ functionUnderTest:  @autoclosure () throws -> Any
  ) throws {

    var thrownError: Error?

    // Call method under test
    XCTAssertThrowsError(try functionUnderTest()) { thrownError = $0 }

    // Check thrown error
    XCTAssertTrue(thrownError is ASN1ReadError, "Unexpected error type: \(type(of: thrownError))")

    let expectedError = ASN1ReadError.invalidLength(
      minimumRemainingBytes: 8,
      forReading: "Contents bytes",
      actualRemainingBytes: 1,
      atPosition: 2,
      ofEncoding: derEncoding_noContentsBytes
    )
    XCTAssertEqual(thrownError as? ASN1ReadError, expectedError)
  }

  static var allTests = [
    ("testCombinedMethodsToReadBitString_derEncoding",
      testCombinedMethodsToReadBitString_derEncoding),
    ("testCombinedMethodsToReadBitString_berEncoding",
      testCombinedMethodsToReadBitString_berEncoding),
    ("testGetReaderForContents",testGetReaderForContents),
    ("testGetReaderForContents_identifiedBy",testGetReaderForContents_identifiedBy),
    ("testReadAheadIdentifier",testReadAheadIdentifier),
    ("testReadAheadIdentifier_noMoreComponentsLeft",testReadAheadIdentifier_noMoreComponentsLeft),
    ("testReadContents",testReadContents),
    ("testReadContents_identifiedBy",testReadContents_identifiedBy),
    ("testReadContents_zeroBytes",testReadContents_zeroBytes),
    ("testSkipIdentifierAndLength",testSkipIdentifierAndLength),
    ("testSkipIdentifierAndLength_expectedIdentifier",
      testSkipIdentifierAndLength_expectedIdentifier),
    ("testSkipComponent",testSkipComponent),
    ("testSkipComponent_identifiedBy",testSkipComponent_identifiedBy),
    ("testSkipBytes",testSkipBytes),
    ("testReadContents_127_bytes", testReadContents_127_bytes),
    ("testReadContents_128_bytes", testReadContents_128_bytes),
    ("testGetReaderForContents_invalidIdentifier",testGetReaderForContents_invalidIdentifier),
    ("testReadContents_invalidIdentifier",testReadContents_invalidIdentifier),
    ("testReadContentsOfBitString_invalidIdentifier",testReadContentsOfBitString_invalidIdentifier),
    ("testReadContentsOfBitString_unsupportedFirstContentsByte",
      testReadContentsOfBitString_unsupportedFirstContentsByte),
    ("testSkipIdentifierAndLength_invalidIdentifier",testSkipIdentifierAndLength_invalidIdentifier),
    ("testSkipComponent_invalidIdentifier",testSkipComponent_invalidIdentifier),
    ("testSkipBytes_invalidBytes",testSkipBytes_invalidBytes),
    ("testGetReaderForContents_invalidLength_1",testGetReaderForContents_invalidLength_1),
    ("testGetReaderForContents_invalidLength_2",testGetReaderForContents_invalidLength_2),
    ("testReadContents_invalidLength_1",testReadContents_invalidLength_1),
    ("testReadContents_invalidLength_2",testReadContents_invalidLength_2),
    ("testReadContentsOfBitString_invalidLength_1",testReadContentsOfBitString_invalidLength_1),
    ("testReadContentsOfBitString_invalidLength_2",testReadContentsOfBitString_invalidLength_2),
    ("testSkipIdentifierAndLength_invalidLength_1",testSkipIdentifierAndLength_invalidLength_1),
    ("testSkipIdentifierAndLength_invalidLength_2",testSkipIdentifierAndLength_invalidLength_2),
    ("testSkipComponent_invalidLength_1",testSkipComponent_invalidLength_1),
    ("testSkipComponent_invalidLength_2",testSkipComponent_invalidLength_2),
    ("testSkipBytes_invalidLength",testSkipBytes_invalidLength),
    ("testReadContents_indefiniteLength",testReadContents_indefiniteLength),
  ]
}
