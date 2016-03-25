//
//  HistoryTest.swift
//  SBVariables
//
//  Created by Ed Gamble on 11/17/15.
//  Copyright © 2015 Edward B. Gamble Jr.  All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//  See the CONTRIBUTORS file at the project root for a list of contributors.
//

import XCTest
import SBUnits

@testable import SBVariables


class HistoryTest: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testHistory() {
    let time = Quantity<Time>(value: 0, unit: second)
    let history = History<Int>(capacity: 1)
    
    XCTAssertEqual(0, history.count)
    
    history.extend(time, value: 0)
    XCTAssertEqual(1, history.count)
    
    history.extend(time, value: 1)
    XCTAssertEqual(1, history.count)
  }
  
  func testPerformanceExample() {
    self.measure {
    }
  }
}

/*
@implementation SBTestHistory

- (void) testHistory
{
  SBHistory *h1 = [[SBHistory alloc] init];
  SBValue   *v1 = [SBValue new];
  
  [h1 extendHistory: v1];
  }
  
  - (void) testHistoryNumeric
    {
      SBNumericHistory *h1 = [[SBNumericHistory alloc] init];
      SBNumeric *n1 = [[SBNumeric alloc] initWithValue: 1.5];
      SBNumeric *n2 = [[SBNumeric alloc] initWithValue: 1.0];
      SBNumeric *n3 = [[SBNumeric alloc] initWithValue: 2.0];
      
      [h1 extendHistory: n1];
      STAssertEqualObjects(h1.hiWatermark, n1, @"missed hi n1");
      STAssertEqualObjects(h1.loWatermark, n1, @"missed lo n1");
      
      [h1 extendHistory: n2];
      STAssertEqualObjects(h1.hiWatermark, n1, @"missed hi n1");
      STAssertEqualObjects(h1.loWatermark, n2, @"missed lo n2");
      
      [h1 extendHistory: n3];
      STAssertEqualObjects(h1.hiWatermark, n3, @"missed hi n3");
      STAssertEqualObjects(h1.loWatermark, n2, @"missed lo n2");
}
@end
*/
