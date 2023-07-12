//
//  Q5.swift
//  GeoSol
//
//  Created by 三浦将人 on 2019/12/03.
//


import Foundation


import UIKit

class Q5ViewController: UIViewController {
    
    //MARK: Property
    
    let pencil = UIImage(named: "pencil.png")
    let pencilSelected = UIImage(named: "pencil_selected.png")
    let eraser = UIImage(named: "eraser.png")
    let eraserSelected = UIImage(named: "eraser_selected.png")
    
    var isPencil = true
    @IBOutlet weak var pencilButton: UIButton!
    @IBOutlet weak var eraserButton: UIButton!
    @IBOutlet weak var solutionNum: UILabel!
    @IBOutlet weak var sawClue: UILabel!
    @IBOutlet weak var endExp: UIButton!
    @IBOutlet weak var clueView: UIView!
    @IBOutlet weak var cluePoint: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var clueButton: UIButton!
    @IBOutlet weak var solutionButton: UIButton!
    @IBOutlet weak var usedButton: UIButton!
    
    @IBOutlet weak var sketchView: SketchView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var clueImg: UIImageView!
    
    @IBOutlet weak var timerLabel: UILabel!
    
    var textFileName = ".txt"
    let initialText = ""
    let documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    var userID: Int?
    var solution = 1
    var startTime: TimeInterval?
    var stopTime: TimeInterval?
    
    var methods = ["解法Aを使用", "解法Bを使用", "解法Cを使用"] //expected solution methods
    var usedNum = 0
    var sawSolution = false
    var didUseClue = false
    var images: [UIImage]!
    
    var timer = Timer()
    var startTimer: Double!
    
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
        
        if(leftTime == 300) {
            let alert = UIAlertController(title: "残り5分です。\nヒントボタンを押して、\n未使用の解法がないか確認してください。", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        } else if(leftTime == 0) {
            timer.invalidate()
            let alert = UIAlertController(title: "時間です。\n解答を終了してください。", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            endExp.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startTime = ProcessInfo.processInfo.systemUptime
        startTimer = Date().timeIntervalSince1970
        timerLabel.text = "20:00"
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateLabel), userInfo: nil, repeats: true)
        userLabel.text = "User: \(String(describing: userID!))"
        solutionNum.text = "答案" + String(solution)
        view.addSubview(sketchView)
        clueView.isHidden = true
        cluePoint.isHidden = true
        sawClue.isHidden = true
        endExp.isHidden = true
        sketchView.lineWidth = CGFloat(2)
        textFileName = "q1_" + String(userID!) + ".txt"
        createTextFile()
    }
    
    // MARK: Actions
    
    @IBAction func pencilSelected(_ sender: Any) {
        if(!isPencil){
            pencilButton.setImage(pencilSelected, for: .normal)
            eraserButton.setImage(eraser, for: .normal)
            sketchView.drawTool = SketchToolType.pen
            sketchView.lineWidth = CGFloat(2)
            isPencil = !isPencil
        }
    }
    
    @IBAction func eraserSelected(_ sender: Any) {
        if(isPencil){
            eraserButton.setImage(eraserSelected, for: .normal)
            pencilButton.setImage(pencil, for: .normal)
            sketchView.drawTool = SketchToolType.eraser
            sketchView.lineWidth = CGFloat(20)
            isPencil = !isPencil
        }
    }
    
    
    func recordData() {
        let strokes = sketchView.strokes
        var str, substr: String
        var i = 0
        str = "solution" + String(solution) + "\n"
        str += String(Int(startTime!*1000))
        appendText(fileURL: documentDirectoryFileURL.appendingPathComponent(textFileName), string: str)  //for real device implementation
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
            appendText(fileURL: documentDirectoryFileURL.appendingPathComponent(textFileName), string: str)  //for real device implementation
        }
        str = String(Int(stopTime!*1000))
        appendText(fileURL: documentDirectoryFileURL.appendingPathComponent(textFileName), string: str)  //for real device implementation
        //コンテキスト開始
        UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, false, 0.0)
        //viewを書き出す
        self.view.drawHierarchy(in: self.view.bounds, afterScreenUpdates: true)
        // imageにコンテキストの内容を書き出す
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        //コンテキストを閉じる
        UIGraphicsEndImageContext()
        //imageをアプリ内に保存
        let fileName = "q1_" + String(userID!) + "_" + String(solution) + ".png"
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
    }
    
    @IBAction func useThisMethod(_ sender: Any) {
        clueView.isHidden = true
        didUseClue = true
        if(sawSolution) {
            sawClue.textColor = UIColor.red
        } else {
            sawClue.textColor = UIColor(displayP3Red: 0/255, green: 162/255, blue: 1, alpha: 1.0)
        }
        sawClue.text = methods[usedNum]
        doneButton.isHidden = false
        clueButton.isHidden = false
    }
    
    @IBAction func alreadyUsed(_ sender: Any) {
        used()
        usedButton.isHidden = true
    }
    
    func used() {
        usedNum += 1
        sawSolution = false
        clueImg.isHidden = false
        cluePoint.isHidden = true
        solutionButton.setImage(UIImage(named: "solution.png"), for: .normal)
        solutionButton.isHidden = false
        if(usedNum == 1) {
            clueImg.image = UIImage(named: "q1_clueB.png")
            cluePoint.image = UIImage(named: "q1_clue2B.png")
        } else if(usedNum == 2) {
            clueImg.image = UIImage(named: "q1_clueC.png")
            cluePoint.image = UIImage(named: "q1_clue2C.png")
        } else {
            endExp.isHidden = false
            clueView.isHidden = true
            doneButton.isHidden = false
            clueButton.isHidden = true
        }
    }
    
    @IBAction func showSolution(_ sender: Any) {
        clueImg.isHidden = true
        cluePoint.isHidden = false
        usedButton.isHidden = false
        solutionButton.isHidden = true
        sawSolution = true
    }
    
    
    @IBAction func endQuestion(_ sender: Any) {
        let alert: UIAlertController = UIAlertController(title: "解答を終了しますか？", message: "", preferredStyle:  UIAlertController.Style.alert)
        
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

