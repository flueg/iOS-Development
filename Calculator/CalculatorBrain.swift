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
    private enum Conts
    {
        case em_PI
    }
   
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
    
    private var knownConsts = [String:Conts]()
    private var preStackDump: String?
    private var curStackDump: String?

    init() {
        knownOps["×"] = Op.BinaryOperation("×") {$0 * $1}
        knownOps["÷"] = Op.BinaryOperation("÷") {$1 / $0}
        knownOps["+"] = Op.BinaryOperation("+") {$0 + $1}
        knownOps["−"] = Op.BinaryOperation("−") {$1 - $0}
        knownOps["√"] = Op.UnaryOperation("√") {sqrt($0)}
        knownOps["𝞹"] = Op.UnaryOperation("𝞹") {_ in M_PI}
        knownOps["cos"] = Op.UnaryOperation("cos") {cos($0)}
        knownOps["sin"] = Op.UnaryOperation("sin") {sin($0)}
        
        knownConsts["𝞹"] = Conts.em_PI
    }
    

    // Another way to make "ops" mutuable
    //private func evaluate(var ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
    private func evaluateValue(ops: [Op]) -> (result: Double?, remainingOps: [Op], stackDump: String?) {
        var stackDump: String?
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
//            case Op.Operand(let operand):
                // use let to make operand readonly
            case .Operand(let operand):
                stackDump = "\(operand)"
                return (operand, remainingOps, stackDump)
                // "_" in swift means: I don;t care what this is.
            case .UnaryOperation(let symbol, let operation):
                let operandEvaluation = evaluateValue(remainingOps)
                if let operand = operandEvaluation.result {
                    stackDump = "(" + symbol + operandEvaluation.stackDump! + ")"
                    return (operation(operand), operandEvaluation.remainingOps, stackDump)
                }
            case .BinaryOperation(let symbol, let operation):
                let op1Evaluation = evaluateValue(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluateValue(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        stackDump = "(" + op2Evaluation.stackDump! + symbol + op1Evaluation.stackDump! + ")"
                        return (operation(operand1,operand2), op2Evaluation.remainingOps, stackDump)
                    }
                }
            // Since we handle all the case in Op, no need "default"
            //default:
            //    break
            }

        }
        return (nil, ops, stackDump)
    }
    
    func evaluate() -> Double? {
        // In case the opStack in not valid.
        let tmpOpStack = opStack
        
        preStackDump = curStackDump
        curStackDump = ""
        
        let (result, remainder, stackDump) = evaluateValue(opStack)
        if stackDump != nil {
            curStackDump = stackDump! + "="
        }
        print("\(opStack) = \(result) with \(remainder) left over")
        if result == nil {
            opStack = tmpOpStack
            // Popup the last invalid operand.
            opStack.popLast()
            print("restore stack: \(opStack)")
            return nil
        } else {
            return result!
        }
    }

    // Clear all input stack
    func cancle() {
        while !opStack.isEmpty {
            opStack.popLast()
        }
        print("Stack [\(opStack)] is clear now.")
    }
    
    // Remove the last input data
    func backSpace() -> Double? {
        if !opStack.isEmpty {
            opStack.popLast()
        }
        return evaluate()
    }

    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    // We will show the operation stack while user has enter the operator ...
    func dumpOpStack() -> String? {
        return curStackDump
    }
    
    // We will show the input stack history while user is typing digit ...
    func dumpHistory() -> String? {
        if !opStack.isEmpty {
            var opHistory: String = ""
            for op in opStack {
                switch op {
                case .Operand(let oprand):
                    opHistory += "\(oprand), "
                case .UnaryOperation(let symble, _):
                    opHistory += symble + ", "
                case .BinaryOperation(let symble, _):
                    opHistory += symble + ", "
                }
            }
            return opHistory
        }
        return nil
    }

    func performOperation(symble: String) -> Double? {
        // Special case:
        // Since we introduce constants (i.e. 𝞹) as operater, we need to push then to opStack as oprand firstly.
        if let constant = knownConsts[symble] {
            switch constant {
            case .em_PI: opStack.append(Op.Operand(M_PI))
            }
        } else {
        if let operation = knownOps[symble] {
            opStack.append(operation)
        }
        }
        return evaluate()
    }
}