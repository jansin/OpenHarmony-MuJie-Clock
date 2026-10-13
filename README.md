# 沐界时钟（MuJie Clock）

> 基于 HarmonyOS ArkTS/ArkUI 的纯本地时钟应用：闹钟、世界时钟、秒表、计时器四合一，界面简洁、开箱即用。

| 项目 | 值 |
| --- | --- |
| **bundleName** | `com.jason.clock` |
| **版本** | 1.0.0（versionCode 1000000） |
| **语言** | 简体中文 |
| **许可证** | Apache License 2.0 |

---

## 一、项目简介

- **应用形态**：单 HAP 应用（`entry` 模块），HarmonyOS **Stage 模型**；入口 `EntryAbility` 加载唯一页面 `pages/Index`，页面内以自维护路由栈切换全屏子页。
- **数据策略**：完全本地化。闹钟、世界时钟城市、深色模式偏好经 `@kit.ArkData` 的 `preferences` 持久化，**不依赖任何网络请求**。
- **目标平台**：HarmonyOS；设备形态 `phone` / `tablet` / `2in1` / `car` / `wearable`。
- **SDK 版本**：`targetSdkVersion` `6.0.2(22)`、`compatibleSdkVersion` `5.0.0(12)`、`modelVersion` `6.0.2`。

---

## 二、功能特性

底部导航在四个 Tab（**闹钟 / 世界时钟 / 秒表 / 计时器**）之间切换，另有设置等全屏子页。

### 1. 闹钟

- **表盘与列表**：Canvas 实时模拟表盘，每秒重绘；列表按时间升序，卡片显示时间、名称、重复规则与「下次响铃」倒计时。
- **新建 / 编辑**：双列 `TextPicker` 滚轮选时、分（循环滚动）；闹钟名留空回退为「闹钟」。
- **重复规则**：`不重复` / `每天` / `工作日`（周一至周五）/ `周末`；「工作日」下可开启「法定工作日 (智能跳过节假日)」，其状态会被保存（`AlarmItem.smartHolidaySkip`），但**响铃判断仍按周一至周五执行**，源码注释写明「节假日数据未接入时与工作日相同」。
- **铃声与时长**：铃声标识 `默认 / 经典 / 轻快 / 电子`，时长 1 / 3 / 5 / 10 分钟；铃声仅为界面标识，**不播放真实音频**。
- **稍后提醒**：5 组预设（5 分×1/3 次、10 分×3/5 次、15 分×3 次），到点弹窗再次提醒并递减次数。
- **开关与删除**：卡片右侧自绘开关即时启停，左滑出现红色「删除」条（二次确认）；单次闹钟触发后自动关闭。

### 2. 世界时钟

- **本地时间卡**：模拟表盘 + 中文日期星期（如 `10月12日 星期日`）。
- **城市目录**：内置 **82 个**世界城市/地区时区（`common/WorldCityCatalog.ets`），支持关键词搜索（中英文、大小写不敏感）、区域筛选（全部 / 亚太 / 欧洲 / 美洲 / 中东与非洲）与首字母索引跳转。
- **城市列表**：显示 GMT 偏移标签（如 `GMT+8`）、当地时间（含秒）与跨日提示；最多 4 个城市，超出时自动移除最早添加的一个并 Toast 提示，重复添加会提示已存在，支持左滑删除。

### 3. 秒表

- **百分秒精度**：10 ms 步进刷新，显示 `MM:SS.CC`；表盘外圈 5–60、内圈 5–30。
- **计次**：记录单圈与累计耗时并倒序展示，最快 / 最慢圈分别以主题蓝、橙色高亮；支持「清除计次」与「复制计次」（写入剪贴板）。

### 4. 计时器

- **设置与表盘**：三列滚轮设时 / 分 / 秒（小时 0–99），另有 1 / 3 / 5 / 10 / 15 / 30 分共 6 个快捷时长；`TimerDial` 环形表盘按剩余比例旋转指针。
- **结束提醒**：归零弹出「计时结束」对话框并触发一次 400 ms 震动；时长为 0 时点击开始会提示先设置时长。

### 5. 设置、外观与数据

- **深色模式**：设置页开关即时切换浅色 / 深色主题令牌并写回偏好；启动与切换时同步设置状态栏/导航栏颜色，页面用 `expandSafeArea` 支持沉浸式安全区。
- **度量与无障碍**：`common/UiTokens.ets` 集中定义标题栏高度、圆角、FAB 尺寸等，内置 12 个矢量图标；关键按钮设置了 `accessibilityText`。
- **持久化与备份**：闹钟存于 `mujie_alarm_store`，界面偏好（深色模式 / 城市 / 当前 Tab）存于 `mujie_app_ui`，均带 `data_version` 与迁移逻辑，JSON 逐字段校验、异常不崩溃；`EntryBackupAbility`（`type: backup`）配合 `backup_config.json`（`allowToBackupRestore: true`）支持随系统备份/恢复。

