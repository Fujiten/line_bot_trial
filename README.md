# LineチャットBot 

## 開発環境

- Ruby 2.6.2
- Sinatra 2.0.5
- PostgreSQL

## 本番環境

- Heroku


## 機能

- 形態素解析(mecab, natto)

文章から地名情報を抜き出し、天気の返答が出来ます。

- ニュースサイトのスクレイピング(mechanize)

yahooニュースからトップニュース情報を抜き出します。

- ユーザー登録機能

LineUIDから、自動的にユーザー登録し、簡易的なセッション管理を行っています。

## 開発時期

2019年3月頃(プログラミングを開始してから4ヶ月目ほど)。フレームワークに頼らず、完全にフルスクラッチで開発したくなり挑戦したもの。

## 簡単な挙動GIF(数秒)

![bot](https://user-images.githubusercontent.com/45753250/61269306-24e15600-a7d9-11e9-9bff-a3dcf023ea73.gif)

## 友達追加用QRコード

![L](https://user-images.githubusercontent.com/45753250/61513424-f614eb00-aa37-11e9-8090-3f4cf1e37be0.png)

※注意　ゲーム機能は未実装です。もとの画面に戻るためには、「戻る」と発言して下さい。
