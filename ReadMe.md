# What's this?

- [MeCab](https://taku910.github.io/mecab/) による形態素解析と [CaboCha/南瓜](https://taku910.github.io/cabocha/) による係り受け解析を実行する環境を構築するための Dockerfile です．
- 辞書として mecab-ipadic-neologd をインストールします．
- イメージの作成には20分程度の時間が必要です．
- コマンドラインから形態素解析や係り受け解析ができるようになります．
- 次の手順で作成したイメージは Docker Hub (https://hub.docker.com/r/rinsaka/mecab-ubuntu) で公開しています．

## イメージの作成から Docker Hub へのプッシュまで（イメージ開発者向け）

### 環境設定
- この Dockerfile は Apple Silicon 向けに作成されています．
- Windows など Intel 向けにイメージを作成するには Dockerfile 内の `--build=arm` を `--build=x86_64` に書き換えてください（2か所あります）．

### イメージの作成

- コマンド
```
docker build --tag [新規タグ名] .
```

- 実行例
  - この作業に20分程度が必要です
  - タグ名は適宜変更してください

```
docker build --tag rinsaka/mecab-ubuntu .
```

###  イメージの確認

```
docker image ls
```

- 実行例

```
docker image ls
REPOSITORY             TAG      IMAGE ID       CREATED          SIZE
rinsaka/mecab-ubuntu   latest   2054132154b4   13 minutes ago   2.29GB
```

### Docker Hub に Push

- まず login する

```
% docker login
```

- push

```
% docker push rinsaka/mecab-ubuntu
Using default tag: latest
The push refers to repository [docker.io/rinsaka/mecab-ubuntu]
208dac63a3c4: Pushed
4e44b655d18a: Pushed
46598ca993cc: Pushed
1c514e8fdea0: Pushed
3e798a66607c: Layer already exists
latest: digest: sha256:1dfd77d3a6d1bfe033106a76e1c7f5d2db3b9b45bdb270cbb89fd51ab77a24a7 size: 1378
%
```

## イメージおよびコンテナの利用方法（利用者向け情報）

### Docker Hub からのイメージダウンロード

```
% docker pull rinsaka/mecab-ubuntu
```

### MeCab による形態素解析

- 形態素解析したいファイルを読み込む場合
  - `--rm` オプションを指定すると実行後にコンテナが自動的に削除されます
  - `-i` オプションによってホストの入力とコンテナの入力を繋げます（必須）
```
% docker run --rm -i rinsaka/mecab-ubuntu < sample.txt
今日	名詞,副詞可能,*,*,*,*,今日,キョウ,キョー
は	助詞,係助詞,*,*,*,*,は,ハ,ワ
メロンパン	名詞,固有名詞,一般,*,*,*,メロンパン,メロンパン,メロンパン
を	助詞,格助詞,一般,*,*,*,を,ヲ,ヲ
食べ	動詞,自立,*,*,一段,連用形,食べる,タベ,タベ
まし	助動詞,*,*,*,特殊・マス,連用形,ます,マシ,マシ
た	助動詞,*,*,*,特殊・タ,基本形,た,タ,タ
．	記号,句点,*,*,*,*,．,．,．
EOS
%
```

- 形態素解析したい文字列を `echo` で指定する場合

```
% echo "今日はメロンパンを食べました" | docker run --rm -i rinsaka/mecab-ubuntu
今日	名詞,副詞可能,*,*,*,*,今日,キョウ,キョー
は	助詞,係助詞,*,*,*,*,は,ハ,ワ
メロンパン	名詞,固有名詞,一般,*,*,*,メロンパン,メロンパン,メロンパン
を	助詞,格助詞,一般,*,*,*,を,ヲ,ヲ
食べ	動詞,自立,*,*,一段,連用形,食べる,タベ,タベ
まし	助動詞,*,*,*,特殊・マス,連用形,ます,マシ,マシ
た	助動詞,*,*,*,特殊・タ,基本形,た,タ,タ
EOS
%
```

#### 出力形式の変更
- `CMD` を使っているのでコマンドは上書き可能

- 出力形式を「分かち書き」や「茶筌」に変更
```
% docker run --rm -i rinsaka/mecab-ubuntu  mecab -Owakati < sample.txt
% docker run --rm -i rinsaka/mecab-ubuntu  mecab -Ochasen < sample.txt
```

- 実行例
```
% docker run --rm -i rinsaka/mecab-ubuntu  mecab -Owakati < sample.txt
今日 は メロンパン を 食べ まし た ．
% docker run --rm -i rinsaka/mecab-ubuntu  mecab -Ochasen < sample.txt
今日    キョウ  今日    名詞-副詞可能
は      ハ      は      助詞-係助詞
メロンパン      メロンパン      メロンパン      名詞-固有名詞-一般
を      ヲ      を      助詞-格助詞-一般
食べ    タベ    食べる  動詞-自立       一段    連用形
まし    マシ    ます    助動詞  特殊・マス      連用形
た      タ      た      助動詞  特殊・タ        基本形
．      ．      ．      記号-句点
EOS
%
```

#### 辞書の変更
- 指定しなければ高機能な「mecab-ipadic-neologd」が利用されます．
- それ以外に「debian」「ipadic-utf8」「juman-utf8」が利用可能です．
- 「ipadic」も搭載されていますが，文字化けするはずです．
- 「mecab-ipadic-neologd」だけは格納ディレクトリが異なるので明示的に指定する場合は注意してください．

```
% docker run --rm -i rinsaka/mecab-ubuntu mecab < sample.txt
% docker run --rm -i rinsaka/mecab-ubuntu mecab -d /var/lib/mecab/dic/debian < sample.txt
% docker run --rm -i rinsaka/mecab-ubuntu mecab -d /var/lib/mecab/dic/ipadic-utf8 < sample.txt
% docker run --rm -i rinsaka/mecab-ubuntu mecab -d /var/lib/mecab/dic/juman-utf8 < sample.txt
% docker run --rm -i rinsaka/mecab-ubuntu mecab -d /usr/lib/aarch64-linux-gnu/mecab/dic/mecab-ipadic-neologd < sample.txt
```

- 辞書を変更した実行例

```
% docker run --rm -i rinsaka/mecab-ubuntu mecab < sample.txt
今日    名詞,副詞可能,*,*,*,*,今日,キョウ,キョー
は      助詞,係助詞,*,*,*,*,は,ハ,ワ
メロンパン      名詞,固有名詞,一般,*,*,*,メロンパン,メロンパン,メロンパン
を      助詞,格助詞,一般,*,*,*,を,ヲ,ヲ
食べ    動詞,自立,*,*,一段,連用形,食べる,タベ,タベ
まし    助動詞,*,*,*,特殊・マス,連用形,ます,マシ,マシ
た      助動詞,*,*,*,特殊・タ,基本形,た,タ,タ
．      記号,句点,*,*,*,*,．,．,．
EOS
% docker run --rm -i rinsaka/mecab-ubuntu mecab -d /var/lib/mecab/dic/debian < sample.txt
今日    名詞,副詞可能,*,*,*,*,今日,キョウ,キョー
は      助詞,係助詞,*,*,*,*,は,ハ,ワ
メロン  名詞,一般,*,*,*,*,メロン,メロン,メロン
パン    名詞,一般,*,*,*,*,パン,パン,パン
を      助詞,格助詞,一般,*,*,*,を,ヲ,ヲ
食べ    動詞,自立,*,*,一段,連用形,食べる,タベ,タベ
まし    助動詞,*,*,*,特殊・マス,連用形,ます,マシ,マシ
た      助動詞,*,*,*,特殊・タ,基本形,た,タ,タ
．      記号,句点,*,*,*,*,．,．,．
EOS
% docker run --rm -i rinsaka/mecab-ubuntu mecab -d /var/lib/mecab/dic/ipadic-utf8 < sample.txt
今日    名詞,副詞可能,*,*,*,*,今日,キョウ,キョー
は      助詞,係助詞,*,*,*,*,は,ハ,ワ
メロン  名詞,一般,*,*,*,*,メロン,メロン,メロン
パン    名詞,一般,*,*,*,*,パン,パン,パン
を      助詞,格助詞,一般,*,*,*,を,ヲ,ヲ
食べ    動詞,自立,*,*,一段,連用形,食べる,タベ,タベ
まし    助動詞,*,*,*,特殊・マス,連用形,ます,マシ,マシ
た      助動詞,*,*,*,特殊・タ,基本形,た,タ,タ
．      記号,句点,*,*,*,*,．,．,．
EOS
% docker run --rm -i rinsaka/mecab-ubuntu mecab -d /var/lib/mecab/dic/juman-utf8 < sample.txt
今日    名詞,時相名詞,*,*,今日,きょう,代表表記:今日/きょう カテゴリ:時間
は      助詞,副助詞,*,*,は,は,*
メロンパン      名詞,普通名詞,*,*,*,*,*
を      助詞,格助詞,*,*,を,を,*
食べ    動詞,*,母音動詞,基本連用形,食べる,たべ,代表表記:食べる/たべる ドメイン:料理・食事
ました  接尾辞,動詞性接尾辞,動詞性接尾辞ます型,タ形,ます,ました,代表表記:ます/ます
．      特殊,句点,*,*,．,．,*
EOS
% docker run --rm -i rinsaka/mecab-ubuntu mecab -d /usr/lib/aarch64-linux-gnu/mecab/dic/mecab-ipadic-neologd < sample.txt
今日    名詞,副詞可能,*,*,*,*,今日,キョウ,キョー
は      助詞,係助詞,*,*,*,*,は,ハ,ワ
メロンパン      名詞,固有名詞,一般,*,*,*,メロンパン,メロンパン,メロンパン
を      助詞,格助詞,一般,*,*,*,を,ヲ,ヲ
食べ    動詞,自立,*,*,一段,連用形,食べる,タベ,タベ
まし    助動詞,*,*,*,特殊・マス,連用形,ます,マシ,マシ
た      助動詞,*,*,*,特殊・タ,基本形,た,タ,タ
．      記号,句点,*,*,*,*,．,．,．
EOS
%
```

### CaboCha による係り受け解析
- cabocha の実行

```
% docker run --rm -i rinsaka/mecab-ubuntu cabocha < sample.txt
      今日は---D
  メロンパンを-D
    食べました．
EOS
%
```

- `-f1` オプションで出力形式を変更できます

```
% docker run --rm -i rinsaka/mecab-ubuntu cabocha -f1 < sample.txt
* 0 2D 0/1 -1.880791
今日    名詞,副詞可能,*,*,*,*,今日,キョウ,キョー
は      助詞,係助詞,*,*,*,*,は,ハ,ワ
* 1 2D 0/1 -1.880791
メロンパン      名詞,固有名詞,一般,*,*,*,メロンパン,メロンパン,メロンパン
を      助詞,格助詞,一般,*,*,*,を,ヲ,ヲ
* 2 -1D 0/2 0.000000
食べ    動詞,自立,*,*,一段,連用形,食べる,タベ,タベ
まし    助動詞,*,*,*,特殊・マス,連用形,ます,マシ,マシ
た      助動詞,*,*,*,特殊・タ,基本形,た,タ,タ
．      記号,句点,*,*,*,*,．,．,．
EOS
%
```

- `-d` オプションで辞書を変更することも可能です

```
% docker run --rm -i rinsaka/mecab-ubuntu cabocha -f1 -d /var/lib/mecab/dic/juman-utf8 < sample.txt
* 0 2D 0/1 -0.849739
今日    名詞,時相名詞,*,*,今日,きょう,代表表記:今日/きょう カテゴリ:時間
は      助詞,副助詞,*,*,は,は,*
* 1 2D 0/1 -0.849739
メロンパン      名詞,普通名詞,*,*,*,*,*
を      助詞,格助詞,*,*,を,を,*
* 2 -1D 2/2 0.000000
食べ    動詞,*,母音動詞,基本連用形,食べる,たべ,代表表記:食べる/たべる ドメイン:料理・食事
ました  接尾辞,動詞性接尾辞,動詞性接尾辞ます型,タ形,ます,ました,代表表記:ます/ます
．      特殊,句点,*,*,．,．,*
EOS
%
```

### Ubuntu へのログイン

- Ubuntu にログインするには `-t` オプションも必要

```
% docker run --rm -i -t rinsaka/mecab-ubuntu /bin/bash
root@e90a4173e9ae:/# ls
bin  boot  dev  etc  home  lib  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
root@e90a4173e9ae:/# exit
exit
%
```

## バックグラウンドでコンテナを起動して利用する
- サーバなどで連続して形態素解析を実行する場合にはコンテナをデーモンとしてバックグラウンドで起動しておくとよいでしょう．
- 起動時に `-d` オプションを指定してバックグラウンドでデーモンとして起動できます．
- 利用時には `docker exec` コマンドを使います．
- コンテナの停止には `docker container stop`，再始動には `docker container start`，停止したコンテナの削除には `docker container rm` コマンドを使います．
- 下のコマンドの説明は次のとおりです．

1. コンテナが存在しないことを確認
2. コンテナに `mecabd` という名前をつけ，`-d` オプションによりデーモンとしてバックグラウンドで起動
3. コンテナが実行中であることを確認
4. `docker exec` コマンドで形態素解析（ファイルを読み込む）
5. `docker exec` コマンドで形態素解析（文字列を渡す）
6. コンテナが実行中であることを確認
7. 実行中のコンテナを停止
8. 停止したコンテナが残っていることを確認
9. コンテナを削除
10. コンテナが存在しない（削除できた）ことを確認

```
% docker container ls -a                                  ...(1)
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
% docker run -i -d --name mecabd rinsaka/mecab-ubuntu     ...(2)
18fb5a69a7e1ea8e0e1c5c466e64e3a226801c35f843a868d5cce74b00bbf515
% docker container ls                                     ...(3)
CONTAINER ID   IMAGE                  COMMAND            CREATED         STATUS         PORTS     NAMES
18fb5a69a7e1   rinsaka/mecab-ubuntu   "/usr/bin/mecab"   5 seconds ago   Up 5 seconds             mecabd
% docker exec -i mecabd mecab < sample.txt                ...(4)
今日    名詞,副詞可能,*,*,*,*,今日,キョウ,キョー
は      助詞,係助詞,*,*,*,*,は,ハ,ワ
メロンパン      名詞,固有名詞,一般,*,*,*,メロンパン,メロンパン,メロンパン
を      助詞,格助詞,一般,*,*,*,を,ヲ,ヲ
食べ    動詞,自立,*,*,一段,連用形,食べる,タベ,タベ
まし    助動詞,*,*,*,特殊・マス,連用形,ます,マシ,マシ
た      助動詞,*,*,*,特殊・タ,基本形,た,タ,タ
．      記号,句点,*,*,*,*,．,．,．
EOS
% echo "今日はカレーパンを食べました" | docker exec -i mecabd mecab     ...(5)
今日    名詞,副詞可能,*,*,*,*,今日,キョウ,キョー
は      助詞,係助詞,*,*,*,*,は,ハ,ワ
カレーパン      名詞,固有名詞,一般,*,*,*,カレーパン,カレーパン,カレーパン
を      助詞,格助詞,一般,*,*,*,を,ヲ,ヲ
食べ    動詞,自立,*,*,一段,連用形,食べる,タベ,タベ
まし    助動詞,*,*,*,特殊・マス,連用形,ます,マシ,マシ
た      助動詞,*,*,*,特殊・タ,基本形,た,タ,タ
EOS
% docker container ls                                     ...(6)
CONTAINER ID   IMAGE                  COMMAND            CREATED          STATUS          PORTS     NAMES
18fb5a69a7e1   rinsaka/mecab-ubuntu   "/usr/bin/mecab"   57 seconds ago   Up 57 seconds             mecabd
% docker container stop mecabd                            ...(7)
mecabd
% docker container ls -a                                  ...(8)
CONTAINER ID   IMAGE                  COMMAND            CREATED              STATUS                       PORTS     NAMES
18fb5a69a7e1   rinsaka/mecab-ubuntu   "/usr/bin/mecab"   About a minute ago   Exited (137) 4 seconds ago             mecabd
% docker container rm mecabd                              ...(9)
mecabd
% docker container ls -a                                  ...(10)
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
%
```

## 参考情報
- cabocha のファイルを curl でダウンロードする
  - https://qiita.com/namakemono/items/c963e75e0af3f7eed732
