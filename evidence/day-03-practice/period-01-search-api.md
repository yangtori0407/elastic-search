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

- HTTP 성공 여부:
- `hits.total.value`:
- `hits.hits`에 반환된 문서 수:
- 첫 번째 문서의 `_id`:
- 첫 번째 문서의 `_source` field 3개:
- `hits.total.value`와 반환 문서 수가 다를 수 있는 이유:

## (공통) 문제 2 — 반환 개수와 field 직접 구현

`products` index의 전체 문서 중 최대 3건만 반환하고, `_source`에는 `product_id`, `name`, `price`, `in_stock`만 포함하는 Search API를 작성하고 실행하세요.

### API 전체 입력

```http

```

### 결과 입력

- 반환 문서 수:
- `_source`에 요구하지 않은 field가 포함됐는가:
- 검증한 문서 ID:

## (공통) 문제 3 — 정렬이 포함된 전체 조회 구현

`products` index의 전체 문서 중 최대 10건을 `price`가 낮은 순서로 반환하세요. `_source`에는 `product_id`, `name`, `price`만 포함하세요.

### API 전체 입력

```http

```

### 결과 입력

- 첫 3개 문서의 ID와 price:
- 오름차순 여부:
- 두 문서의 price가 같을 때 순서가 고정된다고 말할 수 있는가? 근거:

## (개인) 문제 4 — 자기 index의 첫 Search API

자기 index의 전체 문서 중 최대 5건을 반환하는 Search API를 작성하세요.

### 역할·검증 기준

- 실제 자기 index 이름을 사용합니다.
- `_count`와 `hits.total.value`를 비교합니다.
- `size`와 전체 일치 문서 수를 구분해 설명합니다.

### API와 결과 입력

```http

{
  "took": 20,
  "timed_out": false,
  "_shards": {
    "total": 1,
    "successful": 1,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": {
      "value": 10000,
      "relation": "gte"
    },
    "max_score": 1,
    "hits": [
      {
        "_index": "manga-books",
        "_id": "MANGA-00001",
        "_score": 1,
        "_source": {
          "manga_id": "MANGA-00001",
          "title": "장송의 프리렌",
          "description": "마왕을 쓰러뜨린 용사 일행의 모험 이후, 엘프 마법사 프리렌이 인간을 알아가기 위해 다시 여행을 떠나는 판타지 이야기",
          "genre": "판타지",
          "status": "연재중",
          "start_year": 2020,
          "volume_count": 15,
          "paper_price": 7000
        }
      },
      {
        "_index": "manga-books",
        "_id": "MANGA-00002",
        "_score": 1,
        "_source": {
          "manga_id": "MANGA-00002",
          "title": "하이큐!!",
          "description": "배구에 매료된 히나타 쇼요가 카라스노 고등학교 배구부에서 동료들과 함께 성장하며 전국 무대에 도전하는 스포츠 이야기",
          "genre": "스포츠",
          "status": "완결",
          "start_year": 2012,
          "volume_count": 45,
          "paper_price": 5500
        }
      },
      {
        "_index": "manga-books",
        "_id": "MANGA-00003",
        "_score": 1,
        "_source": {
          "manga_id": "MANGA-00003",
          "title": "지옥락",
          "description": "사형수 가비마루가 무죄 방면을 조건으로 불로불사의 선약을 찾기 위해 수수께끼의 섬으로 향하는 다크 판타지 이야기",
          "genre": "판타지",
          "status": "완결",
          "start_year": 2018,
          "volume_count": 13,
          "paper_price": 6000
        }
      },
      {
        "_index": "manga-books",
        "_id": "MANGA-00004",
        "_score": 1,
        "_source": {
          "manga_id": "MANGA-00004",
          "genre": "판타지",
          "title": "판타지 만화 4",
          "description": "판타지 장르의 이야기를 다룬 만화입니다.",
          "status": "연재중",
          "start_year": 2026,
          "volume_count": 11,
          "paper_price": 4500
        }
      },
      {
        "_index": "manga-books",
        "_id": "MANGA-00005",
        "_score": 1,
        "_source": {
          "manga_id": "MANGA-00005",
          "genre": "공포",
          "title": "공포 만화 5",
          "description": "공포 장르의 이야기를 다룬 만화입니다.",
          "status": "연재중",
          "start_year": 2023,
          "volume_count": 25,
          "paper_price": 6500
        }
      }
    ]
  }
}

```

- 자기 index:
- `_count`:
- `hits.total.value`:
- 반환 문서 수:
- 판정과 근거:

## (개인) 문제 5 — 결과 카드 field 설계

자기 서비스에서 검색 결과 카드 한 개를 보여 준다고 가정하세요. 사용자가 클릭 여부를 결정하는 데 필요한 field 3~5개만 반환하는 Search API를 작성하세요.

### 역할·검증 기준

- 선택한 field가 자기 mapping과 실제 문서에 존재해야 합니다.
- 식별자, 제목 역할, 판단용 정보가 포함되어야 합니다.
- 불필요한 field를 하나 이상 제외하고 이유를 설명합니다.

### API와 결과 입력

```http

```

- 포함한 field와 이유:
- 제외한 field와 이유:
- 실제 반환 문서 ID:
- 완료 판정:
