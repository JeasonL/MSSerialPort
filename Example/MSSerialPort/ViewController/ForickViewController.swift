//
//  ForickViewController.swift
//  MSSerialPort
//
//  Created by Jeason Lee on 2022/3/23.
//

import MSSerialPort
import UIKit

class ForickViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "弗雷克"

        let panel = Forick.TriadPanel()
        var aircons: [CommandItem] = [
            CommandItem(title: "空调 - 开机", command: panel.setAircon(isSwitch: true)),
            CommandItem(title: "空调 - 关机", command: panel.setAircon(isSwitch: false)),
            CommandItem(title: "空调 - 制冷", command: panel.setAircon(mode: .cool)),
            CommandItem(title: "空调 - 制热", command: panel.setAircon(mode: .warm)),
            CommandItem(title: "空调 - 除湿", command: panel.setAircon(mode: .wet)),
            CommandItem(title: "空调 - 送风", command: panel.setAircon(mode: .wind)),
            CommandItem(title: "空调 - 风速自动", command: panel.setAircon(speed: .auto)),
            CommandItem(title: "空调 - 风速低速", command: panel.setAircon(speed: .low)),
            CommandItem(title: "空调 - 风速中速", command: panel.setAircon(speed: .middle)),
            CommandItem(title: "空调 - 风速高速", command: panel.setFreshAir(speed: .high)),
        ]
        aircons.append(contentsOf: (10 ... 32).map {
            CommandItem(title: "空调 - 温度[10...32] = \($0)", command: panel.setAircon(temperature: $0))
        })
        aircons.append(contentsOf: (-9 ... 9).map {
            CommandItem(title: "空调 - 补偿温度[-9...9] = \($0)", command: panel.setComp(temperature: $0))
        })
        var heatings: [CommandItem] = [
            CommandItem(title: "暖气 - 开机", command: panel.setHeating(isSwitch: true)),
            CommandItem(title: "暖气 - 关机", command: panel.setHeating(isSwitch: false)),
        ]
        heatings.append(contentsOf: (10 ... 32).map {
            CommandItem(title: "暖气 - 温度[10...32] = \($0)", command: panel.setHeating(temperature: $0))
        })
        let freshAirs: [CommandItem] = [
            CommandItem(title: "新风 - 开机", command: panel.setFreshAir(isSwitch: true)),
            CommandItem(title: "新风 - 关机", command: panel.setFreshAir(isSwitch: false)),
            CommandItem(title: "新风 - 风速低速", command: panel.setFreshAir(speed: .low)),
            CommandItem(title: "新风 - 风速中速", command: panel.setFreshAir(speed: .middle)),
            CommandItem(title: "新风 - 风速高速", command: panel.setFreshAir(speed: .high)),
        ]
        var others: [CommandItem] = [
           CommandItem(title: "当前状态", command: panel.currentStatus),
           CommandItem(title: "接收通知的时间限制", command: panel.notifyTime),
           CommandItem(title: "设定通知回调时间10s", command: panel.setNotify(time: 10)),
           CommandItem(title: "设定通知回调时间60s", command: panel.setNotify(time: 60)),
           CommandItem(title: "一路双线阀或一路三线阀（一控）默认", command: panel.setAircon(relay: 1)),
           CommandItem(title: "一路三线阀（二控）", command: panel.setAircon(relay: 2)),
           CommandItem(title: "两路双线阀或一路三线阀（一控）", command: panel.setAircon(relay: 3)),
           CommandItem(title: "设置亮度 - 屏幕灯: 85 按键灯: 35 ", command: panel.setBackground(lightness: 85, keyLightness: 35)),
           CommandItem(title: "设置亮度 - 屏幕灯: 35 按键灯: 35 ", command: panel.setBackground(lightness: 35, keyLightness: 35)),
           CommandItem(title: "设置亮度 - 屏幕灯: 35 按键灯: 85 ", command: panel.setBackground(lightness: 35, keyLightness: 85)),
           CommandItem(title: "设置亮度 - 屏幕灯: 85 按键灯: 85 ", command: panel.setBackground(lightness: 85, keyLightness: 85)),
       ]
        others.append(contentsOf: (0 ... 6).map {
            CommandItem(title: "设置休眠时间 - level = \($0)", command: panel.setBackground(duration: $0))
        })
        var items: [CommandItem] = []
        items.append(contentsOf: aircons)
        items.append(contentsOf: heatings)
        items.append(contentsOf: freshAirs)
        items.append(contentsOf: others)
        models = items
        tableView.reloadData()
    }
}

extension ForickViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        let item = models[indexPath.row]
        client.send(item.command)
    }
}
