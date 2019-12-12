<!--
{"id":"26006613480862198","title":"Elixir で non-programmer 向けに DSL を作り提供する","categories":["Programming","Elixir"],"draft":"no"}
-->

[言語実装 Advent Calendar 2019 - Qiita](https://qiita.com/advent-calendar/2019/lang_dev) 12/11

C に lex / yacc と云ふ字句解析 generator と構文解析 generator が有る。Erlang には標準 library に leex / yecc と云ふ同じ役割のものが有り簡單に構文解析器を作れる。Elixir からもこれを使える。

昔 Elixir と JavaScript とで game を作る機會が有った。game 中で活動する各 unit は parameter を持ってゐる。parameter の調整に依り game の balance や cycle が變はるのでこの調整を簡單に素早く繰り返せる事は重要だ。調整をする人が直截 data を編輯し反映出來るのが好い。また仮に parameter の編輯や反映が programmer の作業と成ってゐると、囘數の多いこの作業に時間を取られ、parameter の反映も game 開發もどちらも後囘しに成ってしまふ。data を例へば CSV や Google Spreadsheet や理想的には専用の UI で管理して反映出來れば、これは達成出來る。これを整へるのにも開發が要り、白狀すると理想的には出來てゐなかったから一部に programmer や専門の者の手が掛ってしまってゐたが、調整者が出來る丈獨立して反映出來る樣にしてゐた。

各 unit は skill も持ってゐる。skill は一般に複雜に成る。條件と效果、分岐、くり返し、條件の組み合はせ、效果の組み合はせ、條件や效果の打ち消し、それぞれの paramater 等は要るだらう。これを CSV 等表形式で記述しやうとすると、特定の skill 向けの専用 column が大量に生まれ場當り的に logic が増えるだけでなく、skill 設計の柔軟性も失ふ。そこで先述の skill に要る内容を見直すとこれは programming 言語である。skill を program として書いたはうが好い game も有る訣だ。例へば TCG (trading card game) である。

parameter 調整は素早く繰り返し行ふべきだ。skill も parameter である。skill は program だが programmer が skill を書いてゐたのでは開發が停まる。non-programmer が skill を書く樣にするべきだ。これは DSL (domain specific language) の出番である。白狀するとここでも理想的には出來てゐず、相當に後迄調整者が書いてた skill を programmer が review してゐた。この review は後にしなくても囘る樣に成ったから成功したのだと思ふ。

さてこの DSL だが Web server (WebSocket だが) 側である Elixir で實裝する事にした。performance や code の複雜さで苦しむ Web front 側に擔はせるには当時は risk が大き過ぎた。また Elixir には leex / yecc と云ふ DSL 用の library が標準で使へる事を知ってゐた。

言語仕樣は用途の依り異なるだらうが、この樣なものだった。

literal で書ける data 型 :

- lambda : 遲延評價する手續き
- number : 整數と浮動小數点數
- string
- true, false
- tuple : 任意の data 型の任意個數の tuple

函數の返り値として得られる data 型 :

- unit の集合
- player の集合
- その他 Elixir 側で自由に定義される

組み込み演算子。名前が豫約されてゐるだけで、Elixir 側で函數として定義する :

- !
- \+
- \- : 數値演算と集合演算とに override されてある
- \*
- /
- = : 代入ではなく比較演算子。代入演算子は無い
- <
- \>
- <=
- \>=
- | : 論理演算と集合演算とに override されてある
- & : 論理演算と集合演算とに override されてある

その他の literal :

- () : tuple を生成する、或いは評價の優先順位を決める。長さ 1 の tuple は單に値と同一視する
- 函數名 : `A` で函數 A を呼び出す (`A`は Elixir 側で定義する)。`A B`で B を引數として函數 A を呼び出す。特に引數が文字列なら`E"光"`の樣に書ける。tuple の同一視の規則からこれは`A(B)`とも書ける。引數が複數在る場合は`A(B,C)`と tuple を引數に與へる
- 變數名 : `$A`で變數 A の値を得る (正確には`get_var("A")`と云ふ Elixir 側で定義した函數を呼ぶ)。`$A B`で變數 A に B を代入する (これは`set_var("A",B)`)。

他の構文 :

- IF END : else は無い。DSL は if を實行する仕組みを持たず、「if 文の始めが在る」「if 文の終はりが在る」 (入れ子には成れる樣に一意な識別子は持つ) と云ふ情報のみを library に渡す。library が自由に實裝する

函數定義は無い。函數は programmer が Elixir で定義する。

入力された DSL 文字列は Elixir の函數に成り、`:erlang.term_to_binary/2`で file (ETS (Erlang term storage) 形式) に保存される。

```
DSL 文字列
-[leex]-> 字句列
-[yecc]-> AST (abstract syntax tree)
-[dsl.ex]-> Elixir 函數
-[term_to_binary]-> binary
```

Elixir 函數は單に Elixir の`fn -> end`である。Elixir は正格評價だからここに工夫は無い。

compiler は library を持つ。programmer はここに型と函數を定義する。引數の型が異なれば同じ名で函數を複數定義出來る。compiler は引數の型を見てどの函數を呼び出すか決める (compile 時に決まる)。ここで呼び出す函數が見附からなければ compile error に成る。型 error もさうだが、typo も檢出出來る。型は部分型を持てる。函數は引數に對して共變である。generics は實裝しなかった。

DSL には表はれないが Elixir で定義した函數は第一引數に環境を表はす値を受け取る。しかし DSL 側はこの邊りを規定せず library 實裝者 (どちらも我々だが…) が自由に決める。

一部の DSL は VM を持ち、if 文を goto に置き換へ實行した。また特定の函數で實行を一時停止する機能も持った。これらは單に Elixir 上の實裝であり、game logic としての工夫は有るが、言語としての工夫は無い。
