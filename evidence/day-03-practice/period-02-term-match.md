# 2교시 실습 — term과 match

## (공통) 문제 1 — 제공 코드로 정확 조건 확인

```http
GET /products/_search
{
  "size": 5,
  "query": { "term": { "category": "전자기기" } }
}
```

### 결과 입력

- `hits.total.value`: `2,500`
- 상위 3개 문서 ID:
  - `P-00009`
  - `P-00025`
  - `P-00081`
- 상위 3개 문서의 category:
  - `P-00009` — `전자기기`
  - `P-00025` — `전자기기`
  - `P-00081` — `전자기기`
- 모든 확인 문서가 정확 조건을 만족하는가: 예. 확인한 상위 문서의 `category` 값이 모두 `전자기기`였다.
- `term`을 선택한 mapping 근거: `category`는 `keyword` 타입이므로 분석된 전문 검색보다 값 전체가 정확히 일치하는지 비교하는 `term` query가 적합하다.

## (공통) 문제 2 — text 전문 검색 직접 구현

`products` index에서 상품명 `name`에 `무선`이라는 검색 의도가 있는 문서를 찾으세요. text 전문 검색에 적합한 query를 선택해 최대 5건을 반환하세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 5,
  "query": {
    "match": {
      "name": "무선"
    }
  }
}
```

### 결과 입력

- 선택한 query와 이유: `match` query. `name`은 `text` 타입이므로 검색어를 analyzer로 분석한 뒤 상품명에 포함된 token과 비교하는 전문 검색이 적합하다.
- `hits.total.value`: `1,000`
- 상위 3개 ID·name:
  - `P-00025` — `MobiCore 컴팩트 무선 이어폰`
  - `P-00042` — `CleanMate 실속형 무선 청소기`
  - `P-00129` — `Auralis 스마트 무선 이어폰`

## (공통) 문제 3 — 부적절한 조합 비교

같은 `name` field와 `무선` 검색어에 `term` query를 사용한 API를 직접 작성하세요. 문제 2와 결과를 비교하고, 차이를 mapping 또는 분석된 token 관점에서 설명하세요.

### API 전체 입력

```http
GET /products/_search
{
  "size": 5,
  "query": {
    "term": {
      "name": "무선"
    }
  }
}
```

### 비교 결과

- 문제 2 total / 문제 3 total: `1,000 / 1,000`
- 공통으로 나온 문서 ID:
  - `P-00025`
  - `P-00042`
  - `P-00129`
- 달라진 이유: 이번 검색어 `무선`은 `name` field가 분석될 때 실제 token으로 저장되어 있어 `term` query도 같은 token을 직접 찾을 수 있었다. 따라서 이번 데이터에서는 `match`와 `term`의 결과 수와 상위 결과가 동일했다. 다만 `match`는 입력 검색어를 분석한 뒤 검색하고, `term`은 검색어를 분석하지 않고 그대로 비교한다는 동작 차이가 있다.
- `term`은 text에서 항상 0건인가? 실제 근거: 아니다. 실제 실행 결과 `name`이라는 `text` field에 `term`으로 `무선`을 검색했을 때 `1,000건`이 조회되었다. 분석 결과에 `무선`이라는 동일한 token이 존재했기 때문이다.

## (개인) 문제 4 — 자기 정확 조건 검색

자기 mapping에서 값 전체가 정확히 일치해야 하는 `keyword` 또는 `boolean` field 하나를 선택해 정확 조건 검색을 구현하세요.

### 역할·검증 기준

- 실제 존재하는 field와 값을 사용합니다.
- 반환 문서의 `_source`에서 조건을 직접 확인합니다.
- 왜 전문 검색이 아니라 정확 비교인지 설명합니다.

### API와 결과 입력

```http
GET /manga-books/_search
{
  "size": 3,
  "track_total_hits": true,
  "_source": [
    "manga_id",
    "title",
    "genre"
  ],
  "query": {
    "term": {
      "genre": "판타지"
    }
  }
}
```

- field / type / 값: `genre` / `keyword` / `판타지`
- 사용자 질문: 판타지 장르의 만화책을 찾고 싶다.
- 상위 3개 ID와 실제 값:
  - `MANGA-00001` — `장송의 프리렌` / `genre: 판타지`
  - `MANGA-00003` — `지옥락` / `genre: 판타지`
  - `MANGA-00004` — `판타지 만화 4` / `genre: 판타지`
- 통과/실패와 근거: 통과. `hits.total.value`는 `4,775`건이었고, 확인한 상위 3개 문서의 `genre` 값이 모두 정확히 `판타지`였다. `genre`는 `keyword` 타입이므로 전문 검색이 아니라 정확한 값 비교가 적합하다.

## (개인) 문제 5 — 자기 전문 검색

자기 mapping의 `text` field 하나와 사용자가 입력할 검색어를 정해 전문 검색 API를 구현하세요.

### 역할·검증 기준

- field가 실제 `text`인지 mapping으로 확인합니다.
- 상위 3개 결과를 관련/보류/무관으로 판정합니다.
- 정확 조건 문제와 query 선택 이유가 달라야 합니다.

### API와 결과 입력

```http
GET /manga-books/_search
{
  "size": 3,
  "track_total_hits": true,
  "_source": [
    "manga_id",
    "title"
  ],
  "query": {
    "match": {
      "title": "판타지"
    }
  }
}
```

- field / type / 검색어: `title` / `text` / `판타지`
- 상위 3개 ID:
  - `MANGA-00004`
  - `MANGA-00008`
  - `MANGA-00009`
- 관련/보류/무관과 이유:
  - `MANGA-00004` — 관련: 제목이 `판타지 만화 4`로 검색어 `판타지`가 직접 포함되어 있다.
  - `MANGA-00008` — 관련: 제목이 `판타지 만화 8`로 검색어 `판타지`가 직접 포함되어 있다.
  - `MANGA-00009` — 관련: 제목이 `판타지 만화 9`로 검색어 `판타지`가 직접 포함되어 있다.
- 완료 판정: 통과. `title`은 `text` 타입이므로 사용자의 검색어를 분석하여 찾는 `match` query를 사용했고, `4,773건`이 검색되었다. 상위 3개 결과도 모두 검색어와 직접 관련된 제목이었다.
