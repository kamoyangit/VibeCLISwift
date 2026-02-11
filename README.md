# VibeCLISwift

LLM（Ollama, LM Studio, DeepSeek）を活用してSwift CLIツールを自動生成する開発支援ツールです。

## 特徴
- **対話型インターフェース**: 自然言語で作りたいツールを説明するだけ。
- **マルチLLM対応**: ローカル(Ollama/LM Studio)からクラウド(DeepSeek)まで選択可能。
- **自動ビルド**: コード生成からコンパイル(`swiftc`)までを一気通貫で実行。
- **自動修正**: コンパイルエラーが発生した場合、エラー内容をLLMにフィードバックして自動修正を試みます。

## 使い方

1. プロジェクトのビルド
```bash
swift build
```

2. ツールの実行
```bash
.build/debug/VibeCLISwift
```
または
```bash
swift run
```

3. 画面の指示に従って入力
   - **LLMプロバイダの選択**: (1) Ollama, (2) LM Studio, (3) DeepSeek
   - **アプリ名**: 生成する実行ファイルの名前（例: `MyTool`）
   - **機能**: どのようなツールを作りたいか（例: `現在のディレクトリのファイル一覧を表示する`）
   - **補足**: 追加の要件（例: `ファイルサイズも表示して`）

4. 完了
   - 生成されたソースコード（`MyTool.swift`）と実行ファイル（`MyTool`）がカレントディレクトリに作成されます。
   - `./MyTool --help` で動作確認できます。

## 必要要件
- macOS 12.0以降
- Swift 5.5以降
- Ollama / LM Studio (ローカルLLMを利用する場合)
- DeepSeek API Key (DeepSeekを利用する場合、環境変数 `DEEPSEEK_API_KEY` に設定)

## 構成
- `Sources/VibeCLISwift/`: ソースコード
  - `main.swift`: エントリーポイント
  - `LLMClient.swift`: LLM API通信
  - `CodeGenerator.swift`: プロンプト生成・コード抽出
  - `Compiler.swift`: swiftc実行・エラーハンドリング
  - `InteractiveSession.swift`: ユーザー入力処理
