#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
AntigravityJP - Antigravity 言語設定ファイル完全日本語化エンジン (Windows / macOS / Linux 対応)
================================================================================================
Antigravity / Antigravity IDE で表示・使用される全ての言語設定ファイル
(nls.messages.json, main.i18n.json, 拡張機能 package.nls.json / package.json,
languagepacks.json, clp キャッシュ, argv.json) に記載された英語メッセージを
すべて日本語に翻訳・適用します。
"""

import argparse
import glob
import json
import os
import platform
import re
import shutil
import sys
from datetime import datetime

if sys.stdout and hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")
if sys.stderr and hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8")

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DICT_PATH = os.path.join(PROJECT_ROOT, "translations", "ja_dictionary.json")
PENDING_PATH = os.path.join(PROJECT_ROOT, "translations", "untranslated_pending.json")
BACKUP_DIR = os.path.join(PROJECT_ROOT, "backups")

JA_CHAR_RE = re.compile(r"[\u3040-\u30ff\u3400-\u4dbf\u4e00-\u9fff\uff00-\uffef]")
EN_WORD_RE = re.compile(r"[A-Za-z]{2,}")

# 固有名詞・技術識別子など英語のまま維持すべき文字列のセット
KEEP_AS_IS = {
    "OK", "OK(&&O)", "Ctrl", "Shift", "Alt", "Windows", "Super", "Control",
    "CLI", "NULL", "null", "{0}KB", "{0}MB", "{0}GB", "{0}TB", "{0}%", "{0}",
    "({0})", "({0}) {1}", "{0}: {1}", "{0} - {1}", "{0} ({1})", "{0}/{1}",
    "${path}", "Antigravity", "Antigravity IDE", "Google Antigravity",
    "Jetski", "Cloudtop", "Copilot Business", "Copilot Enterprise",
    "Copilot Free", "Copilot Pro", "Copilot Pro+", "Dev Containers",
    "Remote-SSH", "Remote-WSL", "WSL", "Gradle", "Gradle for Java",
    "SynthWave '84", "Tokyo Night", "Tokyo Night Light", "Tokyo Night Storm",
    "{0} for the Web", "Git", "GitHub", "Python", "Java", "Markdown", "JSON",
    "YAML", "HTML", "CSS", "TypeScript", "JavaScript", "C++", "C#", "Go",
    "Rust", "Ruby", "PHP", "Perl", "Lua", "R", "SQL", "XML", "Docker",
    "PowerShell", "Bash", "Zsh", "UTF-8", "ASCII", "MCP", "SSH", "URL", "URI",
    "HTTP", "HTTPS", "SSL", "TLS", "API", "SDK", "IDE", "LLM", "AI",
}


def is_japanese_or_symbol(text: str) -> bool:
    """文字列がすでに日本語を含むか、翻訳不要な記号・固有名詞のみかを判定"""
    if not isinstance(text, str) or not text.strip():
        return True
    if text in KEEP_AS_IS:
        return True
    if JA_CHAR_RE.search(text):
        return True
    cleaned = re.sub(r"\{\d+\}|\$\{[^}]+\}|\$\([^)]+\)|https?://\S+|`[^`]+`", "", text)
    if not EN_WORD_RE.search(cleaned):
        return True
    return False


def _first_existing_dir(candidates: list) -> str:
    for c in candidates:
        if c and os.path.isdir(c):
            return c
    return candidates[0] if candidates else ""


def get_antigravity_paths(custom_app_dir: str = None) -> dict:
    """
    Windows / macOS / Linux それぞれの標準インストールパスから
    Antigravity / Antigravity IDE 関連パスを自動検出します。
    """
    system = platform.system().lower()
    home = os.path.expanduser("~")
    env_app_dir = custom_app_dir or os.environ.get("ANTIGRAVITY_IDE_APP_DIR")

    if system == "windows":
        localappdata = os.environ.get("LOCALAPPDATA", os.path.join(home, "AppData", "Local"))
        appdata = os.environ.get("APPDATA", os.path.join(home, "AppData", "Roaming"))
        programfiles = os.environ.get("ProgramFiles", r"C:\Program Files")
        programfiles_x86 = os.environ.get("ProgramFiles(x86)", r"C:\Program Files (x86)")

        app_candidates = [
            env_app_dir,
            os.path.join(localappdata, "Programs", "Antigravity IDE", "resources", "app"),
            os.path.join(programfiles, "Antigravity IDE", "resources", "app"),
            os.path.join(programfiles_x86, "Antigravity IDE", "resources", "app"),
        ]
        roaming_candidates = [
            os.path.join(appdata, "Antigravity IDE"),
        ]
    elif system == "darwin":
        app_candidates = [
            env_app_dir,
            "/Applications/Antigravity IDE.app/Contents/Resources/app",
            os.path.join(home, "Applications", "Antigravity IDE.app", "Contents", "Resources", "app"),
        ]
        roaming_candidates = [
            os.path.join(home, "Library", "Application Support", "Antigravity IDE"),
        ]
    else:
        # Linux
        xdg_config = os.environ.get("XDG_CONFIG_HOME", os.path.join(home, ".config"))
        xdg_data = os.environ.get("XDG_DATA_HOME", os.path.join(home, ".local", "share"))
        app_candidates = [
            env_app_dir,
            "/usr/share/antigravity-ide/resources/app",
            "/opt/antigravity-ide/resources/app",
            "/opt/Antigravity IDE/resources/app",
            os.path.join(xdg_data, "antigravity-ide", "resources", "app"),
            "/snap/antigravity-ide/current/usr/share/antigravity-ide/resources/app",
        ]
        roaming_candidates = [
            os.path.join(xdg_config, "Antigravity IDE"),
            os.path.join(xdg_config, "antigravity-ide"),
        ]

    ide_app = _first_existing_dir([c for c in app_candidates if c])
    ide_roaming = _first_existing_dir(roaming_candidates)
    ide_exts_user = os.path.join(home, ".antigravity-ide", "extensions")
    ide_argv = os.path.join(home, ".antigravity-ide", "argv.json")

    lp_dirs = sorted(glob.glob(os.path.join(ide_exts_user, "ms-ceintl.vscode-language-pack-ja-*")))
    lp_dir = lp_dirs[-1] if lp_dirs else None

    return {
        "os": system,
        "ide_app": ide_app,
        "ide_out": os.path.join(ide_app, "out"),
        "ide_exts_builtin": os.path.join(ide_app, "extensions"),
        "ide_product_json": os.path.join(ide_app, "product.json"),
        "ide_exts_user": ide_exts_user,
        "ide_argv": ide_argv,
        "ide_roaming": ide_roaming,
        "languagepacks_json": os.path.join(ide_roaming, "languagepacks.json"),
        "clp_dir": os.path.join(ide_roaming, "clp"),
        "lp_dir": lp_dir,
    }


def backup_file_once(src_path: str, tag: str) -> str:
    """
    元ファイルを初回のみバックアップします。
    すでにバックアップが存在する場合は上書きしません。
    """
    if not os.path.exists(src_path):
        return ""
    os.makedirs(BACKUP_DIR, exist_ok=True)
    rel_safe = tag.replace(":", "").replace("\\", "/").lstrip("/")
    dst_path = os.path.join(BACKUP_DIR, rel_safe)
    os.makedirs(os.path.dirname(dst_path), exist_ok=True)
    if not os.path.exists(dst_path):
        shutil.copy2(src_path, dst_path)
    return dst_path


def load_json(path: str, default=None):
    if not path or not os.path.exists(path):
        return default
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def save_json(path: str, data, indent=2):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=indent)


def load_jsonc_simple(path: str) -> dict:
    """コメント付き JSON (argv.json 等) を読み込む"""
    if not os.path.exists(path):
        return {}
    with open(path, "r", encoding="utf-8") as f:
        raw = f.read()
    lines = []
    for line in raw.splitlines():
        stripped = line.strip()
        if stripped.startswith("//"):
            continue
        lines.append(line)
    cleaned = "\n".join(lines)
    cleaned = re.sub(r",\s*([}\]])", r"\1", cleaned)
    try:
        return json.loads(cleaned)
    except Exception:
        return {}


def heuristic_translate_fallback(en_text: str, ja_dict: dict) -> str:
    """
    万一辞書に未登録の新しい英語メッセージが追加された場合のルールベース翻訳フォールバック。
    """
    if en_text in ja_dict:
        return ja_dict[en_text]
    if is_japanese_or_symbol(en_text):
        return en_text

    patterns = [
        (r"^Open (.+) in New Window$", r"新しいウィンドウで \1 を開く"),
        (r"^Open (.+) in Current Window$", r"現在のウィンドウで \1 を開く"),
        (r"^Open (.+)$", r"\1 を開く"),
        (r"^Show (.+)$", r"\1 を表示"),
        (r"^Hide (.+)$", r"\1 を非表示"),
        (r"^Toggle (.+)$", r"\1 の切り替え"),
        (r"^Enable (.+)$", r"\1 を有効化"),
        (r"^Disable (.+)$", r"\1 を無効化"),
        (r"^Create (.+)$", r"\1 を作成"),
        (r"^Delete (.+)$", r"\1 を削除"),
        (r"^Remove (.+)$", r"\1 を削除"),
        (r"^Refresh (.+)$", r"\1 を更新"),
        (r"^Reset (.+)$", r"\1 をリセット"),
        (r"^Configure (.+)$", r"\1 を構成"),
        (r"^Select (.+)$", r"\1 を選択"),
        (r"^Copy (.+)$", r"\1 をコピー"),
        (r"^Clear (.+)$", r"\1 をクリア"),
        (r"^Run (.+)$", r"\1 を実行"),
        (r"^Start (.+)$", r"\1 を開始"),
        (r"^Stop (.+)$", r"\1 を停止"),
        (r"^Restart (.+)$", r"\1 を再起動"),
        (r"^Install (.+)$", r"\1 をインストール"),
        (r"^Uninstall (.+)$", r"\1 をアンインストール"),
        (r"^Update (.+)$", r"\1 を更新"),
        (r"^Manage (.+)$", r"\1 の管理"),
        (r"^View (.+)$", r"\1 を表示"),
        (r"^Filter by (.+)$", r"\1 でフィルター"),
        (r"^Group by (.+)$", r"\1 でグループ化"),
        (r"^Controls whether (.+)\.$", r"\1 かどうかを制御します。"),
        (r"^Controls the (.+)\.$", r"\1 を制御します。"),
        (r"^Whether (.+)\.$", r"\1 かどうか。"),
        (r"^Whether (.+)$", r"\1 かどうか"),
        (r"^Failed to (.+): (.+)$", r"\1 に失敗しました: \2"),
    ]
    for pat, repl in patterns:
        m = re.match(pat, en_text)
        if m:
            inner = m.group(1)
            inner_ja = ja_dict.get(inner, inner)
            if m.lastindex and m.lastindex >= 2:
                return re.sub(pat, repl, en_text, count=1).replace(inner, inner_ja, 1)
            return repl.replace(r"\1", inner_ja)

    word_map = {
        "Settings": "設定",
        "Workspace": "ワークスペース",
        "Window": "ウィンドウ",
        "Terminal": "ターミナル",
        "Editor": "エディター",
        "Agent": "エージェント",
        "Session": "セッション",
        "Sessions": "セッション",
        "Chat": "チャット",
        "File": "ファイル",
        "Files": "ファイル",
        "Folder": "フォルダー",
        "Folders": "フォルダー",
        "Extension": "拡張機能",
        "Extensions": "拡張機能",
        "Model": "モデル",
        "Models": "モデル",
        "Server": "サーバー",
        "Servers": "サーバー",
        "Debug": "デバッグ",
        "Error": "エラー",
        "Warning": "警告",
        "Default": "既定",
        "Custom": "カスタム",
    }
    result = en_text
    for en_w, ja_w in word_map.items():
        result = re.sub(rf"\b{re.escape(en_w)}\b", ja_w, result)
    return result


def build_comprehensive_translation_map(paths: dict, ja_dict: dict):
    """
    既存の Language Pack 内の翻訳と ja_dictionary.json を統合し、
    全英語メッセージ -> 日本語メッセージの辞書を構築します。
    """
    en_to_ja = dict(ja_dict)

    nls_keys_path = os.path.join(paths["ide_out"], "nls.keys.json")
    nls_msgs_path = os.path.join(paths["ide_out"], "nls.messages.json")
    nls_msgs_backup = os.path.join(BACKUP_DIR, "ide_out/nls.messages.json")
    source_msgs_path = nls_msgs_backup if os.path.exists(nls_msgs_backup) else nls_msgs_path

    lp_main_path = (
        os.path.join(paths["lp_dir"], "translations", "main.i18n.json")
        if paths["lp_dir"]
        else None
    )
    lp_main_backup = os.path.join(BACKUP_DIR, "lp/main.i18n.json")
    source_lp_path = lp_main_backup if os.path.exists(lp_main_backup) else lp_main_path

    if os.path.exists(nls_keys_path) and os.path.exists(source_msgs_path) and source_lp_path and os.path.exists(source_lp_path):
        keys = load_json(nls_keys_path, [])
        msgs = load_json(source_msgs_path, [])
        lp_data = load_json(source_lp_path, {}).get("contents", {})
        idx = 0
        for mod_name, mod_keys in keys:
            mod_trans = lp_data.get(mod_name, {})
            for k in mod_keys:
                if idx < len(msgs):
                    en_msg = msgs[idx]
                    if k in mod_trans and not is_japanese_or_symbol(en_msg):
                        ja_val = mod_trans[k]
                        if JA_CHAR_RE.search(ja_val) or ja_val in KEEP_AS_IS:
                            en_to_ja.setdefault(en_msg, ja_val)
                idx += 1

    if paths["lp_dir"] and os.path.exists(paths["ide_exts_builtin"]):
        lp_ext_dir = os.path.join(paths["lp_dir"], "translations", "extensions")
        for ext in sorted(os.listdir(paths["ide_exts_builtin"])):
            ext_dir = os.path.join(paths["ide_exts_builtin"], ext)
            if not os.path.isdir(ext_dir):
                continue
            pkg_path = os.path.join(ext_dir, "package.json")
            nls_path = os.path.join(ext_dir, "package.nls.json")
            nls_backup = os.path.join(BACKUP_DIR, f"builtin_exts/{ext}/package.nls.json")
            src_nls = nls_backup if os.path.exists(nls_backup) else nls_path
            if not os.path.exists(pkg_path) or not os.path.exists(src_nls):
                continue
            pkg = load_json(pkg_path, {})
            ext_id = f"{pkg.get('publisher', '')}.{pkg.get('name', '')}"
            i18n_file = os.path.join(lp_ext_dir, f"{ext_id}.i18n.json")
            if os.path.exists(i18n_file):
                nls_data = load_json(src_nls, {})
                i18n_data = load_json(i18n_file, {}).get("contents", {}).get("package", {})
                for k, en_v in nls_data.items():
                    if k in i18n_data and isinstance(en_v, str) and isinstance(i18n_data[k], str):
                        if JA_CHAR_RE.search(i18n_data[k]):
                            en_to_ja.setdefault(en_v, i18n_data[k])

    return en_to_ja


def translate_or_check(apply_changes: bool = True, custom_app_dir: str = None) -> dict:
    """
    全ての Antigravity 言語設定ファイルを走査し、翻訳の適用または状態確認を行います。
    """
    paths = get_antigravity_paths(custom_app_dir=custom_app_dir)
    ja_dict = load_json(DICT_PATH, {})
    ja_values_set = set(ja_dict.values())
    en_to_ja = build_comprehensive_translation_map(paths, ja_dict)

    stats = {
        "timestamp": datetime.now().isoformat(),
        "os": paths["os"],
        "ide_app_path": paths["ide_app"],
        "mode": "apply" if apply_changes else "status",
        "core_total_messages": 0,
        "core_translated_messages": 0,
        "core_newly_translated": 0,
        "lp_missing_keys_added": 0,
        "builtin_extensions_updated": 0,
        "user_extensions_updated": 0,
        "clp_cache_updated": False,
        "argv_locale_ja": False,
        "untranslated_pending": [],
        "files_modified": [],
    }
    pending_set = set()

    # =========================================================================
    # 1. コア NLS (nls.keys.json / nls.messages.json) & main.i18n.json
    # =========================================================================
    nls_keys_path = os.path.join(paths["ide_out"], "nls.keys.json")
    nls_msgs_path = os.path.join(paths["ide_out"], "nls.messages.json")
    lp_main_path = (
        os.path.join(paths["lp_dir"], "translations", "main.i18n.json")
        if paths["lp_dir"]
        else None
    )

    if os.path.exists(nls_keys_path) and os.path.exists(nls_msgs_path):
        if apply_changes:
            backup_file_once(nls_msgs_path, "ide_out/nls.messages.json")
            if lp_main_path and os.path.exists(lp_main_path):
                backup_file_once(lp_main_path, "lp/main.i18n.json")

        nls_msgs_backup = os.path.join(BACKUP_DIR, "ide_out/nls.messages.json")
        current_msgs = load_json(nls_msgs_path, [])
        if os.path.exists(nls_msgs_backup):
            backup_msgs = load_json(nls_msgs_backup, [])
            source_msgs = backup_msgs if len(backup_msgs) == len(current_msgs) else current_msgs
        else:
            source_msgs = current_msgs

        keys = load_json(nls_keys_path, [])
        lp_full = load_json(lp_main_path, {"contents": {}}) if lp_main_path and os.path.exists(lp_main_path) else {"contents": {}}
        lp_contents = lp_full.setdefault("contents", {})

        translated_msgs = []
        idx = 0
        added_to_lp = 0
        newly_translated = 0

        for mod_name, mod_keys in keys:
            mod_trans = lp_contents.setdefault(mod_name, {})
            for k in mod_keys:
                en_msg = source_msgs[idx] if idx < len(source_msgs) else ""
                cur_msg = current_msgs[idx] if idx < len(current_msgs) else en_msg

                ja_msg = None
                if en_msg in ja_dict:
                    ja_msg = ja_dict[en_msg]
                elif k in mod_trans and (is_japanese_or_symbol(mod_trans[k]) or mod_trans[k] in ja_values_set):
                    ja_msg = mod_trans[k]
                elif en_msg in en_to_ja:
                    ja_msg = en_to_ja[en_msg]
                elif is_japanese_or_symbol(en_msg) or en_msg in ja_values_set:
                    ja_msg = en_msg
                else:
                    pending_set.add(en_msg)
                    ja_msg = heuristic_translate_fallback(en_msg, ja_dict)

                if k not in mod_trans or mod_trans[k] != ja_msg:
                    mod_trans[k] = ja_msg
                    added_to_lp += 1

                if cur_msg != ja_msg:
                    newly_translated += 1

                translated_msgs.append(ja_msg)
                idx += 1

        stats["core_total_messages"] = idx
        stats["core_translated_messages"] = sum(
            1
            for m in (translated_msgs if apply_changes else current_msgs)
            if is_japanese_or_symbol(m) or m in ja_values_set
        )
        stats["core_newly_translated"] = newly_translated
        stats["lp_missing_keys_added"] = added_to_lp

        if apply_changes:
            with open(nls_msgs_path, "w", encoding="utf-8") as f:
                json.dump(translated_msgs, f, ensure_ascii=False)
            stats["files_modified"].append(nls_msgs_path)

            if lp_main_path:
                save_json(lp_main_path, lp_full, indent="\t")
                stats["files_modified"].append(lp_main_path)

            # =================================================================
            # 2. clp キャッシュの生成・更新
            # =================================================================
            prod_data = load_json(paths["ide_product_json"], {})
            commit = prod_data.get("commit")
            lp_cfg_all = load_json(paths["languagepacks_json"], {})
            ja_cfg = lp_cfg_all.get("ja", {})
            lp_hash = ja_cfg.get("hash")

            if commit and lp_hash:
                clp_ja_root = os.path.join(paths["clp_dir"], f"{lp_hash}.ja")
                clp_commit_dir = os.path.join(clp_ja_root, commit)
                os.makedirs(clp_commit_dir, exist_ok=True)
                clp_msgs_file = os.path.join(clp_commit_dir, "nls.messages.json")
                clp_tcf_file = os.path.join(clp_ja_root, "tcf.json")
                with open(clp_msgs_file, "w", encoding="utf-8") as f:
                    json.dump(translated_msgs, f, ensure_ascii=False)
                with open(clp_tcf_file, "w", encoding="utf-8") as f:
                    json.dump(ja_cfg.get("translations", {}), f, ensure_ascii=False)
                stats["clp_cache_updated"] = True
                stats["files_modified"].append(clp_msgs_file)

    # =========================================================================
    # 3. product.json 内の英語メッセージ (aiGeneratedWorkspaceTrust 等)
    # =========================================================================
    if os.path.exists(paths["ide_product_json"]):
        if apply_changes:
            backup_file_once(paths["ide_product_json"], "ide_app/product.json")
        prod_data = load_json(paths["ide_product_json"], {})
        trust = prod_data.get("aiGeneratedWorkspaceTrust", {})
        prod_changed = False
        for tk, tv in list(trust.items()):
            if isinstance(tv, str) and tv in en_to_ja and trust[tk] != en_to_ja[tv]:
                trust[tk] = en_to_ja[tv]
                prod_changed = True
        if prod_changed and apply_changes:
            save_json(paths["ide_product_json"], prod_data, indent="\t")
            stats["files_modified"].append(paths["ide_product_json"])

    # =========================================================================
    # 4. 組み込み拡張機能 (resources/app/extensions/*) の翻訳
    # =========================================================================
    lp_cfg_all = load_json(paths["languagepacks_json"], {})
    ja_translations_map = lp_cfg_all.get("ja", {}).get("translations", {})
    lp_cfg_changed = False

    if os.path.exists(paths["ide_exts_builtin"]):
        lp_ext_dir = (
            os.path.join(paths["lp_dir"], "translations", "extensions")
            if paths["lp_dir"]
            else None
        )
        for ext in sorted(os.listdir(paths["ide_exts_builtin"])):
            ext_dir = os.path.join(paths["ide_exts_builtin"], ext)
            if not os.path.isdir(ext_dir) or ext == "node_modules":
                continue
            pkg_path = os.path.join(ext_dir, "package.json")
            nls_path = os.path.join(ext_dir, "package.nls.json")
            nls_ja_path = os.path.join(ext_dir, "package.nls.ja.json")
            if not os.path.exists(pkg_path):
                continue

            pkg = load_json(pkg_path, {})
            ext_id = f"{pkg.get('publisher', '')}.{pkg.get('name', '')}"

            if os.path.exists(nls_path):
                if apply_changes:
                    backup_file_once(nls_path, f"builtin_exts/{ext}/package.nls.json")
                nls_backup = os.path.join(BACKUP_DIR, f"builtin_exts/{ext}/package.nls.json")
                src_nls = load_json(nls_backup if os.path.exists(nls_backup) else nls_path, {})

                i18n_file = os.path.join(lp_ext_dir, f"{ext_id}.i18n.json") if lp_ext_dir else None
                i18n_full = (
                    load_json(i18n_file, {"version": "1.0.0", "contents": {"package": {}}})
                    if i18n_file and os.path.exists(i18n_file)
                    else {"version": "1.0.0", "contents": {"package": {}}}
                )
                i18n_pkg = i18n_full.setdefault("contents", {}).setdefault("package", {})

                translated_nls = {}
                for k, en_v in src_nls.items():
                    if not isinstance(en_v, str):
                        translated_nls[k] = en_v
                        continue
                    if en_v in ja_dict:
                        ja_v = ja_dict[en_v]
                    elif k in i18n_pkg and (is_japanese_or_symbol(i18n_pkg[k]) or i18n_pkg[k] in ja_values_set):
                        ja_v = i18n_pkg[k]
                    elif en_v in en_to_ja:
                        ja_v = en_to_ja[en_v]
                    elif is_japanese_or_symbol(en_v) or en_v in ja_values_set:
                        ja_v = en_v
                    else:
                        pending_set.add(en_v)
                        ja_v = heuristic_translate_fallback(en_v, ja_dict)

                    translated_nls[k] = ja_v
                    if i18n_pkg.get(k) != ja_v:
                        i18n_pkg[k] = ja_v

                if apply_changes:
                    save_json(nls_path, translated_nls)
                    save_json(nls_ja_path, translated_nls)
                    if i18n_file:
                        backup_file_once(i18n_file, f"lp/extensions/{ext_id}.i18n.json")
                        save_json(i18n_file, i18n_full, indent="\t")
                        if ext_id not in ja_translations_map:
                            ja_translations_map[ext_id] = i18n_file
                            lp_cfg_changed = True
                    stats["builtin_extensions_updated"] += 1
            else:
                if apply_changes:
                    backup_file_once(pkg_path, f"builtin_exts/{ext}/package.json")
                pkg_backup = os.path.join(BACKUP_DIR, f"builtin_exts/{ext}/package.json")
                src_pkg = load_json(pkg_backup if os.path.exists(pkg_backup) else pkg_path, {})

                def translate_pkg_obj(obj):
                    changed = False
                    if isinstance(obj, dict):
                        for k, v in list(obj.items()):
                            if k in ("displayName", "description", "markdownDescription", "title", "category", "label") and isinstance(v, str):
                                if v in en_to_ja:
                                    obj[k] = en_to_ja[v]
                                    changed = True
                                elif not (is_japanese_or_symbol(v) or v in ja_values_set):
                                    pending_set.add(v)
                                    obj[k] = heuristic_translate_fallback(v, ja_dict)
                                    changed = True
                            else:
                                if translate_pkg_obj(v):
                                    changed = True
                    elif isinstance(obj, list):
                        for item in obj:
                            if translate_pkg_obj(item):
                                changed = True
                    return changed

                if translate_pkg_obj(src_pkg) and apply_changes:
                    save_json(pkg_path, src_pkg, indent="\t")
                    stats["builtin_extensions_updated"] += 1
                    stats["files_modified"].append(pkg_path)

    if lp_cfg_changed and apply_changes and os.path.exists(paths["languagepacks_json"]):
        backup_file_once(paths["languagepacks_json"], "roaming/languagepacks.json")
        save_json(paths["languagepacks_json"], lp_cfg_all, indent=None)
        stats["files_modified"].append(paths["languagepacks_json"])

    # =========================================================================
    # 5. ユーザー拡張機能 (.antigravity-ide/extensions/*) の翻訳
    # =========================================================================
    if os.path.exists(paths["ide_exts_user"]):
        for d in sorted(os.listdir(paths["ide_exts_user"])):
            if d.startswith("ms-ceintl.vscode-language-pack-"):
                continue
            ext_dir = os.path.join(paths["ide_exts_user"], d)
            if not os.path.isdir(ext_dir):
                continue
            nls_path = os.path.join(ext_dir, "package.nls.json")
            nls_ja_path = os.path.join(ext_dir, "package.nls.ja.json")
            pkg_path = os.path.join(ext_dir, "package.json")

            if os.path.exists(nls_path):
                if apply_changes:
                    backup_file_once(nls_path, f"user_exts/{d}/package.nls.json")
                nls_backup = os.path.join(BACKUP_DIR, f"user_exts/{d}/package.nls.json")
                src_nls = load_json(nls_backup if os.path.exists(nls_backup) else nls_path, {})
                translated_nls = {}
                for k, en_v in src_nls.items():
                    if not isinstance(en_v, str):
                        translated_nls[k] = en_v
                        continue
                    if en_v in en_to_ja:
                        translated_nls[k] = en_to_ja[en_v]
                    elif is_japanese_or_symbol(en_v) or en_v in ja_values_set:
                        translated_nls[k] = en_v
                    else:
                        pending_set.add(en_v)
                        translated_nls[k] = heuristic_translate_fallback(en_v, ja_dict)
                if apply_changes:
                    save_json(nls_path, translated_nls)
                    save_json(nls_ja_path, translated_nls)
                    stats["user_extensions_updated"] += 1
                    stats["files_modified"].append(nls_path)
            elif os.path.exists(pkg_path):
                if apply_changes:
                    backup_file_once(pkg_path, f"user_exts/{d}/package.json")
                pkg_backup = os.path.join(BACKUP_DIR, f"user_exts/{d}/package.json")
                src_pkg = load_json(pkg_backup if os.path.exists(pkg_backup) else pkg_path, {})

                def translate_user_pkg(obj):
                    changed = False
                    if isinstance(obj, dict):
                        for k, v in list(obj.items()):
                            if k in ("displayName", "description", "markdownDescription", "title", "category", "label") and isinstance(v, str):
                                if v in en_to_ja:
                                    obj[k] = en_to_ja[v]
                                    changed = True
                                elif not (is_japanese_or_symbol(v) or v in ja_values_set):
                                    pending_set.add(v)
                                    obj[k] = heuristic_translate_fallback(v, ja_dict)
                                    changed = True
                            else:
                                if translate_user_pkg(v):
                                    changed = True
                    elif isinstance(obj, list):
                        for item in obj:
                            if translate_user_pkg(item):
                                changed = True
                    return changed

                if translate_user_pkg(src_pkg) and apply_changes:
                    save_json(pkg_path, src_pkg, indent="\t")
                    stats["user_extensions_updated"] += 1
                    stats["files_modified"].append(pkg_path)

    # =========================================================================
    # 6. argv.json の locale: "ja" 設定確認・適用
    # =========================================================================
    argv_data = load_jsonc_simple(paths["ide_argv"])
    if argv_data.get("locale") == "ja":
        stats["argv_locale_ja"] = True
    elif apply_changes:
        if os.path.exists(paths["ide_argv"]):
            backup_file_once(paths["ide_argv"], "user_argv/argv.json")
        argv_data["locale"] = "ja"
        save_json(paths["ide_argv"], argv_data, indent="\t")
        stats["argv_locale_ja"] = True
        stats["files_modified"].append(paths["ide_argv"])

    pending_list = sorted(pending_set)
    stats["untranslated_pending"] = pending_list
    save_json(PENDING_PATH, pending_list)

    return stats


def restore_backups(custom_app_dir: str = None) -> dict:
    """バックアップから元の英語設定ファイルを復元します。"""
    paths = get_antigravity_paths(custom_app_dir=custom_app_dir)
    restored = []

    mapping = [
        ("ide_out/nls.messages.json", os.path.join(paths["ide_out"], "nls.messages.json")),
        ("ide_app/product.json", paths["ide_product_json"]),
        ("roaming/languagepacks.json", paths["languagepacks_json"]),
        ("user_argv/argv.json", paths["ide_argv"]),
    ]
    if paths["lp_dir"]:
        mapping.append(("lp/main.i18n.json", os.path.join(paths["lp_dir"], "translations", "main.i18n.json")))

    for rel, target in mapping:
        b_path = os.path.join(BACKUP_DIR, rel)
        if os.path.exists(b_path) and target:
            shutil.copy2(b_path, target)
            restored.append(target)

    builtin_bdir = os.path.join(BACKUP_DIR, "builtin_exts")
    if os.path.exists(builtin_bdir):
        for ext in os.listdir(builtin_bdir):
            for fname in os.listdir(os.path.join(builtin_bdir, ext)):
                src = os.path.join(builtin_bdir, ext, fname)
                dst = os.path.join(paths["ide_exts_builtin"], ext, fname)
                if os.path.exists(src):
                    shutil.copy2(src, dst)
                    restored.append(dst)

    user_bdir = os.path.join(BACKUP_DIR, "user_exts")
    if os.path.exists(user_bdir):
        for ext in os.listdir(user_bdir):
            for fname in os.listdir(os.path.join(user_bdir, ext)):
                src = os.path.join(user_bdir, ext, fname)
                dst = os.path.join(paths["ide_exts_user"], ext, fname)
                if os.path.exists(src):
                    shutil.copy2(src, dst)
                    restored.append(dst)

    if os.path.exists(paths["clp_dir"]):
        shutil.rmtree(paths["clp_dir"], ignore_errors=True)

    return {"restored_count": len(restored), "restored_files": restored}


def main():
    parser = argparse.ArgumentParser(description="AntigravityJP 言語設定ファイル完全日本語化ツール (Windows / macOS / Linux)")
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--apply", action="store_true", help="すべての英語メッセージを日本語に翻訳して適用します (既定)")
    group.add_argument("--status", action="store_true", help="現在の翻訳状況を確認します")
    group.add_argument("--restore", action="store_true", help="バックアップから元のファイルを復元します")
    parser.add_argument("--app-dir", default=None, help="Antigravity IDE の resources/app パスを手動指定します")
    parser.add_argument("--json", action="store_true", help="結果を JSON 形式で出力します")
    args = parser.parse_args()

    if args.restore:
        res = restore_backups(custom_app_dir=args.app_dir)
        if args.json:
            print(json.dumps(res, ensure_ascii=False, indent=2))
        else:
            print(f"[AntigravityJP] バックアップから {res['restored_count']} 個のファイルを復元しました。")
        return

    apply_mode = not args.status
    stats = translate_or_check(apply_changes=apply_mode, custom_app_dir=args.app_dir)

    if args.json:
        print(json.dumps(stats, ensure_ascii=False, indent=2))
    else:
        print("=" * 68)
        print("  AntigravityJP - Antigravity 言語設定ファイル完全日本語化レポート")
        print("=" * 68)
        print(f"検出 OS / パス           : {stats['os']} ({stats['ide_app_path']})")
        print(f"実行モード               : {'翻訳適用 (--apply)' if apply_mode else 'ステータス確認 (--status)'}")
        print(f"コア総メッセージ数       : {stats['core_total_messages']:,} 件")
        pct = (stats["core_translated_messages"] / stats["core_total_messages"] * 100) if stats["core_total_messages"] else 0.0
        print(f"日本語化完了メッセージ数 : {stats['core_translated_messages']:,} / {stats['core_total_messages']:,} 件 ({pct:.1f}%)")
        print(f"Language Pack 追加キー数 : {stats['lp_missing_keys_added']:,} 件")
        print(f"組み込み拡張機能更新数   : {stats['builtin_extensions_updated']} 個")
        print(f"ユーザー拡張機能更新数   : {stats['user_extensions_updated']} 個")
        print(f"CLP キャッシュ生成・更新 : {'完了' if stats['clp_cache_updated'] else '未更新'}")
        print(f"argv.json ロケール設定   : {'ja (設定済み)' if stats['argv_locale_ja'] else '未設定'}")
        print(f"辞書未登録の新規メッセージ: {len(stats['untranslated_pending'])} 件")
        print("=" * 68)


if __name__ == "__main__":
    main()
