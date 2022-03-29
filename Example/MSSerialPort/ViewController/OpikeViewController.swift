//
//  OpikeViewController.swift
//  MSSerialPort
//
//  Created by Jeason Lee on 2022/3/23.
//

import UIKit

class OpikeViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "欧派克"

        var items: [Item] = []
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

