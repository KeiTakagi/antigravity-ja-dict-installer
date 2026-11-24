
// main.js の末尾に追記される。サンドボックス preload はファイルを読めないので、カスタム辞書は main プロセスが渡す
try {
  const { ipcMain, BrowserWindow, webContents } = require("electron");
  const fs = require("fs");
  const path = require("path");
  const os = require("os");
  const dir = path.join(os.homedir(), ".gemini", "antigravity");
  const file = path.join(dir, "i18n_dict.json");
  const readDict = () => {
    try {
      // メモ帳や PowerShell で保存すると BOM が付き、JSON.parse が落ちる
      return fs.existsSync(file) ? JSON.parse(fs.readFileSync(file, "utf-8").replace(/^\ufeff/, "")) : {};
    } catch (e) {
      console.error("[Antigravity-i18n] Failed to read custom dictionary:", e);
      return null; // 書きかけの壊れた JSON では画面を更新しない
    }
  };
  ipcMain.handle("i18n:get-dict", () => readDict() || {});

  // 辞書が書き換わったら、WebContentsView を含むすべての開いている画面へその場で配る
  let timer = null;
  const push = () => {
    const dict = readDict();
    if (!dict) return;
    const sent = new Set();
    if (webContents && typeof webContents.getAllWebContents === "function") {
      for (const wc of webContents.getAllWebContents()) {
        if (!wc.isDestroyed()) {
          sent.add(wc.id);
          wc.send("i18n:dict-updated", dict);
        }
      }
    }
    for (const w of BrowserWindow.getAllWindows()) {
      if (!w.isDestroyed() && w.webContents && !sent.has(w.webContents.id)) {
        w.webContents.send("i18n:dict-updated", dict);
      }
    }
  };
  fs.mkdirSync(dir, { recursive: true });
  fs.watch(dir, (event, name) => {
    if (name && name !== "i18n_dict.json") return;
    clearTimeout(timer);
    timer = setTimeout(push, 300);
  });
} catch (e) {
  console.error("[Antigravity-i18n] main hook error:", e);
}
