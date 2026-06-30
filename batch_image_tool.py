"""
batch_image_tool.py

生成画像を「メタデータ削除 → 連番リネーム → リサイズ」して別フォルダに保存するツール。
SNS・支援サイト(Patreon等)の運営や、画像納品をスムーズに行うための前処理を想定。
PNG/EXIFに埋め込まれたプロンプト・モデル・LoRA等の情報を削除し、
原本フォルダには一切触れず output に出力する（安全）。

使い方:
  1. このファイルと同じ場所に input フォルダを作り、画像を入れる
  2. python batch_image_tool.py を実行する
  3. output フォルダに「メタデータ削除＋連番＋リサイズ済み」の画像ができる
"""

import os
from PIL import Image

# ===== 設定 =====
src = "input"                                   # 元画像フォルダ
dst = "output"                                  # 出力フォルダ
prefix = "asset"                                # 連番の接頭辞（asset_001.png）
max_size = 512                                  # 長辺の最大px（縦横比はキープ）
strip_metadata = True                           # メタデータを削除するか
image_exts = [".png", ".jpg", ".jpeg", ".webp"] # 対象の拡張子
# ================

os.makedirs(dst, exist_ok=True)

count = 0
for name in sorted(os.listdir(src)):
    ext = os.path.splitext(name)[1].lower()
    if ext in image_exts:
        count += 1
        new_name = f"{prefix}_{count:03d}{ext}"

        img = Image.open(os.path.join(src, name))
        img.thumbnail((max_size, max_size))

        if strip_metadata:
            clean = Image.new(img.mode, img.size)
            clean.paste(img)
            img = clean

        img.save(os.path.join(dst, new_name))
        print(f"{name}  ->  {new_name}  {img.size}")

print(f"\n完了：{count} 枚を「{dst}」に保存しました")
