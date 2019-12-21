<!--
{"id":"26006613480817024","title":"Kubernetes を何故採用したのか","categories":["Programming","Kubernetes"],"draft":"no"}
-->

[Kubernetes3 Advent Calendar 2019 - Qiita](https://qiita.com/advent-calendar/2019/kubernetes3) 12/11

昔 Kubernetes を技術撰定した事が有ったのでその時の話をする。以下の slide の時の話だ。

<script async class="speakerdeck-embed" data-id="78d6aaeac6ec425c9f23a169414e5cac" data-ratio="1.77777777777778" src="//speakerdeck.com/assets/embed.js"></script>

[ステートフルで大規模アクセスのある soft-realtime なゲームサーバーを easy につくる](https://speakerdeck.com/ne_sachirou/sutetohurudeda-gui-mo-akusesufalsearusoft-realtimenagemusabawoeasynitukuru)

採用後の具体的な運用の話はしない。流石に昔話に過ぎる。

## 何が嬉しいか?

前提 :

- 代替手段でも充分、と云ふだけでは代替手段を撰ぶ理由には成らない
- 自分の學習 cost は氣にしない。學習せずに濟む手段は私には常に無いので

検討を始めた時には何となく動く Elixir application は既に在り、infrastructure に求められる事も判ってゐた。Elixir application を動かす。多くの WebSocket を安定して繋ぐ。極端に好い network 性能は求めない。application は素早く scala-in/out する。寢てゐても scale-in/out すると嬉しい。幾つかの subsystem が動く。subsystem は増えたり種類が換はったりするかもしれない。よって構成を變へる柔軟性を保ちたい。出來れば server programmer が變更したい。Elixir application を EC2 上に直截置くのではなく container に入れる事で、下の server から抽象化したい。

組織內にこのやうな前例は無かった。世間には在る樣だったが詳細は判らない。そこで技術撰定をしなければならなく成った。

先づ Elixir application を動かす前例は組織內に有った。また新たに開發されつつもあった。しかし多くの常時接續を行ふ例は無く (Elixir 以外では有った)、scale-in/out も遲い。新たに開發されつつあった手法は、動かす application の logic は我々と比較すると單純で構成が安定し、負荷も豫測し易いものだった。また container は考慮されてゐない。

これを採用しても運用出來ただらうが、Kubernetes はより好い撰擇だと思はれた。

先づ Kubernetes には實績が有る。eco-system も揃い rail が敷かれつつあった。組織的にもいずれは採用しなければならない。container を動かす前例は組織內に無かったから自由に撰べる。組織の全体は cloud service を限定してゐなかったので、AWS 以外も使ふ。そこでも使へると know how を共有出來て好ましい。これも rail だ。構成の變更も Kubernetes 上で出來る。

そこで試してみる事にした。

## 作り切れるか?

實際には作り切ってみなければ作り切れるか否かは判定出來ない。常に不測の事が起きるだらうから。それはどの手段を取らうと同じだ。しかし判斷する必要が有る。

世間には Kubernetes で似た system の實績は有るので、理論的に「作れない」事は無い。

運好く team 內に或る程度の規模で Kubernetes を構築し運用した經驗の有る者がゐた。

組織に infrastructure を開發・管理する team が有り、そこの協力は得られた。(その後實際には cluster の構築と、管理の大部分とをやっていただいた。勿論ありがたいが、私の力不足でもあった)

また fallback 先に、組織內で開發されつつあった手法を取れると判ってゐた。cluster を構築し始めか、或いは開發が進み subsystem の構成が決まった後なら fallback 出來る。

そこで作り切れると判斷した。

## 運用出來るか?

これも上と同じく運用してみなければ運用出來るか否かは判定出來ない。運用は續くものだから、ずっと後で「これは出來なかった」事が判るかもしれない (往々にして有り、infrastructure の乘り換へと云ふ形で現れる。いつ現れるか、と云ふのは大きな違ひを生む)。この判斷は、product や世間の變化を見込み過ぎてはいけないが、「一切見込まない」訣にはいかない。

先づ世間には前例が有る。これも上と同じ。これは大きい。「出來た人はゐる」と云ふ安心だけでなく、know how も少しは共有されてゐると云ふ事だから。

後は經驗者に頼るか、實際に触ってみるしかない。cluster 構築中に触ってみて (私が作った cluster は product-ready ではなかったが…)、出來るだらうと判斷した。それから開發中に色々と試して simulation してゐる。負荷試驗も fallback しなければならないかもしれない timing だ。ここでも問題は解決出來た。

## 人を増やせるか? team を作れるか?

組織內に前例が無く、業界にも前例が少ない application であるから、經驗者を呼ぶ事はどの手段を取ってもそもそも望めない。

組織的にも Kubernetes は進めなければならないものだったから、backup は期待出來る。これも rail である。

學習に就いて。そもそも私は力の無い者 (「知識が無い」ではない。知識は學習できる) に力をつけさせるのは無理だと思ってゐるから (力がつく事は有るがそれは豫測出來ない)、筋の好い技術であれば學習 cost は適正に成ると思ふ。技術は行ふものであるから、一般に「充分に」理解すれば好いのであって、「全てを」理解する事は些事であり必要無い <small>(これが探求であれば「全て」が不可能なのは當然として「充分に」と云ふ概念は片面からしか定義されない)</small>。Kubernetes は既知の技術の集まりであり (既知の技術の集まり自體が既知のものに成るとは限らない。それは新しく興味深いものに成り得る)、集め方も筋が好いものに思はれた。rail の考へで云へば、know how や教材も世間に増えると思はれた (實際にその後増えたと思ふ)。

## 他の product に好い影響を與へられるか?

これは組織的にやってゆくべき事を率先してやるので滿たされる。
