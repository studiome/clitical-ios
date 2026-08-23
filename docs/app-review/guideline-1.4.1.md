# App Review Guideline 1.4.1 への対応

対象: Submission ID `da073f65-715a-4352-b8b3-f4b82701d485` / 2.1.0 (125) / 2026-08-22

> Apple の指摘: *"The app provides medical related data, health related measurements,
> diagnoses or treatment advice without the appropriate regulatory clearance."*
> → *"please attach your regulatory approval documentation in the App Review
> Information section"*

## 1. 結論

- **規制当局の承認を取りに行く必要はない**（本アプリは医療機器プログラムに該当しない前提）。
  Apple が求めているのは「承認書」そのものではなく、**なぜ承認が不要なのかを示す文書**でも受理される。
  多くの臨床スコア計算アプリはこの経路で通っている。
- **カテゴリー変更では解決しない**。1.4.1 は機能に対して適用される。→ §5
- やることは 3 つ:
  1. App Store Connect の **App Review Information に非該当を示す文書を添付**し、返信する（§3・§4）
  2. **配信地域を絞る**（Apple の "subject to all of the local regulatory laws where the
     app is available" への直接の答え）（§3.3）
  3. **アプリ内の開示を戻す**（2.1.0 で失われている。すでに本ブランチで実装済み）（§2）

## 2. まず直すべき退行: アプリ内の開示が 2.1.0 で消えていた

`e26c6f2 Add localized legal links` で `AboutView` が削除され、免責事項・モデルの出典が
**アプリ内から完全になくなった**。2.1.0 では

- 起動 → 患者データ入力 → 死亡率・切断率が「%」で表示される
- 免責事項は「設定 > 利用規約」の **外部 Web ページ**（`SFSafariViewController`）にしかない

という状態で、レビュアー（iPad Air 11-inch で確認）がアプリだけを触ると
「根拠の説明なしに医療的な数値を出すアプリ」に見える。1.4.1 は
*"Apps must clearly disclose data and methodology"* を明示的に要求しているので、
これは実質的に指摘どおりでもある。

本ブランチで実装した内容:

| 変更 | 場所 |
| --- | --- |
| 初回起動時の使用目的の告知（対象利用者・医療機器ではない・値の性質・適用範囲・最終判断は医師）。同意するまでアプリ本体に入れない | `IntendedUseGate` / `IntendedUseDisclaimerView` |
| 予測結果画面に短い注意書きを常設 | `PredictedRiskView` |
| `AboutView` を復活。加えて「使用目的」「算出方法（モデル種別・基準生存率・GNRI 式・係数の出典）」「適用範囲と限界」を追加 | `MainTabView.swift` |

告知はバージョン管理してある（`IntendedUseDisclaimer.currentVersion`）ので、
文面を実質的に変えたら再同意を求められる。UI テストは launch argument
`-intended_use_disclaimer_version` で告知をスキップする。

## 3. App Store Connect でやること

### 3.1 添付する文書（App Review Information > Attachment）

「承認書」がない代わりに、**医療機器非該当であることの説明文書**を PDF で添付する。
日本血管外科学会 / JCLIMB 委員会が発行元なので、**学会の名義・レターヘッドで出す**のが最も効く。
§6 にテンプレートを置いた。同時に添付するもの:

1. 非該当に関する説明書（学会名義、署名入り、日付入り）
2. 原著論文 2 編の PDF または DOI
   - Miyata T. et al. *Br J Surg.* 2022;109(11):1123. <https://doi.org/10.1093/bjs/znab036>
   - Miyata T. et al. *Eur J Vasc Endovasc Surg.* 2022. <https://doi.org/10.1016/j.ejvs.2022.05.038>
3. アプリ内の告知画面のスクリーンショット（ja/en）

> 事前に**薬事の専門家か学会の担当者に非該当の判断を確認**し、その裏付けを取ってから
> 文書を出すこと。以下は判断の枠組みの整理であって、法的助言ではない。

判断の枠組み（日本）: 厚生労働省の「プログラムの医療機器該当性に関するガイドライン」では、
①診断・治療における結果の重要性と社会的影響、②機能の障害が生命・健康に与えるおそれ、
の 2 点で該当性を判断する。既に公表・周知された知見（査読付き論文の予測式）を医療従事者に
提示するだけで、診断・治療の判断は医師が行うものは非該当側に整理されるのが通例。
本アプリは、①入力は医師の手入力のみ（デバイスからの測定・信号取得なし）、
②出力は集団レベルの推定値、③診断名も治療推奨も出さない、④係数と出典を全部開示、
という設計なので、この整理に乗せやすい。

### 3.2 App Review Information > Notes に書くこと

レビュアーは臨床医ではない。**アプリが何をしていないか**を先に書く。§4 に文案。

### 3.3 配信地域を絞る（強く推奨）

