# Objects2XLSX

[![Swift](https://img.shields.io/badge/Swift-6.0+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux-lightgrey.svg)](https://swift.org)
[![Swift Package Manager](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg)](https://swift.org/package-manager)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/fatbobman/Objects2XLSX)

**言語**: [English](README.md) | [中文](README_CN.md) | [日本語](README_JP.md)

Swift オブジェクトを Excel (.xlsx) ファイルに変換するための強力で型安全な Swift ライブラリです。Objects2XLSX は、完全なスタイリングサポート、複数のワークシート、リアルタイムの進捗追跡を備えた現代的な宣言型 API を提供し、プロフェッショナルな Excel スプレッドシートを作成できます。

## ✨ 特徴

### 🎯 **型安全設計**

- **ジェネリックシート**: `Sheet<ObjectType>` でコンパイル時の型安全性
- **KeyPath 統合**: `\.propertyName` による直接プロパティマッピング
- **Swift 6 対応**: Swift の厳密な並行性モデルを完全サポート

### 📊 **包括的な Excel サポート**

- **Excel 標準準拠**: 生成された XLSX ファイルは Excel 仕様に厳密に準拠し、警告や互換性の問題がありません
- **拡張カラム API**: 自動型推論を備えた簡素化された型安全なカラム宣言
- **スマート nil 処理**: オプショナル値の優雅な管理のための `.defaultValue()` メソッド
- **型変換**: カスタムデータ変換のための強力な `.toString()` メソッド
- **複数データ型**: String、Int、Double、Bool、Date、URL、Percentage でオプショナルサポート完備
- **完全スタイリングシステム**: フォント、色、ボーダー、塗りつぶし、配置、数値フォーマット
- **複数ワークシート**: 無制限のシートでワークブックを作成
- **メソッドチェーン**: 幅、スタイリング、データ変換を組み合わせる流暢な API

### 🎨 **高度なスタイリング**

- **プロフェッショナルな外観**: Excel の機能に匹敵する豊富なフォーマットオプション
- **スタイル階層**: Book → Sheet → Column → Cell の適切な優先順位でスタイリング
- **カスタムテーマ**: ドキュメント全体で一貫したスタイリングを作成
- **ボーダー管理**: 自動領域検出による精密なボーダー制御

### 🚀 **パフォーマンスと使いやすさ**

- **標準準拠**: 生成されたファイルは Excel、Numbers、Google Sheets、LibreOffice で警告なくシームレスに開けます
- **非同期データサポート**: `@Sendable` 非同期データプロバイダーによる安全なクロススレッドデータ取得
- **メモリ効率**: 大規模データセット用のストリームベース処理
- **進捗追跡**: AsyncStream によるリアルタイム進捗更新
- **クロスプラットフォーム**: macOS、iOS、tvOS、watchOS、Linux をサポートする純粋な Swift 実装
- **ゼロ依存**: オプショナルな SimpleLogger を除く外部依存なし

### 🛠 **開発者エクスペリエンス**

- **簡素化 API**: 自動型推論を備えた直感的でチェーン可能なカラム宣言
- **ライブデモプロジェクト**: ライブラリのすべての機能を紹介する包括的な例
- **ビルダーパターン**: シートとカラムを作成するための宣言型 DSL
- **包括的ドキュメント**: 実世界の例を含む詳細な API ドキュメント
- **広範囲テスト**: すべてのコア機能の信頼性を保証する 340+ テスト
- **SwiftFormat 統合**: Git フックによる一貫したコードフォーマット

## 📋 システム要件

- **Swift**: 6.0+
- **iOS**: 15.0+
- **macOS**: 12.0+
- **tvOS**: 15.0+
- **watchOS**: 8.0+
- **Linux**: Ubuntu 20.04+ (Swift 6.0+ が必要)

> **注意**：現在のテストは iOS 15+ と macOS 12+ をカバーしています。より古いシステムバージョンでのテストが可能でしたら、最小バージョン要件を調整できるようお知らせください。

## 📦 インストール

### Swift Package Manager

Xcode の Package Manager を使用するか、`Package.swift` に Objects2XLSX を追加してください：

```swift
dependencies: [
    .package(url: "https://github.com/fatbobman/Objects2XLSX.git", from: "1.0.0")
]
```

そしてターゲットに追加：

```swift
.target(
    name: "YourTarget",
    dependencies: ["Objects2XLSX"]
)
```

## 🚀 クイックスタート

### 基本的な使用法

```swift
import Objects2XLSX

// 1. データモデルを定義
struct Person: Sendable {
    let name: String
    let age: Int
    let email: String
}

// 2. データを準備
let people = [
    Person(name: "田中太郎", age: 28, email: "tanaka@example.com"),
    Person(name: "佐藤花子", age: 35, email: "sato@example.com"),
    Person(name: "鈴木一郎", age: 42, email: "suzuki@example.com")
]

// 3. 型安全なカラムでシートを作成
let sheet = Sheet<Person>(name: "従業員", dataProvider: { people }) {
    Column(name: "氏名", keyPath: \.name)
    Column(name: "年齢", keyPath: \.age)
    Column(name: "メールアドレス", keyPath: \.email)
}

// 4. ワークブックを作成し Excel ファイルを生成
let book = Book(style: BookStyle()) {
    sheet
}

let outputURL = URL(fileURLWithPath: "/path/to/employees.xlsx")
try book.write(to: outputURL)
```

### 非同期データプロバイダー（新機能！）

Objects2XLSX は Core Data、SwiftData、API コールとのスレッドセーフ操作のための非同期データ取得をサポートします：

```swift
import Objects2XLSX

// Sendable データ転送オブジェクトを定義
struct PersonData: Sendable {
    let name: String
    let department: String
    let salary: Double
    let hireDate: Date
}

// 非同期取得機能付きのデータサービスを作成
class DataService {
    private let persistentContainer: NSPersistentContainer
    
    @Sendable
    func fetchEmployees() async -> [PersonData] {
        await withCheckedContinuation { continuation in
            // Core Data のスレッドで実行
            persistentContainer.viewContext.perform {
                let employees = // ... Core Data オブジェクトを取得
                
                // Sendable オブジェクトに変換
                let data = employees.map { employee in
                    PersonData(
                        name: employee.name ?? "",
                        department: employee.department?.name ?? "",
                        salary: employee.salary,
                        hireDate: employee.hireDate ?? Date()
                    )
                }
                continuation.resume(returning: data)
            }
        }
    }
}

// 非同期データプロバイダー付きのシートを作成
let dataService = DataService(persistentContainer: container)

let sheet = Sheet<PersonData>(
    name: "非同期従業員",
    asyncDataProvider: dataService.fetchEmployees  // 🚀 非同期でスレッドセーフ！
) {
    Column(name: "氏名", keyPath: \.name)
    Column(name: "部署", keyPath: \.department)
    Column(name: "給与", keyPath: \.salary)
    Column(name: "入社日", keyPath: \.hireDate)
}

let book = Book(style: BookStyle()) { sheet }

// 非同期で Excel ファイルを生成
let outputURL = try await book.writeAsync(to: URL(fileURLWithPath: "/path/to/report.xlsx"))
```

**主な利点：**
- ✅ **スレッドセーフティ**: データ取得は正しいスレッドコンテキストで実行
- ✅ **型安全性**: `@Sendable` 制約により安全なデータ転送を保証
- ✅ **混合ソース**: 同じワークブックで同期・非同期シートを組み合わせ
- ✅ **進捗追跡**: 完全な非同期進捗監視サポート

### ライブデモを試す

包括的なデモプロジェクトですべての機能を体験：

```bash
# リポジトリをクローン
git clone https://github.com/fatbobman/Objects2XLSX.git
cd Objects2XLSX

# 異なるオプションでデモを実行
swift run Objects2XLSXDemo --help
swift run Objects2XLSXDemo -s medium -v demo.xlsx
swift run Objects2XLSXDemo -s large -t mixed -v -b output.xlsx
```

デモは3つのワークシートを持つプロフェッショナルな Excel ワークブックを生成し、以下を紹介：

- **従業員データ** - 企業スタイリングとデータ変換
- **製品カタログ** - モダンスタイリングと条件フォーマット
- **注文履歴** - デフォルトスタイリングと計算フィールド

**デモ機能：**

- 🎨 3つのプロフェッショナルスタイリングテーマ（企業、モダン、デフォルト）
- 📊 複数のデータサイズ（小：30、中：150、大：600レコード）
- 🔧 すべてのカラムタイプと高度な機能をデモ
- ⚡ リアルタイム進捗追跡とパフォーマンスベンチマーク
- 📁 ライブラリ機能を紹介するすぐに開ける Excel ファイル

### 複数データ型と拡張カラム API

Objects2XLSX は様々な Swift データ型を自動で処理する簡素化された型安全なカラム API を特徴とします：

```swift
struct Employee: Sendable {
    let name: String
    let age: Int
    let salary: Double?        // オプショナル給与
    let bonus: Double?         // オプショナルボーナス
    let isManager: Bool
    let hireDate: Date
    let profileURL: URL?       // オプショナルプロフィール URL
}

let employees = [
    Employee(
        name: "田中太郎",
        age: 30,
        salary: 75000.50,
        bonus: nil,           // 今期はボーナスなし
        isManager: true,
        hireDate: Date(),
        profileURL: URL(string: "https://company.com/profiles/tanaka")
    )
]

let sheet = Sheet<Employee>(name: "従業員", dataProvider: { employees }) {
    // シンプルな非オプショナルカラム
    Column(name: "氏名", keyPath: \.name)
    Column(name: "年齢", keyPath: \.age)
    
    // デフォルト値付きのオプショナルカラム
    Column(name: "給与", keyPath: \.salary)
        .defaultValue(0.0)
        .width(12)
    
    Column(name: "ボーナス", keyPath: \.bonus)
        .defaultValue(0.0)
        .width(10)
    
    // ブール値と日付カラム
    Column(name: "管理職", keyPath: \.isManager, booleanExpressions: .yesAndNo)
    Column(name: "入社日", keyPath: \.hireDate, timeZone: .current)
    
    // デフォルト値付きのオプショナル URL
    Column(name: "プロフィール", keyPath: \.profileURL)
        .defaultValue(URL(string: "https://company.com/default")!)
}
```

## 🔧 拡張カラム機能

### 簡素化されたカラム宣言

新しい API は自動型推論を備えた直感的で型安全なカラム作成を提供：

```swift
struct Product: Sendable {
    let id: Int
    let name: String
    let price: Double?
    let discount: Double?
    let stock: Int?
    let isActive: Bool?
}

let sheet = Sheet<Product>(name: "製品", dataProvider: { products }) {
    // 非オプショナルカラム（シンプル構文）
    Column(name: "ID", keyPath: \.id)
    Column(name: "製品名", keyPath: \.name)
    
    // デフォルト値付きのオプショナルカラム
    Column(name: "価格", keyPath: \.price)
        .defaultValue(0.0)
    
    Column(name: "在庫", keyPath: \.stock)
        .defaultValue(0)
    
    Column(name: "アクティブ", keyPath: \.isActive)
        .defaultValue(true)
}
```

### 高度な型変換

強力な `toString` メソッドでカラムデータを変換：

```swift
let sheet = Sheet<Product>(name: "製品", dataProvider: { products }) {
    // 価格帯をカテゴリに変換
    Column(name: "価格カテゴリ", keyPath: \.price)
        .defaultValue(0.0)
        .toString { (price: Double) in
            switch price {
            case 0..<50: "エコノミー"
            case 50..<200: "ミドルレンジ"
            default: "プレミアム"
            }
        }
    
    // 在庫レベルをステータスに変換
    Column(name: "在庫ステータス", keyPath: \.stock)
        .defaultValue(0)
        .toString { (stock: Int) in
            stock == 0 ? "在庫切れ" : 
            stock < 10 ? "在庫少" : "在庫あり"
        }
    
    // オプショナル割引を表示フォーマットに変換
    Column(name: "割引情報", keyPath: \.discount)
        .toString { (discount: Double?) in
            guard let discount = discount else { return "割引なし" }
            return String(format: "%.0f%% オフ", discount * 100)
        }
}
```

### 柔軟な nil 処理

オプショナル値の処理方法を制御：

```swift
let sheet = Sheet<Employee>(name: "従業員", dataProvider: { employees }) {
    // オプション 1：デフォルト値を使用
    Column(name: "給与", keyPath: \.salary)
        .defaultValue(0.0)  // nil は 0.0 になる
    
    // オプション 2：空のセルを保持（デフォルト動作）
    Column(name: "ボーナス", keyPath: \.bonus)
        // nil 値は空のセルとして表示される
    
    // オプション 3：カスタム nil 処理で変換
    Column(name: "給与レンジ", keyPath: \.salary)
        .toString { (salary: Double?) in
            guard let salary = salary else { return "未指定" }
            return salary > 50000 ? "高" : "標準"
        }
}
```

### メソッドチェーン

複数の設定を優雅に組み合わせ：

```swift
let sheet = Sheet<Employee>(name: "従業員", dataProvider: { employees }) {
    Column(name: "給与レベル", keyPath: \.salary)
        .defaultValue(0.0)                    // nil 値を処理
        .toString { $0 > 50000 ? "シニア" : "ジュニア" }  // カテゴリに変換
        .width(15)                            // カラム幅を設定
        .bodyStyle(CellStyle(                 // スタイルを適用
            font: Font(bold: true),
            fill: Fill.solid(.lightBlue)
        ))
}
```

## 🎨 スタイリングとフォーマット

### プロフェッショナルスタイリング

```swift
// カスタムヘッダースタイルを作成
let headerStyle = CellStyle(
    font: Font(size: 14, name: "Arial", bold: true, color: .white),
    fill: Fill.solid(.blue),
    alignment: Alignment(horizontal: .center, vertical: .center),
    border: Border.all(style: .thin, color: .black)
)

// データセルスタイルを作成
let dataStyle = CellStyle(
    font: Font(size: 11, name: "Calibri"),
    alignment: Alignment(horizontal: .left, wrapText: true),
    border: Border.outline(style: .thin, color: .gray)
)

// 拡張 API を使用してシートにスタイルを適用
let styledSheet = Sheet<Person>(name: "スタイル従業員", dataProvider: { people }) {
    Column(name: "氏名", keyPath: \.name)
        .width(20)
        .headerStyle(headerStyle)
        .bodyStyle(dataStyle)
    
    Column(name: "年齢", keyPath: \.age)
        .width(8)
        .headerStyle(headerStyle)
        .bodyStyle(CellStyle(alignment: Alignment(horizontal: .center)))
}
```

### 色のカスタマイズ

```swift
// 事前定義色
let redFill = Fill.solid(.red)
let blueFill = Fill.solid(.blue)

// カスタム色
let customColor = Color(red: 255, green: 128, blue: 0) // オレンジ
let hexColor = Color(hex: "#FF5733") // 16進文字列から
let transparentColor = Color(red: 255, green: 0, blue: 0, alpha: .medium) // 50% 透明赤

// グラデーション塗りつぶし（高度）
let gradientFill = Fill.gradient(
    .linear(angle: 90),
    colors: [.blue, .white, .red]
)
```

## 📈 複数ワークシート

異なるデータ型用の複数シートを含むワークブックを作成：

```swift
struct Customer: Sendable {
    let name: String
    let email: String?
    let registrationDate: Date
}

// 拡張 API を使用して複数シートを作成
let customersSheet = Sheet<Customer>(name: "顧客", dataProvider: { customers }) {
    Column(name: "顧客名", keyPath: \.name)
        .width(25)
    
    Column(name: "メール", keyPath: \.email)
        .defaultValue("no-email@company.com")
        .width(30)
    
    Column(name: "登録日", keyPath: \.registrationDate)
        .width(15)
}

// ワークブックでシートを結合
let book = Book(style: BookStyle()) {
    productsSheet
    customersSheet
}

try book.write(to: outputURL)
```

## 📊 進捗追跡

同期・非同期操作の Excel 生成進捗を監視：

```swift
let book = Book(style: BookStyle()) {
    // 同期・非同期シートの混合
    Sheet<Product>(name: "製品", dataProvider: { products }) {
        Column(name: "名前", keyPath: \.name)
        Column(name: "価格", keyPath: \.price)
    }
    
    Sheet<Employee>(name: "従業員", asyncDataProvider: fetchEmployeesAsync) {
        Column(name: "氏名", keyPath: \.name)
        Column(name: "部署", keyPath: \.department)
    }
}

// 進捗を監視
Task {
    for await progress in book.progressStream {
        print("進捗: \(Int(progress.progressPercentage * 100))%")
        print("現在のステップ: \(progress.description)")
        
        if progress.isFinal {
            print("✅ Excel ファイル生成完了！")
            break
        }
    }
}

// 同期でファイルを生成
Task {
    do {
        try book.write(to: outputURL)
        print("📁 ファイルが保存されました: \(outputURL.path)")
    } catch {
        print("❌ エラー: \(error)")
    }
}

// または非同期でファイルを生成（非同期データプロバイダーサポート）
Task {
    do {
        let outputURL = try await book.writeAsync(to: outputURL)
        print("📁 非同期ファイルが保存されました: \(outputURL.path)")
    } catch {
        print("❌ エラー: \(error)")
    }
}
```

## 🔧 高度な設定

### 非同期データ読み込み＆スレッドセーフティ

Objects2XLSX は複雑なシナリオ向けのスレッドセーフな非同期データ読み込みを提供：

```swift
// スレッドセーフな非同期データ取得
class EmployeeDataService {
    private let coreDataStack: CoreDataStack
    
    @Sendable
    func fetchEmployeesAsync() async -> [EmployeeData] {
        await withCheckedContinuation { continuation in
            // Core Data のスレッドに切り替え
            coreDataStack.viewContext.perform {
                do {
                    let request: NSFetchRequest<Employee> = Employee.fetchRequest()
                    let employees = try self.coreDataStack.viewContext.fetch(request)
                    
                    // Sendable DTO に変換
                    let employeeData = employees.map { EmployeeData(from: $0) }
                    continuation.resume(returning: employeeData)
                } catch {
                    continuation.resume(returning: [])
                }
            }
        }
    }
}

// 非同期データプロバイダーを使用
let service = EmployeeDataService(coreDataStack: stack)

let book = Book(style: BookStyle()) {
    // 同期シート
    Sheet<Product>(name: "製品", dataProvider: { loadProducts() }) {
        Column(name: "名前", keyPath: \.name)
        Column(name: "価格", keyPath: \.price)
    }
    
    // 非同期シート - Core Data スレッドでデータを取得
    Sheet<EmployeeData>(name: "従業員", asyncDataProvider: service.fetchEmployeesAsync) {
        Column(name: "氏名", keyPath: \.name)
        Column(name: "部署", keyPath: \.department)
        Column(name: "給与", keyPath: \.salary)
    }
}

// 非同期サポートで生成
let outputURL = try await book.writeAsync(to: URL(fileURLWithPath: "/path/to/report.xlsx"))
```

**スレッドセーフティガイドライン：**

- ✅ **任意のスレッドで Book を作成** - Book の作成はスレッドセーフ
- ✅ **正しいコンテキストでデータ取得** - 非同期プロバイダーがスレッド切り替えを処理
- ✅ **同期/非同期シートの混合** - 両タイプをシームレスに組み合わせ
- ⚠️ **非同期プロバイダーには `writeAsync()` を使用** - 適切な非同期データ読み込みを保証

## 📋 要件

- **Swift 6.0+**
- **プラットフォーム**: macOS 13+, iOS 16+, tvOS 16+, watchOS 9+, Linux
- **依存関係**: なし（ログ記録用のオプショナル SimpleLogger を除く）

## 👨‍💻 作者

**Fatbobman (東坡肘子)**

- ブログ: [https://fatbobman.com](https://fatbobman.com)
- GitHub: [@fatbobman](https://github.com/fatbobman)
- X: [@fatbobman](https://x.com/fatbobman)
- LinkedIn: [@fatbobman](https://www.linkedin.com/in/fatbobman/)
- Mastodon: [@fatbobman@mastodon.social](https://mastodon.social/@fatbobman)
- BlueSky: [@fatbobman.com](https://bsky.app/profile/fatbobman.com)

### 📰 つながりを保つ

Swift、SwiftUI、Core Data、SwiftData に関する最新の更新と優秀な記事をお見逃しなく。**[Fatbobman's Swift Weekly](https://weekly.fatbobman.com)** を購読して、週次の洞察と価値あるコンテンツを受信箱で直接受け取ってください。

## 💖 プロジェクトをサポート

Objects2XLSX が有用だと感じ、継続的な開発をサポートしたい場合：

- [☕️ Buy Me A Coffee](https://buymeacoffee.com/fatbobman) - 小額寄付で開発をサポート
- [💳 PayPal](https://www.paypal.com/paypalme/fatbobman) - 代替寄付方法

あなたのサポートがこのオープンソースプロジェクトの維持と改善に役立ちます。ありがとうございます！🙏

## 📄 ライセンス

Objects2XLSX は Apache License 2.0 の下でリリースされています。詳細は [LICENSE](LICENSE) をご覧ください。

### サードパーティ依存関係

このプロジェクトには以下のサードパーティソフトウェアが含まれています：

- **[SimpleLogger](https://github.com/fatbobman/SimpleLogger)** - MIT License
  - Swift 用の軽量ログライブラリ
  - Copyright (c) 2024 Fatbobman

## 🙏 謝辞

- Swift 6 のモダンな並行性機能を使用して❤️で構築
- Swift での型安全な Excel 生成の必要性にインスパイア
- フィードバックと貢献をしてくれた Swift コミュニティに感謝

## 📖 ドキュメント

詳細な API ドキュメント、例、高度な使用パターンについては、ライブラリに含まれる包括的な DocC ドキュメントをご覧ください。パッケージをインポート後に Xcode で直接アクセスするか、以下のコマンドでローカルにビルドできます：

```bash
swift package generate-documentation --target Objects2XLSX
```

ライブラリには使用例とベストプラクティスを含む、すべてのパブリック API の広範囲なインラインドキュメントが含まれています。

---

**Swift コミュニティによって❤️で作られました**