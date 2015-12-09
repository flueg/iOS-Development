//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by LiuFlueg on 12/8/15.
//  Copyright © 2015 LiuFlueg. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private enum Op
    {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
    }
    //var opStack Array<Op>()
    private var opStack = [Op]()

//    var knownOps = Dictionary<String, Op>()
    private var knownOps = [String:Op]()
    
    init() {
        knownOps["×"] = Op.BinaryOperation("×") {$0 * $1}
        knownOps["÷"] = Op.BinaryOperation("÷") {$1 / $0}
        knownOps["+"] = Op.BinaryOperation("+") {$0 + $1}
        knownOps["−"] = Op.BinaryOperation("−") {$1 - $0}
        knownOps["√"] = Op.UnaryOperation("√") {sqrt($0)}
    }
    
    // Another way to make "ops" mutuable
    //private func evaluate(var ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
    private func evaluateValue(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
//            case Op.Operand(let operand):
                // use let to make operand readonly
            case .Operand(let operand):
                return (operand, remainingOps)
                // "_" in swift means: I don;t care what this is.
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluateValue(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluateValue(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluateValue(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1,operand2), op2Evaluation.remainingOps)
                    }
                }
            // Since we handle all the case in Op, no need "default"
            //default: break
            }

        }
        return (nil, ops)
    }
    
    func evaluate() -> Double {
        let (result, _) = evaluateValue(opStack)
        return result!
    }

    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func performOperation(symble: String) -> Double? {
        if let operation = knownOps[symble] {
            opStack.append(operation)
        }
        return evaluate()
    }
}