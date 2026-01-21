import pandas as pd
import numpy as np

# 文件路径
input_file = 'BitcoinDonation/260116/19-23issues.xlsx'
output_file = 'BitcoinDonation/260116/weekly_comments_panel_22_23.xlsx'

def process_data():
    print("Loading data...")
    df = pd.read_excel(input_file)
    
    # 转换时间格式
    print("Parsing dates...")
    df['Comment Time'] = pd.to_datetime(df['Comment Time'])
    
    # 筛选2022和2023年的数据
    print("Filtering for years 2022 and 2023...")
    # 确保时间是UTC或者去除时区信息以便比较，这里假设都是UTC
    # 提取年份
    df['Year'] = df['Comment Time'].dt.year
    df_filtered = df[df['Year'].isin([2022, 2023])].copy()
    
    if df_filtered.empty:
        print("No data found for 2022 and 2023.")
        return

    # 生成周ID
    # 使用 to_period('W') 生成周标识 (例如: 2022-01-03/2022-01-09)
    # 默认周一作为一周开始
    print("Generating week IDs...")
    df_filtered['week_period'] = df_filtered['Comment Time'].dt.to_period('W')
    
    # 聚合评论
    # 按照 Commenter 和 week_period 分组，将 Comment 文本拼接
    print("Aggregating comments...")
    # 先处理Comment列，确保是字符串，处理NaN
    df_filtered['Comment'] = df_filtered['Comment'].fillna('').astype(str)
    
    # 聚合函数：用空格连接同一周的评论
    aggregated = df_filtered.groupby(['Commenter', 'week_period'])['Comment'].apply(lambda x: ' '.join(x)).reset_index()
    
    # 构建面板数据 (Panel Data)
    # 1. 获取所有唯一的 Commenter
    unique_commenters = df_filtered['Commenter'].unique()
    
    # 2. 生成 2022-2023 的完整周列表
    # 范围从 2022年初 到 2023年末
    min_date = pd.Timestamp('2022-01-01')
    max_date = pd.Timestamp('2023-12-31')
    all_weeks = pd.period_range(start=min_date, end=max_date, freq='W')
    
    print(f"Total unique commenters: {len(unique_commenters)}")
    print(f"Total weeks: {len(all_weeks)}")
    
    # 3. 创建笛卡尔积 (Commenter x Week)
    print("Creating full panel structure...")
    multi_index = pd.MultiIndex.from_product([unique_commenters, all_weeks], names=['Commenter', 'week_period'])
    panel_df = pd.DataFrame(index=multi_index).reset_index()
    
    # 4. 合并聚合后的数据
    print("Merging data...")
    result = pd.merge(panel_df, aggregated, on=['Commenter', 'week_period'], how='left')
    
    # 5. 缺失数据 Comment 设置为空字符串
    result['Comment'] = result['Comment'].fillna('')
    
    # 格式化输出
    # 将 week_period 转换为字符串或开始日期以便保存
    result['week_start_date'] = result['week_period'].dt.start_time
    
    # week id用数字替换，从0开始
    # 创建周到ID的映射
    week_to_id = {week: i for i, week in enumerate(all_weeks)}
    result['week_id'] = result['week_period'].map(week_to_id)
    
    # 整理列顺序
    final_columns = ['Commenter', 'week_id', 'week_start_date', 'Comment']
    result = result[final_columns]
    
    # 保存结果
    print(f"Saving result to {output_file}...")
    result.to_excel(output_file, index=False)
    print("Done.")

if __name__ == "__main__":
    process_data()
