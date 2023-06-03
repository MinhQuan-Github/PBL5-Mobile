//
//  HistoryTableViewCell.swift
//  PBL5
//
//  Created by Minh Quan on 28/05/2023.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    
    static let identifier = "HistoryTableViewCell"
    
    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var resultTextView: UITextView!
    
    var model: ResultModel!
    
    func config(model: ResultModel) {
        self.model = model
        self.resultTextView.text = model.result
        self.resultImageView.image = decodeBase64Image(base64String: model.image)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = 20
        self.resultImageView.layer.borderColor = UIColor.darkGray.cgColor
        self.resultImageView.layer.borderWidth = 1
        self.resultImageView.layer.cornerRadius = 12
        self.resultTextView.layer.borderColor = UIColor.darkGray.cgColor
        self.resultTextView.layer.borderWidth = 1
        self.resultTextView.layer.cornerRadius = 12
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
