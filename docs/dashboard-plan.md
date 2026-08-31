# Dashboard 계획

## 1. Dashboard 사용자와 목적

- Dashboard를 볼 사용자: 만화 작품의 분포를 확인하고 싶은 사용자
- 이 사용자가 확인하려는 상황: 어떤 장르의 작품이 많고, 작품들의 연재 상태와 발행 시기 등이 어떻게 분포되어 있는지 확인한다.
- Dashboard를 본 뒤 할 다음 행동: 관심 있는 장르나 조건을 정하고 검색할 작품 범위를 좁힌다.

## 2. 분석 질문

1. 어떤 장르의 만화 작품 수가 가장 많은가?
2. 연재중 작품과 완결 작품의 비율은 어떻게 되는가?
3. 연재 시작 연도별 작품 수는 어떻게 분포하는가?
4. 가격대별 만화 작품 수는 어떻게 분포하는가?

## 3. 차트 아이디어 초안

| 차트 아이디어 | 답할 질문 | 사용할 field 후보 |
|---|---|---|
| 장르별 작품 수 막대 차트 | 어떤 장르의 작품이 가장 많은가? | `genre` |
| 연재 상태 비율 차트 | 연재중과 완결 작품의 비율은 어떻게 되는가? | `status` |
| 연재 시작 연도별 작품 수 차트 | 어느 연도에 연재를 시작한 작품이 많은가? | `start_year` |
| 가격대별 작품 수 차트 | 작품 가격은 어떤 가격대에 많이 분포하는가? | `paper_price` |

Day 4 수업 완료 기준은 Lens 차트 4개입니다. 각 차트는 하나의 질문에 답해야 합니다.

| 번호 | Lens 시각화 | 답할 질문 | 사용할 field | 집계 또는 표시 방식 | 결과를 본 뒤의 판단·행동 |
|---:|---|---|---|---|---|
| 1 | Metric |  |  | Records Count 등 |  |
| 2 | Bar 또는 Table |  |  | Top values / terms 등 |  |
| 3 | Bar 또는 Table |  |  | Top values / terms 등 |  |
| 4 | Histogram 또는 Line |  |  | Histogram / date histogram 등 |  |

> 평가 최소 기준은 차트 2개 이상이지만, 수업에서는 차트 4개를 완성합니다.

## 4. Control과 시간 설정

- Options list 또는 range control에 사용할 field:
- 이 control로 함께 좁힐 차트:
- Data View 이름:
- 시간 field: 사용 / 사용하지 않음
- 시간 field를 사용한다면 field 이름과 기간:

## 5. 제목과 배치 계획

- Dashboard 제목:
- 상단에 둘 차트 또는 control:
- 가운데에 둘 차트:
- 하단에 둘 차트:

## 6. Day 4 완료 기록

- 실제로 만든 차트 수:
- Dashboard 화면 캡처: `evidence/dashboard.png`
- 선택 export: `kibana/dashboard.ndjson`
- 계획과 다르게 바꾼 점 및 이유:
