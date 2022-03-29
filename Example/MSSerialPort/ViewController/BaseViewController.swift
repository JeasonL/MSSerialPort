//
//  BaseViewController.swift
//  MSSerialPort
//
//  Created by Jeason Lee on 2022/3/26.
//

import UIKit
import MSSerialPort

struct Item {
    var title: String = ""
    var subTitle: String = ""
    var command: Bytes = [] 
    
    init(title: String, command: Bytes) {
        self.title = title
        self.command = command
        self.subTitle = command.toHexString(hasSpace: true)
    }
}


class BaseViewController: UIViewController {
//    var selectedClosure: ((Int) -> Void)?
    var models: [Item] = []
    
    var ip: String {
        return textField.text?.components(separatedBy: ":").first ?? ""
    }

    var port: Int {
        return textField.text?.components(separatedBy: ":").last?.int ?? 0
    }
    
    lazy var client: MSNIOClient = {
        let client = MSNIOClient(host: ip, port: port)
         return client
     }()

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.textColor = .black
        textField.font = .systemFont(ofSize: 20.0)
        textField.placeholder = "IP Address"
        textField.text = "192.168.0.178:61233"
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        return textField
    }()

    private let cellIdentifier = "UITableViewCell"
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.register(BaseItemCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var connectButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("连接", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(connectAction), for: .touchUpInside)
        button.borderWidth = 1.0
        button.borderColor = UIColor.black
        return button
    }()

    private lazy var shutdownButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("断开连接", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(shutdownAction), for: .touchUpInside)
        button.borderWidth = 1.0
        button.borderColor = UIColor.black
        return button
    }()

    @objc func connectAction() {
        client.connect()
    }

    @objc func shutdownAction() {
        client.shutdown()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .fill
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 10.0
        buttonStackView.addArrangedSubviews([connectButton, shutdownButton])
   
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 15.0
        stackView.addArrangedSubviews([textField, buttonStackView])
        textField.snp.makeConstraints { make in
            make.height.equalTo(50.0)
        }
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100.0)
            make.left.equalToSuperview().offset(15.0)
            make.right.equalToSuperview().offset(-15.0)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(10.0)
            make.left.bottom.right.equalToSuperview()
        }
    }
    
    deinit {
        client.shutdown()
    }
}

extension BaseViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! BaseItemCell
        cell.title = item.title
        cell.subTitle = item.subTitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
