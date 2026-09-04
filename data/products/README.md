# Products 실습 데이터

Elasticsearch 검색과 Kibana Dashboard 실습에 사용하는 공통 상품 데이터 패키지입니다.

이 폴더에는 `products` 인덱스를 만들기 위한 mapping, 상품 데이터 생성기, 생성 결과, Bulk 적재 스크립트가 들어 있습니다.

- Index: `products`
- 기본 생성 문서 수: `10,000`
- 기본 Seed: `9502026`
- Category 수: `8`

---

## 1. 폴더 구조

```text
data/products/
├─ generated/
│  ├─ generation-summary.json
│  ├─ products-10000.ndjson
│  └─ products-sample-30.ndjson
│
├─ generator/
│  └─ generate-products.ps1
│
├─ requests/
│  └─ 01-create-products.http
│
├─ data-contract.ps1
├─ generation-rules.json
├─ load-products.ps1
├─ product-mapping.json
└─ README.md
```

---

## 2. 각 폴더와 파일의 역할

### `generated/`

상품 데이터 생성기를 실행했을 때 만들어진 결과 파일을 보관하는 폴더입니다.

#### `generated/products-10000.ndjson`

Elasticsearch Bulk API에 적재할 실제 상품 데이터입니다.

NDJSON(Newline Delimited JSON) 형식이며 한 문서는 보통 두 줄로 구성됩니다.

```json
{"index":{"_index":"products","_id":"P-00001"}}
{"product_id":"P-00001","name":"...","category":"...","price":100000}
```

첫 번째 줄은 Elasticsearch Bulk 작업 정보이고, 두 번째 줄은 실제 상품 문서입니다.

#### `generated/products-sample-30.ndjson`

전체 데이터 중 일부만 빠르게 확인할 수 있도록 만든 샘플 데이터입니다.

10,000건 전체를 직접 열지 않고도 field와 값의 형태를 확인할 때 사용합니다.

#### `generated/generation-summary.json`

데이터 생성 결과를 요약한 파일입니다.

생성한 문서 수와 Seed 등 생성 결과를 확인할 때 사용합니다.

---

### `generator/`

상품 데이터를 생성하는 코드가 들어 있는 폴더입니다.

#### `generator/generate-products.ps1`

실습용 상품 데이터를 생성하는 PowerShell 스크립트입니다.

```powershell
.\generator\generate-products.ps1 -Count 10000 -Seed 9502026
```

- `Count`: 생성할 상품 문서 수
- `Seed`: 난수 생성 기준값

같은 `Count`와 `Seed`를 사용하면 같은 규칙의 실습 데이터를 다시 생성할 수 있습니다.

---

### `requests/`

Elasticsearch에 실행할 HTTP 요청을 보관하는 폴더입니다.

#### `requests/01-create-products.http`

`products` 인덱스와 mapping을 생성할 때 사용하는 요청 파일입니다.

인덱스를 새로 만들기 전에는 기존 `products` 인덱스가 있는지 먼저 확인합니다.

```http
GET /products
```

---

### `product-mapping.json`

`products` 인덱스의 구조를 정의하는 파일입니다.

각 field를 Elasticsearch에서 어떤 자료형으로 저장하고 검색할지 정합니다.

| Field | Type | 역할 |
|---|---|---|
| `product_id` | `keyword` | 상품 고유 ID |
| `name` | `text` + `keyword` | 상품명 검색 및 정확한 값 처리 |
| `description` | `text` | 상품 설명 검색 |
| `category` | `keyword` | 카테고리 filter와 집계 |
| `brand` | `keyword` | 브랜드 filter와 집계 |
| `price` | `integer` | 가격 범위 검색과 통계 |
| `rating` | `float` | 상품 평점 |
| `review_count` | `integer` | 리뷰 수 |
| `in_stock` | `boolean` | 재고 여부 |
| `tags` | `keyword` | 상품 태그 |
| `created_at` | `date` | 상품 생성일 |
| `updated_at` | `date` | 상품 수정일 |

추가로 다음 설정도 포함합니다.

- shard: 3
- replica: 1
- `dynamic: strict`
- `name`, `description`: 검색용 analyzer 사용

`dynamic: strict`이므로 mapping에 정의하지 않은 field가 들어오면 Elasticsearch가 임의로 field를 추가하지 않고 오류를 발생시킵니다.

