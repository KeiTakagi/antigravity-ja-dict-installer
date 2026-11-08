// Antigravity 日本語化パッチャー
// 実行: ELECTRON_RUN_AS_NODE=1 Antigravity.exe patcher.js [--restore] [--asar <path>]
// Antigravity 本体を Node として使うので、利用者の PC に Node が無くても動く。
// asar を展開・再パックせず、dist/preload.js と dist/main.js の新しい中身をデータ末尾に足してヘッダーだけ書き換える。
"use strict";
const fs = require("original-fs"); // 素の fs は asar を「フォルダ」として扱ってしまう
const path = require("path");
const crypto = require("crypto");
const os = require("os");

const VERSION = "1.4.4";
const MARKER_BASE = "Antigravity UI Japanese Localization Mod";
const MARKER = `${MARKER_BASE} v${VERSION}`;
const HERE = __dirname;
const IS_MAC = process.platform === "darwin";
const DATA_DIR = IS_MAC
  ? path.join(os.homedir(), "Library", "Application Support", "antigravity-ja")
  : path.join(process.env.LOCALAPPDATA || os.homedir(), "antigravity-ja");
const BLOCK = 4 * 1024 * 1024;

const args = process.argv.slice(2);
const restore = args.includes("--restore");
const asarArg = args.indexOf("--asar");
// Windows: <インストール先>\Antigravity.exe → resources\app.asar
// Mac: Antigravity.app/Contents/MacOS/Antigravity → Contents/Resources/app.asar（Mac は実機未確認）
const defaultAsar = IS_MAC
  ? path.join(path.dirname(process.execPath), "..", "Resources", "app.asar")
  : path.join(path.dirname(process.execPath), "resources", "app.asar");
const asarPath = asarArg >= 0 ? args[asarArg + 1] : defaultAsar;

function log(msg) {
  // 画面へは出さない（日本語版 Windows のコンソールは UTF-8 を文字化けさせる）。結果は呼び出し側が終了コードで見る
  const line = `[${new Date().toISOString()}] patcher: ${msg}`;
  try {
    fs.mkdirSync(DATA_DIR, { recursive: true });
    fs.appendFileSync(path.join(DATA_DIR, "patch.log"), line + "\n");
  } catch (e) { /* ログが書けなくても本処理は続ける */ }
}

function readArchive(file) {
  const buf = fs.readFileSync(file);
  const headerSize = buf.readUInt32LE(4);
  const strLen = buf.readUInt32LE(12);
  const header = JSON.parse(buf.toString("utf8", 16, 16 + strLen));
  const base = 8 + headerSize;
  return { buf, header, data: buf.subarray(base) };
}

function entry(header, p) {
  let node = header;
  for (const part of p.split("/")) {
    node = node.files && node.files[part];
    if (!node) throw new Error(`asar に ${p} がありません`);
  }
  return node;
}

function readRaw(arc, p) {
  const e = entry(arc.header, p);
  if (e.unpacked) throw new Error(`${p} は unpacked なので扱えません`);
  const off = Number(e.offset);
  return arc.data.subarray(off, off + e.size);
}

function readEntry(arc, p) {
  return readRaw(arc, p).toString("utf8");
}

function countFiles(node) {
  let n = 0;
  for (const k of Object.keys(node.files || {})) {
    n += 1 + countFiles(node.files[k]);
  }
  return n;
}

function integrity(buf) {
  const blocks = [];
  for (let i = 0; i < buf.length; i += BLOCK) {
    blocks.push(crypto.createHash("sha256").update(buf.subarray(i, i + BLOCK)).digest("hex"));
  }
  return { algorithm: "SHA256", hash: crypto.createHash("sha256").update(buf).digest("hex"), blockSize: BLOCK, blocks };
}

// 以前のパッチ（版違い・旧方式も含む）を剥がして元の中身に戻す
function stripMod(text) {
  const i = text.indexOf("\n// " + MARKER_BASE);
  return i >= 0 ? text.slice(0, i) : text;
}

// データ部を全ファイル分詰め直す。古い中身を残すと、見張り役のマーカー検索が「当たっている」と誤判定する
function buildArchive(arc, replacements) {
  const header = JSON.parse(JSON.stringify(arc.header));
  const chunks = [];
  let offset = 0;
  (function walk(node, prefix) {
    for (const name of Object.keys(node.files || {})) {
      const e = node.files[name];
      const p = prefix ? `${prefix}/${name}` : name;
      if (e.files) { walk(e, p); continue; }
      if (e.unpacked || e.link) continue;
      let body;
      if (p in replacements) {
        body = Buffer.from(replacements[p], "utf8");
        e.size = body.length;
        e.integrity = integrity(body);
      } else {
        const off = Number(e.offset);
        body = arc.data.subarray(off, off + e.size);
      }
      e.offset = String(offset);
      chunks.push(body);
      offset += body.length;
    }
  })(header, "");
  const str = Buffer.from(JSON.stringify(header), "utf8");
  const pad = (4 - (str.length % 4)) % 4;
  const headerPickle = Buffer.alloc(8 + str.length + pad);
  headerPickle.writeUInt32LE(4 + str.length + pad, 0);
  headerPickle.writeUInt32LE(str.length, 4);
  str.copy(headerPickle, 8);
  const sizePickle = Buffer.alloc(8);
  sizePickle.writeUInt32LE(4, 0);
  sizePickle.writeUInt32LE(headerPickle.length, 4);
  return Buffer.concat([sizePickle, headerPickle, ...chunks]);
}

