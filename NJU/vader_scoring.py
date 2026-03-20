"""
VADER Sentiment Analysis Script
对评论文本进行VADER情感分析，输出情感极性评分。
"""

import os
import re
import pandas as pd
from tqdm import tqdm
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer

# ================= 配置 =================
INPUT_FILE = "comment/weekly_comment_19_23.xlsx"
OUTPUT_DIR = "sentiment_result/VADER"
OUTPUT_FILE = os.path.join(OUTPUT_DIR, "weekly_comment_19_23_sentiment_score.xlsx")


def preprocess_text(text):
    """
    文本预处理：去除代码块、URL、@提及等噪声
    """
    if not isinstance(text, str) or not text.strip():
        return ""
    # 去除代码块（```...```）
    text = re.sub(r'```[\s\S]*?```', '', text)
    # 去除行内代码（`...`）
    text = re.sub(r'`[^`]*`', '', text)
    # 去除URL
    text = re.sub(r'https?://\S+', '', text)
    # 去除@提及
    text = re.sub(r'@\w+', '', text)
    # 去除HTML标签
    text = re.sub(r'<[^>]+>', '', text)
    # 去除多余空白
    text = re.sub(r'\s+', ' ', text).strip()
    return text


def split_comments(text):
    """
    将一周合并的评论文本拆分为单条评论，逐条打分后取均值。
    GitHub评论通常以换行符分隔。
    """
    if not text:
        return []
    # 按双换行或长分隔线拆分
    parts = re.split(r'\n{2,}|(?:^|\n)-{3,}(?:\n|$)', text)
    # 过滤过短的片段（少于5个词）
    return [p.strip() for p in parts if len(p.split()) >= 5]


def score_weekly_text(analyzer, raw_text):
    """
    对一周的评论文本进行VADER评分。
    策略：将文本拆分为段落，逐段打分，返回compound分数的均值。
    """
    cleaned = preprocess_text(raw_text)
    segments = split_comments(cleaned)

    if not segments:
        # 如果拆分后无有效段落，直接对整段打分
        if cleaned and len(cleaned.split()) >= 3:
            scores = analyzer.polarity_scores(cleaned)
            return scores['compound'], scores['pos'], scores['neg'], scores['neu'], 1
        return None, None, None, None, 0

    compounds = []
    positives = []
    negatives = []
    neutrals = []
    for seg in segments:
        scores = analyzer.polarity_scores(seg)
        compounds.append(scores['compound'])
        positives.append(scores['pos'])
        negatives.append(scores['neg'])
        neutrals.append(scores['neu'])

    n = len(compounds)
    return (
        sum(compounds) / n,
        sum(positives) / n,
        sum(negatives) / n,
        sum(neutrals) / n,
        n
    )


def compound_to_polarity9(compound):
    """
    将VADER compound分数（-1到1）线性映射到九分制（1到9）。
    compound=-1 → 1, compound=0 → 5, compound=1 → 9
    """
    if compound is None:
        return None
    return round(compound * 4 + 5, 4)


def main():
    print(f"Loading data from {INPUT_FILE}...")
    df = pd.read_excel(INPUT_FILE, keep_default_na=False)
    print(f"Total rows: {len(df)}, Columns: {df.columns.tolist()}")

    # 查找评论列
    comment_col = None
    for col in ['Comment', 'comment', 'text', 'Text', 'content', 'Content']:
        if col in df.columns:
            comment_col = col
            break
    if comment_col is None:
        raise ValueError(f"Cannot find comment column. Available: {df.columns.tolist()}")
    print(f"Comment column: '{comment_col}'")

    # 初始化VADER
    analyzer = SentimentIntensityAnalyzer()

    # 逐行评分
    results = []
    for _, row in tqdm(df.iterrows(), total=len(df), desc="VADER Scoring"):
        raw_text = str(row[comment_col])
        compound, pos, neg, neu, n_segments = score_weekly_text(analyzer, raw_text)
        polarity9 = compound_to_polarity9(compound)
        results.append({
            'compound': compound,
            'positive': pos,
            'negative': neg,
            'neutral': neu,
            'polarity_9scale': polarity9,
            'n_segments': n_segments
        })

    result_df = pd.DataFrame(results)
    output_df = pd.concat([df, result_df], axis=1)

    # 保存结果
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    output_df.to_excel(OUTPUT_FILE, index=False)
    print(f"\nDone! Output saved to: {OUTPUT_FILE}")
    print(f"  Rows scored: {result_df['compound'].notna().sum()} / {len(df)}")
    print(f"  Mean compound: {result_df['compound'].mean():.4f}")
    print(f"  Mean polarity (9-scale): {result_df['polarity_9scale'].mean():.4f}")
    print(f"  Median segments per week: {result_df['n_segments'].median():.0f}")


if __name__ == "__main__":
    main()
