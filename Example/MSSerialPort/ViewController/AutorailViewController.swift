//
//  AutorailViewController.swift
//  MSSerialPort
//
//  Created by Jeason Lee on 2022/3/28.
//

import UIKit
import MSSerialPort

class AutorailViewController: BaseViewController {
    let curtain = Autorail.DreamCurtain()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "奥特威 - 梦幻帘"
        
        let id = 0x1234
        let _id = id.toHexString()
        let items: [Item] = [
            Item(title: "设置ID：0x\(_id)", command: curtain.setID(id: id)),
            Item(title: "打开：0x\(_id)", command: curtain.on(id: id)),
            Item(title: "关闭：0x\(_id)", command: curtain.off(id: id)),
            Item(title: "停止：0x\(_id)", command: curtain.stop(id: id)),
            Item(title: "运行：0x\(_id) 至0%", command: curtain.runPercent(id: id, percent: 0)),
            Item(title: "运行：0x\(_id) 至30%", command: curtain.runPercent(id: id, percent: 30)),
            Item(title: "运行：0x\(_id) 至60%", command: curtain.runPercent(id: id, percent: 50)),
            Item(title: "运行：0x\(_id) 至80%", command: curtain.runPercent(id: id, percent: 80)),
            Item(title: "运行：0x\(_id) 至100%", command: curtain.runPercent(id: id, percent: 100)),
            Item(title: "设置：0x\(_id) 角度：0", command: curtain.setAngle(id: id, angle: 0)),
            Item(title: "设置：0x\(_id) 角度：45", command: curtain.setAngle(id: id, angle: 45)),
            Item(title: "设置：0x\(_id) 角度：90", command: curtain.setAngle(id: id, angle: 90)),
            Item(title: "设置：0x\(_id) 角度：135", command: curtain.setAngle(id: id, angle: 135)),
            Item(title: "设置：0x\(_id) 角度：180", command: curtain.setAngle(id: id, angle: 180)),
            Item(title: "运行：0x\(_id) 至0%，角度：0", command: curtain.setPercentAndAngle(id: id, percent: 0, angle: 0)),
            Item(title: "运行：0x\(_id) 至30%，角度：45", command: curtain.setPercentAndAngle(id: id, percent: 30, angle: 45)),
            Item(title: "运行：0x\(_id) 至50%，角度：90", command: curtain.setPercentAndAngle(id: id, percent: 50, angle: 90)),
            Item(title: "运行：0x\(_id) 至80%，角度：135", command: curtain.setPercentAndAngle(id: id, percent: 80, angle: 135)),
            Item(title: "运行：0x\(_id) 至100%，角度：180", command: curtain.setPercentAndAngle(id: id, percent: 100, angle: 180)),
            Item(title: "读取：0x\(_id) 百分比", command: curtain.readPercent(id: id)),
            Item(title: "读取：0x\(_id) 方向", command: curtain.readDirection(id: id)),
            Item(title: "读取：0x\(_id) 设备类型", command: curtain.readDeviceType(id: id)),
            Item(title: "读取：0x\(_id) 角度", command: curtain.readAngle(id: id)),
            Item(title: "读取：0x\(_id) 当前角度系数", command: curtain.readAngleCoefficient(id: id)),
            Item(title: "设置：0x\(_id) 角度系数：0", command: curtain.setAngleCoefficient(id: id, coefficient: 0)),
            Item(title: "设置：0x\(_id) 角度系数：50", command: curtain.setAngleCoefficient(id: id, coefficient: 50)),
            Item(title: "设置：0x\(_id) 角度系数：100", command: curtain.setAngleCoefficient(id: id, coefficient: 100)),
            Item(title: "设置：0x\(_id) 角度系数：150", command: curtain.setAngleCoefficient(id: id, coefficient: 150)),
            Item(title: "设置：0x\(_id) 角度系数：200", command: curtain.setAngleCoefficient(id: id, coefficient: 200)),
            Item(title: "设置：0x\(_id) 角度系数：255", command: curtain.setAngleCoefficient(id: id, coefficient: 255)),
            Item(title: "设置：0x\(_id) 默认方向", command: curtain.setDeviceDirection(id: id, isDefault: true)),
            Item(title: "设置：0x\(_id) 反方向", command: curtain.setDeviceDirection(id: id, isDefault: false)),
        ]
        models = items
        tableView.reloadData()
    }
}

extension AutorailViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        let item = models[indexPath.row]
        client.send(item.command)
    }
}
