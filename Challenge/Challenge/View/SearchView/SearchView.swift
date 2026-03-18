//
//  SearchView.swift
//  Challenge
//
//  Created by Yeseul Jang on 3/17/26.
//
import UIKit
import RxSwift
import SnapKit

final class SearchView: UIView {
    lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: makeLayout()
    )
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        collectionView.backgroundColor = .systemBackground
        
        registerCells()
        registerSupplementaryViews()
    }
    
    private func registerCells() {
        collectionView.register(
            AlbumBigCardCell.self,
            forCellWithReuseIdentifier: AlbumBigCardCell.identifier
        )
        
        collectionView.register(
            SongListCell.self,
            forCellWithReuseIdentifier: SongListCell.identifier
        )
        
        collectionView.register(
            AlbumCoverCell.self,
            forCellWithReuseIdentifier: AlbumCoverCell.identifier
        )
    }
    
    private func registerSupplementaryViews() {
        collectionView.register(
            HomeSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HomeSectionHeaderView.identifier
        )
    }
    
    private func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, environment in
            guard let section = SearchSection(rawValue: sectionIndex) else { return nil }
            
            switch section {
            case .albums:
                return self.makeSearchAlbumSection(environment: environment)
                
            case .songs:
                return self.makeSearchSongListSection(environment: environment)
                
            case .podcasts:
                return self.makeSearchPodcastSection(environment: environment)
            }
        }
    }
}

extension SearchView {
    private func makeSearchAlbumSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let spacing: CGFloat = 20
        
        let containerSize = environment.container.effectiveContentSize
        let itemWidthSize = (containerSize.width - spacing * 2)
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(itemWidthSize),
            heightDimension: .absolute(itemWidthSize)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(
                widthDimension: .absolute(itemWidthSize),
                heightDimension: .absolute(itemWidthSize)
            ),
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        section.boundarySupplementaryItems = [makeHeaderItem()]
        
        return section
    }
    
    private func makeSearchPodcastSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let spacing: CGFloat = 20
        
        let containerSize = environment.container.effectiveContentSize
        let itemWidthSize = (containerSize.width - spacing * 3) / 2
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(itemWidthSize),
            heightDimension: .absolute(itemWidthSize)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let rowGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .absolute(itemWidthSize * 2 + spacing),
                heightDimension: .absolute(itemWidthSize)
            ),
            subitems: [item]
        )
        
        rowGroup.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: rowGroup)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)
        section.boundarySupplementaryItems = [makeHeaderItem()]
        
        return section
    }
    
    private func makeSearchSongListSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let spacing: CGFloat = 8
        
        let containerSize = environment.container.effectiveContentSize
        let itemWidthSize = (containerSize.width - spacing * 2)
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(itemWidthSize),
            heightDimension: .absolute(72)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: itemSize,
            subitems: [item]
        )
        
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 8, bottom: 10, trailing: 8)
        section.boundarySupplementaryItems = [makeHeaderItem()]
        
        return section
    }
    
    private func makeHeaderItem(height: CGFloat = 36) -> NSCollectionLayoutBoundarySupplementaryItem {
        let size = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(height)
        )
        
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: size,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
}
