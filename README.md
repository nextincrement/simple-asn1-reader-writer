# Simple ASN.1 Reader and Writer

A simple reader and writer for reading and writing `ASN.1` encoded bytes.

[![Swift Version][swift-image]][swift-url] [![License][license-image]][license-url]

This project includes the `SimpleASN1Reader` and `SimpleASN1Writer` module, written in Swift and featuring a reader and writer that can be used for reading and writing `ASN.1` encoded bytes.

## Features

#### Reader
- [x] Reading any `ASN.1 BER` encoding (so, including `DER` and `CER` encoding formats)
- [x] Reading contents bytes
- [x] Readahead of identifier byte
- [x] Validation of identifier byte
- [x] Validation of an expected array of bytes
- [x] Validation of length bytes
- [x] Skipping bytes

#### Writer
- [x] Encoding bytes using the `ASN.1 DER` encoding format
- [x] Inserting new bytes on top of all bytes written before (as a sibling)
- [x] Inserting a component represented with a simple type on top of all bytes written before (as a sibling)
- [x] Composing structured types with a dedicated writer and inserting these components on top of all bytes written before (as a sibling)
- [x] Wrapping all bytes written before (as a parent)

#### Not Supported
- [ ] Conversion of bytes into Swift data types (such as `Int`, `String` etc.)
- [ ] Reading and writing from and to an underlying [`Stream`](https://developer.apple.com/documentation/foundation/stream)
- [ ] High tag numbers (that is, tag numbers are encoded by a single byte)
- [ ] Encodings with an indefinite length
- [ ] `ASN.1 CER` encoding format when writing bytes

The above items are deliberately not supported to keep both the reader and the writer simple and focused. In addition, the assumption has been made that the last three items are not used that often. It is therefore not expected that one of these items will be supported at some time in the future.

## Usage

`simple-asn1-reader-writer` is a SwiftPM project and can be built and tested using these commands:

```bash
$ swift build
$ swift test
```

To depend on `simple-asn1-reader-writer`, put the following in the `dependencies` of your `Package.swift`:

    .package(url: "https://github.com/nextincrement/simple-asn1-reader-writer.git", from: "0.0.3"),

See the [rsa-public-key-importer-exporter](https://github.com/nextincrement/rsa-public-key-importer-exporter) project for an example of how the [reader](https://github.com/nextincrement/rsa-public-key-importer-exporter/blob/master/Sources/RSAPublicKeyImporter/RSAPublicKeyImporter.swift) and [writer](https://github.com/nextincrement/rsa-public-key-importer-exporter/blob/master/Sources/RSAPublicKeyExporter/RSAPublicKeyExporter.swift) can be used.

## Contribute

Your interest in this project is highly appreciated. However, contributions might not be accepted for the following reasons:
- I am just one developer and time is scarce.
- The development environment that I currently have at hand is a Linux system on a virtual machine. I will thus not always be able to test how this code runs on a macOS or an iOS platform (although the first version will be tested on an iOS platform).

Some contributions may get accepted if for example a bug should be fixed that prevents parts of the code from being used in a common situation.

## Resources

[A Layman’s Guide to a Subset of ASN.1, BER, and DER](http://luca.ntop.org/Teaching/Appunti/asn1.html)

[X.690](https://www.itu.int/rec/T-REC-X.690-201508-I/en)

## Thanks
To the following project, which served as reference and inspiration during development:

[JOSESwift](https://github.com/airsidemobile/JOSESwift)


## License
`simple-asn1-reader-writer` is licensed under the MIT License. See LICENSE for details.

[swift-image]:https://img.shields.io/badge/swift-5.0-orange.svg
[swift-url]:https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE
