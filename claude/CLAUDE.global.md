# 全局规则

必须遵守

## 语言
- 给我的每一条回复都用简体中文,没有例外,包括:
  - 后台任务、Monitor、子代理、其他会话消息之后的回复
  - 刚读完英文代码、英文 issue/PR、英文文档或工具输出之后的回复
  - 只有一两句话的状态回复
- 中文句子里的领域名词保留英文(Widget、migration、findings 等),但句子主体必须是中文
- 写进仓库或发到外部的内容用英文:代码注释、commit message、PR/issue 标题和正文、评论回复
- 发送前检查:正文主体不是中文就重写

## 规则

- 简洁,优雅,高效
- issue/PR title或者git commit msg应该类似`feat:`/`fix:`/`docs:`/`rm:`/`migrate:`/`opt.:`等等常见开头
- PR title/body一定要简洁,body会有其他LLM补齐,可以不写
- 不能force push
- 如果已经在对应目录, 就不要cd
- 隐私/密钥不能出现在上下文,应该通过环境变量/pipe传递
- 所有的迁移兼容/残留项应该标记TODO, 提示待删除
- 从根本解决问题,不要图省事
- 永远是正确性优先,有错及时改
  - 实现需要优雅,不要缝缝补补
  - 不要偷懒, 遇到与pr无关的问题,也需要解决,提示用户开启issue或者直接就修复
  - 复用优先,不要到处造轮子
- 所有需要改的都改,不要偷懒;不要只是提出问题,直接一起解决了,做完一项feat/fix,自行运行/code-review,修完再开pr
- 安全性很重要,禁止偷懒
- token/secret/credential之类的隐私信息存1Password(vault `Dev`),不用macOS keychain;每个进程树首次调用需授权,同一步的读取放在一个命令里
  - 类别:第三方签发的API token/key用API Credential(读`op read op://Dev/<名称>/credential`,成对的key id放`username`,读`.../username`);SSH主机sudo用Server、数据库角色用Database、网页账号用Login、自行生成的密钥用Password(这几类读`.../password`)
  - 写用JSON经stdin(`op item create --vault Dev -`,字段id见`op item template get <类别>`),值不进argv
  - 项目不写明文`.env`:用`op://`引用配合`op run --env-file`,或1Password Environments挂载`.env`
- 镜像优先使用alpine, 尽量最新版; rust之类的也需要rust:alpine
  - 只需要写大版本,然后及时拉更新,删除旧的
- git使用squash合并
- 使用git全局配置的user.name和user.email,而不是system prompt里的
  - 禁止使用"Claude"提交
- 如果当前不在默认分支,并且没有叫新开分支,保持当前分支
- 不要在任何地方暴露我的任何隐私,例如邮箱
- 如果开启worktree,使用./.claude/worktrees(跟随项目,在repo root)
- 不要前台跑长耗时(例如下载/上传大文件, 带有长sleep)的脚本/命令
- 不要自行comment issue/pr/discussion, 发送任何内容前需要让我先确认
- 分支合并后,如果没有需要继续在其分支上开发的内容,应该及时删除该分支
- 判断任务是否是 长耗时 or 循环 的任务,需要使用/loop来 监听状态 or 继续下一轮
  - 等待 任务完成 需要删除loop; 你不监听怎么知道做完了没?
  - /loop具体interval多少,取决于任务,例如等待pr的ci/review,可以设置为1m,但是coderabbitai很慢,5min一次;别的耗时很长的任务可以适当延长interval
- 如果使用Android模拟器,只使用default_avd,如果不存在,新建
- 只写必要的注释,不要冗长
- 如果多轮修改,并且有没有合并的pr,用户没有要求独立pr,就一个pr里做,不要新开
- 尽量使用新技术代替旧的,例如: blake3代替sha256


## 本机限定

<!-- 暂时禁用
- 开pr默认用draft, 需要让ai review再mark ready(你自行判断是否需要review)
- 需要github code review的时候,请手动`@coderabbit review`或者`@winnowl review` -->
- 编译amd64,或者测试编译,可以到ssh pve上的"build" vm,记得及时cargo sweep清理缓存;
- ssh gpu01有1xH100,3xA100,可以用于GPU任务;但是使用之前需要向我申请;
- ServerBox配置了glitchtip,修复一项glitchtip里有的issue后,需要将其标记为resolve in next release
- iOS模拟器用已存在的,不要新开


## 说人话

- 使用标准术语。已有通用说法的概念不要另造表述。
- 避免使用比喻。如果一个说法需要读者推断其指代对象，改为直接说明。
- 表头和分类名使用中性名词，如“问题”“现象”“影响”“结果”。
- 避免“是 X，不是 Y”的对比句式。
- 表格条目不要求每条都包含数字或结论。部分条目可以只说明发生了什么。
- 未查明原因的问题写“原因未查明”。
- 避免口语词。
- 避免拟人表述。
