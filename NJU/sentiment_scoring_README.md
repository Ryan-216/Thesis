# 情感分析脚本使用说明

## 功能概述

本脚本使用大语言模型对评论文本进行多维度情感分析，包括：

1. **情感极性评分**（9分制：1-4负面，5中性，6-9正面）
2. **六类基础情感评分**（5分制0-4）：
   - 愤怒（Anger）
   - 厌恶（Disgust）
   - 恐惧（Fear）
   - 幸福（Happiness）
   - 悲伤（Sadness）
   - 惊讶（Surprise）
3. **失望情感评分**（5分制0-4）- 专注于期望失验（Expectation Disconfirmation）

每个评分都附带一个basis字段，解释评分依据。

## 使用方法

### 基本用法

```bash
python NJU/sentiment_scoring.py --input <输入文件路径>
```

### 完整参数

```bash
python NJU/sentiment_scoring.py \
  --input <输入文件路径> \
  --output <输出文件路径> \
  --cache-dir <缓存目录> \
  --threads <线程数>
```

### 参数说明

- `--input, -i`（必需）：输入Excel文件路径
- `--output, -o`（可选）：输出Excel文件路径，默认为`输入文件名_sentiment_scored.xlsx`
- `--cache-dir, -c`（可选）：JSON缓存目录，默认为输入文件所在目录的`sentiment_results/`
- `--threads, -t`（可选）：并发线程数，默认为10

### 使用示例

```bash
# 示例1：处理weekly数据
python NJU/sentiment_scoring.py --input NJU/weekly_comment.xlsx

# 示例2：处理daily数据并指定输出路径
python NJU/sentiment_scoring.py \
  --input NJU/daily_comment.xlsx \
  --output NJU/daily_comment_scored.xlsx

# 示例3：处理面板数据，使用20个线程加速
python NJU/sentiment_scoring.py \
  --input NJU/panel_data.xlsx \
  --threads 20
```

## 输入文件要求

1. **文件格式**：Excel文件（.xlsx）
2. **必需列**：必须包含评论列，支持的列名：
   - `Comment`, `comment`, `comments`, `Comments`
   - `text`, `Text`
   - `content`, `Content`
3. **可选列**：可以包含任何其他列（如Commenter, week_id, date等），这些列会被保留在输出文件中

## 输出文件说明

输出Excel文件包含原始数据的所有列，并在末尾添加以下情感分析列：

| 列名 | 说明 | 取值范围 |
|------|------|----------|
| `sentiment_polarity_score` | 情感极性分数 | 1-9 |
| `sentiment_polarity_basis` | 情感极性评分依据 | 文本 |
| `anger_score` | 愤怒程度 | 0-4 |
| `anger_basis` | 愤怒评分依据 | 文本 |
| `disgust_score` | 厌恶程度 | 0-4 |
| `disgust_basis` | 厌恶评分依据 | 文本 |
| `fear_score` | 恐惧程度 | 0-4 |
| `fear_basis` | 恐惧评分依据 | 文本 |
| `happiness_score` | 幸福程度 | 0-4 |
| `happiness_basis` | 幸福评分依据 | 文本 |
| `sadness_score` | 悲伤程度 | 0-4 |
| `sadness_basis` | 悲伤评分依据 | 文本 |
| `surprise_score` | 惊讶程度 | 0-4 |
| `surprise_basis` | 惊讶评分依据 | 文本 |
| `disappointment_score` | 失望程度 | 0-4 |
| `disappointment_basis` | 失望评分依据（重点关注期望失验） | 文本 |

## 缓存机制

- 脚本会将每条评论的分析结果缓存为JSON文件
- 如果中断后重新运行，已处理的评论会直接从缓存读取，不会重复调用API
- 缓存文件位于`--cache-dir`指定的目录（默认为`sentiment_results/`）

## 关于失望情感的研究建议

### 研究背景
如果你的研究发现某些外部事件（非GitHub内部事件）导致开发者活动减少，理论上推测是产生了失望情绪和期望失验，但评论中可能无法直接捕捉到失望，而是失望带来的其他情绪表现。

### 建议的分析策略

#### 1. **复合情感指标构建**
失望往往不是单独出现，而是伴随其他情感。建议构建复合指标：

```
失望相关情感 = disappointment_score + 0.5 * sadness_score + 0.3 * anger_score
```

或使用主成分分析（PCA）提取潜在的"负面情感因子"。

#### 2. **情感组合模式分析**
分析以下情感组合模式，这些可能是间接的失望表现：
- **高悲伤 + 低愤怒**：可能表示接受现实但感到失落
- **高愤怒 + 中等失望**：期望落空后的挫败感
- **情感极性下降 + 悲伤上升**：从积极转向消极的失望过程

#### 3. **时间序列分析**
- 比较事件前后的情感变化趋势
- 关注情感极性的**下降幅度**而非绝对值
- 分析情感波动性的变化

#### 4. **文本内容的定性分析**
对于disappointment_score较高的评论，仔细阅读`disappointment_basis`字段：
- 即使分数不高，basis中可能包含期望失验的线索
- 关注"unfortunately", "expected", "hoped"等关键词

#### 5. **行为-情感关联分析**
将情感数据与开发行为数据结合：
- 开发活动减少 + 负面情感上升 → 强证据
- 开发活动减少 + 评论减少 → 可能是"沉默的失望"
- 开发活动减少 + 中性评论 → 可能是理性撤出

#### 6. **对照组设计**
- 比较受事件影响的开发者 vs 未受影响的开发者
- 比较事件前后的情感分布差异
- 使用DID（双重差分）方法控制其他因素

#### 7. **间接失望的信号**
除了直接的disappointment_score，以下信号也值得关注：
- **参与度下降**：评论频率减少、评论长度缩短
- **语气变化**：从积极/中性转向消极
- **批评性增加**：anger和disgust分数上升
- **情感平淡化**：所有情感分数都趋向中等值（情感疲劳）

### 实证分析建议

```stata
* 示例：使用Stata进行分析
* 1. 创建复合失望指标
gen disappointment_composite = disappointment_score + 0.5*sadness_score + 0.3*anger_score

* 2. 事件前后对比
ttest disappointment_composite, by(post_event)

* 3. 回归分析
reg dev_activity post_event disappointment_composite controls, cluster(developer_id)

* 4. 中介效应检验
mediation dev_activity, mediator(disappointment_composite) treatment(event_exposure)
```

### 理论框架建议

可以参考以下理论框架：
1. **期望确认理论**（Expectation Confirmation Theory）
2. **认知失调理论**（Cognitive Dissonance Theory）
3. **心理契约违背**（Psychological Contract Breach）
4. **情感事件理论**（Affective Events Theory）

### 稳健性检验

1. 使用不同的情感权重组合
2. 排除极端值后重新分析
3. 使用不同的时间窗口
4. 检验是否存在滞后效应

## 注意事项

1. API调用需要网络连接和有效的API密钥
2. 大量数据处理可能需要较长时间，建议使用缓存机制
3. 确保输入文件编码为UTF-8
4. 空评论行不会被处理，但会保留在输出文件中

## 日志文件

脚本运行日志保存在`sentiment_scoring.log`文件中，包含：
- 成功处理的记录
- 错误信息
- API调用详情

## 技术支持

如遇问题，请检查：
1. 输入文件格式是否正确
2. API密钥是否有效
3. 网络连接是否正常
4. 日志文件中的错误信息
