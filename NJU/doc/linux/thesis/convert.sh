#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# LaTeX → Word 一键转换脚本
# 用法: ./convert.sh [tex文件名] [选项]
# 默认: ./convert.sh thesis_aigc.tex
# 选项: --keep-tmp  保留中间文件
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEX_FILE="${1:-thesis_aigc.tex}"
TEX_BASE="${TEX_FILE%.tex}"
TMP_DOCX="${TEX_BASE}_tmp.docx"
OUT_DOCX="${TEX_BASE}.docx"
KEEP_TMP=false

[[ "${2:-}" == "--keep-tmp" ]] && KEEP_TMP=true

# 颜色
red()  { echo -e "\033[31m$1\033[0m"; }
green(){ echo -e "\033[32m$1\033[0m"; }
cyan() { echo -e "\033[36m$1\033[0m"; }

die() { red "✗ $1"; exit 1; }

# ---------- 检查依赖 ----------
cyan "[1/4] 检查依赖..."
command -v pandoc           >/dev/null 2>&1 || die "需要 pandoc: apt install pandoc"
command -v pandoc-citeproc  >/dev/null 2>&1 || die "需要 pandoc-citeproc: apt install pandoc-citeproc"
python3 -c "import docx"   2>/dev/null    || die "需要 python-docx: pip3 install python-docx"
python3 -c "import lxml"   2>/dev/null    || die "需要 lxml: pip3 install lxml"
green "依赖检查通过"

# ---------- 检查文件 ----------
[[ -f "$TEX_FILE"       ]] || die "找不到 $TEX_FILE"
[[ -f "thesis.bib"      ]] || die "找不到 thesis.bib"
[[ -f "thesis-setup.def" ]] || die "找不到 thesis-setup.def"
[[ -f "format_docx.py"  ]] || die "找不到 format_docx.py"

# ---------- pandoc 转换 ----------
cyan "[2/4] pandoc 转换 LaTeX -> docx ..."
pandoc "$TEX_FILE" \
    --from=latex \
    --to=docx \
    --resource-path="$SCRIPT_DIR" \
    --bibliography=thesis.bib \
    --filter pandoc-citeproc \
    -o "$TMP_DOCX" 2>&1 | tail -5

[[ -f "$TMP_DOCX" ]] || die "pandoc 转换失败，未生成 $TMP_DOCX"
green "pandoc 转换完成"

# ---------- 格式处理 ----------
cyan "[3/4] 应用南京大学格式 + 清理引用..."
python3 "$SCRIPT_DIR/format_docx.py" "$TMP_DOCX" "$OUT_DOCX" --no-cover --clean-refs 2>&1

[[ -f "$OUT_DOCX" ]] || die "格式处理失败"
green "格式处理完成"

# ---------- 清理 ----------
if $KEEP_TMP; then
    cyan "[4/4] 保留中间文件: $TMP_DOCX"
else
    cyan "[4/4] 清理临时文件..."
    rm -f "$TMP_DOCX"
fi

# ---------- 结果 ----------
SIZE=$(du -h "$OUT_DOCX" | cut -f1)
echo ""
green "=========================================="
green "  转换完成 -> $OUT_DOCX ($SIZE)"
green "=========================================="
echo ""
echo "后续手动步骤:"
echo "  1. 从 PDF 截图封面粘贴到文档开头"
echo "  2. Word 中「引用」->「目录」自动生成"
echo "  3. 搜索【表【图 替换为实际编号"
echo "  4. 添加页眉（章标题/论文题目）"
