# 5교시 실습 — bool 검색

## (공통) 문제 1 — 제공 코드로 must·filter 확인

```http
GET /products/_search
{
  "size": 10,
  "query": {
    "bool": {
      "must": [{ "match": { "name": "무선" } }],
      "filter": [
        { "term": { "category": "전자기기" } },
        { "term": { "in_stock": true } },
        { "range": { "price": { "gte": 50000, "lte": 200000 } } }
      ]
    }
  }
}
```

### 결과 입력

- `hits.total.value`: `155`
- 상위 3개 ID·name:
  - `P-00025` — `MobiCore 컴팩트 무선 이어폰`
  - `P-00129` — `Auralis 스마트 무선 이어폰`
  - `P-00369` — `SoundLab 데일리 무선 이어폰`
- 세 filter의 실제 값:
  - `P-00025` — `category: 전자기기`, `in_stock: true`, `price: 59400`
  - `P-00129` — `category: 전자기기`, `in_stock: true`, `price: 53800`
  - `P-00369` — `category: 전자기기`, `in_stock: true`, `price: 162800`
- must와 filter의 역할 차이: `must`는 사용자의 검색 의도인 `무선`을 검색하고 `_score` 계산에 영향을 준다. `filter`는 `전자기기`, `재고 있음`, `5만~20만원`처럼 정확한 조건으로 결과를 걸러내며 `_score`에는 영향을 주지 않는다.
## (공통) 문제 2 — 조건 제거 실험 직접 구현

문제 1의 요청에서 `in_stock` filter만 제거한 API를 작성하세요. 다른 조건은 바꾸지 마세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 10,
  "query": {
    "bool": {
      "must": [{ "match": { "name": "무선" } }],
      "filter": [
        { "term": { "category": "전자기기" } },
        { "range": { "price": { "gte": 50000, "lte": 200000 } } }
      ]
    }
  }
}
```

### 비교 결과

- 변경 전 total / 변경 후 total: `155 / 180`
- 새로 포함된 문서 ID·in_stock:
  - `P-00457` — `in_stock: false`
  - `P-00521` — `in_stock: false`
- 변화가 없다면 데이터 근거: 해당 없음. 실제로 결과가 `25건` 증가했다.
- 제거한 조건의 역할: `in_stock: true` filter는 재고가 있는 상품만 포함하도록 제한한다. 이 조건을 제거하자 품절 상품도 포함되어 전체 결과가 `155건`에서 `180건`으로 증가했다.

## (공통) 문제 3 — should 조건 직접 구현

category가 `전자기기`인 문서 중 `name`에 `무선`이 있거나 `in_stock=true`인 조건을 최소 하나 만족하도록 bool API를 작성하세요. `minimum_should_match`를 명시하세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 10,
  "query": {
    "bool": {
      "filter": [
        { "term": { "category": "전자기기" } }
      ],
      "should": [
        { "match": { "name": "무선" } },
        { "term": { "in_stock": true } }
      ],
      "minimum_should_match": 1
    }
  }
}
```

### 결과 입력

- `hits.total.value`: `2,206`
- 무선이지만 품절인 문서 존재 여부: 있음. `P-00457` (`MobiCore 데일리 무선 이어폰`, `in_stock: false`), `P-00521` (`NeoTech 스마트 무선 이어폰`, `in_stock: false`) 등을 확인했다.
- 무선이 아니지만 재고가 있는 문서 존재 여부: 있음. `P-00009` (`NeoTech 데일리 기계식 키보드`, `in_stock: true`), `P-00081` (`NeoTech 스마트 기계식 키보드`, `in_stock: true`), `P-00185` (`MobiCore 스마트 블루투스 스피커`, `in_stock: true`) 등을 확인했다.
- should 조건 판정: `minimum_should_match: 1`을 사용했기 때문에 `name`에 `무선`이 있거나 `in_stock=true`인 두 조건 중 하나 이상을 만족하는 전자기기 문서가 검색되었다.
## (개인) 문제 4 — 자기 bool 검색

자기 사용자 질문 하나를 검색 의도와 정확 조건으로 분해해 bool 요청을 구현하세요.

### 역할·검증 기준

- must 0~1개, filter 2개 이상을 사용합니다.
- 각 field와 query 선택 이유를 mapping type으로 설명합니다.
- 반환 문서 3개 이상을 실제 값으로 검증합니다.

### API와 결과 입력

```http
GET /manga-books/_search
{
  "size": 5,
  "track_total_hits": true,
  "_source": [
    "manga_id",
    "title",
    "description",
    "genre",
    "status",
    "paper_price"
  ],
  "query": {
    "bool": {
      "must": [
        { "match": { "description": "판타지" } }
      ],
      "filter": [
        { "term": { "genre": "판타지" } },
        { "term": { "status": "완결" } },
        { "range": { "paper_price": { "lte": 7000 } } }
      ]
    }
  }
}
```

- 사용자 질문: 판타지와 관련된 만화 중 완결되었고 종이책 가격이 7,000원 이하인 작품을 찾고 싶다.
- must와 이유: `description`에 `판타지`를 `match`로 검색했다. `description`은 `text` 타입이므로 사용자가 입력한 검색어를 분석해 관련 문서를 찾는 전문 검색에 적합하다.
- filter 2개와 이유: `genre=판타지`와 `status=완결`은 각각 `keyword` 타입이라 정확한 값 비교를 위해 `term`을 사용했다. `paper_price`는 `integer` 타입이라 7,000원 이하 조건을 적용하기 위해 `range`를 사용했다.
- 실제 검증 결과: `hits.total.value`는 `1,672`였다. `MANGA-00009`는 판타지/완결/7,000원, `MANGA-00045`는 판타지/완결/4,500원, `MANGA-00064`는 판타지/완결/4,500원으로 확인되어 모두 검색 조건을 만족했다.

## (개인) 문제 5 — 조건 역할 검증

개인 문제 4에서 filter 하나를 제거하고 전후 결과를 비교하세요. 추가로 원래 조건에서 제외되어야 하는 문서 1개를 독립 요청으로 확인하세요.

### 역할·검증 기준

- 한 번에 filter 하나만 제거합니다.
- 새로 포함된 문서의 실제 값을 확인합니다.
- 제외 문서는 원래 bool 결과에 포함되지 않아야 합니다.
### API와 결과 입력

```http
GET /manga-books/_search
{
  "size": 5,
  "track_total_hits": true,
  "_source": [
    "manga_id",
    "title",
    "description",
    "genre",
    "status",
    "paper_price"
  ],
  "query": {
    "bool": {
      "must": [
        { "match": { "description": "판타지" } }
      ],
      "filter": [
        { "term": { "genre": "판타지" } },
        { "range": { "paper_price": { "lte": 7000 } } }
      ]
    }
  }
}
```

- 제거한 filter: `status = 완결`
- 전/후 total: `1,672 / 4,775`
- 새로 포함된 ID와 값:
  - `MANGA-00004` — `status: 연재중`, `paper_price: 4500`
  - `MANGA-00008` — `status: 연재중`, `paper_price: 7000`
  - `MANGA-00011` — `status: 연재중`, `paper_price: 6000`
- 제외 확인 ID와 근거: `GET /manga-books/_doc/MANGA-00004`로 독립 조회한 결과 `MANGA-00004`는 `genre: 판타지`, `description`에 판타지가 포함되고 `paper_price: 4500`이지만 `status: 연재중`이었다. 따라서 원래 문제 4의 `status=완결` filter를 만족하지 않아 원래 bool 검색에서는 제외되어야 하는 문서임을 확인했다.
