# NJU 论文模板使用说明

## 📁 当前目录结构

```
NJU/doc/tamplate/
├── .vscode/
│   └── settings.json          # VS Code 配置（已配置好）
├── njuthesis-sample.tex       # 主文档（你的论文内容）
├── njuthesis-setup.def        # 配置文件（个人信息）
├── njuthesis-sample.bib       # 参考文献数据库
├── njuthesis.cls              # 文档类（模板核心文件）
├── njuthesis-*.def            # 各类论文配置
├── nju-*.pdf                  # 校徽和校名图片
└── LICENSE                    # 许可证
```

## 🚀 快速开始

### 方法 1：使用 VS Code（推荐）

1. **打开项目文件夹**
   ```
   在 VS Code 中：
   文件 → 打开文件夹 → 选择：
   C:\Users\rhys\Desktop\Thesis\NJU\doc\tamplate
   ```

2. **编辑论文**
   - 打开 `njuthesis-sample.tex` 开始写作
   - 编辑 `njuthesis-setup.def` 修改个人信息

3. **编译论文**
   - 按 `Ctrl + S` 保存后自动编译
   - 或按 `Ctrl + Alt + B` 手动编译
   - 按 `Ctrl + Alt + V` 查看 PDF

### 方法 2：使用命令行

在当前目录下运行：

**快速编译（无参考文献）：**
```cmd
xelatex njuthesis-sample.tex
```

**完整编译（含参考文献）：**
```cmd
xelatex njuthesis-sample.tex
biber njuthesis-sample
xelatex njuthesis-sample.tex
xelatex njuthesis-sample.tex
```

**使用 latexmk（推荐）：**
```cmd
latexmk -xelatex njuthesis-sample.tex
```

## 📝 修改个人信息

编辑 `njuthesis-setup.def` 文件，修改以下内容：

```latex
\njusetup{
  info = {
    title = {你的论文标题},
    title* = {Your Thesis Title in English},
    author = {你的姓名},
    author* = {Your Name},
    student-id = {你的学号},
    department = {你的院系},
    major = {你的专业},
    field = {研究方向},
    advisor = {导师姓名},
    advisor* = {Advisor Name},
    % ... 更多选项见文件
  }
}
```

## 📖 编写论文内容

在 `njuthesis-sample.tex` 中编写：

### 1. 设置论文类型

```latex
\documentclass[
  type = bachelor,        % bachelor|master|doctor|postdoc
  degree = academic,      % academic|professional
]{njuthesis}
```

### 2. 编写章节

```latex
\chapter{第一章标题}

\section{第一节}
这里是正文内容...

\subsection{小节}
更多内容...
```

### 3. 插入图片

```latex
\begin{figure}[htbp]
  \centering
  \includegraphics[width=0.5\textwidth]{图片文件名}
  \caption{图片说明}
  \label{fig:label}
\end{figure}
```

### 4. 插入表格

```latex
\begin{table}[htbp]
  \centering
  \caption{表格标题}
  \label{tab:label}
  \begin{tabular}{ccc}
    \toprule
    列1 & 列2 & 列3 \\
    \midrule
    数据1 & 数据2 & 数据3 \\
    \bottomrule
  \end{tabular}
\end{table}
```

### 5. 添加参考文献

在 `njuthesis-sample.bib` 中添加：

```bibtex
@article{key2024,
  author = {作者名},
  title = {文章标题},
  journal = {期刊名},
  year = {2024},
}
```

在正文中引用：
```latex
\cite{key2024}
```

## 🎯 VS Code 快捷键

| 快捷键 | 功能 |
|--------|------|
| `Ctrl + S` | 保存并自动编译 |
| `Ctrl + Alt + B` | 手动编译 |
| `Ctrl + Alt + V` | 查看 PDF |
| `Ctrl + Alt + J` | 代码与 PDF 同步 |
| `Ctrl + Space` | 命令自动补全 |
| `Ctrl + /` | 注释/取消注释 |

## ⚠️ 重要提示

1. **必须使用 XeLaTeX 编译**（不是 pdfLaTeX）
2. **文件必须是 UTF-8 编码**
3. **首次编译需要等待 TeX Live 安装完成**
4. **包含参考文献时需要完整编译 4 次**（或使用 latexmk）

## 📂 文件说明

- **必须保留的文件**：
  - `njuthesis.cls` - 文档类文件
  - `njuthesis-*.def` - 配置文件
  - `nju-*.pdf` - 校徽和校名

- **可以修改的文件**：
  - `njuthesis-sample.tex` - 你的论文主文档
  - `njuthesis-setup.def` - 你的个人信息
  - `njuthesis-sample.bib` - 你的参考文献

- **编译生成的文件**（可以删除）：
  - `*.aux`, `*.log`, `*.out`, `*.toc` 等辅助文件
  - `njuthesis-sample.pdf` - 最终生成的论文

## 🔧 故障排除

### Q: 编译报错 "xelatex: command not found"

A: TeX Live 还未安装完成，请等待安装完成后再编译

### Q: 找不到字体

A: 确保使用的是 XeLaTeX 编译器，并且系统中安装了相应字体

### Q: 参考文献不显示

A: 需要完整编译流程：XeLaTeX → Biber → XeLaTeX → XeLaTeX

### Q: VS Code 中 PDF 不更新

A: 尝试关闭 PDF 预览标签页，然后重新按 `Ctrl + Alt + V`

## 📚 更多资源

- **NJU 模板文档**: http://mirrors.ctan.org/macros/unicodetex/latex/njuthesis/njuthesis.pdf
- **GitHub 仓库**: https://github.com/nju-lug/NJUThesis
- **LaTeX 教程**: https://www.overleaf.com/learn

## ✨ 开始写作

等待 TeX Live 安装完成后：

1. 用 VS Code 打开 `tamplate` 文件夹
2. 编辑 `njuthesis-sample.tex`
3. 按 `Ctrl + S` 保存
4. 按 `Ctrl + Alt + V` 查看 PDF

祝写作顺利！📝
