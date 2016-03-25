//
//  NameTest.swift
//  SBVariables
//
//  Created by Ed Gamble on 11/17/15.
//  Copyright © 2015 Edward B. Gamble Jr.  All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//  See the CONTRIBUTORS file at the project root for a list of contributors.
//

import XCTest
@testable import SBVariables

class NameTest: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testName() {
    let o1 = Named(name: "o1")
    let o2 = Named(name: "o2")
    let o3 = Named(name: "o2")
    
    XCTAssertEqual("o1", o1.name)
    XCTAssertEqual("o2", o2.name)
    XCTAssertEqual("o2", o3.name)
    
    XCTAssertEqual(o2.name, o3.name)
    
  }
  
  func testNamespace () {
    let n1 = Namespace<Named>(name: "n1")

    let o1 = Named(name: "o1")
    let o2 = Named(name: "o2")
    
    n1.addObjectByName(o1)

    XCTAssertTrue(n1.hasObjectByName(o1))
    XCTAssertFalse(n1.hasObjectByName(o2))
    
    n1.addObjectByName(o2)
    
    XCTAssertTrue(n1.hasObjectByName(o1))
    XCTAssertTrue(n1.hasObjectByName(o2))

    n1.remObjectByName(o1)
    XCTAssertFalse(n1.hasObjectByName(o1))
    XCTAssertTrue(n1.hasObjectByName(o2))

    XCTAssertNotNil(n1.getObjectByName(o2.name))
    XCTAssertTrue(o2 === n1.getObjectByName(o2.name)!)
    XCTAssertNil(n1.getObjectByName(o1.name))
    
    XCTAssertEqual("n1\(n1.separator)o2", n1.fullname(o2))
  }
  
  func testNamespaceSquared () {
    let n1 = Namespace<Named>(name: "n1")
    let n2 = Namespace<Named>(name: "n2", parent: n1)
    let o1 = Named(name: "o1")
    
    XCTAssertEqual("n1\(n1.separator)n2\(n2.separator)o1", n2.fullname(o1))
  }
  
  func testPerformanceExample() {
    self.measure {
    }
  }
}

/*
@implementation SBTestNamedObject

- (void) setUp {}
- (void) tearDown {}

- (void) testCaseNameObject_1
  {

    // objectIsNamed:
    STAssertTrue ([object1 objectIsNamed: name],
    @"object1 should have name");
    STAssertTrue ([object1 objectIsNamed: @"Object Name"],
    @"object1 should have name 'Object Name'");
    STAssertFalse ([object1 objectIsNamed: @"Other Name"],
    @"object1 should not have name 'Object Name'");
    
    // objectsShareName:
    STAssertTrue ([object1 objectsShareName: object1],
    @"object1 and object1 do not share their name");
    STAssertTrue ([object1 objectsShareName: object2],
    @"object1 and object2 do not share their name");
    STAssertTrue ([object2 objectsShareName: object1],
    @"object2 and object1 do not share their name");
    
    STAssertFalse ([object1 objectsShareName: object3],
    @"object1 and object3 should not share their name");
    STAssertFalse ([object2 objectsShareName: object3],
    @"object2 and object3 should not share their name");
    
    // compareByName:
    STAssertTrue (NSOrderedSame == [object1 compareByName: object1],
    @"Missed self name");
    
    STAssertTrue (NSOrderedSame == [object1 compareByName: object2],
    @"Missed self name");
    
    STAssertTrue (NSOrderedSame != [object1 compareByName: object3],
    @"Missed self name");
    
}

@end // SBTestNamedObject
*/

