Tapp
===========================
* 信号処理の学習として実装する。
* 入力された音声信号のピークを検出する。
* 成分分析はせずに、信号の順次カウントだけで実装する。

## 構成
pulseaudio:server --(tcp)--> pulseaudio:client --(stdout)--> audiowaveform --(stdout)--> audiowaveform-ruby
* マイク側(Tapp 以外)
    * pulseaudio(server)
    * 物理マイク
* Tapp
    * pulseaudio(client)
    * audiowaveform
    * ピーク検出処理用 ruby script

## できたこと
* リモート入力デバイスからの録音
* audiowaveform 経由での wav ファイル読み込み
* 順次処理による信号データの解析

## 課題
* 極大値の前後にあるピークをひろってしまう
    * ノイズ除去したい
	* カジュアルなカウントでは難しいので、波の分解と解析を理解したい

## 最終的にやりたいこと
* web ブラウザ上で [Peaks.js](https://github.com/bbc/peaks.js/) などを使って可視化したい
* 手と音を使ってコンピュータを操作したい
    * 3 回机をノックしてコマンド起動するとか
