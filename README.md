# LZU Timetable（兰州大学课程表）

本项目英文名称为 **LZU Timetable**，是以 Flutter 为框架、99%使用Codex开发并适配兰州大学教务系统的课程表应用。

特点：

- Android 端支持直接从教务系统导入课程表。
- 所有数据本地存储，不受网络和服务限制。
- 全端支持从手动导出的教务系统课程 HTML 解析课程数据，支持按学期、周次查看表格课程表。
- 支持多学期课程查看管理，支持课程增删改以应对调课情况，也可当作日程表使用。
- 支持跟随系统、浅色和深色主题。


## 开始使用

在Release下载最新版本安装并使用

TODO：更详细的使用指引

## 课程解析与本地存储

课程导入采用“解析后立即规范化”的流程：

1. 手动粘贴/上传 HTML，或由 Android 教务系统 WebView 在用户点击识别时临时取得当前页面 DOM。
2. `SemesterImporter` 只读取课程表，提取课程号、课程序号、名称、教师和原始上课安排。
3. 教务系统的 48 种时间文字通过 `AcademicPeriodMappings` 映射为统一的起止节次；14 个单节的标签与起止时间由 `TimetableSections` 硬编码提供。
4. 周次表达式在导入时展开为具体周数。运行期课程只保留 `week + weekday + startSection + endSection + location`，不保存周次规则文本、periods 数组或原始 HTML。
5. `TimetableRepository` 在一个事务中将解析结果写入 Drift/SQLite 的关系表。

本地数据库使用以下规范化结构：

- `schedules`：课表名称、第一周星期一、用户设置的总周数。
- `courses`：课程稳定 ID、来源类型、导入匹配键和教务系统链接。导入课程以 `课程号 + 课程序号` 唯一匹配；手动课程使用本地自增 ID。
- `course_versions`：课程基础版本和可选的本地覆盖版本。读取时优先本地覆盖，因此重新导入只更新基础版本，不会清除用户修改。
- `course_teachers`：有序教师列表。
- `course_meetings`：去重后的星期、起止节次和地点组合。
- `meeting_weeks`：一次上课组合对应的具体周次。
- `effective_course_versions`：统一选择当前有效版本的 SQLite 视图。

重新导入时，数据库先把该课表原有导入课程标记为“源中缺失”，再按导入匹配键更新或插入基础数据。课程暂时从教务系统结果中消失时不会删除其本地覆盖；以后再次出现，仍使用原稳定 ID 并恢复原覆盖。课程表、课程、教师、时间组合和周次的删除均由外键级联处理。

课表数据不再存入 `shared_preferences` JSON。项目不读取旧课表记录，也不提供旧格式迁移；`shared_preferences` 仅保留主题偏好等轻量设置。Web 端随应用发布与锁定依赖版本匹配的 `sqlite3.wasm` 和 `drift_worker.dart.js`，Android 使用本地 SQLite 文件。

## 开发命令

- 安装依赖：`flutter pub get`
- 运行测试：`flutter test`
- 构建 Web：`flutter build web`
- Web 本地预览：`flutter run -d web-server`
- 构建 Android 调试 APK：`flutter build apk --debug`
- 构建 Android release APK：`flutter build apk --release`
- 运行 Android 设备或模拟器：`flutter run -d <device-id>`

## Android release 签名

复制示例文件并填写本机 keystore 信息：

```powershell
Copy-Item android\key.properties.example android\key.properties
```

`android/key.properties` 和 keystore 文件不会提交到仓库。填写完成后运行：

```powershell
flutter build apk --release
flutter build appbundle --release
```

## 项目标识

- 仓库名建议：`lzu-timetable`
- Flutter/Dart package：`lzu_timetable`
- Android applicationId：`com.jerry.lzutimetable`
