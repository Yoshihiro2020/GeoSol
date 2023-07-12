//
//  ImagesViewController.swift
//  GeoSol
//
//  Created by TOMA on 2018/11/16.
//

import UIKit

class ImagesViewController: UIViewController {

    var images: [UIImage]!
    var i = 0
    var length = 0
    @IBOutlet weak var imagesView: UIImageView!
    @IBOutlet weak var preAns: UIButton!
    @IBOutlet weak var nextAns: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        length = images.count
        imagesView.layer.borderWidth = 1.0
        imagesView.layer.borderColor = UIColor.black.cgColor
        imagesView.image = images[0]
        preAns.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func showPre(_ sender: Any) {
        i -= 1
        imagesView.image = images[i]
        nextAns.isHidden = false
        if(i == 0) {
            preAns.isHidden = true
        }
    }
    
    @IBAction func showNext(_ sender: Any) {
        i += 1
        imagesView.image = images[i]
        preAns.isHidden = false
        if(i == length-1) {
            nextAns.isHidden = true
        }
    }
    
    @IBAction func nextUser(_ sender: Any) {
        let alert: UIAlertController = UIAlertController(title: "回答は完了しましたか？", message:"", preferredStyle:  UIAlertController.Style.alert)
        
        let defaultAction: UIAlertAction = UIAlertAction(title: "はい", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "toTop", sender: nil)
        })
        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "いいえ", style: UIAlertAction.Style.cancel, handler:{
            (action: UIAlertAction!) -> Void in
        })
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
     */
}
