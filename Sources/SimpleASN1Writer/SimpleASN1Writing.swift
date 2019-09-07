//
//  SimpleASN1Writing.swift
//  simple-asn1-reader-writer
//
//  Created by nextincrement on 27/07/2019.
//  Copyright © 2019 nextincrement
//

/// The `SimpleASN1Writing` protocol describes how a DER encoding can be created or updated by
/// inserting bytes on top of bytes that have been written before.
///
/// Simple in this context means:
/// - No conversion between Swift data types and bytes (so, only bytes in)
/// - No high tag numbers (that is, tag numbers are encoded by a single byte)
/// - No support for encodings that have an indefinite length
///
/// Note that this protocol is designed in a way that multiple instances of an implementation should
/// be created if the encoding has a tree-like structure that forks into multiple branches.
public protocol SimpleASN1Writing: AnyObject {

  /// All encoded bytes added to this writer.
  var encoding: [UInt8] { get }

  /// Convenience method that adds the encoding of another instance to the current instance. All
  /// bytes of the `SimpleASN1Writer` will be written on top of bytes written below (as a sibling).
  ///
  /// - Parameter writer: Another instance of a class implementing this protocol.
  func write(from writer: SimpleASN1Writer)

  /// Writes bytes on top of all bytes written below (as a sibling).
  ///
  /// - Parameter bytes: The bytes that will be written on top of bytes below.
  func write(_ bytes: [UInt8])

  /// Writes contents, length and identifier bytes, in that particular order, on top of all bytes
  /// written below. The number represented by the length bytes applies to the number of contents
  /// bytes of the added component. And if the identifier denotes a bit string, the first byte of
  /// the contents must give the number of bits by which the length of the bit string is less than
  /// the next multiple of eight (this is called the “number of unused bits”). Both the padding
  /// after the last bit and the inclusion of the first contents byte – which gives the length of
  /// this padding – will be considered the responsibility of the client.
  ///
  /// - Parameters:
  ///   - contents: The contents bytes of the component.
  ///   - identifier: The ASN.1 identifier of the component.
  func write(_ contents: [UInt8], identifiedBy identifier: UInt8)

  /// Writes length and identifier bytes, in that particular order, to wrap all bytes written below.
  ///
  /// - Parameter identifier: The ASN.1 identifier byte that will be written on top of the length
  ///     bytes and all bytes below.
  func wrap(with identifier: UInt8)

  /// Writes length and identifier bytes of a bit string, in that particular order, to wrap all
  /// bytes written below. The bit string is assumed to have no unused bits (that is, the fist
  /// contents byte has value 0x00).
  func wrapBitString()
}
