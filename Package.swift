// swift-tools-version:3.1
//
//  Package.swift
//  SBVariables
//
//  Created by Ed Gamble on 12/3/15.
//  Copyright © 2015 Opus Logica Inc. All rights reserved.
//
import PackageDescription

let package = Package (
  name: "SBVariables",
  dependencies: [
    .Package (url: "https://github.com/EBGToo/SBBasics.git", majorVersion: 0),
    .Package (url: "https://github.com/EBGToo/SBUnits.git",  majorVersion: 0),
  ]
)
