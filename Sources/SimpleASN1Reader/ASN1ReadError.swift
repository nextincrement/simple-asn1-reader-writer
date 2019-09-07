//
//  ASN1ReadError.swift
//  simple-asn1-reader-writer
//
//  Created by nextincrement on 27/07/2019.
//  Copyright © 2019 nextincrement
//

import Foundation

public enum ASN1ReadError: Equatable {
  case invalidIdentifier(
    expectedIdentifier: UInt8,
    actualIdentifier: UInt8,
    atPosition: Int,
    ofEncoding: [UInt8]
  )
  case invalidBytes(
    expectedBytes: [UInt8],
    actualBytes: [UInt8],
    atPosition: Int,
    ofEncoding: [UInt8]
  )
  case invalidLength(
    minimumRemainingBytes: Int,
    forReading: String,
    actualRemainingBytes: Int,
    atPosition: Int,
    ofEncoding: [UInt8]
  )
  case unsupportedFirstContentsByte(
    actualByte: UInt8,
    atPosition: Int,
    ofEncoding: [UInt8]
  )
  case indefiniteLengthNotSupported(atPosition: Int)
}

extension ASN1ReadError: LocalizedError {

  public var errorDescription: String? {
    switch self {
    case .invalidIdentifier(
      let expectedIdentifier,
      let actualIdentifier,
      let atPosition,
      let ofEncoding
    ):
      return """
        Invalid identifier: expectedIdentifier: \(toHexString(expectedIdentifier)), \
        actualIdentifier: \(toHexString(actualIdentifier)), atPosition: \(atPosition), \
        ofEncoding: \(toHexString(ofEncoding))
        """

    case .invalidBytes(
        let expectedBytes,
        let actualBytes,
        let atPosition,
        let ofEncoding
    ):
      return """
        Invalid bytes: expectedBytes: \(toHexString(expectedBytes)), \
        actualBytes: \(toHexString(actualBytes)), atPosition: \(atPosition), \
        ofEncoding: \(toHexString(ofEncoding))
        """

    case .invalidLength(
        let minimumRemainingBytes,
        let forReading,
        let actualRemainingBytes,
        let atPosition,
        let ofEncoding
    ):
      return """
        Invalid length: minimumRemainingBytes: \(minimumRemainingBytes), \
        actualRemainingBytes: \(actualRemainingBytes), forReading: \(forReading), \
        atPosition: \(atPosition), ofEncoding: \(toHexString(ofEncoding))
        """

    case .unsupportedFirstContentsByte(
        let actualByte,
        let atPosition,
        let ofEncoding
    ):
      return """
        Unsupported first contents byte: expectedByte: 00, \
        actualByte: \(toHexString(actualByte)), atPosition: \(atPosition), \
        ofEncoding: \(toHexString(ofEncoding))
        """

    case .indefiniteLengthNotSupported(let atPosition):
      return "Indefinite length not supported: atPosition: \(atPosition)"
    }
  }

  private func toHexString(_ bytes: [UInt8]) -> String {
    return bytes.map{ String(format: "%02x ", $0) }.joined()
  }

  private func toHexString(_ byte: UInt8) -> String {
    return String(format: "%02x", byte)
  }
}
