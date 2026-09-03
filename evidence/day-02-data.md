# Day 2 데이터 준비 결과

> 실제 실행한 결과를 기준으로 기록한다. 아직 실행하지 않은 항목은 미완료 상태로 표시한다.

## 1. Index와 문서

* Index 이름: `manga-books`
* 문서 한 건의 의미: 만화 작품 1개
* 실제 색인 건수: `50,000건`
* Mapping의 `dynamic` 설정: `strict`
* Primary shard: `1`
* Replica shard: `1`

`GET /manga-books` 요청을 통해 `manga-books` Index가 존재하며 설정한 Mapping이 적용된 것을 확인했다.

## 2. 최종 Field

| Field          | Type      | 검색에서 사용할 목적           |
| -------------- | --------- | --------------------- |
| `manga_id`     | `keyword` | 작품을 고유 ID로 정확하게 식별    |
| `title`        | `text`    | 작품 제목 및 제목에 포함된 단어 검색 |
| `description`  | `text`    | 줄거리의 단어를 이용한 전문 검색    |
| `genre`        | `keyword` | 장르 정확 조건 검색 및 장르별 집계  |
| `status`       | `keyword` | 연재중·완결 상태 정확 조건 검색    |
| `start_year`   | `integer` | 연재 시작 연도의 범위 검색 및 정렬  |
| `volume_count` | `integer` | 권 수 범위 검색 및 정렬        |
| `paper_price`  | `integer` | 종이책 가격 범위 검색 및 정렬     |

Mapping에는 정의되지 않은 field가 임의로 추가되지 않도록 `"dynamic": "strict"`를 적용했다.

## 3. 대량 데이터 생성·색인 결과

* 생성 건수: `50,000건 색인 확인`
* 로컬 검증 결과: 생성 단계의 로컬 검증 결과는 별도 확인 필요
* Bulk 색인 결과: Elasticsearch에 데이터가 색인되어 조회되는 것을 확인함
* ES 실제 `_count`: `50,000`
* 분류·숫자·boolean 분포 확인 결과: 아직 실행하지 않음

### 실제 조회 확인

`GET /manga-books/_search` 요청을 통해 색인된 문서가 정상적으로 조회되는 것을 확인했다.

조회 결과의 앞부분에서 다음 문서를 확인했다.

* `MANGA-00001` : 장송의 프리렌
* `MANGA-00002` : 하이큐!!
* `MANGA-00003` : 지옥락
* 이후 생성된 테스트 만화 데이터가 이어서 조회됨

`GET /manga-books/_search`의 `hits.total`은 다음과 같이 표시되었다.

* `value`: `10000`
* `relation`: `gte`

이는 검색 API가 기본적으로 전체 hit 수를 정확하게 끝까지 계산하지 않아 `10,000건 이상`으로 표시한 결과이다.

실제 전체 문서 수는 다음 요청으로 별도 확인했다.

`GET /manga-books/_count`

실행 결과:

* `count`: `50,000`
* shard 요청 성공: `1`
* shard 요청 실패: `0`

따라서 현재 `manga-books` Index에 실제 색인된 문서는 `50,000건`으로 판단했다.

## 4. Day 3 연결

* 검색 질문 기준: `docs/data-model.md`의 사용자 질문 3개

  * Q1. 마법이 나오는 판타지 만화를 찾아줘.
  * Q2. 2018년부터 연재를 시작한 판타지 장르의 만화 중 20권 이하인 작품을 찾아줘.
  * Q3. 장르별 만화 작품 수를 보여줘.

## 5. 결과 파일 위치

* Mapping: `elasticsearch/index-create.json`
* 실행 요청: `requests.http`
* 대표 문서: `data/sample-documents.json`
* 데이터 생성 설정: `data/generation-notes.md`
* 생성 표본: `data/pbl-data-template/generated/manga-books-sample-30.ndjson`
* 생성 요약: `data/pbl-data-template/generated/generation-summary.json`

※ 생성 표본과 생성 요약 파일은 실제 생성 여부를 확인한 뒤 최종 제출 상태를 판단한다.

## 6. Pipeline 적용 판단

* 적용 / 미적용 / 보류: `보류`
* 판단 이유: 현재 Mapping을 이용한 색인과 조회까지 확인했으며, Pipeline을 이용한 별도 전처리가 필요한지는 아직 판단하지 않았다. 이후 데이터 전처리 필요 여부를 확인한 뒤 최종 결정한다.

## 7. 미완료·오류

* 현재 상태:

  * `manga-books` Index 생성 완료
  * Mapping 적용 확인 완료
  * Primary shard 1, Replica shard 1 설정 확인
  * 대표 문서 및 생성 데이터 조회 확인
  * 실제 색인 건수 `50,000건` 확인
  * field별 분포 조회는 아직 진행하지 않음
  * Pipeline 적용 여부는 아직 보류 상태

* 다음에 할 작업:

  * Analyzer를 이용한 text 분석 실습
  * CRUD 요청 및 변경 전후 결과 확인
  * `genre`, `status`, `start_year`, `volume_count`, `paper_price` 분포 확인
  * 데이터 생성 결과 파일과 생성 조건 확인
  * Pipeline 적용 여부 최종 판단
