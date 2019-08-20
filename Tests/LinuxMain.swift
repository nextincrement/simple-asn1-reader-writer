//
//  LinuxMain.swift
//  simple-asn1-reader-writer
//
//  Created by nextincrement on 27/07/2019.
//  Copyright © 2019 nextincrement
//

import XCTest
import SimpleASN1ReaderTests
import SimpleASN1WriterTests

var tests = [XCTestCaseEntry]()
tests += SimpleASN1ReaderTests.allTests()
tests += SimpleASN1WriterTests.allTests()

XCTMain(tests)
