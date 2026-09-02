# 4교시 실습 — 정확 조건과 경계

## (공통) 문제 1 — 제공 코드로 세 filter 확인

```http
GET /products/_search
{
  "size": 10,
  "query": {
    "bool": {
      "filter": [
        { "term": { "category": "전자기기" } },
        { "term": { "in_stock": true } },
        { "range": { "price": { "gte": 50000, "lte": 200000 } } }
      ]
    }
  }
}
```

## (공통) 문제 1 — 제공 코드로 세 filter 확인

* `hits.total.value`: **380**

* 확인한 문서 ID 3개:

  1. P-00025
  2. P-00129
  3. P-00185

* 각 문서의 category / in_stock / price:

  1. P-00025 → 전자기기 / true / 59,400원
  2. P-00129 → 전자기기 / true / 53,800원
  3. P-00185 → 전자기기 / true / 161,600원

* 조건을 위반한 문서가 있는가:
  → **없다.** 확인한 3개 문서 모두 category가 `전자기기`, in_stock이 `true`이며, 가격도 50,000원 이상 200,000원 이하의 조건을 만족한다.


## (공통) 문제 2 — 경계 포함 범위 직접 구현

### API 전체 입력

```http
GET /products/_search
{
  "size": 10,
  "_source": ["product_id", "name", "category", "price"],
  "query": {
    "bool": {
      "filter": [
        { "term": { "category": "전자기기" } },
        { "range": { "price": { "gte": 50000, "lte": 200000 } } }
      ]
    }
  }
}
```

### 결과 입력

* `hits.total.value`: **440**

* 최소·최대 price:
  → 전체 440건을 기준으로 추가 확인 필요

* 50,000 또는 200,000 경계 문서 존재 여부와 ID:
  → 추가 확인 필요


## (공통) 문제 3 — 경계 제외 범위 직접 구현

### API 전체 입력

```http
GET /products/_search
{
  "size": 10,
  "_source": ["product_id", "name", "category", "price"],
  "query": {
    "bool": {
      "filter": [
        { "term": { "category": "전자기기" } },
        { "range": { "price": { "gt": 50000, "lt": 200000 } } }
      ]
    }
  }
}
```

### 비교 결과

* 문제 2 total / 문제 3 total:

  * 문제 2: 440
  * 문제 3: 440

* 빠진 경계 문서 ID:
  → 없음

* 경계 문서가 없어 결과가 같다면 확인한 근거:
  → 가격이 정확히 50,000원인 전자기기와 200,000원인 전자기기를 각각 조회했지만 모두 0건이었다. 실제 범위 내 최소 가격은 50,700원, 최대 가격은 199,500원이었기 때문에 `gte/lte`에서 `gt/lt`로 변경해도 제외되는 문서가 없어 총 결과 수가 동일하게 440건으로 나왔다.


## (개인) 문제 4 — 자기 정확 조건 2개

### API 전체 입력

```http
GET /manga-books/_search
{
  "size": 10,
  "query": {
    "bool": {
      "filter": [
        { "term": { "genre": "판타지" } },
        { "term": { "status": "완결" } }
      ]
    }
  }
}
```

* field·type·값 2개:

  1. `genre` / `keyword` / `판타지`
  2. `status` / `keyword` / `완결`

* 기대 ID / 제외 ID:

  * 기대 ID: `MANGA-00003` — 지옥락
  * 제외 ID: `MANGA-00001` — 장송의 프리렌

* 실제 결과와 판정:

  * 총 **1,672건**이 검색되었다.
  * 기대했던 `MANGA-00003` 지옥락이 실제 결과에 포함되었으며, `_source`를 확인한 결과 `genre`가 `판타지`, `status`가 `완결`로 두 조건을 모두 만족했다.
  * 제외 대상으로 정한 `MANGA-00001` 장송의 프리렌은 `genre`는 `판타지`이지만 `status`가 `연재중`이므로 검색 결과에서 제외된다.
  * 따라서 두 정확 조건이 의도대로 적용되었다고 판단했다.


## (개인) 문제 5 — 자기 범위와 경계 실험

자기 데이터의 numeric 또는 date field를 선택해 포함 경계와 제외 경계 요청을 각각 구현하세요.

### 역할·검증 기준

- 실제 데이터의 최소·최대 또는 의미 있는 경계값을 먼저 확인합니다.
- `gte/lte`와 `gt/lt` 외 조건은 동일하게 유지합니다.
- 경계 문서가 없으면 fixture 설계 또는 부재 근거를 기록합니다.

### API와 결과 입력

```http

```

- field / type / 경계값:
- 포함 요청 total / 제외 요청 total:
- 달라진 문서 ID:
- 경계 판정:
