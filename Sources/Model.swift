//
//  Model.swift
//  SBVariables
//
//  Created by Ed Gamble on 10/22/15.
//  Copyright © 2015 Edward B. Gamble Jr.  All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//  See the CONTRIBUTORS file at the project root for a list of contributors.
//

import SBUnits

///
/// Numeric types that can be converted to Double
///   (Swift makes this tedious)
///
public protocol ConvertableToDouble {
  var toDouble : Double { get }
}

extension UInt8 : ConvertableToDouble {
  public var toDouble : Double { return Double(self) }
}

extension  Int8 : ConvertableToDouble {
  public var toDouble : Double { return Double(self) }
}

/// ...

public protocol SupportsBitwise {
  func extract (shift:UInt8, count:UInt8) -> Self
}

#if false
extension SupportsBitwise {
  func extract (offset:UInt8, count:UInt8) -> Self {
    return self.extract (offset: offset, mask: (1 << Self(count)) - 1)
  }
}
  #endif

extension UInt8 : SupportsBitwise {
  public func extract (shift: UInt8, count: UInt8) -> UInt8 {
    return (self >> shift) & ((1 << count) - 1)
  }
}

extension UInt16 : SupportsBitwise {
  public func extract (shift: UInt8, count: UInt8) -> UInt16 {
    return (self >> UInt16(shift)) & ((1 << UInt16(count)) - 1)
  }
}

#if false
extension UInt32 : SupportsBitwise {
  public func extract (shift: UInt8, count: UInt8) -> UInt16 {
    return (self >> UInt32(shift)) & ((1 << UInt32(count)) - 1)
  }
}


extension UInt64 : SupportsBitwise {
  public func extract (shift: UInt8, count: UInt8) -> UInt16 {
    return (self >> UInt64(shift)) & ((1 << UInt64(count)) - 1)
  }
}
#endif


///
/// A Model converts input -> output (as output = f(input)) and, optionally output -> input. The
/// function `applyForward()` does the conversion and must be provided.  The `applyReverse()` is 
/// not guaranteed to be 'well posed' (there may not be an inverse).
///
public protocol Model {

  /// The input type
  associatedtype Input

  /// The output type
  associatedtype Output

  /// Convert input -> output
  func applyForward (_ input:Input) -> Output

  // The inverse is often ill-posed and thus non-existent.  This return will default to 'nil'

  /// Convert output -> input, optionally.
  func applyReverse (_ output:Output) -> Input?
}

///
///
///
extension Model {

  /// Convert output -> input, optionally - by default return `nil`
  public func applyReverse (_ output:Output) -> Input? {
    return nil
  }
}

///
/// A `ConstantModel` is a `Model` that returns the same output not matter the input.
///
public struct ConstantModel<Input, Output> : Model {
  let output : Output
  
  public func applyForward (_ input:Input) -> Output {
    return output
  }

  init (output: Output) {
    self.output = output
  }
}

///
/// A `LinearModel` is a `Model` with parameterized type of SBUnits.Dimension that converts an
/// input of Quantity<D> to a Quantity<D> output by applying a linear model as:
///   `output = scale * input + offset
/// 
/// The `scale` is 'dimensionless' (a raw Double); the `offset` is a `Quantity<D>`
///
/// The inverse, as provided by 'applyReverse` is well-defined.
///
public struct LinearModel<D:SBUnits.Dimension> : Model {
  let scale  : Double
  let offset : Quantity<D>
  
  public func applyForward (_ input:Quantity<D>) -> Quantity<D> {
    // convert units
    return Quantity(value: scale * input.value + offset.value, unit: offset.unit)
  }
  
  public func applyReverse(_ output: Quantity<D>) -> Quantity<D>? {
    guard 0.0 == scale else { return nil }
    
    return Quantity(value: (output.value - offset.value) / scale, unit: offset.unit)
  }
  
  public init (scale: Double, offset: Quantity<D>) {
    self.scale  = scale
    self.offset = offset
  }
}

///
/// A `DataNumberToEngineeringUnitModel` converts an Input (generally an Integer) into a 
/// `Quantity<EU>` using a polynomial model.
///
public struct DataNumberToEngineeringUnitModel<DN:ConvertableToDouble, EU:SBUnits.Dimension> : Model {
  let coeffs : Array<Double>
  let unit : Unit<EU>

  public func applyForward (_ input: DN) -> Quantity<EU> {
    let x = input.toDouble

    var p = 1.0
    var y = 0.0

    for i in 0..<coeffs.count {
      y += coeffs[i] * p
      p *= x
    }

    return Quantity<EU>(value: y, unit: unit)
  }

  init (unit: Unit<EU>, coeffs: [Double]) {
    self.unit = unit
    self.coeffs = coeffs
  }

  init (unit: Unit<EU>, _ usingCoeffs: Double...) {
    self.init (unit: unit, coeffs: usingCoeffs)
  }

}

///
/// A `BitwiseModel` is a `Model` that converts an input bit pattern (as SupportBitwise) into an
/// output bit pattern (as SupportsBitwise) by extracting bits using {`shift`, `count`}
///
public struct BitwiseModel<Bits:SupportsBitwise> : Model {
  let shift : UInt8
  let count : UInt8
  // let mask : Bits = (1 << count) -1

  public func applyForward (_ input: Bits) -> Bits {
    return input.extract (shift: shift, count: count)
  }
  
  public init (shift: UInt8, count: UInt8) {
    self.shift = shift
    self.count = count
  }
}

///
/// A `PiecewiseConstantModel` is a `Model` that converts an input comparable into an output based
/// on an arbitary set of 'pieces' defined by a Range<I> and O tuple.
///
public struct PiecewiseConstantModel<I:Comparable, O> : Model {
  let values : [(Range<I>, O)]
  let otherwise : O

  public func applyForward(_ input: I) -> O {
    for value in values {
      if value.0.contains(input) {
        return value.1
      }
    }
    return otherwise
  }

  init (otherwise: O, values: [(Range<I>, O)]) {
    self.otherwise = otherwise
    self.values = values
  }

  init (otherwise: O, _ withValues: (Range<I>, O)...) {
    self.init (otherwise: otherwise, values: withValues)
  }
}

///
/// A `FunctionalModel` is a `Model` with arbitary `forward` and `reverse` functions (with `reverse`
/// being optional.
///
public struct FunctionalModel<I, O> : Model {
  let forward : ((I) -> O)
  let reverse : ((O) -> I)?

  public func applyForward(_ input: I) -> O {
    return forward (input)
  }

  public func applyReverse(_ output: O) -> I? {
    return reverse?(output)
  }

  init (forward: @escaping (I) -> O, reverse: ((O) -> I)? = nil) {
    self.forward = forward
    self.reverse = reverse
  }
}
