import os
import pandas as pd
import numpy as np
import time
import json
import threading
import logging
import argparse
from queue import Queue
from tqdm import tqdm
from openai import OpenAI, APITimeoutError
from concurrent.futures import ThreadPoolExecutor
from functools import lru_cache

# ================= 配置区域 =================
# 请替换为你的 DeepSeek API Key
API_KEY = "sk-z-z9jSBXLJEOnUOYJ79snQ" 
BASE_URL = "https://llm-gateway.momenta.works/"
MODEL_NAME = "claude-sonnet-4.5"

# 日志配置
logging.basicConfig(
    filename='sentiment_scoring.log',
    encoding='utf-8', 
    level=logging.INFO,
    format='%(asctime)s %(levelname)s: %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)

# 全局客户端实例（复用连接）
_client = None
_client_lock = threading.Lock()

def get_client():
    """获取全局OpenAI客户端实例（线程安全）"""
    global _client
    if _client is None:
        with _client_lock:
            if _client is None:
                _client = OpenAI(api_key=API_KEY, base_url=BASE_URL)
    return _client
# ===========================================

def get_sentiment_prompt(comment_text):
    """
    生成情感分析的 Prompt - 包含所有评分任务
    """
    system_prompt = """
You are an expert sentiment analyst. Analyze the given text and provide comprehensive sentiment scores across multiple dimensions.

**Task 1: Overall Sentiment Polarity (9-point scale)**
Evaluate the overall emotional tone:
- **1-4**: Negative sentiment (1=extremely negative, 4=slightly negative)
  - Indicators: anger, disappointment, criticism, frustration, complaints
- **5**: Neutral sentiment
  - Indicators: objective, factual, balanced, or mixed emotions
- **6-9**: Positive sentiment (6=slightly positive, 9=extremely positive)
  - Indicators: joy, gratitude, approval, excitement, satisfaction

**Task 2: Six Basic Emotions (5-point scale, 0-4 for each)**
Rate the intensity of each emotion:
- **Anger**: Irritation, frustration, hostility (0=none, 4=extreme)
- **Disgust**: Revulsion, contempt, distaste (0=none, 4=extreme)
- **Fear**: Anxiety, worry, concern (0=none, 4=extreme)
- **Happiness**: Joy, satisfaction, contentment (0=none, 4=extreme)
- **Sadness**: Sorrow, disappointment, melancholy (0=none, 4=extreme)
- **Surprise**: Astonishment, unexpectedness (0=none, 4=extreme)

**Task 3: Disappointment - Expectation Disconfirmation (5-point scale, 0-4)**
This is a critical dimension for measuring expectation violation. Disappointment occurs when reality fails to meet prior expectations or hopes. Carefully evaluate:

**Definition**: Disappointment reflects the gap between what was expected/hoped for and what actually occurred. It is distinct from general sadness or anger, as it specifically involves unmet expectations.

**Key Indicators**:
- Explicit statements of unmet expectations (e.g., "I expected X but got Y", "This is not what I hoped for")
- Expressions of letdown, disillusionment, or feeling underwhelmed
- Comparisons between anticipated and actual outcomes
- Phrases like "unfortunately", "sadly", "not as good as expected", "fell short"
- Regret about decisions or outcomes that didn't meet hopes
- Loss of enthusiasm or optimism that was previously present

**Rating Scale**:
- **0**: No disappointment - expectations met or exceeded, or no expectations were present
- **1**: Slight disappointment - minor unmet expectations, easily overlooked
- **2**: Moderate disappointment - clear gap between expectations and reality, noticeable dissatisfaction
- **3**: Strong disappointment - significant expectation violation, considerable distress or frustration
- **4**: Extreme disappointment - severe expectation disconfirmation, profound sense of letdown or betrayal

**Important**: Distinguish disappointment from:
- Pure anger (which may lack the expectation component)
- General sadness (which may not involve unmet expectations)
- Neutral criticism (which may be objective without emotional investment)

**Output Format**:
Return a JSON object with the following structure. For each score, provide a brief one-sentence basis explaining your rating:

{
    "sentiment_polarity": {
        "score": <int, 1-9>,
        "basis": "<string, one sentence explanation>"
    },
    "anger": {
        "score": <int, 0-4>,
        "basis": "<string, one sentence explanation>"
    },
    "disgust": {
        "score": <int, 0-4>,
        "basis": "<string, one sentence explanation>"
    },
    "fear": {
        "score": <int, 0-4>,
        "basis": "<string, one sentence explanation>"
    },
    "happiness": {
        "score": <int, 0-4>,
        "basis": "<string, one sentence explanation>"
    },
    "sadness": {
        "score": <int, 0-4>,
        "basis": "<string, one sentence explanation>"
    },
    "surprise": {
        "score": <int, 0-4>,
        "basis": "<string, one sentence explanation>"
    },
    "disappointment": {
        "score": <int, 0-4>,
        "basis": "<string, detailed explanation focusing on expectation disconfirmation>"
    }
}

**Important**: 
- Provide ONLY the JSON object, no additional text
- Each score must be within the specified range
- Each basis must be a concise explanation
- For disappointment, the basis should explicitly reference the expectation-reality gap if present
"""
    
    user_prompt = f"Text to analyze:\n{comment_text}"
    
    return system_prompt, user_prompt

def request_AI(comment_text, file_name, timeout=60, max_retries=10):
    """调用 API 进行情感分析（带重试机制）"""
    
    for attempt in range(max_retries):
        try:
            client = get_client()  # 复用全局客户端
            
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
            
            # 去除可能的 markdown 代码块标记
            content = content.strip()
            if content.startswith('```json'):
                content = content[7:]  # 移除 ```json
            if content.startswith('```'):
                content = content[3:]  # 移除 ```
            if content.endswith('```'):
                content = content[:-3]  # 移除结尾的 ```
            content = content.strip()
            
            # 尝试解析 JSON
            try:
                result_json = json.loads(content)
            except json.JSONDecodeError:
                # 如果模型没有返回标准 JSON，尝试修复或记录
                logging.warning(f"JSON parse failed for {file_name}, raw content: {content}")
                result_json = {
                    "sentiment_polarity": {"score": np.nan, "basis": "Parse error"},
                    "anger": {"score": np.nan, "basis": "Parse error"},
                    "disgust": {"score": np.nan, "basis": "Parse error"},
                    "fear": {"score": np.nan, "basis": "Parse error"},
                    "happiness": {"score": np.nan, "basis": "Parse error"},
                    "sadness": {"score": np.nan, "basis": "Parse error"},
                    "surprise": {"score": np.nan, "basis": "Parse error"},
                    "disappointment": {"score": np.nan, "basis": "Parse error"}
                }

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
            if attempt < max_retries - 1:
                wait_time = min(2 ** attempt, 30)  # 指数退避，最多30秒
                logging.warning(f"Timeout for {file_name}, retry {attempt + 1}/{max_retries} after {wait_time}s")
                time.sleep(wait_time)
            else:
                logging.error(f"Timeout error for {file_name} after {max_retries} attempts: {te}")
                raise te
                
        except Exception as e:
            error_str = str(e)
            # 检查是否是429错误
            if "429" in error_str or "Too Many Requests" in error_str:
                if attempt < max_retries - 1:
                    wait_time = min((2 ** attempt) * 2, 60)  # 对429错误使用更长等待，最多60秒
                    logging.warning(f"Rate limit (429) for {file_name}, retry {attempt + 1}/{max_retries} after {wait_time}s")
                    time.sleep(wait_time)
                else:
                    logging.error(f"Rate limit error for {file_name} after {max_retries} attempts: {e}")
                    raise e
            else:
                logging.error(f"Error for {file_name}: {e}")
                raise e
    
    # 如果所有重试都失败
    raise Exception(f"Failed to process {file_name} after {max_retries} attempts")

@lru_cache(maxsize=10000)
def check_local_file(file_name, folder_path):
    """检查本地是否已有结果（带缓存）"""
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

def process_single_task(task):
    """处理单个任务（用于ThreadPoolExecutor）"""
    file_name = task['file_name']
    folder_path = task['folder_path']
    comment_text = task['comment_text']
    index = task['index']
    
    # 1. 检查本地缓存
    cached_result = check_local_file(file_name, folder_path)
    if cached_result:
        return (index, file_name, cached_result['result'], True, None)
    
    # 2. 发起请求
    try:
        response_data = request_AI(comment_text, file_name)
        if response_data:
            save_json_object(file_name, folder_path, response_data)
            return (index, file_name, response_data['result'], False, None)
        else:
            return (index, file_name, create_empty_result("No response"), False, None)
    except Exception as e:
        logging.error(f"Error processing {file_name}: {e}")
        # 返回失败标记，稍后重试
        return (index, file_name, None, False, task)

def create_empty_result(error_msg):
    """创建空结果对象"""
    return {
        "sentiment_polarity": {"score": np.nan, "basis": error_msg},
        "anger": {"score": np.nan, "basis": error_msg},
        "disgust": {"score": np.nan, "basis": error_msg},
        "fear": {"score": np.nan, "basis": error_msg},
        "happiness": {"score": np.nan, "basis": error_msg},
        "sadness": {"score": np.nan, "basis": error_msg},
        "surprise": {"score": np.nan, "basis": error_msg},
        "disappointment": {"score": np.nan, "basis": error_msg}
    }

def find_comment_column(df):
    """
    智能查找评论列
    支持的列名: Comment, comment, comments, Comments, text, Text, content, Content
    """
    possible_names = ['Comment', 'comment', 'comments', 'Comments', 
                      'text', 'Text', 'content', 'Content']
    
    for col_name in possible_names:
        if col_name in df.columns:
            return col_name
    
    # 如果没找到，抛出错误
    raise ValueError(f"Cannot find comment column. Available columns: {df.columns.tolist()}")

def generate_unique_filename(row, row_index, comment_col):
    """
    生成唯一的文件名
    优先使用标识列（如Commenter, week_id等），否则使用行索引
    """
    # 尝试使用常见的标识列
    identifier_parts = []
    
    # 常见的标识列名
    id_columns = ['Commenter', 'commenter', 'user', 'User', 'username', 
                  'week_id', 'date', 'Date', 'id', 'ID']
    
    for col in id_columns:
        if col in row.index and pd.notna(row[col]):
            # 清理文件名中的非法字符
            safe_value = "".join([c for c in str(row[col]) if c.isalnum() or c in (' ', '-', '_')]).strip()
            if safe_value:
                identifier_parts.append(safe_value)
    
    # 如果没有找到标识列，使用行索引
    if not identifier_parts:
        identifier_parts.append(f"row_{row_index}")
    
    # 添加评论的前10个字符作为额外标识（避免重复）
    comment_preview = "".join([c for c in str(row[comment_col])[:10] if c.isalnum()]).strip()
    if comment_preview:
        identifier_parts.append(comment_preview)
    
    return "_".join(identifier_parts) + ".json"

def main():
    # 解析命令行参数
    parser = argparse.ArgumentParser(description='Sentiment Analysis Script with Multiple Dimensions')
    parser.add_argument('--input', '-i', required=True, help='Input Excel file path')
    parser.add_argument('--output', '-o', help='Output Excel file path (optional, default: input_sentiment_scored.xlsx)')
    parser.add_argument('--cache-dir', '-c', help='Cache directory for JSON results (optional, default: sentiment_results/)')
    parser.add_argument('--threads', '-t', type=int, default=10, help='Number of concurrent threads (default: 10)')
    parser.add_argument('--max-retries', type=int, default=3, help='Maximum retry attempts for failed requests (default: 3)')
    
    args = parser.parse_args()
    
    # 设置输入输出路径
    INPUT_FILE = args.input
    
    if args.output:
        FINAL_OUTPUT_FILE = args.output
    else:
        # 默认输出文件名：在输入文件名后加 _sentiment_scored
        base_name = os.path.splitext(INPUT_FILE)[0]
        FINAL_OUTPUT_FILE = f"{base_name}_sentiment_scored.xlsx"
    
    if args.cache_dir:
        OUTPUT_FOLDER = args.cache_dir
    else:
        # 默认缓存目录：在输入文件所在目录创建 sentiment_results 文件夹
        input_dir = os.path.dirname(INPUT_FILE) or '.'
        OUTPUT_FOLDER = os.path.join(input_dir, f'sentiment_results_{MODEL_NAME}')
    
    # 1. 读取数据
    print(f"Loading data from {INPUT_FILE}...")
    try:
        df = pd.read_excel(INPUT_FILE, keep_default_na=False)
    except Exception as e:
        print(f"Error reading file: {e}")
        return
    
    print(f"Total rows: {len(df)}")
    print(f"Columns: {df.columns.tolist()}")
    
    # 2. 查找评论列
    try:
        comment_col = find_comment_column(df)
        print(f"Found comment column: '{comment_col}'")
    except ValueError as e:
        print(f"Error: {e}")
        return
    
    # 3. 过滤掉空评论
    df_to_process = df[df[comment_col].astype(str).str.strip() != ''].copy()
    print(f"Rows with non-empty comments to process: {len(df_to_process)}")
    
    if len(df_to_process) == 0:
        print("No comments to process. Exiting.")
        return
    
    # 4. 准备输出目录
    os.makedirs(OUTPUT_FOLDER, exist_ok=True)
    print(f"Cache directory: {OUTPUT_FOLDER}")
    
    # 5. 创建任务列表
    tasks = []
    for index, row in df_to_process.iterrows():
        file_name = generate_unique_filename(row, index, comment_col)
        task = {
            'folder_path': OUTPUT_FOLDER,
            'file_name': file_name,
            'comment_text': row[comment_col],
            'index': index
        }
        tasks.append(task)
    
    total_tasks = len(tasks)
    print(f"Tasks created: {total_tasks}")
    
    # 6. 使用ThreadPoolExecutor进行并行处理
    results_dict = {}  # key: index, value: (file_name, result_json)
    failed_tasks = []  # 存储失败的任务
    num_threads = args.threads
    
    print(f"Starting processing with {num_threads} threads...")
    cached_count = 0
    processed_count = 0
    failed_count = 0
    
    with ThreadPoolExecutor(max_workers=num_threads) as executor:
        with tqdm(total=total_tasks, desc="Processing Comments") as pbar:
            for result in executor.map(process_single_task, tasks):
                index, file_name, result_json, is_cached, failed_task = result
                
                if failed_task:
                    # 记录失败的任务
                    failed_tasks.append(failed_task)
                    failed_count += 1
                else:
                    results_dict[index] = (file_name, result_json)
                    if is_cached:
                        cached_count += 1
                    else:
                        processed_count += 1
                pbar.update(1)
    
    print(f"First pass completed. Cached: {cached_count}, Processed: {processed_count}, Failed: {failed_count}")
    
    # 7. 重试失败的任务
    if failed_tasks:
        max_retry_rounds = args.max_retries
        for retry_round in range(max_retry_rounds):
            if not failed_tasks:
                break
                
            print(f"\nRetry round {retry_round + 1}/{max_retry_rounds}: {len(failed_tasks)} failed tasks...")
            current_failed = failed_tasks.copy()
            failed_tasks = []
            
            with ThreadPoolExecutor(max_workers=num_threads) as executor:
                with tqdm(total=len(current_failed), desc=f"Retry Round {retry_round + 1}") as pbar:
                    for result in executor.map(process_single_task, current_failed):
                        index, file_name, result_json, is_cached, failed_task = result
                        
                        if failed_task:
                            failed_tasks.append(failed_task)
                        else:
                            results_dict[index] = (file_name, result_json)
                            processed_count += 1
                        pbar.update(1)
            
            print(f"Retry round {retry_round + 1} completed. Remaining failures: {len(failed_tasks)}")
        
        if failed_tasks:
            print(f"\n⚠️  Warning: {len(failed_tasks)} tasks still failed after all retries")
            print("Failed tasks will have empty results in the output file")
            # 为失败的任务填充空结果
            for task in failed_tasks:
                index = task['index']
                file_name = task['file_name']
                results_dict[index] = (file_name, create_empty_result("Failed after all retries"))
    
    print(f"\nAll processing completed. Total successful: {len(results_dict)}")
    
    # 8. 整合结果回 DataFrame（优化版）
    print("Merging results...")
    
    # 直接从results_dict构建结果（避免重复遍历）
    sentiment_data = {
        'sentiment_polarity_score': {},
        'sentiment_polarity_basis': {},
        'anger_score': {},
        'anger_basis': {},
        'disgust_score': {},
        'disgust_basis': {},
        'fear_score': {},
        'fear_basis': {},
        'happiness_score': {},
        'happiness_basis': {},
        'sadness_score': {},
        'sadness_basis': {},
        'surprise_score': {},
        'surprise_basis': {},
        'disappointment_score': {},
        'disappointment_basis': {}
    }
    
    # 一次性提取所有结果
    for index, (file_name, res) in results_dict.items():
        if res:
            sentiment_data['sentiment_polarity_score'][index] = res.get('sentiment_polarity', {}).get('score')
            sentiment_data['sentiment_polarity_basis'][index] = res.get('sentiment_polarity', {}).get('basis')
            sentiment_data['anger_score'][index] = res.get('anger', {}).get('score')
            sentiment_data['anger_basis'][index] = res.get('anger', {}).get('basis')
            sentiment_data['disgust_score'][index] = res.get('disgust', {}).get('score')
            sentiment_data['disgust_basis'][index] = res.get('disgust', {}).get('basis')
            sentiment_data['fear_score'][index] = res.get('fear', {}).get('score')
            sentiment_data['fear_basis'][index] = res.get('fear', {}).get('basis')
            sentiment_data['happiness_score'][index] = res.get('happiness', {}).get('score')
            sentiment_data['happiness_basis'][index] = res.get('happiness', {}).get('basis')
            sentiment_data['sadness_score'][index] = res.get('sadness', {}).get('score')
            sentiment_data['sadness_basis'][index] = res.get('sadness', {}).get('basis')
            sentiment_data['surprise_score'][index] = res.get('surprise', {}).get('score')
            sentiment_data['surprise_basis'][index] = res.get('surprise', {}).get('basis')
            sentiment_data['disappointment_score'][index] = res.get('disappointment', {}).get('score')
            sentiment_data['disappointment_basis'][index] = res.get('disappointment', {}).get('basis')
    
    # 批量赋值（更高效）
    for col_name, mapping in sentiment_data.items():
        df[col_name] = df.index.map(mapping)
    
    # 9. 保存最终结果
    # 调整列顺序，将关键信息放在前面
    sentiment_cols = [
        'sentiment_polarity_score', 'sentiment_polarity_basis',
        'anger_score', 'anger_basis',
        'disgust_score', 'disgust_basis',
        'fear_score', 'fear_basis',
        'happiness_score', 'happiness_basis',
        'sadness_score', 'sadness_basis',
        'surprise_score', 'surprise_basis',
        'disappointment_score', 'disappointment_basis'
    ]
    
    # 保持原有列的顺序，然后添加情感分析列
    original_cols = [c for c in df.columns if c not in sentiment_cols]
    new_cols = original_cols + sentiment_cols
    df = df[new_cols]

    print(f"Saving final result to {FINAL_OUTPUT_FILE}...")
    
    # 确保输出目录存在
    output_dir = os.path.dirname(FINAL_OUTPUT_FILE)
    if output_dir and not os.path.exists(output_dir):
        os.makedirs(output_dir, exist_ok=True)
        print(f"Created output directory: {output_dir}")
    
    df.to_excel(FINAL_OUTPUT_FILE, index=False)
    print(f"Done! Output saved to: {FINAL_OUTPUT_FILE}")
    print(f"Total rows processed: {len(df_to_process)}")

if __name__ == "__main__":
    main()
