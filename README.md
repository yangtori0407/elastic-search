# [만화책 검색]

## 1. 프로젝트 소개

- 문제와 사용자: 내가 원하는 만화책을 찾기 위한 사람들이 제목과 조건으로 도서를 찾는다.

- ES로 검색할 문서 1건: 만화책 1개

- 이 주제를 선택한 이유: 만화 장르로 상세한 조건으로 검색하여 내가 원하는 만화책을 찾을 수 있는 검색을 만들고 싶다.

## 2. 실행 순서

1. Docker 환경 시작: Docker Desktop을 실행한 뒤 저장소의 `docker` 폴더로 이동하여 `.env.example`을 `.env`로 복사하고 `.\start.ps1`을 실행한다. PowerShell 실행이 제한된 경우 `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`를 적용하며, `.\status.ps1`으로 Elasticsearch와 Kibana의 실행 상태를 확인한다.

2. index와 mapping 생성: Kibana의 `Dev Tools → Console`에서 `manga-books` index의 존재 여부를 확인하고, index가 없는 경우 `elasticsearch/index-create.json`에 정의한 mapping을 기준으로 `manga-books` index를 생성한다. 생성 후 `GET /manga-books/_mapping`으로 mapping이 정상적으로 적용되었는지 확인한다.

3. 데이터 생성·Bulk 적재: `data/manga-books` 폴더에서 `my-data-settings.ps1`의 설정을 이용해 Seed `20260901`로 50,000건의 만화책 데이터를 생성한다. 생성된 NDJSON 데이터를 `validate-data.ps1`로 검증한 뒤 `load-data.ps1`을 실행하여 `manga-books` index에 Bulk 적재하고, `GET /manga-books/_count`로 50,000건이 적재되었는지 확인한다.

4. 검색 요청 실행: Kibana의 `Dev Tools → Console`에서 `manga-books` index를 대상으로 검색 요청을 실행한다. `multi_match`로 제목과 설명을 검색하고, `term`으로 장르와 연재 상태를 필터링하며, `range`로 가격 범위를 검색하고, `bool`을 이용해 여러 검색 조건을 조합한다.

5. Kibana Dashboard 확인: `manga-books` Data View를 생성한 뒤 Discover에서 데이터와 field가 정상적으로 조회되는지 확인한다. 이후 Lens와 Dashboard를 이용해 전체 작품 수, 장르별 작품 수, 장르별 평균 가격 등을 시각화하고 `genre`, `status` 등의 조건을 이용해 데이터를 필터링한다.

## 3. 데이터와 mapping

- 문서 수: 50,000건

- 데이터 생성 규칙과 seed:
  - Seed: `20260901`
  - 장르, 연재 상태, 시작 연도, 권수, 종이책 가격 등의 값을 조합하여 실습용 만화책 데이터를 생성했다.
  - 동일한 Seed를 사용하면 같은 조건의 데이터를 다시 생성할 수 있도록 구성했다.

- 개인정보 미사용 확인:
  - 개인정보를 사용하지 않았으며, 만화책 정보와 실습을 위해 생성한 더미 데이터만 사용했다.

- 핵심 필드와 타입 선택 이유:
  - `manga_id` (`keyword`): 각 만화책을 구분하는 고유 ID로 사용
  - `title` (`text`): 작품 제목을 검색하기 위해 사용
  - `description` (`text`): 작품 설명의 내용을 검색하기 위해 사용
  - `genre` (`keyword`): 장르를 정확하게 필터링하고 집계하기 위해 사용
  - `status` (`keyword`): `연재중`, `완결` 상태를 정확하게 필터링하기 위해 사용
  - `start_year` (`integer`): 연재 시작 연도를 숫자로 비교하기 위해 사용
  - `volume_count` (`integer`): 발매 권수를 숫자로 비교하기 위해 사용
  - `paper_price` (`integer`): 종이책 가격을 범위 검색하고 평균 가격을 분석하기 위해 사용

## 4. 검색·품질 테스트

| 검색 질문 | 기대 결과 | 실제 결과 | 판정 |
|---|---|---|---|
| `판타지`와 관련된 만화책을 찾을 수 있는가? | 제목 또는 설명에 `판타지`와 관련된 작품이 검색되어야 한다. | `title`, `description`에 `multi_match` 검색을 적용한 결과 4,775건이 검색되었다. | 정상 |
| 장르가 `판타지`이면서 `완결`된 작품만 찾을 수 있는가? | 두 조건을 모두 만족하는 작품만 검색되어야 한다. | 1,672건이 검색되었으며 `지옥락`은 포함되고, `연재중`인 `장송의 프리렌`은 제외되었다. | 정상 |
| 종이책 가격이 5,000원 이상 7,000원 이하인 작품을 찾을 수 있는가? | 5,000원과 7,000원의 경계값을 포함하여 해당 가격 범위의 작품이 검색되어야 한다. | 41,682건이 검색되었으며 5,000원인 작품과 7,000원인 작품도 결과에 포함되었다. | 정상 |

## 5. Dashboard

- Dashboard 사용자: 만화책 회사 관계자

- 차트 1이 답하는 질문:
  - 장르별로 등록된 만화 작품 수는 어떻게 다른가?

- 차트 2가 답하는 질문:
  - 장르별 종이책의 평균 가격은 어떻게 다른가?

- control/filter 목적:
  - `genre`, `status` 등의 조건을 선택하여 특정 장르나 `연재중`, `완결` 상태의 작품만 확인하고 비교할 수 있도록 한다.

## 6. AI Search 확장 판단

- 적용 여부와 근거:
