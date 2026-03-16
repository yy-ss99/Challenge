//
//  HomeView.swift
//  Challenge
//
//  Created by Yeseul Jang on 3/12/26.
//

// TODO: 리스트셀 여백 수정하기
import UIKit
import RxSwift
import SnapKit

enum HomeSection: Int, CaseIterable {
    case featuredAlbum
    case popularSongs
    case recommendedSongs
    case popularAlbums
    case newAlbums
    
    var title: String {
        switch self {
        case .featuredAlbum:
            return "Featured"
        case .popularSongs:
            return "Popular Songs"
        case .recommendedSongs:
            return "Recommended"
        case .popularAlbums:
            return "Popular Albums"
        case .newAlbums:
            return "New Albums"
        }
    }
}

final class HomeView: UIView {
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
            AlbumCardCell.self,
            forCellWithReuseIdentifier: AlbumCardCell.identifier
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
        
        collectionView.register(
            PageControlView.self,
            forSupplementaryViewOfKind: PageControlView.kind,
            withReuseIdentifier: PageControlView.identifier
        )
    }
    
    private func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, environment in
            guard let section = HomeSection(rawValue: sectionIndex) else { return nil }
            
            switch section {
            case .featuredAlbum:
                return self.makeFeaturedAlbumSection(environment: environment)
                
            case .popularSongs, .recommendedSongs:
                return self.makeSongListSection(environment: environment)
                
            case .popularAlbums, .newAlbums:
                return self.makeAlbumCoverSection(environment: environment)
            }
        }
    }
}

extension HomeView {
    private func makeFeaturedAlbumSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let spacing: CGFloat = 10
        
        let containerSize = environment.container.effectiveContentSize
        let itemWidthSize = (containerSize.width - spacing * 2)
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(itemWidthSize),
            heightDimension: .absolute(itemWidthSize)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .absolute(itemWidthSize),
                heightDimension: .absolute(itemWidthSize)
            ),
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 28, trailing: 16)
        section.boundarySupplementaryItems = [makeHeaderItem()]
        
        return section
    }
    
    private func makeSongListSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let spacing: CGFloat = 8
        
        let containerSize = environment.container.effectiveContentSize
        let itemWidthSize = (containerSize.width - spacing * 5)
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(itemWidthSize),
            heightDimension: .absolute(72)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(itemWidthSize),
            heightDimension: .absolute(72 * 3)
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: 3
        )
        
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        // 그룹으로 묶어서 넘어가게
        section.orthogonalScrollingBehavior = .groupPaging
        
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 0, bottom: 28, trailing: 0)
        section.boundarySupplementaryItems = [
            makeHeaderItem(),
            makePageControlItem()
        ]
        
        return section
    }
    
    private func makeAlbumCoverSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let spacing: CGFloat = 10
        
        let containerSize = environment.container.effectiveContentSize
        let itemWidthSize = (containerSize.width - spacing * 8) / 2
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(itemWidthSize),
            heightDimension: .absolute(itemWidthSize)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .absolute(itemWidthSize),
                heightDimension: .absolute(itemWidthSize)
            ),
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 28, trailing: 16)
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
    
    private func makePageControlItem(height: CGFloat = 20) -> NSCollectionLayoutBoundarySupplementaryItem {
        let size = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(height)
        )
        
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: size,
            elementKind: PageControlView.kind,
            alignment: .bottom
        )
    }
}

    
