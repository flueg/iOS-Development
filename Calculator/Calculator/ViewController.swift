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
    
    var brain = CalculatorBrain()

    var stackHistory: String? {
        get {
            if let result = brain.dumpHistory() {
                return result
            }
            return nil
        }
    }
    
    @IBAction func appendDigit(sender: UIButton)
    {
        let digit = sender.currentTitle!
        
        if let history = stackHistory {
            processDisplay.text = history
        } else {
            processDisplay.text = ""
        }

        if userIsTypingNumbers {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsTypingNumbers = true
        }
        processDisplay.text! += display.text!
        
//        print("digit = \(digit)")
    }

   
    @IBAction func operate(sender: UIButton) {
        if userIsTypingNumbers {
            enter()
        }

        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
//                displayValue = 0
            }
            
            if let proText = brain.dumpOpStack() {
                processDisplay.text! = proText
            }

        }
    }

    @IBAction func enter() {
        userIsTypingNumbers = false
        //        operandStack.append(displayValue)
        //        print("Enter operandStack = \(operandStack)")
        if !processDisplay.text!.hasSuffix(", ") {
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
            if let result = NSNumberFormatter().numberFromString(display.text!) {
                return result.doubleValue
            }
            return 0
        }
        set {
            // There's a magic varable newValue
            display.text = "\(newValue)"
        }
    }
    
    @IBAction func delete() {
        if userIsTypingNumbers {
            enter()
        }
        
        if let result = brain.backSpace() {
            displayValue = result
        } else {
            displayValue = 0
        }
        
        if let history = stackHistory {
            processDisplay.text = history
        } else {
            processDisplay.text = ""
        }
        
    }

    @IBAction func clearStack() {
        userIsTypingNumbers = false
        display.text = "\(0)"
        brain.cancle()
        processDisplay.text = "\(0)"
    }
    
    @IBAction func backSpace() {
        if userIsTypingNumbers {
            let newDispay = String(display.text!.characters.dropLast())
            display.text = newDispay

            if let history = stackHistory {
                processDisplay.text = history
            } else {
                processDisplay.text = ""
            }

            processDisplay.text! += newDispay
        }
    }
}

