//
//  EndViewController.swift
//  GeoSol
//
//  Created by TOMA on 2018/09/30.
//

import UIKit

class EndViewController: UIViewController {

    var images: [UIImage]!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let imagesViewController = segue.destination as! ImagesViewController
        imagesViewController.images = images
    }


}