---

## 三、技术栈

| 技术 / 能力 | 说明 |
| --- | --- |
| **ArkTS + ArkUI** | 全部 UI 以 `@Component` / `@Entry` / `@Builder` / `@State` / `@Prop` / `@Link` / `@Watch` 声明式构建 |
| **Stage 模型** | `apiType: "stageMode"`；`UIAbility` 生命周期 `onCreate` / `onWindowStageCreate` |
| **ArkUI Kit** | `window` 系统栏属性、`promptAction` Toast、`AlertDialog`、Canvas 2D、`TextPicker`、`List` + `swipeAction` |
| **ArkData / Core File Kit** | `preferences` 本地键值持久化；`BackupExtensionAbility` 声明 `type: backup` |
| **系统 API 与质量** | `@ohos.vibrator`（震动）、`@ohos.pasteboard`（复制计次）、`hilog` 日志；Hvigor 构建、Hypium + Hamock 测试、`code-linter.json5` 规则集（含 12 条安全规则） |

---

## 四、当前局限（重要）

- **无桌面卡片（Form）**：未声明 `FormExtensionAbility`，服务卡片暂未实现（**待补充**）。
- **闹钟无后台代理提醒**：未使用 `reminderAgentManager`、`notificationManager`、`backgroundTaskManager` 或 `wantAgent`（已全仓检索确认）。响铃由页面内的 `setInterval` 轮询（`Index.checkAlarms`，1 秒一次）触发，**应用被系统回收或进程被杀后不会响铃**，也不会走系统闹钟/提醒代理。
- **法定节假日数据未接入**：「法定工作日 (智能跳过节假日)」开关仅保存状态，响铃判断等同工作日。
- **除数据备份外无后台任务**（**待补充**计划提醒 / 后台代理提醒能力）。

---

## 五、目录结构

```text
OpenHarmony-MuJie-Clock/
├── AppScope/app.json5                  # bundleName、版本号、应用图标与名称
├── entry/                              # 唯一业务模块（entry HAP）
│   ├── build-profile.json5             # apiType=stageMode；targets: default / ohosTest
│   ├── oh-package.json5                # 模块包描述（无三方依赖）
│   └── src/
│       ├── main/module.json5           # 入口 Ability、备份扩展、VIBRATE 权限、页面表、设备形态
│       ├── main/ets/                   # EntryAbility / EntryBackupAbility（备份扩展）
│       │                               # pages/Index.ets（唯一 @Entry 页面：路由栈 + 闹钟调度）
│       │                               # components/（表盘、四个 Tab 页、标题栏与底部导航）
│       │                               # common/（持久化、重复规则、心跳、震动、令牌、82 城市目录）
│       │                               # home/（路由常量、示例闹钟、列表与 Snooze reducer）
│       ├── main/resources/             # 文案、12 个 flat_icon_*.svg、main_pages.json、backup_config.json
│       └── mock/  ohosTest/  test/     # mock 配置、仪器化测试、本地单元测试
├── hvigor/hvigor-config.json5          # modelVersion 6.0.2
└── build-profile.json5 等工程级配置 / LICENSE / README.md
```

---

## 六、环境要求与构建运行

| 项目 | 要求 |
| --- | --- |
| **DevEco Studio** | 需支持 **HarmonyOS 6.0.2 / API 22** 编译（本机验证版本 `DS-261.23567.138.36.2600851`） |
| **HarmonyOS SDK** | 安装 **API 12** 及以上 SDK，并安装 **API 22** 组件以完成默认 target 编译 |
| **工具链** | 建议用 DevEco Studio 自带 Node（`tools/node`）、ohpm（`tools/ohpm`）与 hvigor（`tools/hvigor`，`modelVersion` `6.0.2`）；Windows / macOS |

> **重要提示**：本仓库**未包含** `hvigorw` / `hvigorw.bat` 包装脚本，命令行构建需使用 DevEco Studio 自带的 `tools\hvigor\bin\hvigorw`。

**1. 打开工程（推荐）**：用 DevEco Studio 选择 **Open** 打开工程根目录（含 `build-profile.json5` 的目录），等待 Sync 完成；如提示安装 SDK，按提示安装 API 12 / API 22 组件。

