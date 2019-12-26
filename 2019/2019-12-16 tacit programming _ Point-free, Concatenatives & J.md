<!--
{"id":"26006613489364887","title":"tacit programming : Point-free, Concatenatives & J","categories":["Programming"," J lang"],"draft":"no"}
-->

tacit programming は point-free style としても知られてゐる。函數適用を使って函數を組み立てるのではなく、函數合成を基本の部品とするやり方だ。見た目上では函數の定義から引數が消える。

tacit programming から連鎖性 programming 言語 (concatenative programming language) と J 言語へ繋がる理路が有る。それを書いた資料がこれだ。

<script async class="speakerdeck-embed" data-id="10881f45e7a941e3a8239824ead0a5b4" data-ratio="1.77777777777778" src="//speakerdeck.com/assets/embed.js"></script>

[tacit programming : Point-free, Concatenatives & J - Speaker Deck](https://speakerdeck.com/ne_sachirou/tacit-programming-point-free-concatenatives-and-j)

先づ Haskell での例を擧げてある。例へば階乘は入門書的には

```haskell
factorial n = n * factorial (n - 1)
factorial 0 = 1

factorial 9
```

とするだらう。ここには `n` と云ふ引數が見えてゐる。`foldr` を使ふとこれは tacit に出來る。

```haskell
factorial = (foldr (*) 1) . (enumFromTo 1)

factorial 9
```

引數が消えた。平均の例も見る。

```haskell
average xs = foldr (+) 0 xs / (fromIntegral . length $ xs)

average [2, 3]
```

これは tacit ではない。`(->)` に關する Applicative を使ふと tacit に出來る。

```haskell
instance Applicative ((->) a) where
   pure = const
   (<*>) f g x = f x (g x)
   liftA2 q f g x = q (f x) (g x)
```

これで、

```haskell
average = ((/) . foldr (+) 0) <*> (fromIntegral . length)

average [2, 3]
```

`(<*>)` の定義を好く見てみると、これは SKI combinatory 論理の S に成ってゐる。ここから combinatory 論理の紹介を資料ではしてある。

さて combinatory 論理を基に發想された programming 言語に、連鎖性 programming 言語と呼ばれる一群の言語が有る。Factor や Popr 等が皆さんの手元でも使へるだらう。

[Factor programming language](https://factorcode.org/)

[HackerFoo/poprc: A Compiler for the Popr Language](https://github.com/HackerFoo/poprc)

Popr で平均はこうする

```popr
average: dup sum swap length /f

[2 3] averge
```

階乘はこうする。Factor ではこう。

```factor
MEMO: factorial ( n -- n! )
  dup 1 > [ [1,b] product ] [ drop 1 ] if ;

9 factorial
```

1 から 9 までの數列を作り綜積をとってゐる。Popr ではこう。

```popr
factorial: [1 == 1 swap !] [dup dup 1 - factorial * swap 1 > !] | pushl head

9 factorial
```

`|` はその前の 2 つに同時に `pushl head` を作用させ、失敗した計算を捨て成功した計算を輯める。`n True !` は成功し `n False !` は失敗する。

`fact` と縮める事にして、`2 fact` は概ね下の樣に評價される。

```popr
2 fact
2 [1 == 1 swap !] [dup dup 1 - fact * swap 1 > !] | pushl head
[2 1 == 1 swap !] [2 dup dup 1 - fact * swap 1 > !] | head
[False 1 swap !] [2 dup dup 1 - fact * swap 1 > !] | head
[1 False !] [2 dup dup 1 - fact * swap 1 > !] | head
[2 dup dup 1 - fact * swap 1 > !] head
[2 2 dup 1 - fact * swap 1 > !] head
[2 2 2 1 - fact * swap 1 > !] head
[2 2 1 fact * swap 1 > !] head
[2 1 fact * 2 1 > !] head
[2 1 fact * True !] head
2 1 fact *
2 1 [1 == 1 swap !] [dup dup 1 - fact * swap 1 > !] | pushl head *
2 [1 1 == 1 swap !] [1 dup dup 1 - fact * swap 1 > !] | head *
2 [True 1 swap !] [1 dup dup 1 - fact * swap 1 > !] | head *
2 [1 True !] [1 dup dup 1 - fact * swap 1 > !] | head *
2 [1] [1 dup dup 1 - fact * swap 1 > !] | head *
2 [1] [1 1 dup 1 - fact * swap 1 > !] | head *
2 [1] [1 1 1 1 - fact * swap 1 > !] | head *
2 [1] [1 1 0 fact * swap 1 > !] | head *
2 [1] [1 0 fact * 1 1 > !] | head *
2 [1] [1 0 fact * False !] | head *
2 [1] head *
2 1 *
2
```

Factor に就いては昔書いた事が有る。

- [関数合成型 ( Forth 系) 言語 Factor への入り口 - c4se 記：さっちゃんですよ ☆](https://c4se.hatenablog.com/entry/2013/12/26/044415)
- [Factor で階乗。然して再帰に就いて抄 - c4se 記：さっちゃんですよ ☆](https://c4se.hatenablog.com/entry/2013/12/30/030205)

Unix の pipe & filter も仲間だ。Unix pipe & filter は一次元だが、連鎖性 programming 言語はこれを多次元化してゐる事に成る。

同じく combinatory 論理を基にしたが J 言語は連鎖性 programming 言語とは異なる拡張の仕方を行った。

[Jsoftware](https://www.jsoftware.com/)

足し算の例。

```j
  2+3
5
```

これでは tacit ではない。insert と云ふ adverb (副詞) を使ふと tacit に出來る。adverb は凡そ高階函數であり、insert は fold に當たる。

```j
  +/2 3
5
```

平均はこうする。

```
  average:=(+/%#)

  average 2 3
2.5
```

連鎖性言語では combinatory 論理の規則は函數として見えてゐる。J 言語では combinatory 論理の規則は函數として見えてゐるものも有るが、多くは函數合成の規則に閉じ込められた。今囘登場する規則は二つだ。

- monadic fork : [tex: (fgh)x=(fx)g(hx)]
- monadic hook : [tex: (fg)x=xf(gx)]

"monadic" は「單項の」である。"dyadic" 「二項の」も J 言語では言ふ。

平均の評價を辿る。

```j
(+/ % #) 2 3
(+/ 2 3) % (# 2 3)  NB. monadic fork
5 % 2
2.5
```

`NB.` は comment の始まりを示す。階乘の例。先づ J 言語には階乘を計算する函數が有る。

```j
  !9
362880
```

數列を作って疊み込む例。

```j
  */1+i.9
362880
```

評價手順を示す。

```j
*/ 1 + i. 9
*/ 1 + 0 1 2 3 4 5 6 7 8  NB. `i.` creates a vector
*/ 1 2 3 4 5 6 7 8 9  NB. vector operation
1 * 2 * 3 * 4 * 5 * 6 * 7 * 8 * 9  NB. folds `*`
362880
```

再歸を使ふ例。

```j
  factorial =: 1: ` (* factorial@<:) @. *

  factorial 9
362880
```

`factorial 2` の評價手順を示す。

```j
factorial 2
1: ` (* factorial@<:) @. * 2
(* factorial@<:) 2  NB. `@.` selects the second
2 * (factorial@<: 2)  NB. monadic hook
2 * (factorial 1)
2 * (1 * (factorial 0))  NB. same as `factorial 2`
2 * (1 * (1: ` (* factorial@<:) @. * 0))
2 * (1 * (1: 0))  NB. `@.` selects the first
2 * (1 * 1)
2 * 1
2
```
