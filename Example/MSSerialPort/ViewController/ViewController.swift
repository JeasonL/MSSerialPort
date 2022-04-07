//
//  ViewController.swift
//  MSSerialPort
//
//  Created by Jeason Lee on 2022/3/23.
//

import CryptoSwift
import SnapKit
import SwifterSwift
import UIKit
import MSSerialPort

enum Factory: CaseIterable {
    static var allCases: [Factory] = [.Forick, .Jiecang(type: .LiftCabinet), .Jiecang(type: .TranslationDesk), .Opike, .Lemanli, .Autorail]
    
    case Forick, Jiecang(type: Jiecang.ProductType), Opike, Lemanli, Autorail
    var name: String {
        switch self {
        case .Forick:
            return "弗雷克"
        case let .Jiecang(type):
            return "捷昌" + " - " + type.name
        case .Opike:
            return "欧派克"
        case .Lemanli:
            return "乐满力"
        case .Autorail:
            return "奥特威"
        }
    }
    
    var viewController: UIViewController {
        switch self {
        case .Forick:
            return ForickViewController()
        case let .Jiecang(type):
            return JiecangViewController(type: type)
        case .Opike:
            return OpikeViewController()
        case .Lemanli:
            return LemanliViewController()
        case .Autorail:
            return AutorailViewController()
        }
    }
}

class ViewController: UIViewController {
    var models: [Factory] = Factory.allCases
    
    private let cellIdentifier = "UITableViewCell"
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    

    private lazy var forickButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("弗雷克", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(forickAction), for: .touchUpInside)
        return button
    }()

    @objc func forickAction() {
        let viewController = ForickViewController()
        navigationController?.pushViewController(viewController)
    }
    
    private lazy var opikeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("欧派克", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(opikeAction), for: .touchUpInside)
        return button
    }()

    @objc func opikeAction() {
        let viewController = OpikeViewController()
        navigationController?.pushViewController(viewController)
    }
    
    
    private lazy var lemanliButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("乐满力 - 风琴帘", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(lemanliAction), for: .touchUpInside)
        return button
    }()

    @objc func lemanliAction() {
        let viewController = LemanliViewController()
        navigationController?.pushViewController(viewController)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "第三方设备"
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = item.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = models[indexPath.row]
        navigationController?.pushViewController(item.viewController, animated: true)
    }
}
