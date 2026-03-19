# 📱 iTunes Search App

# 📌 소개

iTunes API를 활용하여 음악, 앨범, 팟캐스트를 검색하고 상세 정보를 확인할 수 있는 iOS 앱입니다.
RxSwift와 MVVM 패턴을 기반으로 비동기 데이터 흐름을 관리하고, 효율적인 UI 업데이트를 구현했습니다.

|홈화면/디테일화면|검색화면/디테일화면|
|---|---|
|![리드미홈화면](https://github.com/user-attachments/assets/d5ab7d6b-6c20-4c8f-b397-cb89e3ebd937)|![리드미검색](https://github.com/user-attachments/assets/463ed507-69c0-475b-854b-4b1297158c79)|



---

# 🛠 기술 스택

* **UIKit**
* **RxSwift / RxCocoa**
* **MVVM (Input / Output 패턴)**
* **Diffable DataSource**
* **SnapKit**
* **Kingfisher (이미지 로딩 및 캐싱)**
* **AVPlayer (iTunes 미리듣기 재생)**

---

# 📂 아키텍처

## MVVM + Input / Output

* ViewModel에서 Input → Output 변환
* ViewController는 Output을 바인딩하여 UI 업데이트

### **프로토콜**
```swift
protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    func transform(input: Input) -> Output
}
```
### **구현 예시**
```swift
struct Input {
    let viewDidLoad: Observable<Void>
}

struct Output {
    let sections: Driver<[HomeSectionModel]>
    let isLoading: Driver<Bool>
    let errorMessage: Signal<String>
}
```
### **목적**
* 비즈니스 로직과 UI 분리
* 테스트 가능성 증가
* 데이터 흐름 단방향 유지

---

# 🔍 주요 기능

### 1. 홈 화면

* iTunes API를 통해 음악 데이터 로드
* Diffable DataSource로 섹션 구성
* 로딩 상태 및 에러 처리

### 2. 검색 기능

* 검색어 입력 시 새로운 화면에서 결과 표시
* song / album / podcast 검색 지원
* RxSwift로 입력 이벤트 스트림 처리
* 로딩 상태 및 에러 처리

### 3. 상세 화면

* 선택한 아이템의 상세 정보 표시
* 미리듣기가 있는 경우 영상 재생 (AVPlayer 활용)

### 4. 네트워크 구조

* `NetworkService` → API 요청 담당
* `ITunesEndpoint` → API URL 구성
* `ITunesResponse` → 응답 모델

🔹 특징
* async/await 기반에서 Rx로 변환하여 사용
* ViewModel에서 비동기 처리

---

# 💡 고민 및 개선 포인트

## 🏠 홈 화면 관련 고민했던 점

### 1. CollectionView를 diffable datasource로 변경해야하는가?

- 지금 코드를 보면 홈 화면 데이터는  
`viewDidLoad -> fetchHomeSectionsData() -> sections 저장 -> reloadData()`  
이 흐름이고, 한 번 받아와서 보여주는 형식이다. 게다가 섹션도 고정이고, 아이템만 채워지는 구조다.
- `diffable datasource`로 바꾸려면 `Hashable`, `snapshot` 구성, `supplementaryView` 처리 방식까지 같이 정리해야 해서 복잡도는 올라감.
- **앞으로 홈 화면 데이터가 자주 바뀌거나**, 검색/필터/좋아요/동적 섹션 추가 같은 기능이 붙을 가능성이 있으면 그때 `diffable datasource`로 가는 게 더 의미 있다고 생각되긴 함

### 2. pageControl을 지금 클로저로 전달하게 해 두었는데 이것도 RxSwift 이용하는 걸로 바꾸는게 좋을까?
- 현재 구조를 보면 `HomeView` 안에서 `visibleItemsInvalidationHandler`로 페이지를 계산하고, 그걸 `changeToCurrentPage` 클로저로 `HomeViewController`에 전달해서 해당 `footer`의 `pageControl.currentPage`를 바꾸고 있음.
- 페이지 변경을 UI 내부 이벤트로 보고 그 이벤트를 한 군데로 전달하고 전달받은 `VC`가 `pageControl`의 `UI`를 갱신하는 구조.
- 비즈니스 로직도 아니고, 이 내용을 다른 뷰에서 알 필요도 없고, 뷰 내부 레벨에서의 동기화하는 식이라 불필요하다고 판단함

## 🔍 검색화면 고민했던 점
### 1. 역할 나누기를 명확하게 하고 시작하기
- 들어가기 전에 역할과 흐름을 미리 정리하고 코드를 작성하기 시작했다.
- **HomeViewController**
    - 검색 버튼 눌림 감지
    - 검색어 꺼내기
    - SearchViewController 생성
    - 검색어 전달
    - 다음 화면 push
- **SearchViewController**
    - 전달받은 검색어를 searchBar에 넣기
    - 그 검색어를 ViewModel에 전달
    - ViewModel output 받아서 컬렉션뷰 갱신
- **SearchViewModel**
    - 검색어로 API 요청
    - song / album / podcast 결과 가공
    - sections / loading / error 내보내기

###  1-1. 서치뷰 흐름
검색어 입력
-> 잠깐 멈출 때까지 기다림
-> 같은 검색어면 무시
-> 최신 검색어만 사용
-> 비어 있으면 빈 결과
-> 아니면 로딩 시작
-> API 요청
-> 성공하면 sections 방출 + 로딩 종료
-> 실패하면 에러 메시지 방출 + 로딩 종료 + 빈 결과 방출
-> UI가 쓰기 좋은 Output으로 반환

### 2. 서치뷰 예외처리
```swift
    func transform(input: Input) -> Output {
        let loadingRelay = BehaviorRelay<Bool>(value: false)
        let errorRelay = PublishRelay<String>()
        
        let sections = input.queryText
            .debounce(.milliseconds(400), scheduler: MainScheduler.instance)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .distinctUntilChanged()
            .flatMapLatest { [weak self] query -> Observable<[SearchSectionModel]> in
                guard let self else { return .just([]) }
                
                if query.isEmpty {
                    return .just([])
                }
                
                loadingRelay.accept(true)
                
                return self.fetchSearchData(query: query)
                    .asObservable()
                    .do(onNext: { _ in
                        loadingRelay.accept(false)
                    })
                    .catch { error in
                        loadingRelay.accept(false)
                        let message = self.makeErrorMessage(from: error)
                        errorRelay.accept(message)
                        return .just([])
                    }
            }
            .asDriver(onErrorJustReturn: []) 
        
```
`[]`가 나오는 경우는 최소 3개:

1. **초기 상태**
    - 아직 검색 안 함
    - query가 빈 문자열이라 `.just([])`
2. **검색 결과 없음**
    - API 성공
    - 결과가 진짜 0개
3. **에러 발생 후 대체값**
    - catch에서 `.just([])`

그냥 다 빈값이라고 한 번에 처리 해버리면 어색할 수 있음

### 2-1. 해결 방안
```swift
struct Output {
        let sections: Driver<[SearchSectionModel]>
        let isLoading: Driver<Bool>
        let errorMessage: Signal<String>
        let isEmpty: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        let loadingRelay = BehaviorRelay<Bool>(value: false)
        let errorRelay = PublishRelay<String>()
        
        let sections = input.queryText
            .debounce(.milliseconds(400), scheduler: MainScheduler.instance)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .distinctUntilChanged()
            .flatMapLatest { [weak self] query -> Observable<[SearchSectionModel]> in
                guard let self else { return .empty() }
                
                if query.isEmpty {
                    return .just([])
                }
                
                loadingRelay.accept(true)
                
                return self.fetchSearchData(query: query)
                    .asObservable()
                    .do(onNext: { _ in
                        loadingRelay.accept(false)
                    })
            }
            .asDriver(onErrorRecover: { error in
                loadingRelay.accept(false)
                let message = self.makeErrorMessage(from: error)
                errorRelay.accept(message)
                return .empty()
            })
        let isEmpty = sections
            .map { $0.isEmpty }
            .distinctUntilChanged()
        
        return Output(
            sections: sections,
            isLoading: loadingRelay.asDriver(),
            errorMessage: errorRelay.asSignal(),
            isEmpty: isEmpty
        )
    }
```
- `asDriver(onErrorRecover:)`: `asDriver` 메서드 변경해서 오류처리 할 수 있도록 변경
- 빈값을 내보내는 부분들을 `.empty()` 변경해서 상황을 더 명확하게 나눔
- `Output`에 `let isEmpty: Driver<Bool>` 추가해서 `sections`가 비었을 때 어떤 `UI`를 보여줄건지 결정할 수 있도록 함

## 📖 상세화면 고민했던 점

### 1. item을 어떻게 스트림으로 전단할 것인가 `Observable.just(item)` vs `input.viewDidLoad.map { item }`
- 상세 화면에서 전달받은 `item`은 이미 생성 시점에 존재하는 값이기 때문에, 단순히 값만 전달하는 목적이라면 `Observable.just(item)`으로도 구현할 수 있음

```swift
Observable.just(item)
```

- 하지만 이 방식은 구독되는 순간 즉시 값이 방출됨
- 원래 의도했었던 View가 로드되면 item을 전달하려는 흐름(View의 생명주기)과는 관련이 없게 됨

### 1-1. 해결방안 
```swift
input.viewDidLoad
    .map { [item] in item }
```
- `viewDidLoad` 이벤트가 발생했을 때를 기준으로 `item`을 방출하도록 변경함
- 원래 의도대로 화면이 준비된 시점에 맞춰 데이터를 전달한다는 흐름을 명확하게 표현할 수 있음

- 이 프로젝트는 MVVM + Input / Output 패턴을 기반으로 구성되어 있기 때문에 단순한 값 전달보다도 이벤트를 기준으로 데이터 흐름을 관리하는 구조를 유지하는 것이 더 중요하다고 판단해서 수정함

### 1-2. 정리

* `Observable.just(item)`
  → 구독 시 즉시 값 방출
* `input.viewDidLoad.map { item }`
  → `viewDidLoad` 이벤트 시점에 값 방출

- 결과적으로 두 방식 모두 기능적으로 큰 차이는 없이 구현은 가능하지만,이번 프로젝트에서는 View 생명주기와 데이터 흐름을 일치시키고, Input Output 구조를 유지하기 위해 `viewDidLoad`를 트리거로 사용하는 방식으로 결정함

---

## 🚀 추가해 보면 좋을 사항

* 무한 스크롤 (pagination) 구현해보기
* 검색 결과 캐싱
* 관련 뮤직비디오 재생
---

