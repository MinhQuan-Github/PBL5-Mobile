//
//  AlertViewController.swift
//  PBL5
//
//  Created by Minh Quan on 28/05/2023.
//

import UIKit
import KRProgressHUD

class AlertViewController: UIViewController {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okeButton: UIButton!
    @IBOutlet weak var resultimageView: UIImageView!
    @IBOutlet weak var mainView: UIView!
    
    let image: UIImage!
    var delegate: DetectReturnProtocol?
    
    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3001987172)
    }
    
    private func initUI() {
        self.resultimageView.image = image
        self.cancelButton.layer.cornerRadius = 12
        self.okeButton.layer.cornerRadius = 12
        self.resultimageView.layer.borderColor = UIColor.darkGray.cgColor
        self.resultimageView.layer.borderWidth = 2
        self.resultimageView.layer.cornerRadius = 20
        self.mainView.layer.cornerRadius = 20
    }
    
    @IBAction func okeTap(_ sender: UIButton) {
        KRProgressHUD.show(withMessage: "Loading...")
        let base64Image = encodeImageToBase64(image: self.image)!
        sendImageToAPI(imageBase64: base64Image, completion: { response in
            print(response)
            if let value = extractValueFromResponse(responseString: response, key: "result") {
                print("Value: \(value)")
                let model = ResultModel(image: base64Image, result: value)
                DBHelper.instance.insertData(resultModel: model)
                self.delegate?.didReturnResult(model: model)
            } else {
                print("Failed to extract value for key: result")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
               KRProgressHUD.dismiss()
                self.dismiss(animated: true)
            }
        }, failure: {
            let model = ResultModel(image: encodeImageToBase64(image: UIImage(systemName: "photo")!), result: "Error load data")
            DBHelper.instance.insertData(resultModel: model)
            self.delegate?.didReturnResult(model: model)
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
               KRProgressHUD.dismiss()
                self.dismiss(animated: true)
            }
        })
    }
    
    @IBAction func cancelTap(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

func decodeBase64Image(base64String: String) -> UIImage? {
    // Convert the base64 string to data
    guard let imageData = Data(base64Encoded: base64String) else {
        return nil
    }
    
    // Create the image from the data
    guard let image = UIImage(data: imageData) else {
        return nil
    }
    
    return image
}

func encodeImageToBase64(image: UIImage) -> String? {
    // Convert the image to data
    guard let imageData = image.jpegData(compressionQuality: 1.0) else {
        return nil
    }
    
    // Convert the data to a base64 string
    let base64String = imageData.base64EncodedString(options: [])
    
    return base64String
}
