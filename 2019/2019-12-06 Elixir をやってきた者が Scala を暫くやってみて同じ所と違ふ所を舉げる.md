<!--
{"id":"26006613476889014","title":"Elixir をやってきた者が Scala を暫くやってみて同じ所と違ふ所を舉げる","categories":["Programming","Elixir","Scala"],"draft":"no"}
-->

[はてなエンジニア Advent Calendar 2019 - Qiita](https://qiita.com/advent-calendar/2019/hatena) 12/6

12/5 は[AWS コストエクスプローラー API と気軽につきあう(2019) - Qiita](https://qiita.com/ma2saka/items/a59e03c53305e52b5477)であった。

今暫くは都合で Scala を書いてゐる。數年 Elixir をやってきた身だから、簡單に比較してみやう。

## 同じ所

### 函數型言語である

Elixir も Scala も、函數を組み合はせる事で program を作る言語だ。

### 不變 data

Lisp のやうに、函數型言語だからと言って data が不變とは限らない。しかし Elixir も Scala (var 付きの class や Java の class を使はなければ) も data は書き換へられない。どちらでも (Scala では var を使ふ) 再代入は出來る。またどちらも Haskell の樣に副作用を局所化したりはしないから、大域的な狀態には注意する。

### actor model に依る parallelism

actor と呼ぶ (Elixir では單に process と呼ぶ) 互ひに獨立な process を協調させて parallel に計算を行ふ。一つの actor 內部は single thread で、異なる actor は、異なる CPU core や network で繋がった異なる計算機にて動ける。actor 間で message をやり取りし協調する。

Elixir は Erlang VM (BEAM)で動作し、VM が actor model を support する。Scala が動く JVM は直接には actor model を support しないが、Scala の言語機能に Actor が有り、また Akka と云ふ Scala で広く使はれる library で actor model を使へる。Akka は Erlang OTP を參考に作ってあって同樣の機能が有る。別 process で處理を行ふだけの簡單な用途では Elixir には Task と云ふ module が有るが、Scala にも Future, Promise と云ふ同等の仕組みが有る。

actor は狀態を持つから、data が書き換はるやうに見える事には注意する。實際のところ手元に有る data は actor 名であってこれは書き換へられない。

actor model を始めから support する最近の言語には他に Pony が在る。

### 既存の資產

Elixir は Erlang の module を使へ、Scala は Java の class を使へる。どちらも OTP や JRE と云ふ大きな標準 library を持つ。Erlang も Java も長い歴史を持ち多くの library が公開されてゐる。

### Web browser でも動作する

Elixir には ElixirScript が、Scala には Scala.js が在り、JavaScript へ transpile 出來る。また Elixir は Lumen で、Scala は Scala Native にて WebAssembly にする事が出來る。

他の實裝 Erlang VM / Elixir :

- [Elixirscript](https://elixirscript.github.io/)
- [lumen/lumen: An alternative BEAM implementation, designed for WebAssembly](https://github.com/lumen/lumen)
- [bettio/AtomVM: Tiny Erlang VM](https://github.com/bettio/AtomVM)

他の實裝 JVM / Scala :

- [List of Java virtual machines - Wikipedia](https://en.wikipedia.org/wiki/List_of_Java_virtual_machines)
- [Scala.js](https://www.scala-js.org/)
- [Scala Native — Scala Native 0.3.9 documentation](https://scala-native.readthedocs.io/)

## 異なる所

### 型の扱ひ

最も異なるのは型であらう。Elixir は compile 時に型檢査をしないが、Dialyzer と云ふ仕組みが有って靜的型檢査が出來る。しかし Dialyzer の型 system (success typing) は表現力が低く、動作も遲い。更には曖昧な Erlang / Elixir の code に合はせきれないところがあり、無視設定を書く事に成る (型 system の表現力が低いので Dialyzer を通る程 program を複雜化させる insantive の無い場合が有る)。

Scala の型 system は表現力が高い。generics も部分型も trait も有り、Elixir の樣に struct が型 system 上では全部 map に他ならないと云ふ事も無いので、代數的 data 型も役に立つ。

型推論も常識的 (Hindley-Milner 型推論を體驗した事が有れば常識的。Scala の型推論は H-M より弱いが) に行なはれるので頼りに成る。

success typing に關しては <q>Tobias Lindahl, Konstantinos Sagonas (2006) "Practical Type Inference Based on Success Typings"</q> を。

### OOP

Scala には Java 由來の OOP が有る。これは Java の class を呼ぶのに要るし、process 間の context switch 無く heap 外に出る事も無く狀態を持てるので使ふ事が在る。最近の OTP 22 で persistent_term が來る迄 Erlang には速い狀態 store が無かったから、函數型 style で全てを引數と返り値に含ませてゐた。この顛末は [DDD: Data Driven Development](https://speakerdeck.com/ne_sachirou/ddd-data-driven-development) に在る。

<script async class="speakerdeck-embed" data-id="ac7e5f6e7fe14c3a862a4b567fad532a" data-ratio="1.77777777777778" src="//speakerdeck.com/assets/embed.js"></script>

### VM level での parallelism

Elixir の parallelism は本質的で、parallel にせず application を作る事が出來ない。全ての application は Application と云ふ種類の actor の集まりであり、Application に Supervisor や GenServer 等と云ふ actor 群をぶら下げる事から開發は始まる。

Scala に於いて actor system の利用は optional である。Elixir では OTP に依り actor を組織化するやり方が強制されてゐるが、Scala / Akka ではさうではないから必ずしも使ひよく組織化されてゐるとは限らない。

その逆に Scala では parallelism を actor model 以外に實現する事が出來る。Java の synchronize や java.util.concurrent class を使っても好いし、ScalaSTM も在る。

### VM level での分散環境

Erlang VM は複數の VM を協調させられる。Akka でも出來るが、VM level で support されてゐるといつでもその手段を取れるので少し嬉しい。Elixir で、動作中の application に REPL を繋げられるのはこの仕組のおかげだ。

### fault tolerant

Elixir の actor は障礙の單位であり、VM の SEGV や VM 全體での leak 以外の障礙を actor に閉じ込められる。resource の制限も出來るし、error からの回復も出來る。Scala の actor はさうではない。但し Akka を使へば error への對處は出來るやうに成る。

### 非線形な pattern match

Erlang / Elixir の pattern match は非線形で、

```elixir
{x, x} = {1, 1}
```

が出來る。pattern 內に同じ名を複數囘登場させられる。一方で正規形を持たない data の pattern match は出來ない。これは Scala では unapply を書く事で對應出來る。

### implicit

型 class は便利だ。

implicit には多くの應用が在る。例へば DI (Dependency Injection) の一部を實現する事も出來るが、これには trait や Guice 等別の方法を使ったはうが好い。

### GPU, SIMD

Elixir からは GPU や SIMD 等 actor model 以外の parallelism を扱へない (C で書いて C node として繋ぐ、別の application として Elixir 以外で書いて RPC する等は出來る)。VM level で actor model が強制されてゐるから難しく、努力は成されてゐるものの未だ實現してゐない。Scala にはこの障礙は無い。

12/7 は id:hokkai7go だ。
