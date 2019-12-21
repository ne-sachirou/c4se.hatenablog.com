<!--
{"id":"26006613480752582","title":"Elixir の application を Mackerel で監視する","categories":["Programming","Elixir","Mackerel"],"draft":"no"}
-->

[Mackerel Advent Calendar 2019 - Qiita](https://qiita.com/advent-calendar/2019/mackerel) 12/11

以前に[Kubernetes 上で動く Elixir アプリを監視する](https://c4se.hatenablog.com/entry/2019/09/10/204428)を書いた。これが完成した。

確かに Erlang/Elixir の system は落ちない。programmer が落ちないやうに書けば落ちなく出來るからだ。基本的な道具は BEAM VM (Erlang VM) と Supervisor の木である。

勿論落ちる事は在る。tuple の入れ子が深過ぎて SEGV したり、memory を使ひ過ぎて OOM Killer に落とされたりだ。memory の使ひ過ぎは、ETS からの data copy <small>(通常の代入や message passing と違ひ、同じ data でも毎囘 copy される)</small>、`:erlang.binary_to_term/2` <small>(理由は ETS のに近い)</small>、atom の増大、process の増大、大きな binary の GC の遲れ、message queue の溢れ <small>(back-pressure の仕組みを作らなければならない。back-pressure により處理速度が激減する事も有るので注意する。或いは process 自身が message queue の長さを監視して自殺する)</small> 等に依り起こる。これらの問題は process 內に閉じ込められたり runtime で解決出來るものも有れば、成す術も無くただ設計や logic を直すものも有る。

また落ちない事は所詮落ちないだけに過ぎない。處理速度が一時的/恒常的に下がったり、長期的な leak は知らなければならない。

詰まり BEAM VM の狀態を知っておく事が要る。私は偶々 KomachiHeartbeat と云ふ、Elixir application の狀態を知る爲の library を作ってゐたから、これに VM の狀態を見る機能を追加した。v0.5.0 以降で使へる。この library で BEAM VM の狀態を見る事が出來る。

[komachi_heartbeat | Hex](https://hex.pm/packages/komachi_heartbeat)

今囘は更に、その狀態を Mackerel に送る。先づは動いてゐる樣子を。

[f:id:Kureduki_Maari:20191212000244p:plain:alt=Elixir の application を Mackerel で監視する]

見られる情報は (それぞれが何であるかは Erlang の公式 document を參照のこと)、

- context_switches
- port_count
- process_count
- reductions
- run_queue
- gc
  - count
  - words_reclaimed
- io
  - in
  - out
- memory
  - atom
  - binary
  - code
  - ets
  - processes
- scheduler_usage
  - 各 scheduler 毎

これは普段見るものに絞った。

KomachiHeartbeat とは Elixir application に healthcheck 用 endpoint を追加する library だ。healthcheck は樣々に要る場面が在る。ELB ALB の healthcheck や、Kubernetes であれば readyness probe, liveness probe が要る。そこで統一された healthcheck 確認方法が有れば便利だ。(何を healthy であるとするかと云ふ話題は他へ譲る。)これには`GET 〜/heartbeat`と云ふ path を提供する。

更に KomachiHeartbeat は、system の狀態を JSON で返す endpoint も追加する。これには`GET 〜/stats`と云ふ path を提供する。

[https://github.com/ne-sachirou/ex_komachi_heartbeat:embed:cite]

先づ HTTP server が要る。HTTP で應答する application であればそこに追加するし、さうでなくても cowboy を Application にぶら下げれば好い。process を簡單に増やせるのは Erlang/Elixir の好い所だ。今囘は plug_cowboy を追加する。`mix.exs`に、

```elixir
defp deps do
  [
    # …
    {:cowboy, "~> 2.7"},
    {:jason, "~> 1.1"},
    {:komachi_heartbeat, "~> 0.5"},
    {:plug, "~> 1.8"},
    {:plug_cowboy, "~> 2.1"}
  ]
end
```

を加える。Application (大抵は`application.exs`) に、

```elixir
def start(_type, _args) do
  # …
  children = [
    # …
    {Plug.Cowboy, scheme: :http, plug: Example.Router, options: [port: 4000]}
  ]
  # …
  Supervisor.start_link(children, opts)
end
```

を加え plug_cowboy を起動する。port は 4000 番にしたが他でも好い。router を、

```elixir
defmodule Example.Router do
  use Plug.Router
  plug(:match)
  plug(:dispatch)
  forward("/ops", to: KomachiHeartbeat, init_opts: [vitals: [KomachiHeartbeat.BeamVital]])
  match(_, do: send_resp(conn, 404, "Not Found"))
end
```

等とし、`/ops/〜`に KomachiHeartbeat を mount する。この時`KomachiHeartbeat.BeamVital`を設定すると BEAM VM の情報を取れる。`GET http://〜/ops/stats`が endpoint だ。

次に mackerel-agent を設定する。私は Kubernetes で動かしてゐるから mackerel-container-agent を。

mackerel-plugin-json は JSON で吐かれたメトリックを Mackerel のカスタムメトリックとして投稿する、mackerel-agent の plugin だ。

[https://github.com/mackerelio/mackerel-plugin-json:embed:cite]

先づ plugin を呼ぶので簡便に`mackerel/mackerel-container-agent:plugins` image を使ふ。agent 用の設定は以下に成る。

```yaml
---
readinessProbe:
  http:
    path: /ops/heartbeat
    port: 4000
plugin:
  metrics:
    json:
      command: |
        mackerel-plugin-json \
          -url="http://localhost:4000/ops/stats" \
          -prefix='beam'
```

この設定を ConfigMap に置いて agent に読ませれば好い。そこで volumeMounts する。

```yaml
---
apiVersion: apps/v1
kind: Deployment
# …
spec:
  # …
  template:
    spec:
      # …
      volumes:
        - name: mackerel-agent-config
          configMap:
            name: mackerel-agent-config
      containers:
        - name: # …
          image: # …
          # …
          ports:
            - containerPort: 4000
              protocol: TCP
          readinessProbe:
            httpGet:
              path: /ops/heartbeat
              port: 4000
        - name: mackerel-container-agent
          image: mackerel/mackerel-container-agent:plugins
          imagePullPolicy: Always
          resources:
            limits:
              memory: 128Mi
          env:
            - name: MACKEREL_AGENT_CONFIG
              value: /etc/mackerel/mackerel.yaml
            - name: MACKEREL_CONTAINER_PLATFORM
              value: kubernetes
            - name: MACKEREL_KUBERNETES_KUBELET_HOST
              valueFrom:
                fieldRef:
                  fieldPath: status.hostIP
            - name: MACKEREL_KUBERNETES_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
            - name: MACKEREL_KUBERNETES_POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: MACKEREL_ROLES
              value: # …
          envFrom:
            - secretRef:
                name: # …
          volumeMounts:
            - name: mackerel-agent-config
              mountPath: /etc/mackerel
              readOnly: true
```

`MACKEREL_APIKEY`は Secret から讀ませてゐる。ConfigMap は、

```yaml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: mackerel-agent-config
data:
  mackerel.yaml: |
    ---
    readinessProbe:
      http:
        path: /ops/heartbeat
        port: 4000
    plugin:
      metrics:
        json:
          command: |
            mackerel-plugin-json \
              -url="http://localhost:4000/ops/stats" \
              -prefix='beam'
```

で好い。私は`kustomize build … | kubectl apply … -f - --prune`で deploy してゐるがこれは都合次第だ。
