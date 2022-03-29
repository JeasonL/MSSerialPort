//
//  BaseItemCell.swift
//  MSSerialPort
//
//  Created by Jeason Lee on 2022/3/26.
//

import UIKit

class BaseItemCell: UITableViewCell {
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    var subTitle: String? {
        didSet {
            subLabel.text = subTitle
        }
    }

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 18.0)
        label.textAlignment = .left
        return label
    }()

    lazy var subLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 15.0)
        label.textAlignment = .left
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8.0
        stackView.addArrangedSubviews([titleLabel, subLabel])
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(20.0)
        }
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.equalToSuperview().offset(15.0)
            make.right.equalToSuperview().offset(-15.0)
        }
    }
}
