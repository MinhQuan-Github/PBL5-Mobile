//
//  ViewController.swift
//  PBL5
//
//  Created by Minh Quan on 27/05/2023.
//

import UIKit
import WebKit
import Lottie

protocol DetectReturnProtocol: AnyObject {
    func didReturnResult(model: ResultModel)
}

class ViewController: UIViewController {
    
    @IBOutlet var animationView: LottieAnimationView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var historyTableView: UITableView!
    
    var data: [ResultModel] = []
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.animationView.contentMode = .scaleAspectFit
        self.animationView.loopMode = .loop
        self.animationView.animationSpeed = 0.5
        self.animationView.play()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        self.initData()
    }
    
    let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Empty history"
        label.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        return label
    }()
    
    func initData() {
        self.data = DBHelper.instance.readData()
    }
    
    func initUI() {
        self.webView.layer.borderWidth = 1.0
        self.webView.layer.borderColor = UIColor.darkGray.cgColor
        self.startButton.layer.cornerRadius = 15
        self.stopButton.layer.cornerRadius = 15
        self.captureButton.layer.cornerRadius = 15
        self.historyTableView.layer.cornerRadius = 20
        self.historyTableView.register(UINib(nibName: HistoryTableViewCell.identifier, bundle: .main), forCellReuseIdentifier: HistoryTableViewCell.identifier)
    }
    

    @IBAction func playTap(_ sender: UIButton) {
        self.animationView.isHidden = true
        let url = "\(BASE_DOMAIN):5000/streaming"

        let request = URLRequest(url: URL(string: url)!)
        webView.load(request)
    }
    
    @IBAction func stopTap(_ sender: UIButton) {
        webView.stopLoading()
    }
    
    @IBAction func captureTap(_ sender: UIButton) {
        if let capturedImage = captureImage(from: webView) {
            let vc = AlertViewController(image: capturedImage)
            vc.delegate = self
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }

    func captureImage(from view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        view.layer.render(in: context)
        
        guard let capturedImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        
        return capturedImage
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.data.isEmpty {
            self.emptyLabel.translatesAutoresizingMaskIntoConstraints = false
            self.historyTableView.addSubview(self.emptyLabel)
            self.emptyLabel.centerXAnchor.constraint(equalTo: self.historyTableView.centerXAnchor).isActive = true
            self.emptyLabel.centerYAnchor.constraint(equalTo: self.historyTableView.centerYAnchor).isActive = true
        } else {
            self.emptyLabel.isHidden = true
        }
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController(model: self.data[indexPath.row])
//        vc.config(model: self.data[indexPath.row])
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HistoryTableViewCell.identifier, for: indexPath) as! HistoryTableViewCell
        cell.config(model: self.data[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
}

extension ViewController: DetectReturnProtocol {
    func didReturnResult(model: ResultModel) {
        self.data = DBHelper.instance.readData()
        DispatchQueue.main.async {
            self.historyTableView.reloadData()
        }
    }
}

//class ViewController: UIViewController {
//
//    @IBOutlet weak var textField: UITextField!
//    @IBOutlet weak var greyView: UIView!
//
//
//    private let videoPlayer = StreamingVideoPlayer()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupVideoPlayer()
//    }
//
//    func setupVideoPlayer() {
//        videoPlayer.add(to: greyView)
//    }
//
//    @IBAction func playTap(_ sender: UIButton) {
//        guard let text = textField.text , let url = URL(string: text) else {
//            print("error")
//            return
//        }
//
//        videoPlayer.play(url: url)
//    }
//
//    @IBAction func stopTap(_ sender: UIButton) {
//        videoPlayer.pause()
//    }
//
//    @IBAction func clearTap(_ sender: UIButton) {
//        self.textField.text = ""
//        videoPlayer.pause()
//    }
//
//}