// Electron の fuse で asar の改ざん検知が有効だと、書き換えた途端にアプリが起動しなくなる。その版では触らない
// （v2.18.1 は無効＝fuses "101100011" の5文字目が 0。2026-10-01 確認）
function asarIntegrityEnforced() {
  // fuse の置き場所は Windows が本体 exe、Mac が Electron Framework
  const bin = IS_MAC
    ? path.join(path.dirname(process.execPath), "..", "Frameworks", "Electron Framework.framework", "Electron Framework")
    : process.execPath;
  if (!fs.existsSync(bin)) return IS_MAC; // Mac で確かめられない時は、安全側に倒して書き換えない
  const exe = fs.readFileSync(bin);
  const i = exe.indexOf("dL7pKGdnNz796PbbjQWNKmHXBZaB9tsX");
  if (i < 0) return IS_MAC;
  const len = exe[i + 33];
  return len > 4 && exe[i + 34 + 4] === 0x31; // '1' = 有効
}

function main() {
  if (!fs.existsSync(asarPath)) throw new Error(`app.asar が見つかりません: ${asarPath}`);
  if (!restore && asarArg < 0 && asarIntegrityEnforced()) {
    throw new Error("この版の Antigravity は改ざん検知が有効なため、日本語化できません（書き換えると起動しなくなります）");
  }
  const arc = readArchive(asarPath);
  const preload = readEntry(arc, "dist/preload.js");
  const mainJs = readEntry(arc, "dist/main.js");
  const patchedNow = preload.includes(MARKER_BASE);

  if (!restore && preload.includes(MARKER)) {
    log(`既に v${VERSION} 適用済み（${asarPath}）`);
    return 0;
  }
  if (restore && !patchedNow) {
    log("パッチは当たっていません。何もしません");
    return 0;
  }

  // 未パッチの原本は、インストール先の外に控えておく（アップデートで resources ごと消えるため）
  if (!patchedNow) {
    fs.mkdirSync(path.join(DATA_DIR, "backup"), { recursive: true });
    fs.copyFileSync(asarPath, path.join(DATA_DIR, "backup", "app.asar"));
  }

  const origPreload = stripMod(preload);
  const origMain = stripMod(mainJs);
  let newPreload = origPreload;
  let newMain = origMain;
  if (!restore) {
    const header = `\n// ${MARKER}\n`;
    newPreload += header + fs.readFileSync(path.join(HERE, "i18n_module.js"), "utf8").replace(/^﻿/, "");
    newMain += header + fs.readFileSync(path.join(HERE, "main_hook.js"), "utf8").replace(/^﻿/, "");
  }

  const out = buildArchive(arc, { "dist/preload.js": newPreload, "dist/main.js": newMain });

  // 書いたものを読み直して、壊れていないことを確かめてから差し替える
  const tmp = asarPath + ".ja-tmp";
  fs.writeFileSync(tmp, out);
  const check = readArchive(tmp);
  const replaced = { "dist/preload.js": newPreload, "dist/main.js": newMain };
  let ok = countFiles(check.header) === countFiles(arc.header);
  (function walk(node, prefix) {
    for (const name of Object.keys(node.files || {})) {
      const e = node.files[name];
      const p = prefix ? `${prefix}/${name}` : name;
      if (e.files) { walk(e, p); continue; }
      if (e.unpacked || e.link) continue;
      const want = p in replaced ? Buffer.from(replaced[p], "utf8") : readRaw(arc, p);
      if (!readRaw(check, p).equals(want)) ok = false;
    }
  })(arc.header, "");
  if (!ok) {
    fs.unlinkSync(tmp);
    throw new Error("書き出した asar の検査に失敗しました。app.asar は触っていません");
  }
  try {
    fs.renameSync(tmp, asarPath);
  } catch (e) {
    fs.unlinkSync(tmp);
    throw new Error(`app.asar を差し替えられません（Antigravity が起動中の可能性）: ${e.code || e.message}`);
  }
  log(restore ? "元に戻しました" : `v${VERSION} を適用しました（${asarPath}）`);
  return 0;
}

try {
  process.exitCode = main();
} catch (e) {
  log("失敗: " + e.message);
  process.exitCode = 1;
}
