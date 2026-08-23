# CLiTICAL for iOS

*English: [README.md](README.md)*

包括的高度慢性下肢虚血（CLTI: Chronic Limb-Threatening Ischaemia）に対する血行再建術の
術後リスクを、患者データから予測する iOS アプリです。

日本血管外科学会（JSVS）JCLIMB レジストリのデータをもとに構築された Miyata らの予測モデルを
実装しており、Flutter/Android 版 CLiTICAL を SwiftUI でネイティブ実装したものです。

> **免責事項**
> 本アプリは医療従事者の臨床判断を支援することを目的としています。算出される値は統計モデルに
> よる推定であり、診断や治療方針を決定するものではありません。最終的な判断は担当医師の責任に
> おいて行ってください。

## 主な機能

- **患者データ入力** — 基本情報・生活歴・臨床情報・動脈病変部位・その他血管病変・合併症の
  6 セクションに分けて入力
- **リスク予測** — 入力値から 5 つの指標を算出
- **参考文献** — 予測モデルの原著論文を `SFSafariViewController` で表示
- **設定** — 日本語／英語の切り替え（アプリ内で即時反映）、利用規約・プライバシーポリシー・
  サポート、アプリ情報
- **アクセシビリティ** — VoiceOver 対応、Dynamic Type、色に依存しないリスク表示

## 予測できる指標

| 指標 | 内容 |
| --- | --- |
| 予測 30 日死亡・大切断率 | 術後 30 日以内の死亡または大切断の発生率 |
| 予測 30 日 MALE 発生率 | 術後 30 日以内の主要有害下肢事故（大切断／新たな急性・慢性下肢虚血） |
| 予測 2 年 OS | 2 年全生存率（低／中等度／高リスクの分類付き） |
| 予測 2 年 AFS | 2 年大切断回避生存率 |
| GNRI | Geriatric Nutritional Risk Index（栄養リスク指標、4 段階分類付き） |

GNRI は `14.89 × Alb + 41.7 × min(体重 / (22 × 身長²), 1.0)` で算出し、
98 以上＝リスクなし／92–98＝軽度／82–92＝中等度／82 未満＝高度に分類します。
30 日リスクはロジスティック回帰、2 年 OS/AFS は Cox 比例ハザードモデル
（基準生存率 OS 0.922、AFS 0.876）で算出しています。

なお動脈病変は AI（大動脈・腸骨動脈）／FP（大腿膝窩）／BK（膝下）のうち
最低 1 部位の選択が必要で、上位部位が優先されて病変分類が決まります。

## 動作環境

- iOS 16.0 以降（iPhone・iPad対応）
- Xcode 15 以降 / Swift 5.9
- 外部依存パッケージなし（ネットワーク通信は文献・法務ページのリンク表示のみ）

## プロジェクト構成

```
clitical-ios/
├── clitical/                     # アプリ本体（SwiftUI）
│   ├── CliticalApp.swift         # エントリポイント
│   ├── MainTabView.swift         # タブ構成／参考文献／設定・アプリ情報
│   ├── ContentView.swift         # 患者データ入力フォーム
│   ├── PredictedRiskView.swift   # 予測結果画面
│   ├── ChoiceListView.swift      # ToggleRow / SegmentedRow / MenuChoiceRow
│   ├── AgeFormView.swift ほか     # 数値入力フォーム（年齢・身長・体重・Alb）
│   ├── Labels.swift              # ドメイン enum → ローカライズキーの対応
│   ├── LocalizationManager.swift # アプリ内言語切り替え
│   ├── QuestionError.swift       # 入力エラーの定義
│   └── CLPatientData/            # ローカル Swift Package（ドメインロジック）
│       ├── Sources/CLPatientData/
│       │   ├── PatientData.swift # 患者データのモデル（値型）
│       │   ├── PatientRisk.swift # リスク計算とリスク分類
│       │   └── Questions.swift   # 各モデルの説明変数と回帰係数
│       └── Tests/CLPatientDataTests/
├── cliticalUITests/              # XCUITest
├── ja.lproj / en.lproj           # Localizable.strings
└── clitical-ios.xcodeproj
```

## アーキテクチャ

- **ドメインロジックの分離** — リスク計算は UI から独立したローカル Swift Package
  `CLPatientData` に置き、SwiftUI に依存しない形でテスト可能にしています。
  回帰係数は `Questions.swift` に説明変数ごとの `enum` として集約されています。
