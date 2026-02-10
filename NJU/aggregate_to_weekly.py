#!/usr/bin/env python3
"""
日度数据汇总为周数据脚本
用途：将日度比特币事件数据按周汇总

使用方法：
  python aggregate_to_weekly.py --input 19_23_bitcoin_evnet_by_time.xlsx --output weekly_bitcoin_event.xlsx
"""

import pandas as pd
import argparse
import sys
from pathlib import Path

def aggregate_to_weekly(input_file, output_file):
    """
    将日度数据汇总为周数据
    
    参数：
        input_file: 输入Excel文件路径（日度数据）
        output_file: 输出Excel文件路径（周数据）
    """
    print(f"输入文件: {input_file}")
    print(f"输出文件: {output_file}")
    
    # 1. 读取数据
    print("\n正在加载数据...")
    try:
        df = pd.read_excel(input_file)
        print(f"成功加载 {len(df)} 条日度记录")
    except Exception as e:
        print(f"错误：无法读取文件 {input_file}")
        print(f"详细信息: {e}")
        sys.exit(1)
    
    # 2. 转换时间格式
    print("\n正在解析时间...")
    df['Created_at'] = pd.to_datetime(df['Created_at'])
    
    # 3. 按日期排序（确保数据按时间顺序）
    df = df.sort_values('Created_at').reset_index(drop=True)
    
    # 4. 生成周标识（周一作为一周开始）
    print("\n正在生成周标识...")
    df['week_period'] = df['Created_at'].dt.to_period('W')
    
    # 5. 定义需要汇总的事件列（所有事件类型列）
    event_columns = [
        'CommitCommentEvent', 'CreateEvent', 'DeleteEvent', 'ForkEvent',
        'IssueCommentEvent', 'IssuesEvent', 'PullRequestEvent',
        'PullRequestReviewCommentEvent', 'PushEvent', 'ReleaseEvent',
        'WatchEvent', 'PullRequestReviewEvent'
    ]
    
    # 6. 定义聚合规则
    print("\n正在汇总数据...")
    agg_dict = {}
    
    # 事件列：求和
    for col in event_columns:
        if col in df.columns:
            agg_dict[col] = 'sum'
    
    # Open: 取周开始日期的值（第一个值）
    agg_dict['Open'] = 'first'
    
    # Close: 取周结束日期的值（最后一个值）
    agg_dict['Close'] = 'last'
    
    # High: 取周最大值
    agg_dict['High'] = 'max'
    
    # Low: 取周最小值
    agg_dict['Low'] = 'min'
    
    # Adj Close: 取周结束日期的值（最后一个值）
    agg_dict['Adj Close'] = 'last'
    
    # Volume: 求和
    agg_dict['Volume'] = 'sum'
    
    # 7. 按周分组并聚合
    weekly_df = df.groupby('week_period').agg(agg_dict).reset_index()
    
    print(f"汇总后共 {len(weekly_df)} 条周度记录")
    
    # 8. 添加周开始日期列
    weekly_df['week_start_date'] = weekly_df['week_period'].dt.start_time
    
    # 9. 添加周ID
    weekly_df['week_id'] = range(len(weekly_df))
    
    # 10. 整理列顺序
    final_columns = ['week_id', 'week_start_date'] + event_columns + ['Open', 'High', 'Low', 'Close', 'Adj Close', 'Volume']
    weekly_df = weekly_df[final_columns]
    
    # 11. 保存结果
    print(f"\n正在保存结果到 {output_file}...")
    try:
        weekly_df.to_excel(output_file, index=False)
        print("✓ 保存成功！")
        print(f"\n输出文件信息:")
        print(f"  周数: {len(weekly_df)}")
        print(f"  列数: {len(weekly_df.columns)}")
        print(f"  时间范围: {weekly_df['week_start_date'].min()} 至 {weekly_df['week_start_date'].max()}")
        
        # 显示前几行数据示例
        print(f"\n前5行数据预览:")
        print(weekly_df.head().to_string())
        
    except Exception as e:
        print(f"错误：无法保存文件 {output_file}")
        print(f"详细信息: {e}")
        sys.exit(1)

def main():
    # 设置命令行参数解析
    parser = argparse.ArgumentParser(
        description='将日度比特币事件数据汇总为周数据',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  # 基本用法
  python aggregate_to_weekly.py --input 19_23_bitcoin_evnet_by_time.xlsx --output weekly_bitcoin_event.xlsx
  
  # 使用默认输入文件
  python aggregate_to_weekly.py --output weekly_bitcoin_event.xlsx
        """
    )
    
    parser.add_argument(
        '--input',
        type=str,
        default='contribution&sentiment/19_23_bitcoin_evnet_by_time.xlsx',
        help='输入Excel文件路径（默认: contribution&sentiment/19_23_bitcoin_evnet_by_time.xlsx）'
    )
    
    parser.add_argument(
        '--output',
        type=str,
        required=True,
        help='输出Excel文件路径（必需）'
    )
    
    args = parser.parse_args()
    
    # 检查输入文件是否存在
    input_path = Path(args.input)
    if not input_path.exists():
        print(f"错误：输入文件不存在: {args.input}")
        sys.exit(1)
    
    # 执行处理
    print("="*60)
    print("日度数据汇总为周数据脚本")
    print("="*60)
    
    aggregate_to_weekly(args.input, args.output)
    
    print("\n" + "="*60)
    print("处理完成！")
    print("="*60)

if __name__ == "__main__":
    main()
