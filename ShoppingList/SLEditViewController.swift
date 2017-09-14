//
//  SLEditViewController.swift
//  ShoppingList
//
//  Created by Mac on 2017/09/10.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

protocol SLEditViewControllerDelegate {
    func editedList(aEditText: String, aNewText: [String])
    func newList(aNewText: [String])
}

class SLEditViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    var text:String?
    var font:UIFont?
    var isEditingMode = true
    var delegate:SLEditViewControllerDelegate?
        
    @IBAction func doneButtonPressed(_ sender: Any) {
        var editText = ""
        var newText = [String]()
        
        let textArray = textView.text.components(separatedBy: NSCharacterSet.newlines)
        
        for text in textArray {
            if !text.isEmpty {
                newText.append(text)
            }
        }
        
        if newText.count > 0 {
            if isEditingMode {
                editText = newText[0]
                newText.removeFirst()
            }
        }
        
        if isEditingMode {
            delegate?.editedList(aEditText: editText, aNewText: newText)
        }else {
            delegate?.newList(aNewText: textArray)
        }
        self.dismiss(animated: true) {
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true) {
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        
        textView.font = font
        textView.text = text
        textView.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func keyboardWillShow(_ notification:NSNotification) {
        if let keyboardSize = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? CGRect {
            bottomLayoutConstraint.constant = keyboardSize.height
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
