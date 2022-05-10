//
//  JiecangViewController.swift
//  MSSerialPort
//
//  Created by Jeason Lee on 2022/3/30.
//

import UIKit
import MSSerialPort

class JiecangViewController: BaseViewController {
    
    var type: Jiecang.ProductType = .LiftCabinet
    let cabinet = Jiecang.LiftCabinet()
    
    convenience init(type: Jiecang.ProductType) {
        self.init()
        self.type = type
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "捷昌" + " - " + type.name
        let items: [CommandItem] = [
            CommandItem(title: "查询协议版本", command: cabinet.queryProtocolVersion()),
            CommandItem(title: "查询软件版本", command: cabinet.querySoftwareVersion()),
            CommandItem(title: "控制设备 - 续动上运行", command: cabinet.control(.autoUp)),
            CommandItem(title: "控制设备 - 续动下运行", command: cabinet.control(.autoDown)),
            CommandItem(title: "控制设备 - 点动上运行", command: cabinet.control(.clickUp)),
            CommandItem(title: "控制设备 - 点动下运行", command: cabinet.control(.clickDown)),
            CommandItem(title: "控制设备 - 正常停止", command: cabinet.control(.stop)),
            CommandItem(title: "控制设备 - 急停", command: cabinet.control(.fetchUp)),
            CommandItem(title: "控制设备 - 运行至记忆1", command: cabinet.control(.memory1)),
            CommandItem(title: "控制设备 - 运行至记忆2", command: cabinet.control(.memory2)),
            CommandItem(title: "控制设备 - 运行至记忆3", command: cabinet.control(.memory3)),
            CommandItem(title: "控制设备 - 运行至记忆4", command: cabinet.control(.memory4)),
        ]
        models = items
        tableView.reloadData()
    }
}

extension JiecangViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        let item = models[indexPath.row]
        client.send(item.command)
    }
}
