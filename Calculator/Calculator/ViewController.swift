//
//  ViewController.swift
//  Calculator
//
//  Created by LiuFlueg on 12/1/15.
//  Copyright © 2015 LiuFlueg. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{

    @IBOutlet weak var display: UILabel!

    @IBOutlet weak var processDisplay: UILabel!
    
    var userIsTypingNumbers:Bool = false
    var showOperationStack = false
    
    var brain = CalculatorBrain()

    @IBAction func appendDigit(sender: UIButton)
    {
        let digit = sender.currentTitle!
        if userIsTypingNumbers {
            display.text = display.text! + digit
            processDisplay.text! += digit
        } else {
            display.text = digit
            userIsTypingNumbers = true
            if !showOperationStack {
                processDisplay.text! = digit
                showOperationStack = true
            } else {
                processDisplay.text! += digit
            }
        }
        
//        print("digit = \(digit)")
    }

   
    @IBAction func operate(sender: UIButton) {
        if userIsTypingNumbers {
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
                processDisplay.text! += operation
            } else {
                displayValue = 0
            }

        }
    }

    @IBAction func enter() {
        userIsTypingNumbers = false
        //        operandStack.append(displayValue)
        //        print("Enter operandStack = \(operandStack)")
        if showOperationStack {
            processDisplay.text! += ", "
        }
        if let result = brain.pushOperand(displayValue) {
            displayValue = result
        } else {
            displayValue = 0
        }
        
    }
    
    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            // There's a magic varable newValue
            display.text = "\(newValue)"
        }
    }
    
    @IBAction func delete() {
        userIsTypingNumbers = false
        display.text = "\(0)"
        brain.cancle()
        processDisplay.text = "\(0)"
        showOperationStack = false
//        print("DEL operandStack = \(operandStack)")

    }

}

