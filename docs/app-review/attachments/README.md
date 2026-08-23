# App Review Information の添付ファイル

Submission `da073f65-715a-4352-b8b3-f4b82701d485` / Guideline 1.4.1 への返信で
App Store Connect の **App Review Information > Attachment** に添付する資料。
経緯と返信文案は [../guideline-1.4.1.md](../guideline-1.4.1.md) を参照。

## 見解書

| ファイル | 内容 |
| --- | --- |
| `jsvs-non-device-statement-draft.pdf` | 医療機器非該当に関する見解書の**草案**（日本語・英語の 2 ページ） |
| `jsvs-non-device-statement-draft.html` | 上記の原稿。修正はこちらを編集して PDF を再生成する |

> **そのまま提出しないこと。** これは草案であり、日本血管外科学会 JCLIMB 委員会の
> 確認を受け、日付と署名（役職・連絡先）を入れて学会名義で発行してもらう必要がある。
> 非該当の判断そのものについても、薬事の担当者または学会に確認を取ること。
> ファイル内の判断の記述は法的助言ではない。

PDF の再生成:

```
cd docs/app-review/attachments
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless \
  --no-pdf-header-footer --print-to-pdf=jsvs-non-device-statement-draft.pdf \
  jsvs-non-device-statement-draft.html
```

## スクリーンショット

いずれも 2.1.0 (126) を **iPad Air 11-inch (M3) / iOS 26.5**（レビュー機と同一）で撮影。

| ファイル | 内容 |
| --- | --- |
| `01-intended-use-notice-ja-1.png` | 起動時の使用目的の告知（日本語・上半分） |
| `02-intended-use-notice-ja-2.png` | 同（日本語・下半分、利用規約へのリンクまで） |
| `03-intended-use-notice-en-1.png` | 同（英語・上半分） |
| `04-intended-use-notice-en-2.png` | 同（英語・下半分） |
| `05-about-methodology-en-1.png` | 設定 > CLiTICAL > About（使用目的・予測項目） |
| `06-about-methodology-en-2.png` | 同（算出方法・モデルの出典・適用範囲と限界・免責事項） |
| `07-results-notice-en.png` | 算出結果の数値と、その直下に常時表示される注意書き |

レビュアーは英語で読むため、返信で参照する際は英語版（03〜07）を先に挙げる。

## 別途用意するもの

- 原著論文 2 編の PDF または DOI
  - Miyata T, et al. *Br J Surg.* 2022;109(11):1123. <https://doi.org/10.1093/bjs/znab036>
  - Miyata T, et al. *Eur J Vasc Endovasc Surg.* 2022. <https://doi.org/10.1016/j.ejvs.2022.05.038>
- 価格および配信状況 > App 配信可能な国または地域 の画面（日本のみ、かつ
  「今後 App Store に追加される国または地域で自動的に配信する」がオフであること）
