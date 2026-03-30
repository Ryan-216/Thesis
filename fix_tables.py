#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
优化LaTeX表格格式，解决换行不美观问题
"""

import os
import re
import glob

def find_tex_files(directory):
    """查找所有TeX文件"""
    tex_files = glob.glob(os.path.join(directory, "*.tex"))
    return [f for f in tex_files if os.path.isfile(f)]

def fix_table_format(content):
    """修复表格格式，减少不必要的换行"""
    lines = content.split('\n')
    new_lines = []
    i = 0
    in_table = False
    in_tabularx = False
    table_lines = []
    
    while i < len(lines):
        line = lines[i]
        
        # 检测表格开始
        if r'\begin{table}' in line:
            in_table = True
            table_lines = [line]
            i += 1
            continue
            
        # 检测表格结束
        if r'\end{table}' in line and in_table:
            table_lines.append(line)
            # 处理这个表格
            fixed_table = process_table(table_lines)
            new_lines.extend(fixed_table)
            in_table = False
            table_lines = []
            i += 1
            continue
            
        # 如果在表格中，收集行
        if in_table:
            table_lines.append(line)
            i += 1
            continue
            
        # 非表格行直接添加
        new_lines.append(line)
        i += 1
    
    return '\n'.join(new_lines)

def process_table(table_lines):
    """处理单个表格，优化格式"""
    # 检查是否有过长的行导致换行
    for i, line in enumerate(table_lines):
        # 对于包含URL或长描述的行，尝试优化
        if 'GH Archive' in line or 'X 平台' in line or 'Brink 官方网站' in line or 'Yahoo Finance' in line or 'Google Trends' in line:
            # 尝试将多行合并为一行
            if i+1 < len(table_lines) and table_lines[i+1].strip().startswith('&'):
                # 合并当前行和下一行
                table_lines[i] = table_lines[i].rstrip() + ' ' + table_lines[i+1].lstrip()
                table_lines[i+1] = ''
    
    # 移除空行
    table_lines = [line for line in table_lines if line.strip() != '']
    
    # 优化列宽设置
    for i, line in enumerate(table_lines):
        if r'\begin{tabularx}' in line:
            # 调整列宽设置
            # 将过窄的列宽适当增加
            line = re.sub(r'p\{2\.8cm\}', r'p{3.2cm}', line)
            line = re.sub(r'p\{3cm\}', r'p{3.5cm}', line)
            line = re.sub(r'p\{4\.2cm\}', r'p{4.5cm}', line)
            line = re.sub(r'p\{4\.5cm\}', r'p{5cm}', line)
            table_lines[i] = line
    
    return table_lines

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
        
        new_content = fix_table_format(content)
        
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