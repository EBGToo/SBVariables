//
//  Name.swift
//  SBVariables
//
//  Created by Ed Gamble on 10/22/15.
//  Copyright © 2015 Edward B. Gamble Jr.  All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//  See the CONTRIBUTORS file at the project root for a list of contributors.
//

///
/// A Protocol for named objects 
///
public protocol Nameable {
  
  /// The `name`
  var name : String { get }
}

/// 
/// An `AsNameable` is a `Nameable` for an arbitrary typed `Item`
///
public struct AsNameable<Item> : Nameable {
  
  /// The `name`
  public var name : String
  
  /// The `item`
  public var item : Item

  /// Initialize an insntance
  ///
  /// - parameter name: the name
  /// - parameter item: the item
  ///
  public init (item: Item, name: String) {
    self.name = name
    self.item = item
  }
}

///
/// A concreate Nameable class 
///
open class Named : Nameable {
  
  /// The `name` 
  public let name : String

  /// Initialize an instance
  ///
  /// - parameter name: The name
  ///
  public init (name: String) {
    self.name = name
  }
}

///
/// A Namespace maintains a set of Named objects
///
public class Namespace<Object : Nameable> : Named {
  
  /// The optional parent namespace 
  let parent : Namespace<Object>?
  
  /// The separator 
  let separator = "."

  /// The mapping from Name -> Value 
  var dictionary = Dictionary<String,Object>()
  
  func hasObjectByName (_ obj: Object) -> Bool {
    return nil != dictionary[obj.name]
  }

  /// Remove `obj` from `self` - based on `obj.name`
  func remObjectByName (_ obj: Object) {
    dictionary.removeValue (forKey: obj.name)
  }

  /// Add `obj` to `self` - overwritting any other object with  `obj.name`
  func addObjectByName (_ obj: Object) {
    dictionary[obj.name] = obj
  }

  /// If one exists, return the object in `self` with `name`
  func getObjectByName (_ name: String) -> Object? {
    return dictionary[name]
  }
  
  ///
  /// The fullname of `obj` in namespace.  Note the `obj` need not be in namespace.
  ///
  /// - parameter obj:
  ///
  /// - returns: The fullname
  ///
  func fullname (_ obj: Nameable) -> String {
    return (parent?.fullname(self) ?? name) + separator + obj.name
  }
  
  ///
  /// Create an instance
  ///
  /// - parameter name: the name
  /// - parameter parent: the parent namespace
  ///
  public init (name: String, parent: Namespace<Object>) {
    self.parent = parent
    super.init(name: name)
  }
  
  ///
  /// Create an instance; the `parent` will be .None
  ///
  /// - parameter name: The name
  ///
  public override init (name: String) {
    self.parent = nil
    super.init(name: name)
  }
}