/*
@implementation SBTestNamespace

- (void) setUp {}
  - (void) tearDown {}
    
    - (void) testCaseNamespace_1
      {
        NSString    *name1  = @"Space Name 1";
        SBNamespace *space1 =
          [[SBNamespace alloc] initWithName: name1
            withSeparator: @":"
        inNamespace: [SBNamespace standardNamespace]];
        
        STAssertTrue([@":" isEqualToString: space1.separator],
        @"The space1 separator should be ':'.");
        STAssertEqualObjects(space1.parent, [SBNamespace standardNamespace],
        @"The space1 parent should be standardNamespace");
        
        SBNamedObject *object1 = [[SBNamedObject alloc] initWithName: @"object_1"];
        SBNamedObject *object2 = [[SBNamedObject alloc] initWithName: @"object_2"];
        SBNamedObject *object3 = [[SBNamedObject alloc] initWithName: @"object_3"];
        
        STAssertNotNil (space1,  @"Could not create 'space1'.");
        STAssertNotNil (object1, @"Could not create 'object1'.");
        STAssertNotNil (object2, @"Could not create 'object2'.");
        STAssertNotNil (object3, @"Could not create 'object3'.");
        
        // STAssertFalse (space1.name == name1,
        //                 @"The space1 name is identical to name1");
        STAssertTrue  ([space1.name isEqualToString: name1],
        @"The space1 name is not string equal ot name1");
        STAssertEqualObjects (space1.name, name1,
        @"The space1 name and name1 are not equal");
        STAssertTrue ([space1 objectIsNamed: name1],
        @"The space1 name should be name1");
        
        STAssertTrue ([space1 addObjectByName: object1],
        @"Could not add object1 to space1");
        STAssertTrue ([space1 hasObjectByName: object1],
        @"Space1 contains object1");
        STAssertTrue ([space1 hasObjectWithName: @"object_1"],
        @"Space1 contains object1");
        STAssertFalse ([space1 addObjectByName: object1],
        @"Added object1 to space1 but it is already in space1");
        STAssertTrue ([space1 count] == 1,
        @"Space1 count is not 1");
        STAssertEqualObjects(object1, [space1 objectByName: @"object_1"],
        @"Space1 should have object1 by name");
        
        STAssertTrue ([space1 remObjectByName: object1],
        @"Could not remove object1 from space1");
        STAssertFalse ([space1 hasObjectByName: object1],
        @"Space1 contains object1");
        STAssertFalse ([space1 remObjectByName: object1],
        @"Removed object1 from space1 but it is not in space1");
        STAssertTrue ([space1 count] == 0,
        @"Space1 count is not 0");
        STAssertFalse (object1 == [space1 objectByName: @"object_1"],
        @"Space1 should not have object1 by name");
        
        STAssertTrue ([space1 addObjectByName: object1],
        @"Could not add object1 to space1");
        STAssertTrue ([space1 addObjectByName: object2],
        @"Could not add object2 to space1");
        STAssertTrue ([space1 count] == 2,
        @"Space1 count is not 2");
        STAssertEqualObjects(object1, [space1 objectByName: @"object_1"],
        @"Space1 should have object1 by name");
        STAssertEqualObjects(object2, [space1 objectByName: @"object_2"],
        @"Space1 should have object2 by name");
        
        NSArray *allNames = [space1 allNames];
        
        STAssertTrue ([allNames containsObject: @"object_1"],
        @"allNames should contain object_1");
        STAssertTrue ([allNames containsObject: @"object_2"],
        @"allNames should contain object_2");
        STAssertTrue (2 == [allNames count],
        @"allNames count should be 2");
        
        NSArray *allObjs  = [space1 allNamedObjects];
        STAssertTrue ([allObjs containsObject: object1],
        @"allObjs should contain object1");
        STAssertTrue ([allObjs containsObject: object2],
        @"allObjs should contain object2");
        STAssertTrue (2 == [allObjs count],
        @"allObjs count should be 2");
        
        STAssertEqualObjects ([space1 fullname: object1], @"SB.Space Name 1:object_1",
        @"Mismatched fullname for object_1");
        STAssertEqualObjects ([space1 fullname: object2], @"SB.Space Name 1:object_2",
        @"Mismatched fullname for object_2");
        // object3 not in space1
        STAssertFalse ([space1 hasObjectByName: object3],
        @"Space1 shouldn't have object3");
        STAssertEqualObjects ([space1 fullname: object3], @"object_3",
        @"Mismatched fullname for object_3");
        
        STAssertTrue ([space1 addObjectByName: object3],
        @"Could not add object3 to space1");
        
        space1 = [[SBNamespace alloc] initWithName: @"Space1-2"
        inNamespace: [SBNamespace standardNamespace]];
        
}

@end // SBTestNamespace
*/
