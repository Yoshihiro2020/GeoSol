//
//  Q1ViewController.swift
//  GeoSol
//
//  Created by TOMA on 2018/09/29.
//  Copyright © 2018 TOMA. All rights reserved.
//

import UIKit

class Q1ViewController: UIViewController {
    
    //MARK: Property
    
    let pencil = UIImage(named: "pencil.png")
    let pencilSelected = UIImage(named: "pencil_selected.png")
    let eraser = UIImage(named: "eraser.png")
    let eraserSelected = UIImage(named: "eraser_selected.png")
    
    @IBOutlet weak var imageview1: UIImageView!
    
    @IBOutlet weak var pencilButton: UIButton!
    @IBOutlet weak var eraserButton: UIButton!
    var isPencil = true
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var solutionNum: UILabel!
    @IBOutlet weak var sawClue: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var clueButton: UIButton!
    @IBOutlet weak var clueImg: UIImageView! //clue1
    @IBOutlet weak var clueView: UIView!
    @IBOutlet weak var cluePoint: UIImageView! //clue2
    @IBOutlet weak var solutionButton: UIButton!
    @IBOutlet weak var usedButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var problemNum: UILabel!
    
    @IBOutlet weak var sketchView: SketchView!
    
    @IBOutlet weak var timerLabel: UILabel!
    
//    let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate

    var textFileName = ".txt"
    let initialText = ""
    
    var url1 = ""
    var url2 = ""
    var url3 = ""
    
    
    let documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    var userID: Int?
    var problemID: Int?
    var solution = 1
    var startTime: TimeInterval?
    var stopTime: TimeInterval?
    var hintTime: TimeInterval?
    
    var usedNum = 0
    var didUseClue = false
    var sawSolution = false
    let methods = ["解法Aを使用", "解法Bを使用", "解法Cを使用"]

    var images = [UIImage]()
    
    var timenow: TimeInterval?
    
    var timer = Timer()
    var startTimer: Double!
    var stopTimer: TimeInterval?
    
