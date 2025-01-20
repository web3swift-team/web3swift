//
//  TokenCell.swift
//  myWeb3Wallet
//
//  Created by 6od9i on 15/01/25.
//

import UIKit

final class TokenCell: UITableViewCell {
    var name: String = "" {
        didSet { nameLabel.text = name }
    }

    var network: String = "" {
        didSet { networkLabel.text = network }
    }

    var balance: String = "" {
        didSet { balanceLabel.text = balance }
    }

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()

    private let networkLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.numberOfLines = 1
        return label
    }()

    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .right
        label.numberOfLines = 1
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        [nameLabel, networkLabel, balanceLabel].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: balanceLabel.trailingAnchor, constant: -16).isActive = true

        balanceLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        balanceLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        balanceLabel.topAnchor.constraint(equalTo: nameLabel.topAnchor).isActive = true
        balanceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true

        networkLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        networkLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        networkLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
    }
}
