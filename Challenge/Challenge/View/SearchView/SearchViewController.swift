//
//  SearchViewController.swift
//  Challenge
//
//  Created by Yeseul Jang on 3/17/26.
//
import UIKit
import RxSwift
import RxCocoa
import SnapKit

struct SearchSectionModel {
    let section: SearchSection
    let items: [SearchItem]
}

nonisolated
enum SearchItem: Hashable, Sendable {
    case song(MusicItem)
    case album(MusicItem)
    case podcast(MusicItem)
}

final class SearchViewController: UIViewController {
    private let searchView = SearchView()
    private let disposeBag = DisposeBag()
    private let viewModel = SearchViewModel()
    private let searchBar = UISearchBar()
    
    private var dataSource: UICollectionViewDiffableDataSource<SearchSection, SearchItem>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        configureUI()
        configureDataSource()
        applyMockSnapshot()
    }
    
    func configureUI() {
        view.addSubview(searchView)
        view.addSubview(searchBar)
        searchBar.searchBarStyle = .minimal
        
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }
        
        searchView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }
    }
}
extension SearchViewController {
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<SearchSection, SearchItem>(
            collectionView: searchView.collectionView) { collectionView, indexPath, item in
            switch item {
            case .song(let musicItem):
                let cell: SongListCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.configure(with: musicItem)
                return cell
                
            case .album(let musicItem):
                let cell: AlbumBigCardCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.configure(with: musicItem)
                return cell
                
            case .podcast(let musicItem):
                let cell: AlbumCoverCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.configure(with: musicItem)
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else {
                return UICollectionReusableView()
            }
            
            let header: HomeSectionHeaderView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                for: indexPath
            )
            
            if let section = SearchSection(rawValue: indexPath.section) {
                header.titleLabel.text = section.title
            }
            
            return header
        }
    }
}

extension SearchViewController {
    private func applySnapshot(with sections: [SearchSectionModel]) {
        // 빈 스냅샷(화면) 만들기
        var snapshot = NSDiffableDataSourceSnapshot<SearchSection, SearchItem>()
        
        for section in sections {
            // 이 섹션들과 이 섹션안에 아이템들이 존재한다고 넘김
            snapshot.appendSections([section.section])
            snapshot.appendItems(section.items, toSection: section.section)
        }
        // 넣어둔걸 적용함
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension SearchViewController {
    private func applyMockSnapshot() {
        let sections: [SearchSectionModel] = [
            SearchSectionModel(
                section: .songs,
                items: MusicItem.mockSongs.map { SearchItem.song($0) }
            ),
            SearchSectionModel(
                section: .albums,
                items: MusicItem.mockAlbums.map { SearchItem.album($0) }
            ),
            SearchSectionModel(
                section: .podcasts,
                items: MusicItem.mockPodcasts.map { SearchItem.podcast($0) }
            )
        ]
        
        applySnapshot(with: sections)
    }
}
