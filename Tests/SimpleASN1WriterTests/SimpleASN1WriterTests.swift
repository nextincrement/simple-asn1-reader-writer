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

  func testWrite_from() {

    // Prepare test
    let parentWriter = SimpleASN1Writer()
    parentWriter.write([0x05, 0x00])
    let childWriter = SimpleASN1Writer()
    childWriter.write([0x02, 0x01, 0x01])

    // Call function under test
    parentWriter.write(from: childWriter)

    // Check result
    parentWriter.wrap(with: 0x30)
    let encoding = parentWriter.encoding
    XCTAssertEqual([0x30, 0x05, 0x02, 0x01, 0x01, 0x05, 0x00], encoding)
  }

  func testWrite() {

    // Prepare test
    let simpleASN1Writer = SimpleASN1Writer()

    // Call function under test
    simpleASN1Writer.write([0x05, 0x00])

    // Check result
    let encoding = simpleASN1Writer.encoding
    XCTAssertEqual([0x05, 0x00], encoding)
  }

  func testWrite_identifiedBy() {

    // Prepare test
    let simpleASN1Writer = SimpleASN1Writer()

    // Call function under test
    simpleASN1Writer.write([0x05, 0x00], identifiedBy: 0x30)

    // Check result
    let encoding = simpleASN1Writer.encoding
    XCTAssertEqual([0x30, 0x02, 0x05, 0x00], encoding)
  }

  func testWrap() {

    // Prepare test
    let simpleASN1Writer = SimpleASN1Writer()

    simpleASN1Writer.write([0x05, 0x00])

    // Call function under test
    simpleASN1Writer.wrap(with: 0x30)

    // Check result
    let encoding = simpleASN1Writer.encoding
    XCTAssertEqual([0x30, 0x02, 0x05, 0x00], encoding)
  }

  func testWrap_127_bytes() {

    // Prepare test
    let simpleASN1Writer = SimpleASN1Writer()
    let bytes127: [UInt8] = Array(repeating: 0x00, count: 127)
    simpleASN1Writer.write(bytes127)

    // Call function under test
    simpleASN1Writer.wrap(with: 0x30)

    // Check result
    let encoding = simpleASN1Writer.encoding
    let expectedResult = insert([0x30, 0x7F], atTheBeginningOf: bytes127)
    XCTAssertEqual(expectedResult, encoding)
  }

  func testWrap_128_bytes() {

    // Prepare test
    let simpleASN1Writer = SimpleASN1Writer()
    let bytes128: [UInt8] = Array(repeating: 0x00, count: 128)
    simpleASN1Writer.write(bytes128)

    // Call function under test
    simpleASN1Writer.wrap(with: 0x30)

    // Check result
    let encoding = simpleASN1Writer.encoding
    let expectedResult = insert([0x30, 0x81, 0x80], atTheBeginningOf: bytes128)
    XCTAssertEqual(expectedResult, encoding)
  }

  func testWrap_255_bytes() {

    // Prepare test
    let simpleASN1Writer = SimpleASN1Writer()
    let bytes255: [UInt8] = Array(repeating: 0x00, count: 255)
    simpleASN1Writer.write(bytes255)

    // Call function under test
    simpleASN1Writer.wrap(with: 0x30)

    // Check result
    let encoding = simpleASN1Writer.encoding
    let expectedResult = insert([0x30, 0x81, 0xff], atTheBeginningOf: bytes255)
    XCTAssertEqual(expectedResult, encoding)
  }

  func testWrap_256_bytes() {

    // Prepare test
    let simpleASN1Writer = SimpleASN1Writer()
    let bytes256: [UInt8] = Array(repeating: 0x00, count: 256)
    simpleASN1Writer.write(bytes256)

    // Call function under test
    simpleASN1Writer.wrap(with: 0x30)

    // Check result
    let encoding = simpleASN1Writer.encoding
    let expectedResult = insert([0x30, 0x82, 0x01, 0x00], atTheBeginningOf: bytes256)
    XCTAssertEqual(expectedResult, encoding)
  }

  func testWrapBitString() {

    // Prepare test
    let simpleASN1Writer = SimpleASN1Writer()
    simpleASN1Writer.write([0x05, 0x00])

    // Call function under test
    simpleASN1Writer.wrapBitString()

    // Check result
    let encoding = simpleASN1Writer.encoding
    XCTAssertEqual([0x03, 0x03, 0x00, 0x05, 0x00], encoding)
  }

  func testWrapBitString_126_bytes() {

    // Prepare test
    let simpleASN1Writer = SimpleASN1Writer()
    let bytes126: [UInt8] = Array(repeating: 0x01, count: 126)
    simpleASN1Writer.write(bytes126)

    // Call function under test
    simpleASN1Writer.wrapBitString()

    // Check result
    let encoding = simpleASN1Writer.encoding
    let expectedResult = insert([0x03, 0x7f, 0x00], atTheBeginningOf: bytes126)
    XCTAssertEqual(expectedResult, encoding)
  }

  func testWrapBitString_127_bytes() {

    // Prepare test
    let simpleASN1Writer = SimpleASN1Writer()
    let bytes127: [UInt8] = Array(repeating: 0x01, count: 127)
    simpleASN1Writer.write(bytes127)

    // Call function under test
    simpleASN1Writer.wrapBitString()

    // Check result
    let encoding = simpleASN1Writer.encoding
    let expectedResult = insert([0x03, 0x81, 0x80, 0x00], atTheBeginningOf: bytes127)
    XCTAssertEqual(expectedResult, encoding)
  }

  // MARK: - Private helper functions

  private func insert(_ addedBytes: [UInt8], atTheBeginningOf bytes: [UInt8]) -> [UInt8] {
    var concatenatedBytes = bytes
    concatenatedBytes.insert(contentsOf: addedBytes, at: 0)

    return concatenatedBytes
  }

  static var allTests = [
    ("testWrite_from", testWrite_from),
    ("testWrite", testWrite),
    ("testWrite_identifiedBy", testWrite_identifiedBy),
    ("testWrap", testWrap),
    ("testWrap_127_bytes", testWrap_127_bytes),
    ("testWrap_128_bytes", testWrap_128_bytes),
    ("testWrap_255_bytes", testWrap_255_bytes),
    ("testWrap_256_bytes", testWrap_256_bytes),
    ("testWrapBitString", testWrapBitString),
    ("testWrapBitString_126_bytes", testWrapBitString_126_bytes),
    ("testWrapBitString_127_bytes", testWrapBitString_127_bytes),
  ]
}
