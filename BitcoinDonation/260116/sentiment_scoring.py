import os
import pandas as pd
import numpy as np
import time
import json
import threading
import logging
from queue import Queue
from tqdm import tqdm
from openai import OpenAI, APITimeoutError

# ================= 配置区域 =================
# 请替换为你的 DeepSeek API Key
API_KEY = "sk-535d60361a634ede9e62014fbcba4e901" 
BASE_URL = "https://api.deepseek.com/v1"
MODEL_NAME = "deepseek-chat"

# 输入和输出文件路径
INPUT_FILE = 'BitcoinDonation/260116/weekly_comments_panel_22_23.xlsx'
OUTPUT_FOLDER = 'BitcoinDonation/260116/sentiment_results/'
FINAL_OUTPUT_FILE = 'BitcoinDonation/260116/weekly_comments_sentiment_scored.xlsx'

# 日志配置
logging.basicConfig(
    filename='sentiment_scoring.log',
    encoding='utf-8', 
    level=logging.INFO,
    format='%(asctime)s %(levelname)s: %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
# ===========================================

def get_sentiment_prompt(comment_text):
    """
    生成情感分析的 Prompt
    """
    system_prompt = """
    Use the following step-by-step instructions to read the text content and evaluate the extent to which it conveys different sentiment dimensions, without any emotion.

    **Step 1**: The user will ask you to evaluate a given comment. Evaluate the overall **Sentiment** of the text. **Do not output all your reasoning for this step**.

    **Dimension Definitions**:
    1. **Sentiment**: The overall emotional tone of the text, ranging from negative to positive.
       - **1 to 4**: Negative sentiment (anger, disappointment, criticism, frustration).
       - **5**: Neutral sentiment (objective, factual, balanced, or mixed).
       - **6 to 9**: Positive sentiment (joy, gratitude, approval, excitement, satisfaction).

    **Step 2**: Reply with a single score following the required format below. The score should be an integer from 1 to 9. After the score, provide **one sentence** briefly explaining the basis for the score. **Do not output all your reasoning for this step**.

    **Required Output Format**:
    Just output the JSON object with the following fields:
    {
        "score": <int, 1-9>,
        "basis": "<string, briefly explain the basis for the score in one sentence>"
    }
    Do not output any other text.
    """
    
    user_prompt = f"Text to analyze:\n{comment_text}"
    
    return system_prompt, user_prompt

def request_AI(comment_text, file_name, timeout=60):
    """调用 API 进行情感分析"""
    try:
        client = OpenAI(api_key=API_KEY, base_url=BASE_URL)
        
        system_prompt, user_prompt = get_sentiment_prompt(comment_text)
        
        response = client.chat.completions.create(
            model=MODEL_NAME,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt}
            ],
            temperature=0, # 保持结果确定性
            stream=False,
            timeout=timeout,
            response_format={ "type": "json_object" } # 强制 JSON 输出
        )
        
        content = response.choices[0].message.content
        
        # 尝试解析 JSON
        try:
            result_json = json.loads(content)
        except json.JSONDecodeError:
            # 如果模型没有返回标准 JSON，尝试修复或记录
            logging.warning(f"JSON parse failed for {file_name}, raw content: {content}")
            result_json = {"score": np.nan, "basis": content}

        # 构建完整的保存对象
        completion = {
            "id": response.id,
            "created": response.created,
            "model": response.model,
            "result": result_json,
            "usage": {
                "prompt_tokens": response.usage.prompt_tokens,
                "completion_tokens": response.usage.completion_tokens,
                "total_tokens": response.usage.total_tokens
            }
        }
        
        logging.info(f"Request successful for {file_name}")
        return completion

    except APITimeoutError as te:
        logging.error(f"Timeout error for {file_name}: {te}")
        raise te
    except Exception as e:
        logging.error(f"Error for {file_name}: {e}")
        raise

def check_local_file(file_name, folder_path):
    """检查本地是否已有结果"""
    file_path = os.path.join(folder_path, file_name)
    if os.path.exists(file_path):
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = json.load(f)
            return content
        except json.JSONDecodeError:
            return None
    return None

def save_json_object(file_name, folder_path, data):
    """保存结果到 JSON 文件"""
    file_path = os.path.join(folder_path, file_name)
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=4)

