//
//  ForickViewController.swift
//  MSSerialPort
//
//  Created by Jeason Lee on 2022/3/23.
//

import UIKit
import MSSerialPort

class ForickViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "弗雷克"

        var items: [CommandItem] = []
        for ctrl in Forick.Ctrl.allCases {
            items.append(CommandItem(title: ctrl.name, command: ctrl.bytes))
        }
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
