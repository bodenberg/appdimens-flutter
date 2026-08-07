## 3.1.6

* Reescreve do zero a engine multiplataforma com as 13 estratégias da API
  Dynamic: balanced, percentage, default, logarithmic, power, fluid,
  interpolated, diagonal, perimeter, fit, fill, autosize e none.
* Adiciona cálculo rápido e independente de contexto com `calculateFor`.
* Adiciona snapshots `AppDimensViewport` e resolução tipada de qualificadores.
* Adiciona API inteligente por tipo de elemento e extensões numéricas.
* Adiciona entrypoints modulares `appdimens_core` e `appdimens_units`.
* Remove dependência direta de `dart:io` da detecção de plataforma.
* Expande testes e documentação de migração, desempenho e plataformas.
* Atualiza o SDK mínimo, `flutter_lints` e as GitHub Actions para versões atuais.
* Remove código legado não exportado, corrige o benchmark Flutter e valida builds
  web/Linux, documentação e publicação.

## 2.0.0

* API legada de dimensões fixas, dinâmicas, fluidas e unidades físicas.