**2. 签名配置（必须自行调整）**：`build-profile.json5` 中 `signingConfigs[0].material` **指向原开发机器的绝对路径**，在其他机器上无法直接使用，请二选一：在 `File` → `Project Structure` → `Signing Configs` 勾选 `Automatically generate signature`（方式 A，推荐，需登录华为开发者账号）；或手动指定自己的 `.p12` / `.cer` / `.p7b` 路径与 `keyAlias`、密码，由 IDE 回写（方式 B）。请勿把含真实口令的该文件提交到公开仓库。

**3. 命令行构建与安装**（`<DEVECO>` 为安装目录，Windows 默认 `C:\Program Files\Huawei\DevEco Studio`）：

```bash
git clone https://github.com/jansin/OpenHarmony-MuJie-Clock.git
ohpm install    # 安装依赖（ohpm 位于 <DEVECO>/tools/ohpm/bin）

# 构建 entry 模块 debug HAP（hvigorw 位于 <DEVECO>/tools/hvigor/bin）
"C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat" --mode module -p product=default -p module=entry@default assembleHap --no-daemon
# macOS / Linux: "$DEVECO/tools/hvigor/bin/hvigorw" ...（参数同上）
# 变体：省略 -p module 为全工程；加 -p buildMode=release 为 Release（混淆当前 enable=false）；clean 清理

hdc list targets               # 查看已连接设备
hdc install -r <path-to-hap>   # 产物位于 entry/build/default/outputs/default/
```

也可在 DevEco Studio 中点击 **Run ▶** 一键完成编译、签名、安装与启动；测试用例在 `entry/src/test` 与 `entry/src/ohosTest`（后者需连接设备），可在 IDE 中右键用例文件 **Run**，或用 hvigor 任务 `test` / `onDeviceTest`（任务名以 `hvigorw -h` 为准）；代码检查用 **Code → Code Linter**（`code-linter.json5`）。

---

## 七、使用说明

应用只有**一个页面** `pages/Index`，内部用自维护路由栈切换全屏子页：`Main`（四 Tab 主界面，启动默认页）、`Settings`（标题栏右上角 2×2 菜单按钮）、`TimeZone`（世界时钟 Tab 右下角地球 FAB）、`AlarmEdit`（闹钟列表 `+` FAB 新建，点按卡片编辑）。

- **闹钟 Tab**：点 **+** 新建，滑动时、分滚轮；点按「重复」「铃声」「响铃时长」「稍后提醒」行弹出底部选择面板，「闹钟名」可直接输入。右上角 **✓** 保存，左上角返回取消；列表开关即时启停，**左滑**卡片出现红色「删除」条，编辑页底部「删除闹钟」二次确认。
- **世界时钟 Tab**：点右下角地球 FAB 进入「添加城市」（搜索城市或国家 / 区域筛选 / 字母索引，点按任一行即添加并返回）；已添加城市显示 `GMT±X`、当地时间与跨日提示，**左滑**删除，最多 4 个。
- **秒表 / 计时器 Tab**：显示 `MM:SS.CC` 或环形表盘，底部为 **↻ 重置**、**▶ / ⏸ 开始暂停**；秒表另有 **◷ 计次**（含「清除计次」「复制计次」），计时器另有 **♢ 切换快捷时长**（1 / 3 / 5 / 10 / 15 / 30 分）。
- **设置页**：打开「深色模式」开关即时切换主题，返回后状态保持（已写入首选项）。

---

## 八、配置说明

**1. 权限声明**：`entry/src/main/module.json5` 中 `requestPermissions` 仅声明一项：

| 权限 | 类型 | 用途 |
| --- | --- | --- |
| `ohos.permission.VIBRATE` | normal（安装即授予） | 计时器倒计时结束时触发一次 400 ms 震动反馈 |

> 未声明网络、通知、后台任务、系统闹钟等任何权限；应用不发起网络请求。

**2. 需要自行填写的配置项**：

| 配置项 | 位置 | 说明 |
| --- | --- | --- |
| **签名材料路径与口令** | `build-profile.json5` → `app.signingConfigs[0].material` | 当前为原开发机绝对路径，**必须替换为你的签名配置** |
| **发布方** | `AppScope/app.json5` → `app.vendor` | 当前为占位值 `"example"`，建议改为实际厂商/作者名 |
| **模块描述** | `entry/oh-package.json5` → `description` / `author` / `license` | 当前为模板占位值，可按需补全 |

