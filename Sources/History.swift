//
//  History.swift
//  SBVariables
//
//  Created by Ed Gamble on 10/22/15.
//  Copyright © 2015 Opus Logica Inc. All rights reserved.
//
import SBUnits
import SBBasics

public class History<Value> {
  var buffer: Ring<(Quantity<Time>, Value)>

  public init (capacity: Int) {
    self.buffer = Ring(capacity: capacity)
  }

  // pairs of (object, time)
  public func extend (_ time: Quantity<Time>, value:Value) {
    buffer.put((time, value))
  }
  
  public var count : Int {
    return buffer.count
  }
  
  // severity
  
  // buffered
  
  // multi-buffer
  
  // ordered
}

