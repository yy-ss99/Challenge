//
//  PageControlView.swift
//  Challenge
//
//  Created by Yeseul Jang on 3/16/26.
//
import UIKit
import SnapKit

final class PageControlView: UICollectionReusableView {
    static let identifier = "PageControlView"
    static let kind = "PageControlView-kind"
    
    let pageControl = UIPageControl()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(pageControl)
        pageControl.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        pageControl.numberOfPages = 3
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
