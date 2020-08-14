//
//  ImpactStatisticsOverallCollectionViewCell.swift
//  labs-ios-starter
//
//  Created by Wyatt Harrell on 8/13/20.
//  Copyright © 2020 Spencer Curtis. All rights reserved.
//

import UIKit

class ImpactStatisticsOverallCollectionViewCell: UICollectionViewCell {
    
    // MARK: - View Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        self.layer.cornerRadius = 8.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 0.25
    }
}
