//
// Created by Eli Thompson on 6/29/20.
//

import UIKit

class PaymentMethodCell: UICollectionViewCell {
    let padding: CGFloat = 8.0

    var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    var textLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    var container: UIView = {
        let container = UIView(frame: .zero)
        container.backgroundColor = .tertiarySystemBackground
        container.layer.cornerRadius = 15
        return container
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    func addShadow(view: UIView) {
        view.layer.shadowOpacity = 0.15
        view.layer.shadowRadius = 5
        view.layer.shadowOffset = CGSize(width: 0, height: 1.0)
    }

    func setup() {
        layer.backgroundColor = UIColor.clear.cgColor
        addShadow(view: contentView)

        contentView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        ])

        container.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: container.topAnchor, constant: padding),
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: padding),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -padding),
            imageView.heightAnchor.constraint(equalToConstant: 80)
        ])

        container.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: padding),
            textLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: padding),
            textLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -padding)
        ])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        fatalError("not supported")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        textLabel.text = nil
        imageView.image = nil
    }
}
