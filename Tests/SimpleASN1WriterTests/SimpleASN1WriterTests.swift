//
//  SimpleASN1WriterTests.swift
//  simple-asn1-reader-writer
//
//  Created by nextincrement on 27/07/2019.
//  Copyright © 2019 nextincrement
//

import XCTest

import SimpleASN1Writer

class SimpleASN1WriterTests: XCTestCase {

  func testWriteBytes_from() {

    // Prepare test
    let parentWriter = SimpleASN1Writer()
    parentWriter.writeBytes([0x05, 0x00])

    let childWriter = SimpleASN1Writer()
    childWriter.writeBytes([0x02, 0x01, 0x01])

    // Call function under test
    parentWriter.writeBytes(from: childWriter)

    // Check result
    parentWriter.writeLengthAndIdentifier(0x30)
    let derEncoding = parentWriter.encoding

    XCTAssertEqual([0x30, 0x05, 0x02, 0x01, 0x01, 0x05, 0x00], derEncoding)
  }

  func testWriteBytes() {

    // Prepare test
    let simpleASN1Writer = SimpleASN1Writer()

    // Call function under test
    simpleASN1Writer.writeBytes([0x05, 0x00])

    // Check result
    let derEncoding = simpleASN1Writer.encoding

    XCTAssertEqual([0x05, 0x00], derEncoding)
  }

  func testWriteContents() {

    // Prepare test
    let simpleASN1Writer = SimpleASN1Writer()

    // Call function under test
    simpleASN1Writer.writeContents([0x05, 0x00], identifiedBy: 0x30)

    // Check result
    let derEncoding = simpleASN1Writer.encoding

    XCTAssertEqual([0x30, 0x02, 0x05, 0x00], derEncoding)
  }

  func testWriteBytesLengthAndIdentifier() {

    // Prepare test
    let simpleASN1Writer = SimpleASN1Writer()
    simpleASN1Writer.writeBytes([0x05, 0x00])

    // Call function under test
    simpleASN1Writer.writeLengthAndIdentifier(0x30)

    // Check result
    let derEncoding = simpleASN1Writer.encoding

    XCTAssertEqual([0x30, 0x02, 0x05, 0x00], derEncoding)
  }

  func testWriteBytesLengthAndIdentifier_127_bytes() {

    // Prepare test
    let simpleASN1Writer = SimpleASN1Writer()
    let bytes127: [UInt8] = Array(repeating: 0x00, count: 127)
    simpleASN1Writer.writeBytes(bytes127)

    // Call function under test
    simpleASN1Writer.writeLengthAndIdentifier(0x30)

    // Check result
    let derEncoding = simpleASN1Writer.encoding
    let expectedResult = insert([0x30, 0x7F], atTheBeginningOf: bytes127)
    XCTAssertEqual(expectedResult, derEncoding)
  }

  func testWriteBytesLengthAndIdentifier_128_bytes() {

    // Prepare test
    let simpleASN1Writer = SimpleASN1Writer()
    let bytes128: [UInt8] = Array(repeating: 0x00, count: 128)
    simpleASN1Writer.writeBytes(bytes128)

    // Call function under test
    simpleASN1Writer.writeLengthAndIdentifier(0x30)

    // Check result
    let derEncoding = simpleASN1Writer.encoding
    let expectedResult = insert([0x30, 0x81, 0x80], atTheBeginningOf: bytes128)
    XCTAssertEqual(expectedResult, derEncoding)
  }

  func testWriteBytesLengthAndIdentifierOfBitString() {

    // Prepare test
    let simpleASN1Writer = SimpleASN1Writer()
    simpleASN1Writer.writeBytes([0x05, 0x00])

    // Call function under test
    simpleASN1Writer.writeLengthAndIdentifierOfBitString()

    // Check result
    let derEncoding = simpleASN1Writer.encoding

    XCTAssertEqual([0x03, 0x03, 0x00, 0x05, 0x00], derEncoding)
  }

  func testWriteBytesLengthAndIdentifierOfBitString_126_bytes() {

    // Prepare test
    let simpleASN1Writer = SimpleASN1Writer()
    let bytes126: [UInt8] = Array(repeating: 0x01, count: 126)
    simpleASN1Writer.writeBytes(bytes126)

    // Call function under test
    simpleASN1Writer.writeLengthAndIdentifierOfBitString()

    // Check result
    let derEncoding = simpleASN1Writer.encoding
    let expectedResult = insert([0x03, 0x7F, 0x00], atTheBeginningOf: bytes126)
    XCTAssertEqual(expectedResult, derEncoding)
  }

  func testWriteBytesLengthAndIdentifierOfBitString_127_bytes() {

    // Prepare test
    let simpleASN1Writer = SimpleASN1Writer()
    let bytes127: [UInt8] = Array(repeating: 0x01, count: 127)
    simpleASN1Writer.writeBytes(bytes127)

    // Call function under test
    simpleASN1Writer.writeLengthAndIdentifierOfBitString()

    // Check result
    let derEncoding = simpleASN1Writer.encoding
    let expectedResult = insert([0x03, 0x81, 0x80, 0x00], atTheBeginningOf: bytes127)
    XCTAssertEqual(expectedResult, derEncoding)
  }

  // MARK: - Private helper functions

  private func insert(_ addedBytes: [UInt8], atTheBeginningOf bytes: [UInt8]) -> [UInt8] {
    var concatenatedBytes = bytes
    concatenatedBytes.insert(contentsOf: addedBytes, at: 0)
    return concatenatedBytes
  }

  static var allTests = [
    ("testWriteBytes_from", testWriteBytes_from),
    ("testWriteBytes", testWriteBytes),
    ("testWriteContents", testWriteContents),
    ("testWriteBytesLengthAndIdentifier", testWriteBytesLengthAndIdentifier),
    ("testWriteBytesLengthAndIdentifier_127_bytes", testWriteBytesLengthAndIdentifier_127_bytes),
    ("testWriteBytesLengthAndIdentifier_128_bytes", testWriteBytesLengthAndIdentifier_128_bytes),
    ("testWriteBytesLengthAndIdentifierOfBitString", testWriteBytesLengthAndIdentifierOfBitString),
    ("testWriteBytesLengthAndIdentifierOfBitString_126_bytes",
      testWriteBytesLengthAndIdentifierOfBitString_126_bytes),
    ("testWriteBytesLengthAndIdentifierOfBitString_127_bytes",
      testWriteBytesLengthAndIdentifierOfBitString_127_bytes),
  ]
}