- **値型の患者データ** — `PatientData` は `struct` で、`@State` / `@Binding` を通じて
  各フォームに渡されます。永続化は行いません。
- **アプリ内言語切り替え** — `LocalizationManager` が `Bundle.main` のクラスを差し替え、
  選択した `.lproj` を優先させることで、再起動なしに `Text("key")` を再解決します。
  UIKit 側にキャッシュされるナビゲーションタイトルのみ `localization.string(forKey:)` で
  明示的に解決しています。
- **HIG 準拠の UI** — 設定的な項目はタブを持たせず「設定」タブに集約し、選択肢は画面遷移では
  なくインラインの `Picker` / `Toggle` で表現しています。

## ビルドと実行

Xcode で `clitical-ios.xcodeproj` を開き、スキーム `clitical-ios` を実行します。

コマンドラインからビルドする場合:

```bash
xcodebuild -project clitical-ios.xcodeproj -scheme clitical-ios -destination 'platform=iOS Simulator,name=iPhone 16' build
```

## テスト

Red/Green の TDD で開発しています。ドメインロジックのユニットテストは
[Swift Testing](https://developer.apple.com/documentation/testing) で記述しています。

パッケージ単体のテスト:

```bash
swift test --package-path clitical/CLPatientData
```

UI テストを含む全テスト:

```bash
xcodebuild -project clitical-ios.xcodeproj -scheme clitical-ios -destination 'platform=iOS Simulator,name=iPhone 16' test
```

## ローカライズ

対応言語は日本語（既定）と英語です。文言は `ja.lproj/Localizable.strings` と
`en.lproj/Localizable.strings` に配置し、キーは両ファイルで一致させます。
選択言語は `UserDefaults` の `app_language` に保存され、初回起動時は端末の言語設定に従います。

## バージョニング

`MARKETING_VERSION`（表示バージョン）と `CURRENT_PROJECT_VERSION`（ビルド番号）は
Xcode プロジェクトのビルド設定で管理しています。表示バージョンは「設定 > アプリ情報」に
表示されます。

## 参考文献

1. Miyata T. et al, *Risk prediction model for early outcomes of revascularization for
   chronic limb-threatening ischaemia.* Br J Surg. 2022 Oct 14;109(11):1123.
   <https://doi.org/10.1093/bjs/znab036>
2. Miyata T. et al, *Prediction Models for Two Year Overall Survival and Amputation Free
   Survival After Revascularisation for Chronic Limb Threatening Ischaemia.*
   Eur J Vasc Endovasc Surg. 2022 Jun 7;S1078-5884(22)00340-9.
   <https://doi.org/10.1016/j.ejvs.2022.05.038>

## 利用規約

法務関連の文書はアプリ外でホストしており、「設定」から `SFSafariViewController` で
表示します。表示言語は設定で選択中の言語に従います。

- **利用規約** — [日本語](https://studiome.github.io/clitical-legal/terms/ja/) /
  [English](https://studiome.github.io/clitical-legal/terms/en/)
- **プライバシーポリシー** — [日本語](https://studiome.github.io/clitical-legal/privacy/ja/) /
  [English](https://studiome.github.io/clitical-legal/privacy/en/)
- **サポート** — [日本語](https://studiome.github.io/clitical-legal/support/ja/) /
  [English](https://studiome.github.io/clitical-legal/support/en/)

URL は `MainTabView.swift` の `AppInfo.legalURL(for:language:)` で組み立てています。

初回起動時はアプリ本体の代わりに「意図された使用目的」の通知を表示し、そこから利用規約を
開けます。「内容を理解しました」をタップすると、通知および利用規約に同意したものとして
記録します。同意内容は `UserDefaults` の `intended_use_disclaimer_version` に、同意した
通知のバージョン（`IntendedUseDisclaimer.currentVersion`）として保存され、文言を実質的に
変更した場合は再度同意を求めます。

## プライバシー

入力された患者データは端末内でのみ処理され、外部への送信・保存は行いません。
アプリ内に保存されるのは、選択言語の設定と、同意済みの通知バージョンのみです。

## ライセンス

本ソフトウェアは [MIT License](LICENSE) で公開しています。

予測モデルの回帰係数や分類基準は「参考文献」に挙げた論文に基づくものであり、
MIT License はソフトウェアの実装にのみ適用されます。

## クレジット

- 発行: 特定非営利活動法人 日本血管外科学会 / JCLIMB 委員会（2022）
- ソフトウェア制作: 宮原和洋
- 利用規約: <https://studiome.github.io/clitical-legal/terms/ja/>
