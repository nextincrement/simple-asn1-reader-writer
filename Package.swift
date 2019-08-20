// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

//
//  Package.swift
//  simple-asn1-reader-writer
//
//  Created by nextincrement on 27/07/2019.
//  Copyright © 2019 nextincrement
//

import PackageDescription

var targets: [PackageDescription.Target] = [
  .target(
    name: "SimpleASN1Reader",
    dependencies: []),
  .target(
    name: "SimpleASN1Writer",
    dependencies: []),
  .testTarget(
    name: "SimpleASN1ReaderTests",
    dependencies: ["SimpleASN1Reader"]),
  .testTarget(
    name: "SimpleASN1WriterTests",
    dependencies: ["SimpleASN1Writer"]),
]

let package = Package(
  name: "simple-asn1-reader-writer",
  products: [
    .library(
      name: "SimpleASN1Reader",
      targets: ["SimpleASN1Reader"]),
    .library(
      name: "SimpleASN1Writer",
      targets: ["SimpleASN1Writer"]),
  ],
  dependencies: [
  ],
  targets: targets
)