**3. 运行期可配置项**：深色模式、世界时钟城市（最多 4 条）、当前 Tab 存于 `mujie_app_ui`，闹钟存于 `mujie_alarm_store`；两个首选项库均带 `data_version` 与迁移逻辑，升级时可平滑处理历史数据。

---

## 九、第三方依赖与开源许可

### 1. 依赖清单（`oh-package.json5`）

| 依赖 | 版本 | 类型 | 用途 | 许可证 |
| --- | --- | --- | --- | --- |
| `@ohos/hypium` | 1.0.25 | devDependencies | HarmonyOS 单元测试框架（`describe` / `it` / `expect`） | Apache License 2.0 |
| `@ohos/hamock` | 1.0.0 | devDependencies | HarmonyOS mock 框架 | Apache License 2.0 |

- 工程级与 `entry/oh-package.json5` 的 `dependencies` 均为空 `{}`：**运行时没有任何第三方库依赖**。
- `oh-package-lock.json5` 显示两个依赖均来自 ohpm 官方仓库（`https://ohpm.openharmony.cn/ohpm/`），未引入其它传递依赖，且**仅在开发/测试期使用**，不参与 `entry` HAP 的运行时代码。

### 2. 内置（vendored）第三方代码核查

已对全仓源码（`entry/src/**` 与 `AppScope/**`，共约 4,486 行 ETS）逐文件检查 `Copyright` / `SPDX` / `Licensed under` 等许可头与外部代码引入痕迹：

> **结论：本项目未内置任何第三方源码或二进制。** 除下列 HarmonyOS 系统 SDK 公开 API 外，全部业务代码为项目自有实现：
>
> - `@kit.AbilityKit`、`@kit.ArkUI`、`@kit.ArkData`、`@kit.CoreFileKit`、`@kit.PerformanceAnalysisKit`（HarmonyOS SDK 系统能力）
> - `@ohos.vibrator`、`@ohos.pasteboard`（HarmonyOS SDK 系统能力）
> - `@ohos/hypium`、`@ohos/hamock`（ohpm 三方测试库，不随应用分发）
>
> 内置的 82 条世界城市时区数据（`common/WorldCityCatalog.ets`）与 12 个 `flat_icon_*.svg` 图标均为项目自有资源，未标注任何第三方许可头。

因此本项目不涉及额外的第三方许可证合规义务；若后续引入三方代码或资源，请在本节逐个补全名称、版本与许可证。

---

## 十、开源协议

本项目采用 **Apache License 2.0** 开源，完整协议文本见仓库根目录的 [LICENSE](LICENSE)。

在遵守协议条款的前提下，你可以 ✅ **商用**、✅ **修改**（含发布衍生作品）、✅ **分发**（源码或二进制形式，包括再许可）、✅ **专利授权**（贡献者授予你使用其专利的权利）。

同时你必须 📌 **保留版权与许可声明**（在源码、文档与分发物中保留原始版权声明、本协议副本及重要提示）、📌 **标注修改**、📌 **附带许可证**（分发时随附协议全文）。

协议还明确规定：⚠️ **不提供担保**——软件按「原样」提供，不附带任何明示或默示担保（包括适销性、特定用途适用性与非侵权担保）；⚠️ 若你针对本项目发起专利诉讼，你依据本协议获得的专利授权将随之终止。

协议全文：<http://www.apache.org/licenses/LICENSE-2.0>

Copyright 2026 MiaoSir1988

---

## 十一、贡献与联系

欢迎提交 Issue 与 Pull Request：请基于 Fork 的新分支开发，使用 ArkTS 严格类型；提交前执行 **Code → Code Linter**（`code-linter.json5`）确保无新增告警；界面改动请复用 `common/UiTokens.ets` 的度量与颜色令牌并同时适配明暗主题，文案放入 `resources/base/element/string.json`，逻辑改动请补充 `entry/src/test` 与 `entry/src/ohosTest` 用例，并在 PR 中说明改动目的、影响范围与验证方式。

- **项目主页 / 作者**：GitHub 主页 <https://github.com/jansin>
- **问题反馈**：欢迎在本仓库提交 Issue（界面问题请附设备型号、系统版本与截图）。
- **致谢**：感谢 OpenHarmony / HarmonyOS 的 ArkTS、ArkUI 与 Stage 模型框架、DevEco Studio 与 Hvigor 工具链、Hypium / Hamock 测试框架的贡献者，以及所有提交 Issue 与 PR 的贡献者。

---

<p align="center">Copyright © 2026 MiaoSir1988 · Licensed under the Apache License, Version 2.0</p>