def worker(task_queue, pbar, results_dict):
    """工作线程"""
    while not task_queue.empty():
        task = task_queue.get()
        file_name = task['file_name']
        folder_path = task['folder_path']
        comment_text = task['comment_text']
        
        # 1. 检查本地缓存
        cached_result = check_local_file(file_name, folder_path)
        if cached_result:
            results_dict[file_name] = cached_result['result']
            # logging.info(f"Skipping {file_name}, already exists.")
            task_queue.task_done()
            pbar.update(1)
            continue
        
        # 2. 发起请求
        try:
            response_data = request_AI(comment_text, file_name)
            if response_data:
                results_dict[file_name] = response_data['result']
                save_json_object(file_name, folder_path, response_data)
            else:
                results_dict[file_name] = {"score": np.nan, "basis": "No response"}
        except Exception as e:
            results_dict[file_name] = {"score": np.nan, "basis": str(e)}
        
        task_queue.task_done()
        pbar.update(1)

def main():
    # 1. 读取数据
    print(f"Loading data from {INPUT_FILE}...")
    df = pd.read_excel(INPUT_FILE, keep_default_na=False)
    
    # 过滤掉空评论
    # 注意：根据之前的处理，空评论是空字符串
    df_to_process = df[df['Comment'].str.strip() != ''].copy()
    print(f"Total rows: {len(df)}. Rows with comments to process: {len(df_to_process)}")
    
    # 2. 准备输出目录
    os.makedirs(OUTPUT_FOLDER, exist_ok=True)
    
    # 3. 创建任务队列
    task_queue = Queue()
    # 为每一行生成一个唯一的文件名，例如: commenter_weekid.json
    # 注意文件名要合法，避免特殊字符
    
    for index, row in df_to_process.iterrows():
        # 清理文件名中的非法字符
        safe_commenter = "".join([c for c in str(row['Commenter']) if c.isalnum() or c in (' ', '-', '_')]).strip()
        file_name = f"{safe_commenter}_{row['week_id']}.json"
        
        task = {
            'folder_path': OUTPUT_FOLDER,
            'file_name': file_name,
            'comment_text': row['Comment'],
            'index': index
        }
        task_queue.put(task)
    
    total_tasks = task_queue.qsize()
    print(f"Tasks created: {total_tasks}")
    
    # 4. 启动多线程处理
    results_dict = {} # key: file_name, value: result_json
    num_threads = 10 # 并发线程数
    
    threads = []
    with tqdm(total=total_tasks, desc="Processing Comments") as pbar:
        for _ in range(min(num_threads, total_tasks)):
            t = threading.Thread(target=worker, args=(task_queue, pbar, results_dict))
            t.daemon = True
            t.start()
            threads.append(t)
            
        task_queue.join()
        
    print("All tasks completed.")
    
    # 5. 整合结果回 DataFrame
    print("Merging results...")
    
    # 创建用于映射的字典
    score_map = {}
    basis_map = {}
    
    for index, row in df_to_process.iterrows():
        safe_commenter = "".join([c for c in str(row['Commenter']) if c.isalnum() or c in (' ', '-', '_')]).strip()
        file_name = f"{safe_commenter}_{row['week_id']}.json"
        
        # 优先从内存字典取，如果内存没有（比如重启脚本后），尝试从文件读
        res = results_dict.get(file_name)
        if not res:
            cached = check_local_file(file_name, OUTPUT_FOLDER)
            if cached:
                res = cached['result']
        
        if res:
            score_map[index] = res.get('score')
            basis_map[index] = res.get('basis')
    
    # 将结果赋值回原始 DataFrame (使用索引匹配)
    df['sentiment_score'] = df.index.map(score_map)
    df['sentiment_basis'] = df.index.map(basis_map)
    
    # 6. 保存最终结果
    # 确保输出包含 Commenter 和 week_id 以便后续匹配
    # 调整列顺序，将关键信息放在前面
    cols = df.columns.tolist()
    priority_cols = ['Commenter', 'week_id', 'sentiment_score', 'sentiment_basis']
    new_cols = [c for c in priority_cols if c in cols] + [c for c in cols if c not in priority_cols]
    df = df[new_cols]

    print(f"Saving final result to {FINAL_OUTPUT_FILE}...")
    print(f"Output columns: {df.columns.tolist()}")
    df.to_excel(FINAL_OUTPUT_FILE, index=False)
    print("Done!")

if __name__ == "__main__":
    main()
