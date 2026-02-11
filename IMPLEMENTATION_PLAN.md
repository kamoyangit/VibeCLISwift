# 実装計画書: VibeCLISwift (Swift CLI Tool Generator)

## 1. プロジェクト概要
**VibeCLISwift** は、自然言語による指示からSwift製のCLIツールを自動生成・コンパイル・実行可能にする開発支援ツールです。
ユーザーは「アプリ名」「機能」「補足」を入力するだけで、LLM（Ollama, LM Studio, DeepSeek）がコードを生成し、自動的に実行ファイルを作成します。

## 2. 技術スタック
- **言語**: Swift 5.10+ (macOS)
- **ビルドツール**: Swift Package Manager (SPM) または `swiftc` 直接実行
- **依存ライブラリ**: 標準ライブラリ (`Foundation`) のみを使用し、軽量動作を目指します。
- **対応LLM**: 
    - Ollama (Local)
    - LM Studio (Local Network)
    - DeepSeek (Cloud API)

## 3. 実装ステップ

### ステップ 1: プロジェクトの初期化
- ディレクトリ構造の作成: `/Users/koji/Desktop/MySwift/VibeCLISwift`
- `swift package init --type executable` の実行。
- `.gitignore` の設定（生成物や一時ファイルの除外）。

### ステップ 2: LLMクライアントの実装 (`LLMClient.swift`)
- 共通インターフェースの定義。
- **Ollama**: `http://localhost:11434/api/generate` へのPOSTリクエスト実装。
- **LM Studio**: OpenAI互換APIへのリクエスト実装。
- **DeepSeek**: `https://api.deepseek.com` へのリクエスト実装（API Key認証）。
- レスポンスのパース（JSONデコード）。

### ステップ 3: ユーザー対話インターフェース (`InteractiveSession.swift`)
- 起動時のパラメータ（環境変数 `DEEPSEEK_API_KEY`）チェック。
- ユーザー入力の受付ループ（アプリ名、機能定義、補足説明）。
- 接続先LLMの選択ロジック。

### ステップ 4: コード生成と処理 (`CodeGenerator.swift`)
- システムプロンプトの構築（要件：単一ファイル、`ArgumentParser`依存なし、`--help`実装）。
- LLMからの応答（Markdownコードブロック）からSwiftコードのみを抽出する正規表現処理。

### ステップ 5: コンパイルとエラーハンドリング (`Compiler.swift`)
- `Process` クラスを使用した `swiftc` コマンドの実行。
- 成功時: 生成されたバイナリへの実行権限付与 (`chmod +x`) とパスの表示。
- 失敗時: エラーログを取得し、LLMに再送して修正コードを生成させる再帰ループ（最大試行回数を設定予定）。

### ステップ 6: 統合とテスト (`main.swift`)
- 全モジュールの統合。
- 動作確認（各LLMでの疎通、単純なHello World生成、エラー時の修正挙動）。

## 4. ファイル構成予定
```
VibeCLISwift/
├── Package.swift
├── Sources/
│   └── VibeCLISwift/
│       ├── main.swift           # エントリーポイント
│       ├── LLMClient.swift      # API通信
│       ├── InteractiveSession.swift # ユーザー入力処理
│       ├── CodeGenerator.swift  # プロンプト構築・コード抽出
│       └── Compiler.swift       # swiftc実行・エラーフィードバック
└── README.md
```