---

### `generation-rules.json`

상품 데이터가 어떤 규칙으로 생성되는지를 기록한 설명 파일입니다.

현재 다음과 같은 기준이 들어 있습니다.

- 기본 문서 수: 10,000
- Seed: 9502026
- 생성일 범위
- `in_stock=true` 생성 비율
- `tags` 누락 비율
- `updated_at` 누락 비율
- category 수
- Dashboard에서 확인할 분석 질문

이 파일은 generator가 직접 읽는 설정 파일이라기보다 **데이터 생성 규칙을 문서화한 파일**입니다.

---

### `data-contract.ps1`

생성된 NDJSON 파일이 Elasticsearch에 적재 가능한 상태인지 검사하는 검증 코드입니다.

주요 확인 항목:

- NDJSON 형식
- 예상 문서 수
- Elasticsearch `_id`
- 중복 ID
- `product_id`와 `_id` 일치 여부
- mapping에 없는 field 존재 여부
- field 값과 mapping type 일치 여부

이 파일은 데이터를 생성하거나 적재하지 않고, `load-products.ps1` 실행 전에 데이터 품질을 확인하는 역할을 합니다.

---

### `load-products.ps1`

생성된 NDJSON 데이터를 Elasticsearch의 `products` 인덱스에 Bulk 적재하는 스크립트입니다.

실행 흐름:

```text
NDJSON 파일 확인
   ↓
data-contract.ps1로 검증
   ↓
Docker Elasticsearch 실행 상태 확인
   ↓
products mapping 존재 여부 확인
   ↓
NDJSON을 es01 컨테이너로 복사
   ↓
Bulk API 적재
   ↓
_count로 적재 결과 확인
```

현재 기본 파일은:

```text
generated/products-10000.ndjson
```

입니다.

기본 실행:

```powershell
.\load-products.ps1
```

---

### `README.md`

현재 폴더의 구조와 각 파일의 역할, 실행 방법을 설명하는 문서입니다.

---

## 3. 데이터 생성 규칙

상품은 총 8개의 category를 기준으로 생성됩니다.

```text
전자기기
생활
패션
스포츠
도서
뷰티
식품
반려동물
```

10,000건을 생성하면 category가 균등하게 배분되어 각 category가 1,250건씩 생성됩니다.

`in_stock`은 약 85% 확률을 기준으로 생성하므로 정확히 8,500건으로 고정되는 값은 아닙니다.

`tags`, `updated_at`에는 일부 누락값이 생성될 수 있습니다.

---

## 4. 실행 순서

현재 `load-products.ps1`은 **데이터 적재만 담당**합니다.

즉, 스크립트를 실행하기 전에 Elasticsearch에 `products` 인덱스와 mapping이 먼저 만들어져 있어야 합니다.

전체 순서는 다음과 같습니다.

```text
Docker 실행
   ↓
products 인덱스 + mapping 생성
   ↓
상품 데이터 생성
   ↓
data-contract.ps1로 검증
   ↓
load-products.ps1로 Bulk 적재
   ↓
_count로 문서 수 확인
   ↓
Kibana Data View 생성
   ↓
Discover / Lens / Dashboard 사용
```

---

### 1) Docker 환경 실행

저장소 루트에서:

```powershell
cd docker
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\start.ps1
.\status.ps1
```

Elasticsearch와 Kibana가 정상적으로 실행된 것을 확인한 뒤 다음 단계로 진행합니다.

---

### 2) `products` 인덱스와 mapping 생성

데이터를 적재하기 전에 Elasticsearch에 `products` 인덱스를 먼저 생성합니다.

현재 loader는 인덱스를 자동으로 생성하지 않으므로 이 단계가 필요합니다.

Kibana에서:

```text
Dev Tools
→ Console
```

로 이동한 뒤, 먼저 인덱스가 존재하는지 확인합니다.

```http
GET /products
```

`products`가 없다면 `data/products/requests/01-create-products.http`의 인덱스 생성 요청을 실행합니다.

이 요청은 `product-mapping.json`에서 정의한 field 구조를 기준으로 `products` 인덱스를 생성하기 위한 용도입니다.

생성 후 mapping을 확인합니다.

```http
GET /products/_mapping
```

#### 왜 데이터를 넣기 전에 인덱스를 먼저 만드는가?

