//
//  DetailViewController.swift
//  PBL5
//
//  Created by Minh Quan on 28/05/2023.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    let model: ResultModel!
    
    init(model: ResultModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = decodeBase64Image(base64String: model.image)
        self.textView.text = model.result
        self.textView.isUserInteractionEnabled = false
        self.textView.layer.cornerRadius = 20
        self.textView.layer.borderColor = UIColor.darkGray.cgColor
        self.textView.backgroundColor = .white
    }


}
