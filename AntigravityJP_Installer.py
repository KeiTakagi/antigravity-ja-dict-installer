#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Antigravity 日本語化インストーラー (antigravity-ja-dict-installer) Ver1.2.1
==========================================================================
Windows / macOS / Linux マルチプラットフォーム対応
Google Antigravity デスクトップアプリ (v2.35.0 動作確認済み) のメニュー・設定画面・UI
（全 1,279 項目）を常駐プロセスなし（CPU/メモリ消費ゼロ）でワンクリック日本語化します。
※ Antigravity IDE (VS Code エディタ版) の設定は変更しません（完全除外）。
"""

import argparse
import os
import platform
import subprocess
import sys
from pathlib import Path

APP_VERSION = "1.2.1"
CURRENT_OS = platform.system()
SCRIPT_DIR = Path(__file__).resolve().parent


def run_translation(mode: str = "--apply", app_dir: str | None = None, log_callback=None) -> tuple[int, str]:
    if CURRENT_OS == "Windows":
        ps1 = SCRIPT_DIR / ("uninstall-windows.ps1" if mode == "--restore" else "install-windows.ps1")
        cmd = ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(ps1)]
        if mode == "--status":
            cmd.append("-Status")
        elif mode == "--apply":
            cmd.append("-Silent")
    else:
        sh_script = SCRIPT_DIR / ("uninstall-linux.sh" if mode == "--restore" else "install-linux.sh")
        cmd = ["/bin/bash", str(sh_script)]
        if mode == "--status":
            cmd.append("--status")

    if log_callback:
        log_callback(f"[Installer] 実行中: {' '.join(cmd)}")

    env = os.environ.copy()
    env["PYTHONIOENCODING"] = "utf-8"

    creationflags = 0
    if CURRENT_OS == "Windows":
        creationflags = getattr(subprocess, "CREATE_NO_WINDOW", 0)

    proc = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        env=env,
        creationflags=creationflags,
    )
    out = (proc.stdout or "") + ("\n" + proc.stderr if proc.stderr else "")
    if log_callback:
        for line in out.strip().splitlines():
            log_callback(line)
    return proc.returncode, out


def can_use_gui() -> bool:
    if CURRENT_OS == "Linux" and not (os.environ.get("DISPLAY") or os.environ.get("WAYLAND_DISPLAY")):
        return False
    try:
        import tkinter  # noqa: F401
        return True
    except Exception:
        return False


def launch_cli_interactive(default_app_dir: str | None = None) -> int:
    print("=" * 68)
    print(f"  Antigravity 日本語化インストーラー Ver{APP_VERSION} ({CURRENT_OS})")
    print("=" * 68)
    while True:
        print("\n実行したい操作を選択してください:")
        print("  [1] 日本語化を適用する (推奨)")
        print("  [2] 現在の日本語化ステータスを確認する")
        print("  [3] 公式の英語環境へ復元 (アンインストール)")
        print("  [0] 終了")
        try:
            choice = input("\n番号を入力 [1]: ").strip() or "1"
        except (EOFError, KeyboardInterrupt):
            print("\n終了します。")
            return 0

        if choice == "0":
            return 0
        elif choice == "1":
            code, _ = run_translation("--apply", app_dir=default_app_dir, log_callback=print)
            if code == 0:
                print("\n[完了] 日本語化が完了しました。Antigravity を再起動すると反映されます。")
            return code
        elif choice == "2":
            run_translation("--status", app_dir=default_app_dir, log_callback=print)
        elif choice == "3":
            code, _ = run_translation("--restore", app_dir=default_app_dir, log_callback=print)
            if code == 0:
                print("\n[完了] 公式の英語状態へ復元しました。")
            return code


def launch_gui(default_app_dir: str | None = None) -> int:
    import threading
    import tkinter as tk
    from tkinter import messagebox, scrolledtext, ttk

    root = tk.Tk()
    root.title(f"Antigravity 日本語化インストーラー Ver{APP_VERSION} ({CURRENT_OS})")
    root.geometry("760x540")
    root.minsize(680, 480)
    root.configure(bg="#1e1e2e")

    header_frame = tk.Frame(root, bg="#181825", padx=20, pady=14)
    header_frame.pack(fill=tk.X)

    tk.Label(
        header_frame,
        text=f"Antigravity 日本語化インストーラー Ver{APP_VERSION}",
        font=("Yu Gothic UI", 15, "bold"),
        fg="#cdd6f4",
        bg="#181825",
        anchor="w",
    ).pack(fill=tk.X)

    tk.Label(
        header_frame,
        text="Antigravity デスクトップアプリ (v2.35.0 対応) のメニュー・設定・UI を 100% 日本語化します（常駐なし）",
        font=("Yu Gothic UI", 9),
        fg="#a6adc8",
        bg="#181825",
        anchor="w",
    ).pack(fill=tk.X, pady=(4, 0))

    body_frame = tk.Frame(root, bg="#1e1e2e", padx=20, pady=10)
    body_frame.pack(fill=tk.BOTH, expand=True)

    tk.Label(
        body_frame,
        text="実行ログ:",
        font=("Yu Gothic UI", 9, "bold"),
        fg="#cdd6f4",
        bg="#1e1e2e",
        anchor="w",
    ).pack(fill=tk.X, pady=(4, 4))

    log_box = scrolledtext.ScrolledText(
        body_frame,
        font=("Consolas", 9),
        bg="#11111b",
        fg="#a6e3a1",
        insertbackground="#cdd6f4",
        relief=tk.FLAT,
        height=14,
    )
    log_box.pack(fill=tk.BOTH, expand=True)

    progress = ttk.Progressbar(body_frame, mode="indeterminate")
    progress.pack(fill=tk.X, pady=(8, 4))

    def append_log(msg: str):
        def _do():
            log_box.insert(tk.END, msg + "\n")
            log_box.see(tk.END)
        root.after(0, _do)

    append_log(f"Antigravity 日本語化インストーラー Ver{APP_VERSION} へようこそ。")
    append_log("下の「日本語化を実行」ボタンを押すと、Antigravity デスクトップアプリに日本語化パッチと辞書（1,279項目）を適用します。")
    append_log("※ Antigravity IDE (VS Code エディタ版) の設定は変更しません。常駐プロセスも作成しません。")
    append_log("-" * 64)

    btn_frame = tk.Frame(root, bg="#181825", padx=20, pady=12)
    btn_frame.pack(fill=tk.X, side=tk.BOTTOM)

    buttons: list[tk.Button] = []

    def set_busy(busy: bool):
        def _do():
            if busy:
                progress.start(12)
                for b in buttons:
                    b.configure(state=tk.DISABLED)
            else:
                progress.stop()
                for b in buttons:
                    b.configure(state=tk.NORMAL)
        root.after(0, _do)

    def on_install():
        def worker():
            set_busy(True)
            try:
                code, _ = run_translation("--apply", app_dir=default_app_dir, log_callback=append_log)
                if code == 0:
                    root.after(
                        0,
                        lambda: messagebox.showinfo(
                            "日本語化完了",
                            "Antigravity デスクトップアプリの日本語化セットアップが完了しました！\n\n"
                            "Antigravity を起動（または再起動）すると日本語表示が反映されます。",
                        ),
                    )
                else:
                    root.after(0, lambda: messagebox.showerror("エラー", "適用中にエラーが発生しました。ログを確認してください。"))
            finally:
                set_busy(False)
        threading.Thread(target=worker, daemon=True).start()

    def on_status():
        def worker():
            set_busy(True)
            try:
                run_translation("--status", app_dir=default_app_dir, log_callback=append_log)
            finally:
                set_busy(False)
        threading.Thread(target=worker, daemon=True).start()

    def on_restore():
        if not messagebox.askyesno("復元確認", "Antigravity デスクトップアプリを公式の英語状態へ復元しますか？"):
            return
        def worker():
            set_busy(True)
            try:
                code, _ = run_translation("--restore", app_dir=default_app_dir, log_callback=append_log)
                if code == 0:
                    root.after(0, lambda: messagebox.showinfo("復元完了", "公式の英語状態への復元が完了しました。"))
            finally:
                set_busy(False)
        threading.Thread(target=worker, daemon=True).start()

    btn_install = tk.Button(
        btn_frame,
        text="日本語化を実行 (推奨)",
        command=on_install,
        bg="#89b4fa",
        fg="#11111b",
        activebackground="#b4befe",
        font=("Yu Gothic UI", 10, "bold"),
        relief=tk.FLAT,
        padx=18,
        pady=6,
        cursor="hand2",
    )
    btn_install.pack(side=tk.RIGHT, padx=(8, 0))

    btn_status = tk.Button(
        btn_frame,
        text="ステータス確認",
        command=on_status,
        bg="#313244",
        fg="#cdd6f4",
        font=("Yu Gothic UI", 9),
        relief=tk.FLAT,
        padx=12,
        pady=6,
    )
    btn_status.pack(side=tk.LEFT, padx=(0, 8))

    btn_restore = tk.Button(
        btn_frame,
        text="英語に復元 (アンインストール)",
        command=on_restore,
        bg="#45475a",
        fg="#f38ba8",
        font=("Yu Gothic UI", 9),
        relief=tk.FLAT,
        padx=12,
        pady=6,
    )
    btn_restore.pack(side=tk.LEFT)

    buttons.extend([btn_install, btn_status, btn_restore])
    root.mainloop()
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Antigravity 日本語化インストーラー Ver1.2.1 (Windows / macOS / Linux)")
    parser.add_argument("--silent", action="store_true", help="GUI を表示せず自動で日本語化を適用する")
    parser.add_argument("--cli", action="store_true", help="対話型 CLI メニューで起動する")
    parser.add_argument("--status", action="store_true", help="現在の日本語化状況を確認する")
    parser.add_argument("--restore", "--uninstall", action="store_true", dest="restore", help="公式の英語状態へ復元する")
    parser.add_argument("--app-dir", type=str, default=None, help="Antigravity のインストールディレクトリを明示指定する")
    args = parser.parse_args()

    if args.status:
        code, _ = run_translation("--status", app_dir=args.app_dir, log_callback=print)
        return code

    if args.restore:
        code, _ = run_translation("--restore", app_dir=args.app_dir, log_callback=print)
        return code

    if args.silent:
        print("=" * 68)
        print(f"  Antigravity 日本語化インストーラー Ver{APP_VERSION} ({CURRENT_OS})")
        print("=" * 68)
        code, _ = run_translation("--apply", app_dir=args.app_dir, log_callback=print)
        return code

    if args.cli or not can_use_gui():
        return launch_cli_interactive(default_app_dir=args.app_dir)

    return launch_gui(default_app_dir=args.app_dir)


if __name__ == "__main__":
    sys.exit(main())
