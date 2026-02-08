#!/usr/bin/env python3
"""
评论数据处理脚本
用途：将评论按周或按日汇总，生成面板数据

使用方法：
  python process_comments.py --mode weekly --output weekly_comment.xlsx
  python process_comments.py --mode daily --output daily_comment.xlsx
"""

import pandas as pd
import argparse
import sys
from pathlib import Path

def process_comments(input_file, output_file, mode='weekly', exclude_granted=False, years=None):
    """
    处理评论数据
    
    参数：
        input_file: 输入Excel文件路径
        output_file: 输出Excel文件路径
        mode: 'weekly' 或 'daily'，指定汇总方式
        exclude_granted: 是否排除获得资助的评论者
        years: 指定年份列表，例如 [2022, 2023]。如果为None，默认使用2022-2023
    """
    print(f"处理模式: {mode}")
    print(f"输入文件: {input_file}")
    print(f"输出文件: {output_file}")
    print(f"排除资助者: {exclude_granted}")
    
    # 1. 读取数据
    print("\n正在加载数据...")
    try:
        df = pd.read_excel(input_file)
        print(f"成功加载 {len(df)} 条评论记录")
    except Exception as e:
        print(f"错误：无法读取文件 {input_file}")
        print(f"详细信息: {e}")
        sys.exit(1)
    
    # 2. 转换时间格式
    print("\n正在解析时间...")
    df['Comment Time'] = pd.to_datetime(df['Comment Time'])
    
    # 3. 筛选指定年份的数据
    if years is None:
        years = [2022, 2023]
    
    print(f"\n正在筛选{'-'.join(map(str, sorted(years)))}年的数据...")
    df['Year'] = df['Comment Time'].dt.year
    df_filtered = df[df['Year'].isin(years)].copy()
    
    if df_filtered.empty:
        print(f"警告：未找到{'-'.join(map(str, sorted(years)))}年的数据！")
        return
    
    print(f"筛选后保留 {len(df_filtered)} 条评论记录")
    
    # 3.5. 如果需要，排除获得资助的评论者
    if exclude_granted:
        granted_commenters = [
            "0xB10C", "vincenzopalazzo", "dergoegge", "brunoerg",
            "fanquake", "adiabat", "stickies-v", "fjahr"
        ]
        print(f"\n正在排除获得资助的评论者: {', '.join(granted_commenters)}")
        before_count = len(df_filtered)
        df_filtered = df_filtered[~df_filtered['Commenter'].isin(granted_commenters)].copy()
        excluded_count = before_count - len(df_filtered)
        print(f"排除了 {excluded_count} 条评论记录")
        print(f"剩余 {len(df_filtered)} 条评论记录")
    
    # 4. 根据模式生成时间ID
    if mode == 'weekly':
        print("\n正在生成周ID...")
        # 使用 to_period('W') 生成周标识（周一作为一周开始）
        df_filtered['period'] = df_filtered['Comment Time'].dt.to_period('W')
        period_name = 'week_period'
        id_name = 'week_id'
        start_date_name = 'week_start_date'
    elif mode == 'daily':
        print("\n正在生成日ID...")
        # 使用 to_period('D') 生成日标识
        df_filtered['period'] = df_filtered['Comment Time'].dt.to_period('D')
        period_name = 'day_period'
        id_name = 'day_id'
        start_date_name = 'date'
    else:
        print(f"错误：不支持的模式 '{mode}'，请使用 'weekly' 或 'daily'")
        sys.exit(1)
    
    # 5. 聚合评论
    print("\n正在汇总评论...")
    # 确保 Comment 列是字符串，处理 NaN
    df_filtered['Comment'] = df_filtered['Comment'].fillna('').astype(str)
    
    # 按照 period 分组，将同一时间周期内所有开发者的评论用空格连接
    aggregated = df_filtered.groupby('period')['Comment'].apply(
        lambda x: ' '.join(x)
    ).reset_index()
    
    print(f"汇总后共 {len(aggregated)} 条记录")
    
    # 6. 生成指定年份的完整时间周期列表
    min_year = min(years)
    max_year = max(years)
    min_date = pd.Timestamp(f'{min_year}-01-01')
    max_date = pd.Timestamp(f'{max_year}-12-31')
    
    if mode == 'weekly':
        all_periods = pd.period_range(start=min_date, end=max_date, freq='W')
    else:  # daily
        all_periods = pd.period_range(start=min_date, end=max_date, freq='D')
    
    print(f"\n时间周期统计:")
    print(f"  时间周期数量: {len(all_periods)}")
    
    # 7. 创建完整的时间周期DataFrame
    print("\n正在创建完整时间周期结构...")
    result = pd.DataFrame({'period': all_periods})
    
    # 8. 合并聚合后的数据
    print("正在合并数据...")
    result = pd.merge(result, aggregated, on='period', how='left')
    
    # 9. 缺失数据的 Comment 设置为空字符串
    result['Comment'] = result['Comment'].fillna('')
    
    # 10. 格式化输出
    # 提取周期开始日期
    result[start_date_name] = result['period'].dt.start_time
    
    # 创建数字ID（从0开始）
    result[id_name] = range(len(result))
    
    # 整理列顺序
    final_columns = [id_name, start_date_name, 'Comment']
    result = result[final_columns]
    
    # 11. 保存结果
    print(f"\n正在保存结果到 {output_file}...")
    try:
        result.to_excel(output_file, index=False)
        print("✓ 保存成功！")
        print(f"\n输出文件信息:")
        print(f"  行数: {len(result)}")
        print(f"  列数: {len(result.columns)}")
        print(f"  非空评论数: {(result['Comment'] != '').sum()}")
    except Exception as e:
        print(f"错误：无法保存文件 {output_file}")
        print(f"详细信息: {e}")
        sys.exit(1)

