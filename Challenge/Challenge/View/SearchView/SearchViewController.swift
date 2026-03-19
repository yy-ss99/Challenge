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

final class SearchViewController: UIViewController {
    private let searchView = SearchView()
    private let disposeBag = DisposeBag()
    private let viewModel: SearchViewModel
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let initialQuery: String
    private let initialQueryRelay = PublishRelay<String>()
    
    private var dataSource: UICollectionViewDiffableDataSource<SearchSection, SearchItem>!
    
    init(initialQuery: String, viewModel: SearchViewModel = SearchViewModel()) {
        self.initialQuery = initialQuery
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Search"
        navigationItem.largeTitleDisplayMode = .always
        searchView.collectionView.delegate = self
        configureUI()
        configureDataSource()
        bindViewModel()
        
        // 입력된거 보여줌
        searchController.searchBar.text = initialQuery
        // 서치뷰 띄우면서 넘겨받은 첫 검색어를 검색 이벤트로 만들기
        initialQueryRelay.accept(initialQuery)
    }
    
    private func bindViewModel() {
        // 분기가 둘로 나누어져서 홈에서 오자마자 검색, 서치에서 다시 검색
        // merge로 하나로 만들어줌
        let queryText = Observable.merge(
            // 홈뷰에서 받아온거랑 서치뷰에서 입력된거 받아서 묶음
            initialQueryRelay.asObservable(),
            searchController.searchBar.rx.text.orEmpty.asObservable()
        )
        // 인풋 넣기
        let input = SearchViewModel.Input(queryText: queryText)
        
        // 아웃풋이 나옴
        let output = viewModel.transform(input: input)
        
        // 성공 - 섹션이면 스냅샷에 흘려 넣어서 콜렉션뷰 그리기
        output.sections
            .drive(with: self) { SearchVC, sections in
                SearchVC.applySnapshot(with: sections) // 콜렉션 업데이트
            }
            .disposed(by: disposeBag)
        
        // 로딩 받으면 로딩시 하는 동작들
        output.isLoading
            .drive(with: self) { SearchVC, isLoading in
                if isLoading {
                    SearchVC.searchView.showLoading()
                } else {
                    SearchVC.searchView.hideLoading()
                }
            }
            .disposed(by: disposeBag)
        
        // 오류 받으면 오류 띄우기
        output.errorMessage
            .emit(with: self) { SearchVC, message in
                let alert = UIAlertController(
                    title: "에러",
                    message: message,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                SearchVC.present(alert, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.isEmpty
            .drive(with: self) { SearchVC, isEmpty in
                SearchVC.searchView.collectionView.backgroundView?.isHidden = !isEmpty
            }
            .disposed(by: disposeBag)
    }
    
    func configureUI() {
        view.addSubview(searchView)
        
        searchController.searchBar.searchBarStyle = .default
        searchController.searchBar.placeholder = "음악,팟캐스트 검색"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        searchView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }
    }
}
extension SearchViewController {
    private func configureDataSource() {
        // 데이터 소스에 데이터 넣어줌
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

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        let musicItem: MusicItem
        switch item {
        case .song(let selectedItem), .album(let selectedItem), .podcast(let selectedItem):
            musicItem = selectedItem
        }
        
        let detailViewController = DetailViewController(item: musicItem)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
