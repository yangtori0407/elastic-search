$IndexName = 'manga-books'
$DocumentCount = 50000
$Seed = 20260901
$IdPrefix = 'MANGA'
$IdField = 'manga_id'
$SampleCount = 30

$Vocabularies = [ordered]@{
genres = @(
'판타지',
'액션',
'로맨스',
'코미디',
'스포츠',
'미스터리',
'공포',
'SF',
'드라마',
'일상'
)

prices = @(
4500,
5000,
5500,
6000,
6500,
7000
)
}

$FieldRules = @(
@{ Name = 'manga_id'; Kind = 'id'; Digits = 5 }

@{ Name = 'genre'; Kind = 'choice'; Source = 'genres' }

@{ Name = 'title'; Kind = 'template'; Template = '{{genre}} 만화 {{sequence}}' }

@{ Name = 'description'; Kind = 'template'; Template = '{{genre}} 장르의 이야기를 다룬 만화입니다.' }

@{ Name = 'status'; Kind = 'weighted_choice'; Values = @(
@{ Value = '연재중'; Weight = 65 },
@{ Value = '완결'; Weight = 35 }
) }

@{ Name = 'start_year'; Kind = 'integer'; Min = 2010; Max = 2026 }

@{ Name = 'volume_count'; Kind = 'integer'; Min = 5; Max = 70 }

@{ Name = 'paper_price'; Kind = 'choice'; Source = 'prices' }
)
