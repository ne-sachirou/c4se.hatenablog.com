<!--
{"id":"26006613407276252","title":"Elixir で stateful なアプリケーションを作るのは簡單です","categories":["Programming","Elixir"],"draft":"no"}
-->

Let's create stateful systems, by Elixir. Elixir で stateful なアプリケーションを作るのは簡單です。

Elixir の得意な事としてよく眞っ先に擧げられるのは竝列性 parallelism です。確かに、簡單で安全に或る程度效率好く parallel にできるのは Elixir の得意とするところです。しかし parallel である事が得意な言語/環境は他にも在ります。Go は人気で簡單に parallel に成り、そこまで安全ではありませんがそこまで危險でもなく、高速です。Clojure (core.async) は parallel な變換處理を簡單に構築し組織できます。Akka (Scala) は Erlang と殆ど同じ思想で作られ、殆ど同じ事を實現できます。また SIMD や GPU 等の parallelism を扱ふのは、Erlang VM は未だ苦手です (これも得意にしようと云ふ試みは在り、樂しみです)。

少なくとも今のところ、Elixir が他の言語/環境と比べて得意なのは、stateful なアプリケーションを作り運用する事です。stateful なアプリケーションを長期間運用するのには面倒な前提を色々と滿たさなければなりませんんが、Elixir と Erlang VM にはその仕組みが備はってゐるので簡單ですね、と云ふ話を以下でしました。GenStage や Phoenix.Channel は典型的な stateful アプリケーションです。

<script async class="speakerdeck-embed" data-id="5dc906bbf0834b34b6b359edd5d0cc4d" data-ratio="1.77777777777778" src="//speakerdeck.com/assets/embed.js"></script>

[Let's create stateful systems, by Elixir](https://speakerdeck.com/ne_sachirou/lets-create-stateful-systems-by-elixir)

數年前に Elixir に關する記事を書く事が流行って以來、Elixir に入門する情報は充實してゐます。これは同じやうな内容でも場に細かく合はせて繼續して書かれる事の要る領野なので、今後も増えてゆく事が期待されますが、Elixir に入門し使へる段階から、Elixir で優れた機能を作る爲の、と云ふ中間的な段階の資料は全く不足してゐます。その資料の一つであるべく、Elixir の表面的な動作を説明するものが以下です。

<script async class="speakerdeck-embed" data-id="cb3572677d9d42279b9facb5361c08c5" data-ratio="1.77777777777778" src="//speakerdeck.com/assets/embed.js"></script>

[Elixir 完全に理解した](https://speakerdeck.com/ne_sachirou/elixirwan-quan-nili-jie-sita)

## Advanced resources

實際の know how を開示したものが以下です。

一つ目は Elixir でのリアルタイム對戰システムの開發開始から運用迄で、困った事とその解決に就いて亂雜且つ網羅的に載せたものです。

<script async class="speakerdeck-embed" data-id="78d6aaeac6ec425c9f23a169414e5cac" data-ratio="1.77777777777778" src="//speakerdeck.com/assets/embed.js"></script>

[ステートフルで大規模アクセスのある soft-realtime なゲームサーバーを easy につくる](https://speakerdeck.com/ne_sachirou/sutetohurudeda-gui-mo-akusesufalsearusoft-realtimenagemusabawoeasynitukuru)

二つ目以降は、上のそれぞれの topic を展開したものです。下は、Phoenix.Channel で二種類のアプリケーションを作った時に、どちらも scale in/out せず、それぞれ scale in/out させる手法が異なった事を説明したものです。

<script async class="speakerdeck-embed" data-id="b5bca9558bde4c72a53a4aff2825951c" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>

[Phoenix at Scale](https://speakerdeck.com/ne_sachirou/phoenix-at-scale)

これには、process 間通信は μ sec の速度でしか動かないので、process を使はずに state を管理したりアプリケーションの構造を組み立てる中で、他の函數型言語と共通はするものの、Elixir 特有の困難を解く幾つかの方法を載せました。

<script async class="speakerdeck-embed" data-id="ac7e5f6e7fe14c3a862a4b567fad532a" data-ratio="1.77777777777778" src="//speakerdeck.com/assets/embed.js"></script>

[DDD: Data Driven Development](https://speakerdeck.com/ne_sachirou/ddd-data-driven-development)

Elixir を Docker container で開發し Kubernetes で運用する時の tips をあらんかぎり載せました。載せてゐないのは多分 CI/CD に就いてくらいだと思ひます。どこかで書けるとよいですね。

<script async class="speakerdeck-embed" data-id="80bae87e23a74ae6ad021d906f364be9" data-ratio="1.77777777777778" src="//speakerdeck.com/assets/embed.js"></script>

[Elixir on Containers](https://speakerdeck.com/ne_sachirou/elixir-on-containers)

## 今後

個人的には Elixir の商用運用からは離れてしまったので、個人的な研鑽のできるところを見附けつつ、何かします。
