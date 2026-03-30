#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
处理LaTeX章节文件中的中英文对照格式
只在第一次出现时保留"中文（英文）"格式，后续出现时只保留中文
"""

import os
import re
import glob
from pathlib import Path

def find_chapters(directory):
    """查找所有章节文件"""
    tex_files = glob.glob(os.path.join(directory, "*.tex"))
    return [f for f in tex_files if os.path.isfile(f)]

def extract_chinese_english_pairs(text):
    """从文本中提取所有中英文对照对"""
    # 匹配中文后跟括号内的英文（支持中文括号和英文括号）
    pattern = r'([\u4e00-\u9fa5]+)[（(]([A-Za-z\s,;:\-]+)[）)]'
    matches = re.findall(pattern, text)
    
    # 转换为字典：中文 -> 英文
    pairs = {}
    for chinese, english in matches:
        # 清理英文中的多余空格
        english_clean = ' '.join(english.strip().split())
        pairs[chinese] = english_clean
    
    return pairs

def process_file(filepath, first_occurrence_map):
    """处理单个文件，替换中英文对照"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 用于跟踪本文件中已经处理过的术语
    processed_in_file = set()
    new_content = content
    
    # 找到所有匹配
    pattern = r'([\u4e00-\u9fa5]+)[（(]([A-Za-z\s,;:\-]+)[）)]'
    
    def replace_match(match):
        chinese = match.group(1)
        english = match.group(2)
        
        # 检查是否是第一次出现（全局）
        if chinese not in first_occurrence_map:
            # 第一次出现，记录并保留完整格式
            first_occurrence_map[chinese] = english
            processed_in_file.add(chinese)
            return match.group(0)  # 保留原格式
        elif chinese in processed_in_file:
            # 本文件中已经处理过，只保留中文
            return chinese
        else:
            # 全局不是第一次，但本文件是第一次出现
            processed_in_file.add(chinese)
            # 只保留中文
            return chinese
    
    # 执行替换
    new_content = re.sub(pattern, replace_match, new_content)
    
    # 写回文件
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        return True
    return False

def main():
    chapters_dir = "NJU/doc/linux/thesis/chapters"
    
    if not os.path.exists(chapters_dir):
        print(f"目录不存在: {chapters_dir}")
        return
    
    chapter_files = find_chapters(chapters_dir)
    print(f"找到 {len(chapter_files)} 个章节文件")
    
    # 按章节顺序处理文件（假设按数字顺序）
    chapter_files.sort()
    
    # 全局跟踪第一次出现
    first_occurrence_map = {}
    
    # 先扫描所有文件，建立全局第一次出现映射
    print("扫描所有文件建立术语映射...")
    for filepath in chapter_files:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        pairs = extract_chinese_english_pairs(content)
        for chinese, english in pairs.items():
            if chinese not in first_occurrence_map:
                first_occurrence_map[chinese] = english
    
    print(f"找到 {len(first_occurrence_map)} 个唯一的中英文术语")
    
    # 处理每个文件
    modified_count = 0
    for filepath in chapter_files:
        filename = os.path.basename(filepath)
        print(f"处理文件: {filename}")
        
        if process_file(filepath, first_occurrence_map):
            modified_count += 1
            print(f"  ✓ 已修改")
        else:
            print(f"  - 无需修改")
    
    print(f"\n完成！修改了 {modified_count} 个文件")
    
    # 输出术语表
    print("\n术语表（中文 -> 英文）：")
    for chinese, english in sorted(first_occurrence_map.items()):
        print(f"  {chinese} -> {english}")

if __name__ == "__main__":
    main()