//
//  ViewController.swift
//  SimpleGUI
//
//  Created by TOMA on 2018/04/25.
//  Copyright © 2018 TOMA. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var userField: UITextField!
    @IBOutlet weak var userLabel: UILabel!

    @IBAction func inputUser(_ sender: UITextField) {
        userLabel.text = userField.text
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

