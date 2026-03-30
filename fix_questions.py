#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
修改论文中的疑问句，使其更加严谨
"""

import os
import re
import glob

def find_tex_files(directory):
    """查找所有TeX文件"""
    tex_files = glob.glob(os.path.join(directory, "*.tex"))
    return [f for f in tex_files if os.path.isfile(f)]

def fix_questions(content):
    """修改疑问句为陈述句"""
    # 定义疑问句模式及其对应的修改规则
    patterns = [
        # 以问号结尾的句子
        (r'([^。！？])\？\s*$', r'\1。'),
        (r'([^。！？])\?\s*$', r'\1。'),
        
        # 常见的疑问词替换
        (r'如何([^，。！？]+)[？?]', r'对\1进行探讨'),
        (r'如何([^，。！？]+)的', r'\1的'),
        (r'是否([^，。！？]+)[？?]', r'对\1进行检验'),
        (r'是否([^，。！？]+)的', r'\1的'),
        (r'能否([^，。！？]+)[？?]', r'对\1的可能性进行考察'),
        (r'能否([^，。！？]+)的', r'\1的'),
        (r'有没有([^，。！？]+)[？?]', r'对\1的存在性进行检验'),
        (r'有没有([^，。！？]+)的', r'\1的'),
        (r'是不是([^，。！？]+)[？?]', r'对\1进行验证'),
        (r'是不是([^，。！？]+)的', r'\1的'),
        (r'为什么([^，。！？]+)[？?]', r'对\1的原因进行探究'),
        (r'为什么([^，。！？]+)的', r'\1的'),
        (r'怎么([^，。！？]+)[？?]', r'对\1的机制进行分析'),
        (r'怎么([^，。！？]+)的', r'\1的'),
        
        # 直接疑问句改为陈述句
        (r'([^。！？]+)吗[？?]', r'对\1进行考察。'),
        (r'([^。！？]+)呢[？?]', r'对\1进行探讨。'),
        (r'([^。！？]+)吧[？?]', r'对\1进行分析。'),
        
        # 研究问题表述的优化
        (r'(研究问题[一二三四五六七八九十]+：)([^。！？]+)[？?]', r'\1对\2进行探究。'),
        (r'(RQ\d+：)([^。！？]+)[？?]', r'\1对\2进行探究。'),
        
        # 章节开头的疑问句
        (r'本章围绕([^。！？]+)[？?]', r'本章围绕\1展开研究。'),
        (r'本章聚焦([^。！？]+)[？?]', r'本章聚焦于\1的研究。'),
        
        # 理论框架中的疑问句
        (r'期望理论中的工具性维度关注一个核心判断："([^"]+)"[？?]', r'期望理论中的工具性维度关注一个核心判断："\1"。'),
        (r'核心挑战在于：([^。！？]+)[？?]', r'核心挑战在于\1。'),
    ]
    
    # 应用所有模式
    for pattern, replacement in patterns:
        content = re.sub(pattern, replacement, content)
    
    # 处理特定的疑问句式
    lines = content.split('\n')
    new_lines = []
    
    for line in lines:
        # 处理以疑问词开头的句子
        if re.match(r'^[ \t]*如何', line):
            line = re.sub(r'^([ \t]*)如何', r'\1对', line)
            if line.endswith('？'):
                line = line[:-1] + '进行探讨。'
            elif line.endswith('?'):
                line = line[:-1] + '进行探讨。'
        
        # 处理以"是否"开头的句子
        elif re.match(r'^[ \t]*是否', line):
            line = re.sub(r'^([ \t]*)是否', r'\1对', line)
            if line.endswith('？'):
                line = line[:-1] + '进行检验。'
            elif line.endswith('?'):
                line = line[:-1] + '进行检验。'
        
        # 处理以"能否"开头的句子
        elif re.match(r'^[ \t]*能否', line):
            line = re.sub(r'^([ \t]*)能否', r'\1对', line)
            if line.endswith('？'):
                line = line[:-1] + '的可能性进行考察。'
            elif line.endswith('?'):
                line = line[:-1] + '的可能性进行考察。'
        
        new_lines.append(line)
    
    return '\n'.join(new_lines)

def main():
    chapters_dir = "NJU/doc/linux/thesis/chapters"
    
    if not os.path.exists(chapters_dir):
        print(f"目录不存在: {chapters_dir}")
        return
    
    tex_files = find_tex_files(chapters_dir)
    print(f"找到 {len(tex_files)} 个TeX文件")
    
    modified_count = 0
    for filepath in tex_files:
        filename = os.path.basename(filepath)
        print(f"处理文件: {filename}")
        
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        new_content = fix_questions(content)
        
        if new_content != content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            modified_count += 1
            print(f"  ✓ 已修改")
        else:
            print(f"  - 无需修改")
    
    print(f"\n完成！修改了 {modified_count} 个文件")

if __name__ == "__main__":
    main()