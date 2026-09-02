# work-dotfiles

個人情報や会社固有情報を含まない、macOS 向けの汎用 dotfiles です。

Git の氏名・メールアドレス、SSH、各種トークンや認証情報はこのリポジトリでは管理しません。

## 含まれるもの

- zsh / zprofile
- Vim のプラグイン非依存設定
- Homebrew の CLI パッケージ一覧
- Ghostty、Zed、OrbStack の選択式インストール
- mise、direnv、fzf などの条件付き初期化
- Git のグローバル ignore（identity や Git 本体の設定は含めない）
- macOS の控えめな defaults
- dry-run 対応のインストーラーと診断スクリプト

## セットアップ

```sh
git clone <YOUR_REMOTE_URL> ~/.work-dotfiles
cd ~/.work-dotfiles

# 変更内容だけ確認
./scripts/install.sh

# Homebrew がなければ先に公式手順で導入
# CLI パッケージを導入（任意）
brew bundle --file ./Brewfile

# dotfiles を適用。既存ファイルは ~/.dotfiles-backup/ 以下へ退避
./scripts/install.sh --apply

# 状態確認
./scripts/doctor.sh
```

GUI アプリは必要なものだけ選んで導入できます。引数なしなら対話式です。

```sh
./scripts/apps.sh

# 引数で直接指定する例
./scripts/apps.sh ghostty
./scripts/apps.sh ghostty zed
./scripts/apps.sh all

# 選択肢だけ表示
./scripts/apps.sh --list
```

macOS defaults は内容を確認してから明示的に実行します。

```sh
./macos/defaults.sh
```

## Git identity

Git の identity は端末ごと、または会社・ディレクトリごとに別途設定してください。このリポジトリには保存しません。

端末全体で一つの identity を使う例:

```sh
git config --global user.name "YOUR NAME"
git config --global user.email "you@example.com"
```

特定リポジトリだけに設定する例:

```sh
cd /path/to/repository
git config user.name "YOUR NAME"
git config user.email "you@example.com"
```

ディレクトリ単位で切り替える場合は `includeIf` が使えますが、パスや identity は機密・組織固有になり得るため、別のローカル設定として管理してください。

## 方針

- SSH、GPG 秘密鍵、API トークン、GitHub の認証ファイルは管理しない
- プロジェクト固有の言語バージョンは各リポジトリの `mise.toml` などで固定する
- インストーラーは通常ファイルを勝手に上書きしない
- アンインストール時は、このリポジトリを指すシンボリックリンクだけを削除する

## アンインストール

まず対象を確認し、問題なければ適用します。

```sh
./scripts/uninstall.sh
./scripts/uninstall.sh --apply
```

バックアップは自動削除されません。