    func createTextFile() {
        let targetTextFilePath = documentDirectoryFileURL.appendingPathComponent(textFileName)
        print("target file path: \(targetTextFilePath)")
        do {
            try initialText.write(to: targetTextFilePath, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("failed to write: \(error)")
        }
    }
    
    func appendText(fileURL: URL, string: String) {
        do {
            let fileHandle = try FileHandle(forWritingTo: fileURL)
            
            // 改行を入れる
            let stringToWrite = "\n" + string
            
            // ファイルの最後に追記
            fileHandle.seekToEndOfFile()
            fileHandle.write(stringToWrite.data(using: String.Encoding.utf8)!)
        } catch let error as NSError {
            print("failed to append: \(error)")
        }
    }
    
    private func saveImage (image: UIImage, fileName: String ) {
        //pngで保存する場合
        let pngImageData = image.pngData()
        // jpgで保存する場合
        //    let jpgImageData = UIImageJPEGRepresentation(image, 1.0)
        let fileURL = documentDirectoryFileURL.appendingPathComponent(fileName)
        do {
            try pngImageData!.write(to: fileURL)
        } catch {
            //エラー処理
        }
    }
    
    @objc func updateLabel() {
        let elapsedTime = Int(Date().timeIntervalSince1970 - startTimer)
        let leftTime = 1200 - elapsedTime
        let leftMin = leftTime / 60
        let leftSec = leftTime - leftMin * 60
        let dispStr: String!
        if(leftSec < 10) {
            dispStr = "\(leftMin):0\(leftSec)"
        } else {
            dispStr = "\(leftMin):\(leftSec)"
        }
        timerLabel.text = dispStr
        
        if(leftTime == 600) {
            let alert = UIAlertController(title: "10分経過。\n証明問題の場合は\n解答を続けてください。", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        } else if(leftTime == 0) {
            timer.invalidate()
            let alert = UIAlertController(title: "時間です。「できた！」ボタンを押して\n次の問題に進んでください。", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            nextButton.isHidden = false
        }
        if(problemID == 0) {
            let alert = UIAlertController(title: "この表示が出た場合は\n実験担当者をお呼びください。", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
        if(userID == 0) {
            let alert = UIAlertController(title: "この表示が出た場合は\n実験担当者をお呼びください。", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func getImageByUrl(url: String) -> UIImage{
        let url = URL(string: url)
        do {
            let data = try Data(contentsOf: url!)
            return UIImage(data: data)!
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }
        return UIImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startTime = ProcessInfo.processInfo.systemUptime
        startTimer = Date().timeIntervalSince1970
        timerLabel.text = "20:00"
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateLabel), userInfo: nil, repeats: true)
        
        let image1:UIImage = getImageByUrl(url:url1)
        self.imageview1.image = image1
        let image2:UIImage = getImageByUrl(url:url2)
        self.clueImg.image = image2
        let image3:UIImage = getImageByUrl(url:url3)
        self.cluePoint.image = image3
        
        userLabel.text = "User: \(String(describing: userID!))"
        solutionNum.text = "答案" + String(solution)
        problemNum.text = "問題: \(String(describing: problemID!))"
        view.addSubview(sketchView)
        clueView.isHidden = true
        cluePoint.isHidden = true
        sawClue.isHidden = true
        nextButton.isHidden = true
        sketchView.lineWidth = CGFloat(2)
        textFileName = "q" + String(problemID!) + "_" + String(userID!) + ".txt"
        createTextFile()
    }

    // MARK: Actions
    
    @IBAction func usePencil(_ sender: Any) {
        if(!isPencil){
            pencilButton.setImage(pencilSelected, for: .normal)
            eraserButton.setImage(eraser, for: .normal)
            sketchView.drawTool = SketchToolType.pen
            sketchView.lineWidth = CGFloat(2)
            isPencil = !isPencil
        }
    }
    
    @IBAction func useEraser(_ sender: Any) {
        if(isPencil){
            eraserButton.setImage(eraserSelected, for: .normal)
            pencilButton.setImage(pencil, for: .normal)
            sketchView.drawTool = SketchToolType.eraser
            sketchView.lineWidth = CGFloat(20)
            isPencil = !isPencil
        }
    }
    
    func recordData(){
        let strokes = sketchView.strokes
        var str, substr: String
        var i = 0
        str = "solution" + String(solution) + "\n"
        str += String(Int(startTime!*1000))
        //print(str)
        appendText(fileURL: documentDirectoryFileURL.appendingPathComponent(textFileName), string: str)
        for stroke in strokes{
            str = "{'\(sketchView.states[i])':["
            i += 1
            for point in stroke{
                substr = "{'time':\(Int(point.timestamp*1000)),'x':\(point.location.x),'y':\(point.location.y),'force':\(point.force),'altAng':\(point.altitudeAngle),'azmAng':\(point.azimuthAngle)},"
                str += substr
            }
            str = String(str.dropLast())
            str += "]}"
            print(str) //debugging
            appendText(fileURL: documentDirectoryFileURL.appendingPathComponent(textFileName), string: str)
        }
        //timenow = Date().timeIntervalSince1970
        str = String(Int(stopTime!*1000))
        //print(str)
        appendText(fileURL: documentDirectoryFileURL.appendingPathComponent(textFileName), string: str)
        
        //コンテキスト開始
        UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, false, 0.0)
        //viewを書き出す
        self.view.drawHierarchy(in: self.view.bounds, afterScreenUpdates: true)
        // imageにコンテキストの内容を書き出す
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        //コンテキストを閉じる
        UIGraphicsEndImageContext()
        //imageをアプリ内に保存
        timenow = Date().timeIntervalSince1970
        let fileName = "q" + String(problemID!) + "_" + String(userID!) + "_fin" + String(solution) + "_2022_" + String(Int(timenow!)) + ".png"
        self.saveImage(image: image, fileName: fileName)
        //imageをimagesに追加
        images.append(image)
        // imageをカメラロールに保存
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        solution += 1
    }
    
    @IBAction func dispAlert(_ sender: Any) {
        let alert: UIAlertController = UIAlertController(title: "現在の答案を保存し、\n新しい解答画面を表示します。", message: "", preferredStyle:  UIAlertController.Style.alert)
        
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            self.stopTime = ProcessInfo.processInfo.systemUptime

            if(self.didUseClue) {
                self.sawClue.isHidden = false
                self.recordData()
                self.used()
                self.didUseClue = false
            } else {
                self.recordData()
            }
            self.sketchView.clear()
            self.solutionNum.text = "答案" + String(self.solution)
            self.sawClue.isHidden = true
            self.nextButton.isHidden = false
            self.startTime = ProcessInfo.processInfo.systemUptime
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
        usedButton.isHidden = true
        self.hintTime = ProcessInfo.processInfo.systemUptime
        let strhint = "PushHint" + String(Int(hintTime!*1000))
        appendText(fileURL: documentDirectoryFileURL.appendingPathComponent(textFileName), string: strhint)
    }
    
    @IBAction func useThisMethod(_ sender: Any) {
        clueView.isHidden = true
        didUseClue = true
        if(sawSolution) {
            sawClue.textColor = UIColor.red
        } else {
            sawClue.textColor = UIColor(displayP3Red: 0/255, green: 162/255, blue: 1.0, alpha: 1.0)
        }
        sawClue.text = methods[usedNum]
        doneButton.isHidden = false
        clueButton.isHidden = false
        self.hintTime = ProcessInfo.processInfo.systemUptime
        let strhint = "PushUse" + String(Int(hintTime!*1000))
        appendText(fileURL: documentDirectoryFileURL.appendingPathComponent(textFileName), string: strhint)
    }
    
    @IBAction func alreadyUsed(_ sender: Any) {
        used()
        usedButton.isHidden = true
        self.hintTime = ProcessInfo.processInfo.systemUptime
        let strhint = "PushAlready" + String(Int(hintTime!*1000))
        appendText(fileURL: documentDirectoryFileURL.appendingPathComponent(textFileName), string: strhint)
    }
    
    func used() {
        usedNum += 1
        sawSolution = false
        clueImg.isHidden = false
        cluePoint.isHidden = true
        solutionButton.setImage(UIImage(named: "solution.png"), for: .normal)
        solutionButton.isHidden = false
        if(usedNum == 1) {
            nextButton.isHidden = true
            clueView.isHidden = true
            doneButton.isHidden = false
            clueButton.isHidden = true
        }
    }
    
    
    @IBAction func showSolution(_ sender: Any) {
        clueImg.isHidden = true
        cluePoint.isHidden = false
        usedButton.isHidden = true
        solutionButton.isHidden = true
        sawSolution = true
        self.hintTime = ProcessInfo.processInfo.systemUptime
        let strhint = "PushSolution" + String(Int(hintTime!*1000))
        appendText(fileURL: documentDirectoryFileURL.appendingPathComponent(textFileName), string: strhint)
    }
    
    @IBAction func nextQuestion(_ sender: Any) {
        let alert: UIAlertController = UIAlertController(title: "解答終了後に「できた！」ボタンは押しましたか？", message: "", preferredStyle:  UIAlertController.Style.alert)
        
        let defaultAction: UIAlertAction = UIAlertAction(title: "はい", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "toEND", sender: nil)
        })
        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
            (action: UIAlertAction!) -> Void in
        })
        
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
    
    

    // MARK: Rotation
    
    override var shouldAutorotate: Bool {
        get { return true }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get { return [.portrait] }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let endViewController = segue.destination as! EndViewController
        endViewController.images = images
        // Pass the selected object to the new view controller.
    }
    
}
