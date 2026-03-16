//
//  HomeSectionHeaderView.swift
//  Challenge
//
//  Created by Yeseul Jang on 3/13/26.
//
import UIKit
import SnapKit
import Then

final class HomeSectionHeaderView: UICollectionReusableView {
    
    static let identifier = "HomeSectionHeaderView"
    
    let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 22, weight: .bold)
        $0.textColor = .label
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.verticalEdges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