Apple の *"subject to all of the local regulatory laws where the app is available"* は、
「全世界配信のままだと EU MDR も含めて全部説明しろ」という意味になる。
予測モデル自体が **日本の JCLIMB レジストリから導出されていて日本の患者にしか妥当性がない**
のだから、配信地域を **日本のみ**（必要なら日本語圏の学会員向けに数か国）に絞るのが、
臨床的にも規制的にも筋が通る。EU MDR Annex VIII Rule 11 の議論を丸ごと回避できる。

Availability は App Store Connect > 該当アプリ > 価格および配信状況 > 国または地域 から変更。
返信でこの変更に触れると、Apple 側の懸念に直接答えたことになる。

### 3.4 メタデータの見直し

- **説明文の冒頭を告知にする**: 「本アプリは医療従事者向けの参考ツールです。医療機器では
  なく、診断・治療を行うものではありません。」を 1 行目に置く。
- 「診断」「治療方針を決定」「判定」を想起させる語を説明文・キーワード・スクリーンショットの
  キャプションから外す。「参考情報」「推定」「臨床判断の補助」に統一。
- スクリーンショットに数値だけの画面を先頭に置かない。告知画面か入力画面を先頭に。
- 年齢制限アンケートの「医療・治療に関する情報」の項目を正直に申告する。

## 4. 返信文案

App Store Connect の当該メッセージにそのまま返信する。英語のほうが往復が早い。

### 英語

> Thank you for the review. We would like to clarify the nature of the app, as we
> believe it does not fall within the scope of the regulatory clearance requirement.
>
> **CLiTICAL is a calculator for licensed healthcare professionals, not a medical device.**
>
> - The app performs **no measurement and no data acquisition**. It takes no input from
>   the device's sensors, from HealthKit, from an image, or from any diagnostic
>   instrument. Every value is typed in manually by the clinician.
> - The app produces **no diagnosis and no treatment recommendation**. It does not name a
>   condition, propose a procedure, or advise for or against an intervention.
> - What it displays are **population-level statistical estimates**, produced by applying
>   the clinician's entries to prediction models published in two peer-reviewed journals
>   (British Journal of Surgery 2022 and European Journal of Vascular and Endovascular
>   Surgery 2022, both attached). Every explanatory variable and regression coefficient is
>   taken as published; the app adds no model of its own. The methodology, the derivation
>   cohort, the model types and the coefficients' source are disclosed inside the app,
>   under Settings > CLiTICAL > About, and the original articles are linked from the
>   References tab.
> - The intended user is a vascular surgeon or other healthcare professional. The app is
>   not intended for patients. Since this build, the app opens on an intended-use notice
>   that states this — and that the app is not a medical device, that the figures are
>   estimates from published models, and that diagnosis and treatment decisions remain
>   with the attending physician — which must be acknowledged before the app can be used.
>   The same notice is repeated beside the calculated figures.
>
> **Regulatory status.** Because the app only presents already-published knowledge to a
> healthcare professional who makes the clinical decision themselves, it is not a
> regulated medical device program under Japan's Pharmaceuticals and Medical Devices Act,
> and therefore no approval or certification document exists to attach. We have attached a
> signed statement from the publisher, the Japanese Society for Vascular Surgery (JCLIMB
> Committee), setting out this position, together with the two source articles.
>
> **Availability.** The prediction models were derived from the JCLIMB registry of
> patients treated in Japan and are only validated for that population. We have therefore
> limited the app's availability to Japan, so that no other jurisdiction's medical device
> regulation is engaged.
>
> We would be glad to provide anything further that would help. Thank you.

### 日本語（Apple は日本語での返信も受け付けている）

> ご確認ありがとうございます。本アプリの性質について補足いたします。規制当局の承認を要する
> 医療機器には該当しないと考えております。
>
> **CLiTICAL は医療従事者向けの計算ツールであり、医療機器ではありません。**
>
> - **測定・データ取得を一切行いません**。センサー、HealthKit、画像、診断機器のいずれからも
>   入力を受け取らず、すべての値は医師が手入力します。
> - **診断も治療推奨も行いません**。疾患名を提示せず、術式を提案せず、治療の実施可否を
>   助言しません。
> - 表示するのは、査読付き論文 2 編（British Journal of Surgery 2022 / European Journal of
>   Vascular and Endovascular Surgery 2022、いずれも添付）で公表された予測モデルに入力値を
>   当てはめて得られる**集団レベルの統計的推定値**です。説明変数・回帰係数はすべて原著記載の
>   ままで、独自のモデルは含みません。算出方法・導出コホート・モデル種別・係数の出典は
>   アプリ内（設定 > CLiTICAL > アプリ情報）に開示しており、原著は参考文献タブから参照できます。
> - 想定利用者は血管外科医をはじめとする医療従事者であり、患者本人の利用を意図していません。
>   本ビルドより、起動時に「医療従事者向けであること」「医療機器ではないこと」「表示値は公表
>   モデルによる推定であること」「診断・治療の判断は担当医師が行うこと」を明示する告知を表示し、
>   同意しない限りアプリを利用できない構成としました。同趣旨の注意書きは算出結果の画面にも
>   常時表示しています。
>
> **規制上の位置づけ**: 本アプリは、既に公表された知見を医療従事者に提示するのみで、臨床判断は
> 医師が行うため、日本の薬機法上の医療機器プログラムには該当せず、添付すべき承認書・認証書が
> 存在しません。発行元である特定非営利活動法人 日本血管外科学会（JCLIMB 委員会）名義の
> 見解書を、原著論文 2 編とあわせて添付しております。
>
> **配信地域**: 予測モデルは日本国内で治療された患者の JCLIMB レジストリから導出されており、
> その集団以外では妥当性が担保されません。したがって配信地域を日本のみに限定し、他法域の
> 医療機器規制が及ばないようにいたしました。
>
> 追加で必要な資料がございましたらお知らせください。

