//
//  ViewController.swift
//  Challenge
//
//  Created by Yeseul Jang on 3/11/26.
//

import UIKit
import RxSwift

class MainViewController: UIViewController {
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .brown
        testAPI()
    }
    
    func testAPI() {
        NetworkManager.shared.fetch(endpoint: .kpopAlbums)
            .subscribe( // 구독해서 성공받으면 출력 오류받으면 오류 출력
                onSuccess: { (response: ITunesResponse<MusicItem>) in
                    print(response.results)
                },
                onFailure: { error in
                    print(error)
                }
            )
            .disposed(by: disposeBag)

    }
}

