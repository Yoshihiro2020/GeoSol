//
//  ViewController.swift
//  GeoSol
//
//  Created by TOMA on 2018/04/25.
//  Copyright © 2018 TOMA. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var userID = 0
    var problemID = 0
    
    @IBOutlet weak var userField: UITextField!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var clueButton: UIButton!
    @IBOutlet weak var solutionButton: UIButton!
    @IBOutlet weak var solveButton: UIButton!
    @IBOutlet weak var usedButton: UIButton!
    @IBOutlet weak var clueView: UIView!
    @IBOutlet weak var clueLabel: UILabel!
    @IBOutlet weak var problemField: UITextField!
    
    @IBOutlet weak var url1: UITextField!
    @IBOutlet weak var url2: UITextField!
    @IBOutlet weak var url3: UITextField!
    
    @IBAction func inputUser(_ sender: UITextField) {
        userLabel.text = userField.text
        userID = Int(userLabel.text!)!
        startButton.isHidden = false
    }
    
    @IBAction func inputProblem(_ sender: UITextField){
        userLabel.text = problemField.text
        problemID = Int(userLabel.text!)!
    }
    
    
    @IBOutlet weak var sketchView: SketchView!
    @IBOutlet weak var pencilButton: UIButton!
    @IBOutlet weak var eraserButton: UIButton!
    
    let pencil = UIImage(named: "pencil.png")
    let pencilSelected = UIImage(named: "pencil_selected.png")
    let eraser = UIImage(named: "eraser.png")
    let eraserSelected = UIImage(named: "eraser_selected.png")
    var isPencil = true
    var isSolDisp = false
    
    @IBAction func pencilUse(_ sender: Any) {
        if(!isPencil){
            pencilButton.setImage(pencilSelected, for: .normal)
            eraserButton.setImage(eraser, for: .normal)
            sketchView.drawTool = SketchToolType.pen
            sketchView.lineWidth = CGFloat(2)
            isPencil = !isPencil
        }
    }
    
    @IBAction func eraserUse(_ sender: Any) {
        if(isPencil){
            eraserButton.setImage(eraserSelected, for: .normal)
            pencilButton.setImage(pencil, for: .normal)
            sketchView.drawTool = SketchToolType.eraser
            sketchView.lineWidth = CGFloat(5)
            isPencil = !isPencil
        }
    }
    
    
    func getID() -> Int{
        return userID
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startButton.isHidden = true
        userField.layer.cornerRadius = 10.0
        userField.layer.masksToBounds = true
        userField.layer.borderColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1).cgColor
        userField.layer.borderWidth = 1.5
        clueView.isHidden = true
    }
    
    @IBAction func dispAlert(_ sender: Any) {
        let alert: UIAlertController = UIAlertController(title: "現在の答案を保存し、\n新しい解答画面を表示します。", message: "", preferredStyle:  UIAlertController.Style.alert)
        
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            self.sketchView.clear()
            self.clueLabel.text = "解法のヒントが表示されます。"
            self.solutionButton.isHidden = false
        })
        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
            (action: UIAlertAction!) -> Void in
        })
        
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func showClue(_ sender: Any) {
        clueView.layer.borderColor = UIColor.gray.cgColor
        clueView.layer.borderWidth = 1
        clueView.isHidden = false
        doneButton.isHidden = true
        clueButton.isHidden = true
        clueLabel.isHidden = false
        usedButton.isHidden = true
    }
    
    @IBAction func useThisMethod(_ sender: Any) {
        clueView.isHidden = true
        doneButton.isHidden = false
        clueButton.isHidden = false
    }
    
    @IBAction func usedThisMethod(_ sender: Any) {
        clueLabel.text = "次の解法のヒントが表示されます。"
        solutionButton.isHidden = false
        usedButton.isHidden = true
    }
    
    @IBAction func seeSolution(_ sender: Any) {
        clueLabel.text = "解法が表示されます。"
        solutionButton.isHidden = true
        usedButton.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getUrl1()->String{
        return url1.text!
    }
    
    func getUrl2()->String{
        return url2.text!
    }
    
    func getUrl3()->String{
        return url3.text!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let q1ViewController = segue.destination as! Q1ViewController
        q1ViewController.userID = userID
        q1ViewController.problemID = problemID
        q1ViewController.url1 = getUrl1()
        q1ViewController.url2 = getUrl2()
        q1ViewController.url3 = getUrl3()
    }

}

