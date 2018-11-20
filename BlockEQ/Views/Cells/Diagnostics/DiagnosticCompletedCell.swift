//
//  DiagnosticCardCompletedView.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-11-12.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

final class DiagnosticCompletedCell: UICollectionViewCell, ReusableView, NibLoadableView {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var diagnosticIdLabel: UILabel!
    @IBOutlet weak var cellWidthConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyle()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        setupStyle()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = DiagnosticViewController.stepCornerRadius
    }

    func setupStyle() {
        contentView.translatesAutoresizingMaskIntoConstraints = false

        contentView.backgroundColor = Colors.transparent
        backgroundView?.backgroundColor = Colors.transparent
        containerView.backgroundColor = Colors.white

        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        titleLabel.text = "DIAGNOSTIC_ID_TITLE".localized()

        imageView.image = UIImage(named: "icon-check")
        imageView.tintColor = Colors.green

        diagnosticIdLabel.textColor = Colors.darkGray
        diagnosticIdLabel.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        diagnosticIdLabel.text = "31"
    }

    func update(with diagnosticId: String?) {
        if let diagnosticId = diagnosticId {
            diagnosticIdLabel.text = diagnosticId
            imageView.image = UIImage(named: "icon-check")
            imageView.tintColor = Colors.green
        } else {
            diagnosticIdLabel.text = "FAILED_DIAGNOSTIC".localized()
            imageView.image = UIImage(named: "icon-check")
            imageView.tintColor = Colors.red
        }
    }

    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var frame = layoutAttributes.frame
        frame.size.height = ceil(size.height)
        layoutAttributes.frame = frame
        return layoutAttributes
    }
}
