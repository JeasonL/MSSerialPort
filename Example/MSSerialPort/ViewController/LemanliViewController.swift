//
//  LemanliViewController.swift
//  MSSerialPort
//
//  Created by Jeason Lee on 2022/3/26.
//

import UIKit
import MSSerialPort

class LemanliViewController: BaseViewController {
    let curtain = Lemanli.AccordionCurtain()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "乐满力 - 风琴帘"
        
        let id: Byte = 0x09
        let gID = 0
        let items: [CommandItem] = [
            CommandItem(title: "上移-群控", command: curtain.groupToUp(id: gID)),
            CommandItem(title: "停止-群控", command: curtain.groupToStop(id: gID)),
            CommandItem(title: "下移-群控", command: curtain.groupToDown(id: gID)),
            CommandItem(title: "上移", command: curtain.toUp(id: id)),
            CommandItem(title: "停止", command: curtain.toStop(id: id)),
            CommandItem(title: "下移", command: curtain.toDown(id: id)),
            CommandItem(title: "指定位置-0%", command: curtain.runToValue(id: id, percent: 0)),
            CommandItem(title: "指定位置-20%", command: curtain.runToValue(id: id, percent: 20)),
            CommandItem(title: "指定位置-40%", command: curtain.runToValue(id: id, percent: 40)),
            CommandItem(title: "指定位置-80%", command: curtain.runToValue(id: id, percent: 80)),
            CommandItem(title: "指定位置-100%", command: curtain.runToValue(id: id, percent: 100)),
            CommandItem(title: "设置ID", command: curtain.setDeviceID(id: id)),
            CommandItem(title: "查询状态-ID=\(id)", command: curtain.queryStateFromId(id: id)),
            CommandItem(title: "查询状态-不管ID", command: curtain.queryStateFromId(id: id)),
        ]
        models = items
        tableView.reloadData()
    }
}

extension LemanliViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        let item = models[indexPath.row]
        client.send(item.command)
    }
}