## 5. カテゴリーは変えるべきか → 変えない

- **1.4.1 はカテゴリーではなく機能に対して適用される**。Medical から Reference や
  Medical → Education に移しても、審査で見えるのは「死亡率を % で出す画面」なので指摘は消えない。
- むしろ、実態が医療従事者向け臨床ツールなのに Reference 等に移すと
  **Guideline 2.3（正確なメタデータ）**の指摘を新たに呼び込むリスクがある。
  「規制を避けるためにカテゴリーを変えた」と読まれるのが最悪。
- 臨床医が App Store で探すのは Medical カテゴリー。ユーザー到達性の面でも下げる理由がない。

**結論: Primary = Medical のまま。効くのは「カテゴリー」ではなく「Review Notes + 添付文書 +
配信地域 + アプリ内開示」。**

Secondary Category を設定していないなら、`Medical` + `Reference` にするのは無害で、
「参考情報を提示するツール」という位置づけの補強にはなる。ただしこれは主要因ではない。

## 6. 学会名義の見解書テンプレート（PDF にして添付）

> **CLiTICAL アプリの規制上の位置づけに関する見解**
>
> 発行者: 特定非営利活動法人 日本血管外科学会 JCLIMB 委員会
> 対象: iOS アプリケーション「CLiTICAL」（Bundle ID: ＿＿＿＿）
> 日付: ＿＿＿＿
>
> 1. **目的**: 本アプリは、包括的高度慢性下肢虚血（CLTI）に対する血行再建術の術後転帰について、
>    査読付き論文として公表済みの予測モデルに基づく参考情報を、医療従事者に提示することを
>    目的とする。
> 2. **対象利用者**: 医師その他の医療従事者。患者本人による使用を意図しない。
> 3. **機能**: 利用者が手入力した患者情報を、下記文献に記載された回帰式に代入し、
>    集団レベルの推定値を表示する。測定・信号取得・画像解析の機能を有しない。
>    診断名の提示、治療方針の提案、治療の実施可否に関する助言を行わない。
> 4. **出典**（回帰係数・分類基準はすべて原著記載のとおり）
>    - Miyata T, et al. Br J Surg. 2022;109(11):1123. doi:10.1093/bjs/znab036
>    - Miyata T, et al. Eur J Vasc Endovasc Surg. 2022. doi:10.1016/j.ejvs.2022.05.038
> 5. **規制上の位置づけ**: 上記の機能・使用目的に鑑み、本アプリは医薬品医療機器等法に定める
>    医療機器プログラムに該当しないものと判断する。したがって、医療機器としての承認・認証・
>    届出は行っておらず、これに対応する承認書等は存在しない。
> 6. **配信地域**: 予測モデルの導出集団に鑑み、日本国内のみを配信対象とする。
>
> （署名 / 役職 / 連絡先）

## 7. 再提出前チェックリスト

- [ ] 学会名義の見解書（署名・日付入り PDF）を用意した
- [ ] 薬事の担当者に非該当の判断を確認した
- [ ] App Review Information > Attachment に見解書・論文 2 編・告知画面のスクリーンショットを添付した
- [ ] App Review Information > Notes に §4 の要旨を記載した
- [ ] 配信地域を日本のみに変更した
- [ ] 説明文の 1 行目を「医療従事者向け・医療機器ではない」の告知にした
- [ ] 説明文・キーワードから「診断」「治療方針の決定」を想起させる語を外した
- [ ] 本ブランチのアプリ内変更（告知画面・結果画面の注意書き・About 復活）を含むビルドを上げた
- [ ] スクリーンショットを更新した（先頭を告知画面または入力画面に）
- [ ] Primary Category は Medical のまま
- [ ] 上記メッセージに返信した（添付は返信前に完了させる）
