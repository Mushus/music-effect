# music_effect

指定した音楽に合わせて画面にエフェクトを付けるコード郡

## 用途

SNSの投稿に動画は許可されていても音楽は許可されていないことが多いので、適当にビジュアライザつけて動画として投稿するときに使う。

## イメージ

![effect1](https://raw.github.com/Mushus/music-effect/master/doc/img/effect1.png)

## 使い方

### processing の導入

processing が必要です。

> [processingの公式サイト](https://processing.org/)

### ソースコードのダウンロード

このリポジトリをチェックアウトします。ダウンロードからzipで取得でも構いません。

```sh
git clone xxx.git
```

### Minim ライブラリのインストール

もしかしたら`minim`が読み込まれていないかもしれません。<br>
メニューバーから「スケッチ > ライブラリをインポート > ライブラリを追加」を押すと「Conturibution Manager」ダイアログが出ます。<br>
「Libraries」タブのテキストフォームにminimと検索するとNameが「Minim | An audio library...」で始まるライブラリが見つかりますので、それをクリックして、「install」ボタンを押します。<br>
インストールが完了したらダイアログを閉じてください。<br>

### フレームの出力

`./effect[n]/effect[n].pde` をprocessingで開きます。`[n]`のところは適当な数字です。<br>
コメントついてるパラメータをいい感じにいじります。

**NOTE:** Processingのエディタの場合、日本語が正常に表示されない環境もあります。その場合適当なエディタで編集してください。

データについては`./effect[n]/frame/data/`内の素材が読み込まれます。<br>
必要な素材はそちらのディレクトリに配置してください。

実行すると`./effect[n]/frame/`に連番pngが吐き出されますので最後まで見届けます。<br>
すべて終われば勝手に閉じられます。

NOTE: 初期はプレビューモードになっています。`outputFrame = true;` に設定するとframeフォルダにpng形式でフレームが吐き出されます。

**NOTE:** フォルダ内の連番画像は自動で削除はされないので、書き出すごとに適宜削除してください。

### ムービー生成

メニューバーの「ツール > ムービーメーカー」をクリックすると「QuickTime ムービーメーカー」ダイアログが表示されます。

「Drag a folder with image files into the field below」のフィールドに`./effect[n]/frame/`を設定します。<br>
「幅」は`1280`、「高さ」は`720`、「Framerate」は`60`、「Compression」は`PNG`を指定します。<br>
「Drag a sound file into the field below」にはフレーム出力時に生成した音楽ファイルを指定してください。

「Create movie...」で動画が保存できます。

### ムービーをSNSにアップロードできるように変換する

適当なツールを使用して動画を変換します。<br>
とりあえず動画のフォーマットは`mp4`でビデオのコーデックを`H.264`、音楽のコーデックを`AAC`にしておけば問題無いと思います。

## TODO

- [ ] 他にもバリエーションを用意する
- [ ] コードが書き殴った感じで酷いのでできたらリファクタする
