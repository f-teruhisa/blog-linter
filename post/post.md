みなさんこんにちは、フィッツプラス エンジニアの福本です。 早いもので入社して半年が経過し、普段はRailsを中心に色々と書いてます。
リモートワークが長く続いていることもあって、最近は自宅開発環境の(過剰な)整備にハマっています。先日はlogicoolのPCスピーカーを買いました。所得がゴリゴリ削られていきツラい。
さて今回は、これまで~~忙しくて~~紹介する機会のなかったフィッツプラス事業のサービスの概要やアーキテクチャ、使用技術についてお話していきます。アーキテクチャに悩むエンジニアの方の参考に、あるいは皆様のフィッツプラスへの事業理解が深まれば幸いです。
# 特定保健指導事業とは？
技術の話に入る前に、タイトルにもある”特定保健指導”という事業ドメイン	について簡単にご説明します。この”特定保健指導”という単語に、すぐにピンと来るエンジニアの方はさほど多くないと思います。
というのも、40歳以上の労働者の方が対象となるためです。私も例に漏れずピチピチの若エンジニアですので、あまりよく知りませんでした。厚生労働省から義務化されてたりするので、今は若い方もその内お世話になることでしょう。
さて、特定保健指導とは、特定健康診査で対象となった（要するに引っかかった）方の生活習慣病の予防および改善を目的に行われる、面接などの支援活動のことを指します。”管理栄養士”という国家資格を持った方により、計画に基づいた食生活改善のアドバイスやサポートが行われます。
フィッツプラスはその”特定保健指導”を行うためのWebサービスと、一般の方に食事のアドバイスを行うアプリを運営しており、「食」から健康をサポートしています。
メドピアグループはヘルステック企業として、幅広い医療領域を技術でサポートしています。中でも「予防領域」は、高齢化社会により高騰した医療費の削減などの社会的背景から重要視されていますが、フィッツプラスは”食”の観点からこの予防医療をケアする事業にあたります。
# アーキテクチャ
[image:B88ACE8C-988D-479E-9A9B-6EB4E27EF8AB-19372-000043E24DCCEDE9/FitsPlus Architecture-Page-1.png]
さて、この章から具体的な技術の話をしていきます。
上記の図は、先ほどご説明したフィッツプラス事業のサービスの中核となるRailsアプリケーション(`dietplus-server`)と、その周辺を取り巻くアプリケーションやサービスとの関係を図にしたためたものです。
「周辺を取り巻く」という表現に引っかかった方が居るかと思いますが、この図には記載されていないWebのアプリケーションが多数（５つほど）稼働しています。
モダンなプロジェクトで言うと、Vue.js + Nuxt.js + Rails 6によるSPA構成のサービスを絶賛開発してたりします。完成した暁には、そちらをメインで担当しているエンジニアがテックブログの記事を書いてくれると思いますので、首を長くして待っていてください~~（キラーパス）~~。
上記の図をすべて解説するだけでも薄い本が1冊書けてしまいそうなので、中心となるRails(`dietplus-server`)と上部オレンジ色の領域にあるiOSアプリケーション(`DietPlus`)のふたつに、ある程度的を絞って今回はお話します。
## モノリシック Rails
中核となるRailsアプリケーションですが、先ほどの図だけでは詳細が分かりづらいので、今回お話したいAPIと管理画面に関わるライブラリを記載した図を別途作ってみました。特徴的な部分について説明していきます。
[image:0D63A16C-FFF1-4178-AB69-9F0124C8B875-19372-000043F2F5AFBB23/FitsPlus Architecture-Copy of Page-1 (1).png]
また、2020年6月1日時点、`develop`ブランチに対して、`rails status` をしてみたところ以下のような結果となりました。Railsのサイズ感が伝われば幸いです。
```                                                                            
+----------------------+--------+--------+---------+---------+-----+-------+
| Name                 |  Lines |    LOC | Classes | Methods | M/C | LOC/M |
+----------------------+--------+--------+---------+---------+-----+-------+
| Controllers          |  11144 |   9420 |     223 |     840 |   3 |     9 |
| Helpers              |    212 |    175 |       0 |      27 |   0 |     4 |
| Jobs                 |    447 |    364 |      14 |      18 |   1 |    18 |
| Models               |  13809 |   8639 |     167 |     799 |   4 |     8 |
| Mailers              |    586 |    502 |      26 |      66 |   2 |     5 |
| Channels             |      8 |      8 |       2 |       0 |   0 |     0 |
| JavaScripts          |     67 |     21 |       0 |       4 |   0 |     3 |
| Libraries            |   1019 |    909 |       7 |       9 |   1 |    99 |
| Mailer specs         |      8 |      6 |       1 |       0 |   0 |     0 |
| Decorator specs      |     67 |     60 |       0 |       0 |   0 |     0 |
| Loyalty specs        |    205 |    147 |       0 |       0 |   0 |     0 |
| Model specs          |   6153 |   5438 |       0 |       0 |   0 |     0 |
| Request specs        |  10968 |   9586 |       0 |       0 |   0 |     0 |
| System specs         |   6937 |   5931 |       0 |       0 |   0 |     0 |
| Lib specs            |    659 |    560 |       0 |       0 |   0 |     0 |
| Job specs            |    154 |    123 |       0 |       0 |   0 |     0 |
+----------------------+--------+--------+---------+---------+-----+-------+
| Total                |  52443 |  41889 |     440 |    1763 |   4 |    21 |
+----------------------+--------+--------+---------+---------+-----+-------+
  Code LOC: 20038     Test LOC: 21851     Code to Test Ratio: 1:1.1
```
### ActiveModelSerializers
APIでJSONを返すオブジェクトの作成は、`ActiveModelSerializers`で行っています。いちいちviewファイルを作ってレンダリングさせる必要がなく、関連オブジェクトの指定もRailsっぽく書けます。メドピアでは過去に他のチームでも採用情報があり、かつ一般的にもよく使われるgemなので特に違和感なく使っています。
[ActiveModelSerializersを使った所感 - メドピア開発者ブログ](https://tech.medpeer.co.jp/entry/2018/04/25/080000)
一方で最近気づいた懸念点として、かなりRubyライクな記法なために、アプリエンジニアがAPIを返すコードを読んだ際に「どんなJSONを返すか全くわからない」ことです。サーバサイド中心に書いている側からは気づかない点で、アプリエンジニアの方に言われはじめて気づきました。
大きなチームで開発していると、アプリとサーバサイドのエンジニア間での隔たりが生まれたりするかもしれませんね。そういった点では、JSONっぽく定義可能な`jbuilder`の採用も一考の余地があるとではないかと感じました。
https://github.com/rails-api/active_model_serializers
### Open API
各APIの定義は、Open API記法でSwagger関連のDocker imageを使い管理しています。
特徴としては、当初の図の通りAPIのレスポンスを返す先のアプリケーションが2つ（上部のオレンジの領域と右の緑の領域）ある点です。幸いにも２つのAPIは互いに独立しているので、各レスポンス先ごとに `spec.yml` の参照パスを分けた `docker-compose` コマンドを作って運用しています。
```
# Makefile
## Swagger-ui
### DietPlus
vitamin/api/docs:
	docker run --rm -p 8591:8080 -v $(CURDIR)/${VITAMIN_API_SPEC_PATH}:/usr/share/nginx/html/spec.yml -e API_URL=spec.yml swaggerapi/swagger-ui
### DietPlus Pro
dietplus/api/docs:
	docker run --rm -p 8591:8080 -v $(CURDIR)/${DIETPLUS_API_SPEC_PATH}:/usr/share/nginx/html/spec.yml -e API_URL=spec.yml swaggerapi/swagger-ui
```
Open APIについては、私が後入れでSwaggerを導入したためモック環境など一部整っていない部分がありますが、引き続き徐々に環境整備を進めていきたいなという気持ちです。気持ちはあります。
### Houston(プッシュ通知)
RailsからiOSアプリに対してのプッシュ通知（いわゆる`APNs`）は、`houston`というgemを`ActiveJob`と併用して行っています。`Houston::Notification`をインスタンス化すれば、バッヂや音声をプロパティで簡単に設定できます。
https://github.com/nomad/houston
問題としては、執筆時点でmasterブランチがiOSのバージョン13のプッシュ通知に対応していない点です。詳細は以下のissueに記載されていますが、[Apple Developersが要求するheaderの情報](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/sending_notification_requests_to_apns)をgemで設定できないためです。
[iOS 13 requires new headers to the APNS · Issue #170 · nomad/houston · GitHub](https://github.com/nomad/houston/issues/170)
幸いにもこの問題に対応するPRが上げられているので、現在はGemfileのgitオプションを使用し該当するcommitを取り込む形で対処しています。実際には、以下のように記述しています。
```rb
# ios push notification
# TODO: マージされたら git オプション外す
gem 'houston', git: 'https://github.com/ab320012/houston', ref: 'efbeb6c'
```
上記の対応には若干懸念が残っていて、オプションでcommit hashを直接指定している関係上、ハッシュ値が変わってしまった場合に`bundle install`できなくなります。幸い(?)メンテナンスが活発でないのでリスクは低いですが、`rebase`とか`force push`などが行われるとハッシュ値が変わる危険性があるみたいです。
調査したところ、リポジトリをforkして`protect branch`しておけばケアできるようですが、メンテナンスされないgemを使い続けるのはよくないため、長期的にはOne Signalへの移行を検討しています。
[#1 Push Service | Send Mobile & Web Push Notifications - OneSignal](https://onesignal.com/)
### Sorcery & Banken(認証/認可)
管理画面にログインするユーザーの管理手法としては、Sorceryでユーザーの認証を行い、Bankenで権限を管理しています。
前提として、管理画面ではアプリごとに違う画面を切り替えて操作するようになっており、（当然ですが）他のアプリの管理栄養士さんや管理者がユーザーの個人情報を見ることができないようになっています。また、同じアプリの画面内でも、センシティブな情報が含まれるもの(例: ユーザーとのチャットのやり取り画面)があったりするため、画面ごとに細かく権限を制御する必要があります(詳細は後述）。
Railsで権限管理を行う方法はいくつかありますが、フィッツプラスではBankenを使っています。アプリごとのnamespace(実際にはmodule)が複数存在し、画面ごとに権限を定義するひつようがあるため、Controllerベースに権限を付与していくBankenは違和感なく使えています。RSpecでテストコードを書く際も、Request Spec内で権限ごとにparameterizedで条件を分ければ、かなりDRYなテストが書けます。
また、ユーザーのログイン機構はSorceryを用いています。deviseとの比較は他で散々されているのでここでは割愛しますが、「コードを書く量が多いため、自分たちで保守・拡張しやすい」という点はメリットが多いように感じます。具体的には、管理画面もアプリのユーザーも同じ認証機構をそのまま使い回すことができたり、一部の画面ではPINコードを用いた認証を特別に実装したり、といったあたりでしょうか。
## VIPER  Swift
[image:3E11A611-1F79-4175-832E-3439F826E639-19372-000043EDC1CEAE06/FitsPlus Architecture-Copy of Copy of Page-1.png]
ここからは、クライアントサイドであるSwiftコードの設計と使用するライブラリについてお話できればと思います。
今回スポットを当てるアプリ『DietPlus』ですが、食事の写真を投稿すると管理栄養士の方が食事の内容をアドバイスしてくれるサービスです。2019年10月にiOSアプリをリリースし、その後いくつかの機能追加や改善を行いました。

こちらもコードのサイズ感をお伝えすると、2020年5月時点での`cloc` の実行結果は以下のとおりです。
```
$ cloc --include-lang=Swift,Objective\ C --exclude-dir=Pods,Carthage ./
    6401 text files.
    6269 unique files.
    5721 files ignored.

github.com/AlDanial/cloc v 1.86  T=4.17 s (168.1 files/s, 13199.7 lines/s)
-------------------------------------------------------------------------------
Language                     files          blank        comment           code
-------------------------------------------------------------------------------
Swift                          697           9707          11423          33492
Objective C                      5             86             37            363
-------------------------------------------------------------------------------
SUM:                           702           9793          11460          33855
-------------------------------------------------------------------------------
```
DietPlusのSwiftコードにおける特徴は、ピュアなVIPERアーキテクチャで構築されている点でしょう。VIPERについて詳細に書くと分厚い本が数冊書けてしまうので割愛しますが、いわゆるClean Architectureの一種です。
Rubyエンジニア的に言うと、フレームワークの『Hanami』に近いイメージがあります。HanamiのActionごとにクラスを切って１画面≒１クラスになる点や、VIewsファイルとTemplateファイルが独立している点が、VIPERのViewやPresenterの仕組みと似通っていると感じました。
（実際、HanamiはClean Architectureに影響を受けているそうです）
### Entityがキモ
さて、VIPERにおいて最も設計が難しい点のひとつ（諸説あり）は、Entityに何を置くかでしょう。Clean ArchitectureではEntityを「アプリケーションに依存しないドメインおよびビジネスロジック（を示すデータの構造やメソッドの集合）」だとされています。
[クリーンアーキテクチャ(The Clean Architecture翻訳) | blog.tai2.net](https://blog.tai2.net/the_clean_architecture.html)
このEntityをインターフェースやDBから完全に切り離し、依存の方向を一方向にすることで（図を参照）、UIなどの変更が多い部分を変更しやすく、そうでない部分に影響を与えないようにします。この設計をいかに維持できるかで、アプリケーションの変更を容易にできるかが決まります。
### DietPlusにおけるEntity
DietPlusにおけるEntityですが、結論から言うと「ユーザーの食事」と「食事の日付」に関わる部分が最も中心のドメインロジックとなっています。
人間の食事習慣や日付といった概念は普遍的なものですが、その食事や日付に対して「どうコメントを返信するか」「どういう」は、サービスを提供する私たち側の問題です。これをしっかり分けて考えることで、変更の多い部分をできる限りInteractorやPresenterに切り出せています。
具体的にはこんな感じのコードが、ユーザーの食事投稿を表示するPresenterに書かれていて、Entityとなる食事（Meals）をUIで表現するデータに変換したりしています。
```swift
// MARK: - MealRecordPresenterProtocol
final class MealRecordPresenter: MealRecordPresenterProtocol {

		struct Constant {
        // 反映可能食事枚数の上限
        static let maxMealPhotoCount: Int = 4
    }

    
    struct InitialState {
        var date = Date(second: nil)
        var memo = ""
        var selectedCategory: MealCategory = .breakfast
        var selectedStyle: MealStyle = .home
        var tags: [MealTag] = []
    }
    
    // 取得可能枚数の上限
    private var maxAddableCount: Int {
        return Constant.maxMealPhotoCount - photos.count + deletePhotos.count - addedImages.count
    }
    private(set) var date = Date(second: nil)
    private(set) var photos = [Photo]()
    private(set) var deletePhotos = [Photo]()
    private(set) var addedImages = [UIImage]()
    var memo: String = ""
    var mealTags = [MealTag]()
    var selecetedCategory: MealCategory = .breakfast
    var selectedStyle: MealStyle = .home
    
    private(set) var mealDetail: MealDetail? // Editの場合に取得
    private(set) var initialState: InitialState?
    private var completionHandler: (() -> Void)?
    
    weak var view: MealRecordViewProtocol!
    var interactor: MealRecordInteractorProtocol!
    var router: MealRecordRouterProtocol!
    
    init(completionHandler: (() -> Void)?) {
        self.completionHandler = completionHandler
    }

    /// 時刻から食事のカテゴリ（朝食など）を決定
    /// 朝食 04:00〜10:59, 昼食 11:00〜15:59, 夕食 16:00〜03:59, 間食 それ以外
    func caluculateCategory(from date: Date) -> MealCategory {
        let hour = date.hour
        switch hour {
        case 4..<11: return .breakfast
        case 11..<16: return .lunch
        case 16..<24: return .dinner
        case 0..<4: return .dinner
        default: return .snack // 0 ~ 24までしかないためここには入らない
        }
    }
}
```

一方、食事を表すEntityであるMeal.swiftはかなりシンプルに書かれています。ここにすべては記載できませんが、ファイル内のコードはExtensionを含めて66行しかありませんでした。主要Entityとしてはかなり薄い部類だと思います。
```swift
struct Meal: Codable {
    
    let id: ID
    let time: Date
    let category: MealCategory
    let style: MealStyle
    var content: String?
    var memo: String?
    let createdAt: Date
    let updatedAt: Date
    var photos: [Photo]
    var mealTags: [MealTag]
    
    struct ID: Identifiable {
        let rawValue: Int
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case time
        case category = "categoryCode"
        case style = "styleCode"
        case content
        case memo
        case createdAt
        case updatedAt
        case photos
        case mealTags
    }
 
}
```

### 工夫
VIPERやClean Architectureは、何でも解決できる魔法の杖ではありません。課題のあるところはいくつか工夫して対応しています。
#### ファイルやコードの自動生成
まず、Clean Architectureでは”ファイル数が多くなりがち”という点が上げられるでしょう。責務を分割すれば、ひとつのファイル（あるいはレイヤー）あたりのコード数が少なくなるので、その裏返しと考えれば当然です。
ひとつの画面を作るためには、VIPERの頭文字（E除く）とstoryboard1つ（不要な場合もある）の合計5つのファイルを作成する必要があります。RailsならViewファイルを作成して、Controllerとrouteファイルに追記するくらい（ざっくり）なので、比べるとやはり多いですね。
これについては、Generambaというコードとファイルの自動生成gemを用ることで工数削減を行っています。アプリ開発のライブラリにRuby製のgemが使われていると、Rubyistとしては少し嬉しい気持ちになります。
https://github.com/strongself/Generamba
工数の削減以外にも、Module構成やクラス記述などを統一できるメリットもあります。
自動生成ツールとしては、他にもSwiftGenでリソースと型の作成を行ったりしています。
[GitHub - SwiftGen/SwiftGen: The Swift code generator for your assets, storyboards, Localizable.strings, … — Get rid of all String-based APIs!](https://github.com/SwiftGen/SwiftGen)
#### Embedded Frameworkによるマルチモジュール構成
VIPERの章で述べたレイヤーの分割や依存関係の構造を守るために、UIコンポーネントや拡張メソッドを別のモジュールに切り出して管理しています。具体的には、以下の3つにモジュールが分かれています。
```
# DietPlus(App)
	- アプリ本体のコード
	- 画面に関するModule（View, Interactor, Presenter, Router）
	- Entityおよびサービスクラス（API、Database, Keychain, UserDefaultsなど）
# UIComponent
	- 各種UIパーツの格納
	- Color Asset, Image Assetも基本的にはこっちで管理
	- UITableViewCell, UICollectionViewCellといったCellクラスもUIComponentに追加
	- アプリ本体のモジュールはImportしない（依存は一方向のみ）
# Common
	- Extensionメソッド(UIは除く)
	- Standard Libraryに関するUtilityクラス
	- UIに限定されない各種定義値
```

アーキテクチャの設計を遵守できるのはもちろん、依存の方向性をある程度強制できるので「UIComponent →アプリ本体」という依存を作り循環参照が起きてぐちゃぐちゃになる…ということが防げます。他にも`namespace`をきっちり分けることで、	呼び出すモジュールやクラスを明確にできる、という利点があったり。
[Embedded Framework使いこなし術 - Qiita](https://qiita.com/mono0926/items/e29cd17789fd1d1548aa)
まだ実施していませんが、EntityやAPIは他のアプリのコードと比較して変更の頻度が速くないので、これも別モジュールに切り出して良いかもしれません。

# 現状のメリット/課題
さて、冒頭から偉そうに解説していますが、RailsとSwiftのどちらも私が設計したものではなく、過去に在籍したエンジニアの方が設計したものです（そのため私の解釈がある程度混ざっています）。私はその恩恵に預かっているわけですが、これまで約半年間在籍して感じたアーキテクチャの「メリット」と「課題」についてお話します。
## メリット
### 少人数のエンジニアリソースで開発できる
個人的にはこれが最も大きなメリットだと感じるのですが、コードベースの大きさと比較すると、人数の少ないチームで開発を進めていくことができます。
実際に2020年5月の執筆時点で、フィッツプラスはサーバサイド4名とアプリエンジニア1名の計5名で開発を行っています。今回ご紹介したサービス以外にもRailsアプリケーションが2つ、PHPのサービスやPythonスクリプトなどが複数あることを考えると少ない人数だと思います。
小さなチームではコミュニケーションコストを低く抑えられ、ノウハウやポストモーテムの共有が比較的ラクです。
一般的な話をすると、そもそもベンチャー企業では物理的に大量のエンジニアを採用しづらいパターンもあるかと思います。まず最初はサービスをモノリシックに作り、市場に必要とされる機能を開発していくスタイルは、オーソドックスですがひとつの解ではあると感じます。
### 拡張性が高く複数のアプリケーションを展開しやすい
これはVIPERのくだりでしっかりドメインを定めたおかげだと思っていますが、Entityのロジックを複数のアプリケーションで共有しやすい状態になっていると感じます。社内にはDietPlusに近いドメインを持ったiOSおよびAndroidのアプリ（冒頭のアーキテクチャ図参照）が存在していますが、アプリやバックエンドともに既存アプリと同じようにコードを書ける部分が多く、後から入った身としては助かります。
実はサーバサイドと連携するアプリを他にも増やす予定があり（まだ喋れないやつ）、現在私が担当者としてモリモリとコードを書いているのですが、こういったことを自然とできるのはひとつの強みだと考えます。

## 課題
### アカウントや権限の管理が複雑になる
Sorcery & Bankenの章で少しピンと来た方がいるかもしれませんが、複数の権限が必要なアプリが複数存在しているため権限が複雑になってきています。
それぞれユーザーの権限を各Modelのenumで判断しているため、権限の説明やコンテキストをコードで管理するのが難しいです。マイグレーション時にDBにコメントを残すことができますが、そこに盛り込むのに権限の説明は少し長すぎます。Model内に長文でコメントアウトを残すのが妥当なラインでしょうか。
長期的には、太ってきた権限を他のテーブルに分割していく等の改善方法があるかと考えています。権限の説明をコードで把握するのを諦めて、しっかりドキュメントを残すことも大切でしょう（視線を泳がせながら）。
### Railsが単一障害点となる
Railsがすべてのアプリケーションの中核になっているので、当然ながらRails自体が落ちてしまうと~~放送自粛~~。
システム全体のダウンを防いでいくために、ある程度システムの運用経験のあるメンバーで開発を進めていくのが望ましいでしょう。もちろんですが、僕が入社してからの半年間でRailsが落ちた事件は一度も起きていません。
### 一部のコードがmodule間でDRYにならない（しづらい）
`A::User`と`B::User`といった別moduleの類似クラス(AやBはアプリ名)が数多く存在するのですが、共通化すべきコードとそうでないコードの見極めが難しいと感じます。各アプリのグロース速度が異なるのでなおさらです。
普段コードを書いていて「あっ、このscopeってBの方には生えてなかったのか...」みたいなことがよくあります。共通化するにも「3つ以上のmodule間で共通して使われ続けるであろう処理」かどうかの判断は容易ではありません。
個人的には、ヘンに共通化して罠にハマるくらいなら、メンテナンスするコード量が多少増えても、影響範囲をmoduleの中に閉じ込めておく方が無難なのではないかと考えます。
# さいごに
長くなりましたが以上です。最後までお付き合いいただきありがとうございました。 アプリケーションのアーキテクチャや使用するgemなど、皆さまになにか得るものがありましたら幸いです。
冒頭で事業について触れましたが、メドピアはメインサービスである「MedPeer」を中心に、さまざまな医療領域をカバーするため新しい事業をつぎつぎと立ち上げています。事業を支えるプロダクトが社内にたくさんある現状から学べること・経験できることはとても多く、エンジニアとしてとても魅力的な環境だと思います。
~~ステマみたいになりました~~ しかし、プロダクトをより良くするために、私たちにはエンジニアの力がもっと必要になります。というか足りないって一生言い続けてそうだなって感じですが、そんな中でも一緒に走りながらお互いを高めあえるエンジニアの方はぜひメドピアへ！
 
