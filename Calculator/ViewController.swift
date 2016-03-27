//
//  ViewController.swift
//  Calculator
//
//  Created by Xi Cheng on 16/1/3.
//  Copyright © 2016年 Xi Cheng. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!

    var userIsTying : Bool = false
    var inputFloat : Bool = false
    
    @IBAction func clean(sender: UIButton) {
        brain.reset()
        userIsTying = false
        displayValue = 0
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if digit == "." {
            if inputFloat == true {
                //error
            }
            else {
                inputFloat = true
            }
        }
        
        if userIsTying {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsTying = true
        }
        print(" digit = \(digit) ")
        
    }

    // the green arrow from controller to model: can be DB to get data
    var brain = CalculatorBrain()
    
    @IBAction func operate(sender: UIButton) {

        if userIsTying {
            // 3,enter,6,enter,× : x don't push 2nd 6
            enter()
        }
        
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = 0
            }
            
//            switch operation {
//            case "×": performOperation { $0 * $1 }
//            case "−": performOperation { $1 - $0 } // $0 is 1st removelast(), $1 is 2nd removelast()
//            case "+": performOperation { $0 + $1 }
//            case "÷": performOperation { $1 / $0 }
//            case "√": performOperation { sqrt($0) }
//            default: break
//            }
        }
    }
    

//    func performOperation( operations: (Double,Double) -> Double ) {
//        if operandStack.count >= 2 {
//            displayValue = operations(operandStack.removeLast(),operandStack.removeLast())
//            enter()
//        }
//    }
    
//    //Objective－C不支持函数重载：
//    private func performOperation( operations: Double -> Double ) {
//        if operandStack.count >= 1 {
//            displayValue = operations(operandStack.removeLast())
//            enter()
//        }
//    }
    
//    var operandStack = Array<Double>()
    
    @IBAction func enter() {
        userIsTying = false
//        operandStack.append( displayValue)
//        print(" operandStack = \(operandStack) ")
        
        if let result = brain.pushOperand(displayValue) {
            displayValue = result
        }else {
            // for nil still display sth, 0
            displayValue = 0
        }
    }

    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            display.text = "\(newValue)"
            userIsTying = false
        }
    }
}