Elasticsearch는 인덱스가 없어도 문서를 먼저 넣으면 인덱스를 자동 생성할 수 있습니다.

하지만 이 경우 Elasticsearch가 데이터를 보고 field type을 자동 추론하기 때문에 실습에서 의도한 mapping과 달라질 수 있습니다.

예를 들어 이 프로젝트에서는 다음처럼 field type을 명확히 사용합니다.

```text
category   → keyword
price      → integer
name       → text
in_stock   → boolean
created_at → date
```

이 mapping은 이후 다음 기능에 직접 영향을 줍니다.

- `term` filter
- `range` query
- `bool` query
- Kibana Top values
- Lens 집계
- Dashboard 분석

따라서 **원하는 mapping으로 인덱스를 먼저 만든 뒤 데이터를 적재하는 방식**을 사용합니다.

---

### 3) 상품 데이터 생성

저장소 루트 기준으로:

```powershell
cd data\products
.\generator\generate-products.ps1 -Count 10000 -Seed 9502026
```

생성 후:

```text
generated/
├─ products-10000.ndjson
├─ products-sample-30.ndjson
└─ generation-summary.json
```

을 확인합니다.

---

### 4) Elasticsearch에 Bulk 적재

`products` 인덱스와 mapping이 준비된 상태에서 실행합니다.

```powershell
.\load-products.ps1
```

loader는 다음 순서로 동작합니다.

```text
NDJSON 파일 확인
   ↓
data-contract.ps1로 데이터 검증
   ↓
Elasticsearch 실행 상태 확인
   ↓
products mapping 존재 여부 확인
   ↓
Bulk API 적재
   ↓
_count 확인
```

현재 기본 적재 파일은:

```text
generated/products-10000.ndjson
```

입니다.

---

### 5) 적재 결과 확인

Kibana Dev Tools에서:

```http
GET /products/_count
```

10,000건을 깨끗한 인덱스에 적재한 경우:

```json
{
  "count": 10000
}
```

샘플 확인:

```http
GET /products/_search
{
  "size": 5
}
```

---

### 6) Kibana Data View 생성

Elasticsearch의 `products` 인덱스와 Kibana Data View는 서로 다른 개념입니다.

```text
products
└─ Elasticsearch의 실제 인덱스
   └─ 상품 문서가 저장되는 곳

products_board
└─ Kibana Data View
   └─ Kibana에서 products 인덱스를 조회하기 위한 설정
```

따라서 Data View는 Bulk 적재 전에 만들 필요가 없습니다.

데이터 적재가 끝난 뒤 Kibana에서 Data View를 생성합니다.

예:

```text
Data View 이름: products_board
Index pattern: products
Time field: created_at
```

이후 다음 기능에서 사용할 수 있습니다.

- Discover
- Lens
- Dashboard
- KQL
- Filter / Control

---

## 5. 주의사항

- Docker 환경을 먼저 실행해야 합니다.
- 현재 `load-products.ps1`은 `products` 인덱스를 자동으로 생성하지 않습니다.
- 따라서 **Bulk 적재 전에 `products` 인덱스와 mapping을 먼저 생성해야 합니다.**
- Kibana의 `products_board` Data View는 Elasticsearch 인덱스 생성과 별개의 단계입니다.
- Data View는 데이터 적재 후 생성해도 됩니다.
- 기존 `products` 인덱스에 데이터가 있는 상태에서 다시 적재하면 결과가 예상과 달라질 수 있습니다.
- 동일한 데이터를 재현하려면 같은 `Count`와 `Seed`를 사용합니다.
- 현재 `load-products.ps1`의 기본 기준은 `products-10000.ndjson` 10,000건입니다.
- Day 4에서 사용한 20,000건 환경을 clone 후 그대로 재현하려면 이후 loader를 20,000건도 처리할 수 있도록 수정해야 합니다.
- 추후에는 `load-products.ps1`이 인덱스 존재 여부를 확인하고, 없을 경우 mapping까지 자동 생성하도록 개선할 수 있습니다.

---

## 6. 전체 흐름

```text
generate-products.ps1
        │
        ▼
products-10000.ndjson
        │
        ▼
data-contract.ps1
   데이터 검증
        │
        ▼
load-products.ps1
   Bulk API 적재
        │
        ▼
Elasticsearch
   products index
        │
        ├── Search API 실습
        └── Kibana Dashboard 실습
```
