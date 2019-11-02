去る九月七日に[ElixirConfJP 2019 小倉城](https://fukuokaex.connpass.com/event/138846/)が開かれ、公募 (審査無し) で五分間喋った。

過去 K8s 上で Elixir の Phoenix.Channel を運用してゐて、今は個人で、K8s 上で Elixir の bot とかを運用してゐる。運用するのに監視は必要なものであり、樂に充分な監視をするのに KomachiHeartbeat + mackerel-container-agent が好いのではないかと云ふ考へを喋った。

<script async class="speakerdeck-embed" data-id="d8e020d58cd34c819e530f0b0ca22361" data-ratio="1.77777777777778" src="//speakerdeck.com/assets/embed.js"></script>

[Monitoring Containerized Elixir
](https://speakerdeck.com/ne_sachirou/monitoring-containerized-elixir)

deadtrickster/beam-dashboards を Prometheus + Grafana で使ってゐた事も在ったが、Prometheus の運用自體が自明ではない。Prometheus はまた運用してみやうと思ふが、Mackerel だけで取り敢へず充分な狀態を作ってしまへる。

[ne-sachirou/ex_komachi_heartbeat](https://github.com/ne-sachirou/ex_komachi_heartbeat) は私が作ってゐる Elixir の library で、名前は同名の Rubygems からとった。Rubygems のを作ったのは知り合ひで、同じ組織が同じ目的に使ふ爲に作ったのでそう成った。HTTP 接續を受け入れるか否かの死活監視が出來るのと、plugin を書けば繋がってゐる DB 等との接續監視や統計情報が見られる。K8s の readiness probe と組み合はせて、DB と接續したり Application の起動處理が終はる迄 `/ops/heartbeat` で OK を返さず load balancer に加へるのを待たせる事をしてゐた。今回喋った `KomachiHeartbeat.BeamVital` は恥ずかしながら開發中で pull request の狀態に在る。情報蒐集法が面倒なので、書き直すつもりだ。
