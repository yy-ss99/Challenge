//
//  ITunesResponse.swift
//  Challenge
//
//  Created by Yeseul Jang on 3/12/26.
//

// 다른 분야 API도 가져와야 하기 때문에 제네릭 설정
struct ITunesResponse<T: Decodable>: Decodable {
    let resultCount: Int
    let results: [T]
}
