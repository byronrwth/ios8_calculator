//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Xi Cheng on 16/1/3.
//  Copyright © 2016年 Xi Cheng. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private enum Op: CustomStringConvertible {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double) // 一元运算符
        case BinaryOperation(String, (Double, Double) -> Double) //二元运算符
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation( let symbol, _):
                    return symbol //string
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    // knownOps[String]  --> enum Op
    private var knownOps = [String:Op]() //Dictionary<String, Op>()
    
    init() {
        // set a enum Op to its knownOps[String]
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        
//        knownOps["×"] = Op.BinaryOperation("×", *)
        learnOp(Op.BinaryOperation("×", *))
        
        //原型是: knownOps["+"] = Op.BinaryOperation("+", (Double, Double) -> Double)
        knownOps["+"] = Op.BinaryOperation("+", +)
        knownOps["-"] = Op.BinaryOperation("-") { $1 - $0 } // cannot change order !
        knownOps["÷"] = Op.BinaryOperation("÷") { $1 / $0 }
        knownOps["√"] = Op.UnaryOperation("√", sqrt)

    }
    
    typealias PropertyList = AnyObject
    
    // add a public property program to CalculatorBrain and this caller won't know what kind of object it is
    var program: AnyObject {//guaranteed to be PropertyList, built from known peices
        get {
            return opStack.map { $0.description }
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    }
                }
            }
        }
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            
            case .UnaryOperation(_, let operation): // _ means don't care ; let operation: Double -> Double
                let operandEvaluation = evaluate(remainingOps)
                
                if let operand = operandEvaluation.result {
                    
                    return ( operation(operand), operandEvaluation.remainingOps)
                }
                
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return ( operation(operand1, operand2), op2Evaluation.remainingOps)
                    }

                }
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        
        print("\(opStack) = \(result) with \(remainder) left over ")
        return result
    }
    
    // 输入了一个数 作为运算数
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    // 输入了一个运算符
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {   //operation change from optional Op to Op
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func reset() {
        opStack.removeAll()
    }
}