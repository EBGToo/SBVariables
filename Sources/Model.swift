//
//  Model.swift
//  SBVariables
//
//  Created by Ed Gamble on 10/22/15.
//  Copyright © 2015 Opus Logica Inc. All rights reserved.
//
import SBUnits

public protocol Model {
  associatedtype Input
  associatedtype Output

  func applyForward (input:Input) -> Output

  // The inverse is often ill-posed and thus non-existent.  This return will default to 'nil'
  func applyReverse (output:Output) -> Input?
}

extension Model {
  public func applyReverse (output:Output) -> Input? {
    return nil
  }
}

public final class ConstantModel<Input, Output> : Model {
  let output : Output
  
  public func applyForward (input:Input) -> Output {
    return output
  }

  init (output: Output) {
    self.output = output
  }
}

public final class LinearModel<D:Dimension> : Model {
  let scale  : Double
  let offset : Quantity<D>
  
  public func applyForward (input:Quantity<D>) -> Quantity<D> {
    // convert units
    return Quantity(value: scale * input.value + offset.value, unit: offset.unit)
  }
  
  public func applyReverse(output: Quantity<D>) -> Quantity<D>? {
    guard 0.0 == scale else { return nil }
    
    return Quantity(value: (output.value - offset.value) / scale, unit: offset.unit)
  }
  
  public init (scale: Double, offset: Quantity<D>) {
    self.scale  = scale
    self.offset = offset
  }
}

/*
// Numeric Model

public class ConstantModel<I:Input, O:Output> : Model {
  let output : Output
  
  func applyForward(input: Input) -> Self.Output {
    return ouput;
  }
  
  init (output:Output) {
    self.output = output
  }
}

// MARK: LinearModel

public class LinearModel : Model {
  let scale  : Double
  let offset : Double
}

// MARK: Quadratic Model

// MARK: Polynomial Model

// MARK: Piecewise Constant Model
*/