def main():
    # 设置命令行参数解析
    parser = argparse.ArgumentParser(
        description='处理评论数据，按周或按日汇总',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  # 按周汇总（默认2022-2023年）
  python process_comments.py --mode weekly --output weekly_comment.xlsx
  
  # 按日汇总
  python process_comments.py --mode daily --output daily_comment.xlsx
  
  # 指定年份（单个年份）
  python process_comments.py --mode weekly --output weekly_2022.xlsx --years 2022
  
  # 指定年份（多个年份）
  python process_comments.py --mode weekly --output weekly_19_23.xlsx --years 2019 2020 2021 2022 2023
  
  # 指定输入文件
  python process_comments.py --input data.xlsx --mode weekly --output result.xlsx
        """
    )
    
    parser.add_argument(
        '--input',
        type=str,
        default='19-23issues.xlsx',
        help='输入Excel文件路径（默认: 19-23issues.xlsx）'
    )
    
    parser.add_argument(
        '--output',
        type=str,
        required=True,
        help='输出Excel文件路径（必需）'
    )
    
    parser.add_argument(
        '--mode',
        type=str,
        choices=['weekly', 'daily'],
        required=True,
        help='处理模式：weekly（按周）或 daily（按日）（必需）'
    )
    
    parser.add_argument(
        '--exclude_granted',
        action='store_true',
        help='排除获得资助的评论者（0xB10C, vincenzopalazzo, dergoegge, brunoerg, fanquake, adiabat, stickies-v, fjahr）'
    )
    
    parser.add_argument(
        '--years',
        type=int,
        nargs='+',
        default=None,
        help='指定要处理的年份，可以指定多个年份，例如：--years 2022 2023（默认: 2022 2023）'
    )
    
    args = parser.parse_args()
    
    # 检查输入文件是否存在
    input_path = Path(args.input)
    if not input_path.exists():
        print(f"错误：输入文件不存在: {args.input}")
        sys.exit(1)
    
    # 执行处理
    print("="*60)
    print("评论数据处理脚本")
    print("="*60)
    
    process_comments(args.input, args.output, args.mode, args.exclude_granted, args.years)
    
    print("\n" + "="*60)
    print("处理完成！")
    print("="*60)

if __name__ == "__main__":
    main()
