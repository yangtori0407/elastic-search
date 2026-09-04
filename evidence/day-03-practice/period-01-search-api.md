# 1교시 실습 — Search API 기본

## (공통) 문제 1 — 제공 코드 실행·응답 읽기

다음 요청을 실행하세요.

```http
GET /products/_search
{
  "size": 5,
  "query": { "match_all": {} }
}
```

### 결과 입력

- HTTP 성공 여부: 성공
- `hits.total.value`: `10,000`
- `hits.total.relation`: `gte`
- `hits.hits`에 반환된 문서 수: `5`
- 첫 번째 문서의 `_id`: `P-00003`
- 첫 번째 문서의 `_source` field 3개:
  - `product_id`: `P-00003`
  - `name`: `Morrow 실속형 오버핏 후드`
  - `description`: `출근에 잘 어울리는 패션 상품입니다. 사용 편의성과 실용성을 함께 고려했습니다.`
- `hits.total.value`와 반환 문서 수가 다를 수 있는 이유:
  - `hits.total.value`는 검색 조건에 일치하는 전체 문서 수를 나타내고, `size`는 실제 응답으로 반환할 문서 수를 제한하기 때문이다.
  - 현재 `hits.total.relation`이 `gte`이므로 검색 결과가 정확히 10,000건이라는 뜻이 아니라 **10,000건 이상**이라는 의미이다.

---

## (공통) 문제 2 — 반환 개수와 field 직접 구현

`products` index의 전체 문서 중 최대 3건만 반환하고, `_source`에는 `product_id`, `name`, `price`, `in_stock`만 포함하는 Search API를 작성하고 실행하세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 3,
  "_source": [
    "product_id",
    "name",
    "price",
    "in_stock"
  ],
  "query": {
    "match_all": {}
  }
}
```

### 결과 입력

- 반환 문서 수: `3`
- `_source`에 요구하지 않은 field가 포함됐는가: 포함되지 않음
- 검증한 문서 ID:
  - `P-00003`
  - `P-00004`
  - `P-00008`

---

## (공통) 문제 3 — 정렬이 포함된 전체 조회 구현

`products` index의 전체 문서 중 최대 10건을 `price`가 낮은 순서로 반환하세요. `_source`에는 `product_id`, `name`, `price`만 포함하세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 10,
  "_source": [
    "product_id",
    "name",
    "price"
  ],
  "query": {
    "match_all": {}
  },
  "sort": [
    {
      "price": {
        "order": "asc"
      }
    }
  ]
}
```

### 결과 입력

- 첫 3개 문서의 ID와 price:
  1. `P-00431` — `5,900원`
  2. `P-06599` — `5,900원`
  3. `P-06479` — `5,900원`

- 오름차순 여부: 정상
  - 처음 6개 상품은 `5,900원`, 이후 상품은 `6,000원`으로 조회되어 가격이 낮은 순서대로 정렬되었다.

- 두 문서의 price가 같을 때 순서가 고정된다고 말할 수 있는가? 근거:
  - 고정된다고 말할 수 없다.
  - 현재 정렬 기준은 `price` 하나뿐이기 때문에 가격이 같은 문서끼리는 어떤 문서가 먼저 나올지 추가 기준이 없다.
  - 동일 가격에서도 순서를 고정하려면 `product_id`와 같은 두 번째 정렬 조건을 추가해야 한다.

---

## (개인) 문제 4 — 자기 index의 첫 Search API

자기 index의 전체 문서 중 최대 5건을 반환하는 Search API를 작성하세요.

### 역할·검증 기준

- 실제 자기 index 이름을 사용합니다.
- `_count`와 `hits.total.value`를 비교합니다.
- `size`와 전체 일치 문서 수를 구분해 설명합니다.

### API와 결과 입력

```http
GET /manga-books/_search
{
  "size": 5,
  "query": {
    "match_all": {}
  }
}
```

- 자기 index: `manga-books`
- `_count`: `50,000`
- `hits.total.value`: `10,000`
- `hits.total.relation`: `gte`
- 반환 문서 수: `5`
- 판정과 근거:
  - 정상.
  - `_count`는 `manga-books` index에 실제 저장된 전체 문서 수인 `50,000건`을 나타낸다.
  - Search API의 `hits.total.value`는 `10,000`, `relation`은 `gte`로 표시되었다.
  - 이는 전체 검색 결과가 정확히 10,000건이라는 의미가 아니라 **10,000건 이상**이라는 뜻이다.
  - `size: 5`는 전체 검색 결과의 개수와 관계없이 실제 응답으로 반환할 문서를 최대 5건으로 제한한다.
  - 따라서 전체 문서는 50,000건이지만 응답의 `hits.hits`에는 5건만 반환된다.

---

## (개인) 문제 5 — 결과 카드 field 설계

자기 서비스에서 검색 결과 카드 한 개를 보여 준다고 가정하세요. 사용자가 클릭 여부를 결정하는 데 필요한 field 3~5개만 반환하는 Search API를 작성하세요.

### 역할·검증 기준

- 선택한 field가 자기 mapping과 실제 문서에 존재해야 합니다.
- 식별자, 제목 역할, 판단용 정보가 포함되어야 합니다.
- 불필요한 field를 하나 이상 제외하고 이유를 설명합니다.

### API와 결과 입력

```http
GET /manga-books/_search
{
  "size": 3,
  "_source": [
    "manga_id",
    "title",
    "genre",
    "status",
    "paper_price"
  ],
  "query": {
    "match_all": {}
  }
}
```

- 포함한 field와 이유:
  - `manga_id`: 만화 작품을 구분하기 위한 고유 ID
  - `title`: 사용자가 어떤 작품인지 확인하기 위한 제목
  - `genre`: 원하는 장르인지 확인하기 위한 정보
  - `status`: 연재중인지 완결인지 확인하기 위한 정보
  - `paper_price`: 구매할 때 가격을 확인하기 위한 정보

- 제외한 field와 이유:
  - `description`: 검색 결과 카드에 표시하기에는 내용이 길어 우선 제외
  - `start_year`: 기본 검색 결과에서 작품을 선택할 때 우선순위가 낮아 제외
  - `volume_count`: 기본 검색 결과에서 반드시 보여줄 필요는 없다고 판단해 제외

- 실제 반환 문서 ID:
  1. `MANGA-00001` — 장송의 프리렌 / 판타지 / 연재중 / 7,000원
  2. `MANGA-00002` — 하이큐!! / 스포츠 / 완결 / 5,500원
  3. `MANGA-00003` — 지옥락 / 판타지 / 완결 / 6,000원

- 완료 판정:
  - 통과.
  - 작품의 식별자, 제목, 장르, 연재 상태, 가격을 반환하여 사용자가 검색 결과에서 작품을 선택하는 데 필요한 정보를 확인할 수 있다.
