//
//  SimpleASN1Reading.swift
//  simple-asn1-reader-writer
//
//  Created by nextincrement on 27/07/2019.
//  Copyright © 2019 nextincrement
//

/// The `SimpleASN1Reading` protocol describes how bytes can be extracted from a BER encoding.
///
/// Simple in this context means:
/// - No conversion between Swift data types and bytes (so, only bytes out)
/// - No support for high tag numbers (that is, tag numbers are encoded by a single byte)
/// - No support for encodings that have an indefinite length
///
/// Note that this protocol is designed in a way that only a single instance of an implementation
/// has to be created to read any encoding, as long as it is clear upfront which tags are expected
/// at each position. If this condition is not met, a new instance should be created for reading
/// the contents of any structured type that contains optional types or a variable number of
/// components. The methods `getReaderForContents(identifiedBy:)` and `getReaderForContents()` can
/// be used to create a new reader for reading each structured type.
public protocol SimpleASN1Reading: AnyObject {

  /// Returns a new child reader for reading the contents bytes of the next component. Subsequent
  /// reads using the current reader (parent) will work on bytes below.
  ///
  /// - Returns: A reader that implements the `SimpleASN1Reading` protocol.
  /// - Throws: An `ASN1ReadError` if the encoding appears to be invalid.
  func getReaderForContents() throws -> SimpleASN1Reading

  /// Returns a new child reader for reading the contents bytes of the next component. Subsequent
  /// reads using the current (parent) reader will work on bytes below.
  ///
  /// Note that the identifier byte will be verified and that an error is thrown if it does not
  /// match provided argument.
  ///
  /// - Parameter expectedIdentifier: An ASN.1 identifier that will be verified.
  /// - Returns: A reader implementing the `SimpleASN1Reading` protocol.
  /// - Throws: An `ASN1ReadError` if the encoding appears to be invalid.
  func getReaderForContents(identifiedBy expectedIdentifier: UInt8) throws -> SimpleASN1Reading

  /// Reads contents bytes of the next component. Subsequent reads will work on bytes below.
  ///
  /// - Returns: The contents bytes.
  /// - Throws: An `ASN1ReadError` if the encoding appears to be invalid.
  func readContents() throws -> [UInt8]

  /// Reads contents bytes of the next component. Subsequent reads will work on bytes below.
  ///
  /// Note that the identifier byte will be verified and that an error is thrown if it does not
  /// match provided argument.
  ///
  /// - Parameter expectedIdentifier: An ASN.1 identifier that will be verified.
  /// - Returns: The contents bytes.
  /// - Throws: An `ASN1ReadError` if the encoding appears to be invalid.
  func readContents(identifiedBy expectedIdentifier: UInt8) throws -> [UInt8]

  /// Convenience method for reading the contents of the most basic type of bit string that has no
  /// unused bits (that is, the fist contents byte has value 0x00). Subsequent reads will work on
  /// bytes below.
  ///
  /// Note that both the identifier byte and the first contents byte will be verified. An error is
  /// thrown if either the identifier byte does not match expected value `0x03` or the first
  /// contents byte does not match the expected value `0x00`.
  ///
  /// - Returns: The contents bytes of a bit string while excluding the first byte.
  /// - Throws: An `ASN1ReadError` if the encoding appears to be invalid.
  func readContentsOfBitString() throws -> [UInt8]

  /// Skips bytes of a component (including identifier, length and contents bytes) so that
  /// subsequent reads will work on bytes below.
  ///
  /// - Throws: An `ASN1ReadError` if the encoding appears to be invalid.
  func skipComponent() throws

  /// Skips bytes of a component (including identifier, length and contents bytes) so that
  /// subsequent reads will work on bytes below.
  ///
  /// Note that the identifier byte will be verified and that an error is thrown if it does not
  /// match provided argument.
  ///
  /// - Parameter expectedIdentifier: The ASN.1 identifier of the component that is to be skipped,
  ///     which will be verified.
  /// - Throws: An `ASN1ReadError` if the encoding appears to be invalid.
  func skipComponent(identifiedBy expectedIdentifier: UInt8) throws

  /// Skips provided bytes. Subsequent reads will work on bytes below.
  ///
  /// Note that all bytes will be verified and that an error is thrown if these bytes don’t match
  /// provided argument.
  ///
  /// - Parameter expectedBytes: The bytes that will be verified.
  /// - Throws: An `ASN1ReadError` if the encoding appears to be invalid.
  func skip(_ expectedBytes: [UInt8]) throws

  /// Skips identifier and length bytes of the next component so that subsequent reads will work on
  /// bytes below.
  ///
  /// - Throws: An `ASN1ReadError` if the encoding appears to be invalid.
  func unwrap() throws

  /// Skips identifier and length bytes of the next component so that subsequent reads will work on
  /// bytes below.
  ///
  /// Note that the identifier byte will be verified and that an error is thrown if it does not
  /// match provided argument.
  ///
  /// - Parameter expectedIdentifier: The ASN.1 identiefier of the wrapping component, which will be
  ///     verified.
  /// - Throws: An `ASN1ReadError` if the encoding appears to be invalid.
  func unwrap(expectedIdentifier: UInt8) throws

  /// Reads the identifier of the next component without consuming it. Subsequent reads will work as
  /// if this method has not been called. If there are no more components left to read, the value
  /// 0x00 will be returned.
  ///
  /// - Returns: The ASN.1 identifier of the next component or 0x00.
  /// - Throws: An `ASN1ReadError` if the encoding appears to be invalid.
  func peek() throws -> UInt8
}
