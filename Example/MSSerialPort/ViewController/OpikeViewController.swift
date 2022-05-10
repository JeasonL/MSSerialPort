//
//  OpikeViewController.swift
//  MSSerialPort
//
//  Created by Jeason Lee on 2022/3/23.
//

import UIKit
import MSSerialPort

class OpikeViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "欧派克"
        let id = 0x50.toByte()
        let busdoor = Opike.BusDoor()
        let items: [CommandItem] = [CommandItem(title: "初始化设备", command: busdoor.device(id: id)),
                                    CommandItem(title: "广播初始化设备", command: busdoor.broadcastDevice()),
                                    CommandItem(title: "广播获取地址", command: busdoor.broadcastAddress()),
                                    CommandItem(title: "获取设备类型", command: busdoor.getType(id)),
                                    CommandItem(title: "广播获取设备类型", command: busdoor.broadcastGetType()),
                                    CommandItem(title: "广播设置设备ID", command: busdoor.broadcastSetID(id)),
                                    CommandItem(title: "设置设备新ID - 0x51", command: busdoor.setID(oldID: id, newID: 0x51)),
                                    CommandItem(title: "获取设备状态", command: busdoor.getState(id)),
                                    CommandItem(title: "控制门 - 打开门1", command: busdoor.control(id, d1: .open, d2: .none, d3: .none, d4: .none)),
                                    CommandItem(title: "控制门 - 打开门2", command: busdoor.control(id, d1: .none, d2: .open, d3: .none, d4: .none)),
                                    CommandItem(title: "控制门 - 打开门3", command: busdoor.control(id, d1: .none, d2: .none, d3: .open, d4: .none)),
                                    CommandItem(title: "控制门 - 打开门4", command: busdoor.control(id, d1: .none, d2: .none, d3: .none, d4: .open)),
                                    CommandItem(title: "控制门 - 打开门13", command: busdoor.control(id, d1: .open, d2: .none, d3: .open, d4: .none)),
                                    CommandItem(title: "控制门 - 打开门24", command: busdoor.control(id, d1: .none, d2: .open, d3: .none, d4: .open)),
                                    CommandItem(title: "控制门 - 打开两边", command: busdoor.control(id, d1: .open, d2: .none, d3: .none, d4: .open)),
                                    CommandItem(title: "控制门 - 关闭两边", command: busdoor.control(id, d1: .close, d2: .none, d3: .none, d4: .close)),
                                    CommandItem(title: "控制门 - 打开中间", command: busdoor.control(id, d1: .none, d2: .open, d3: .open, d4: .none)),
                                    CommandItem(title: "控制门 - 关闭中间", command: busdoor.control(id, d1: .none, d2: .close, d3: .close, d4: .none)),
                                    CommandItem(title: "控制门 - 全关", command: busdoor.control(id, d1: .close, d2: .close, d3: .close, d4: .close)),
                                    CommandItem(title: "获取运行速度", command: busdoor.getSpeed(id)),
                                    CommandItem(title: "设置运行速度 - 1", command: busdoor.setSpeed(id, speed: 1)),
                                    CommandItem(title: "设置运行速度 - 25", command: busdoor.setSpeed(id, speed: 25)),
                                    CommandItem(title: "设置运行速度 - 50", command: busdoor.setSpeed(id, speed: 50)),
                                    CommandItem(title: "设置运行速度 - 75", command: busdoor.setSpeed(id, speed: 75)),
                                    CommandItem(title: "设置运行速度 - 100", command: busdoor.setSpeed(id, speed: 100)),
                                    CommandItem(title: "获取开门时间", command: busdoor.getOpenTime(id)),
                                    CommandItem(title: "获取是否自动关门", command: busdoor.getIsAutoClose(id)),
                                    CommandItem(title: "设置自动关门 - 是", command: busdoor.setAutoClose(id, auto: true)),
                                    CommandItem(title: "设置自动关门 - 否", command: busdoor.setAutoClose(id, auto: false)),
                                    CommandItem(title: "获取是否开门换向", command: busdoor.getIsReversal(id)),
                                    CommandItem(title: "设置开门换向 - 是", command: busdoor.setReversal(id, isReversal: true)),
                                    CommandItem(title: "设置开门换向 - 否", command: busdoor.setReversal(id, isReversal: false)),
                                    CommandItem(title: "获取是否自动上锁", command: busdoor.getIsAutoLock(id)),
                                    CommandItem(title: "获取是否门头感应", command: busdoor.getIsSense(id)),
                                    CommandItem(title: "获取是否保持力", command: busdoor.getIsForce(id)),
                                    CommandItem(title: "获取是否中门同步", command: busdoor.getIsSyncCenter(id)),
                                    CommandItem(title: "设置中门同步 - 是", command: busdoor.setSyncCenter(id, sync: true)),
                                    CommandItem(title: "设置中门同步 - 否", command: busdoor.setSyncCenter(id, sync: false)),
                                    CommandItem(title: "获取是否边门同步", command: busdoor.getDeviceIsSyncSide(id)),
                                    CommandItem(title: "设置边门同步 - 是", command: busdoor.setSyncSide(id, sync: true)),
                                    CommandItem(title: "设置边门同步 - 否", command: busdoor.setSyncSide(id, sync: false))]
        models = items
        tableView.reloadData()
    }
}

extension OpikeViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        let item = models[indexPath.row]
        client.send(item.command)
    }
}
