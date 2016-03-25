// swift-tools-version:5.5
//
//  Package.swift
//  SBVariables
//
//  Created by Ed Gamble on 12/3/15.
//  Copyright © 2015 Edward B. Gamble Jr.  All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//  See the CONTRIBUTORS file at the project root for a list of contributors.
//

import PackageDescription

let package = Package(
    name: "SBVariables",
    platforms: [
        .macOS("11.1")
    ],

    products: [
        .library(
            name: "SBVariables",
            targets: ["SBVariables"]),
    ],

    dependencies: [
        .package(url: "https://github.com/EBGToo/SBUnits",  .upToNextMajor(from: "0.1.0")),
        .package(url: "https://github.com/EBGToo/SBBasics", .upToNextMajor(from: "0.1.0")),
    ],

    targets: [
        .target(
            name: "SBVariables",
            dependencies: ["SBUnits", "SBBasics"],
            path: "Sources"
        ),
        .testTarget(
            name: "SBVariablesTests",
            dependencies: ["SBVariables"],
            path: "Tests"
        ),
    ]
)
