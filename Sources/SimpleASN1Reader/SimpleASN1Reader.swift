//
//  SimpleASN1Reader.swift
//  simple-asn1-reader-writer
//
//  Created by nextincrement on 27/07/2019.
//  Copyright © 2019 nextincrement
//

import Foundation

public final class SimpleASN1Reader: SimpleASN1Reading {

  // Constants
  private let bitStringIdentifier: UInt8 = 0x03
  private let supportedFirstContentsByte: UInt8 = 0x00

  // Instance variables
  private var currentIndex = 0
  private let encoding: [UInt8]

  public init(_ encoding: [UInt8]) {
    self.encoding = encoding
  }

  public func getReaderForContents() throws -> SimpleASN1Reading {
    let contents = try doReadContents()

    return SimpleASN1Reader(Array(contents))
  }

  public func getReaderForContents(
    identifiedBy expectedIdentifier: UInt8
  ) throws -> SimpleASN1Reading {

    let contents = try doReadContents(identifiedBy: expectedIdentifier)

    return SimpleASN1Reader(Array(contents))
  }

  public func readContents() throws -> [UInt8] {
    let contents = try doReadContents()

    return Array(contents)
  }

  public func readContents(identifiedBy expectedIdentifier: UInt8) throws -> [UInt8] {
    let contents = try doReadContents(identifiedBy: expectedIdentifier)

    return Array(contents)
  }

  public func readContentsOfBitString() throws -> [UInt8] {
    let contents = try doReadContents(identifiedBy: bitStringIdentifier, skipFirstByte: true)

    return Array(contents)
  }

  public func skipComponent() throws {
    let _ = try doReadContents()
  }

  public func skipComponent(identifiedBy expectedIdentifier: UInt8) throws {
    let _ = try doReadContents(identifiedBy: expectedIdentifier)
  }

  public func skip(_ expectedBytes: [UInt8]) throws {
    try check(minimumRemainingBytes: expectedBytes.count, forReading: "Bytes")
    let bytes = encoding[currentIndex..<(currentIndex + expectedBytes.count)]

    guard expectedBytes.elementsEqual(bytes) else {
      throw ASN1ReadError.invalidBytes(
        expectedBytes: expectedBytes,
        actualBytes: Array(bytes),
        atPosition: currentIndex,
        ofEncoding: encoding
      )
    }
    currentIndex += expectedBytes.count
  }

  public func unwrap() throws {
    let contentsLength = try readLength()
    try check(minimumRemainingBytes: contentsLength, forReading: "Contents bytes")
  }

  public func unwrap(expectedIdentifier: UInt8) throws {
    let contentsLength = try readLength(identifiedBy: expectedIdentifier)
    try check(minimumRemainingBytes: contentsLength, forReading: "Contents bytes")
  }

  public func peek() throws -> UInt8 {
    guard encoding.count > currentIndex else {
      return 0x00
    }
    return encoding[currentIndex]
  }

  private func doReadContents(
    identifiedBy expectedIdentifier: UInt8? = nil,
    skipFirstByte: Bool = false
  ) throws -> ArraySlice<UInt8> {

    var contentsLength = try readLength(identifiedBy: expectedIdentifier)

    if skipFirstByte == true {
      try skipFirstContentsByte()
      contentsLength -= 1
    }
    try check(minimumRemainingBytes: contentsLength, forReading: "Contents bytes")

    return encoding[currentIndex..<(currentIndex + contentsLength)]
  }

  private func skipFirstContentsByte() throws {
    try check(minimumRemainingBytes: 1, forReading: "First contents byte")

    let firstByte = encoding[currentIndex]

    guard firstByte == supportedFirstContentsByte else {
      throw ASN1ReadError.unsupportedFirstContentsByte(
        actualByte: firstByte,
        atPosition: currentIndex,
        ofEncoding: encoding
      )
    }
    currentIndex += 1
  }

  private func readLength(identifiedBy expectedIdentifier: UInt8? = nil) throws -> Int {
    let lengthField = try skipIdentifierAndReadLengthField(identifiedBy: expectedIdentifier)

    return length(encodedBy: lengthField)
  }

  private func skipIdentifierAndReadLengthField(
    identifiedBy expectedIdentifier: UInt8?
  ) throws -> ArraySlice<UInt8> {

    try skipIdentifier(expectedIdentifier)

    return try readLengthField()
  }

  private func skipIdentifier(_ expectedIdentifier: UInt8?) throws {
    try check(minimumRemainingBytes: 1, forReading: "Identifier byte")

    if let expectedIdentifier = expectedIdentifier {
      let firstByte = encoding[currentIndex]

      guard firstByte == expectedIdentifier else {
        throw ASN1ReadError.invalidIdentifier(
          expectedIdentifier: expectedIdentifier,
          actualIdentifier: firstByte,
          atPosition: currentIndex,
          ofEncoding: encoding
        )
      }
    }
    currentIndex += 1
  }

  private func readLengthField() throws -> ArraySlice<UInt8> {
    try check(minimumRemainingBytes: 1, forReading: "First byte of length field")

    let firstByte = encoding[currentIndex]
    guard  firstByte != 128 else {
      throw ASN1ReadError.indefiniteLengthNotSupported(atPosition: currentIndex)
    }

    if firstByte < 128 {
      currentIndex += 1
      return [firstByte]
    }
    return try readLongLengthField(withFirstByte: firstByte)
  }

  private func readLongLengthField(withFirstByte firstByte: UInt8)
    throws -> ArraySlice<UInt8> {

    let lengthFieldCount = Int(firstByte - 128) + 1
    try check(minimumRemainingBytes: lengthFieldCount, forReading: "Length field bytes")

    let lengthField = encoding[currentIndex..<(currentIndex + lengthFieldCount)]
    currentIndex += lengthFieldCount

    return lengthField
  }

  private func length(encodedBy lengthField: ArraySlice<UInt8>) -> Int {

    // Length is encoded by the first byte in the length field
    if lengthField.count == 1 {
      return Int(lengthField[0])
    }

    // Length is encoded by all bytes after the first byte in the length field
    let length = lengthField.dropFirst().reduce(UInt64(0)) { ($0 << 8) + UInt64($1) }

    return Int(length)
  }

  private func check(minimumRemainingBytes: Int, forReading: String) throws {
    guard encoding.count >= (minimumRemainingBytes + currentIndex) else {
      throw ASN1ReadError.invalidLength(
        minimumRemainingBytes: minimumRemainingBytes,
        forReading: forReading,
        actualRemainingBytes: encoding.count - currentIndex,
        atPosition: currentIndex,
        ofEncoding: encoding
      )
    }
  }
}
