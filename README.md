# LZU Timetable（兰州大学课程表）

本项目英文名称为 **LZU Timetable**，是以 Flutter 为框架、99%使用Codex开发并适配兰州大学教务系统的课程表应用。

特点：
- Android 端支持直接从教务系统导入课程表。
- 所有数据本地存储，不受网络和服务限制。
- 全端支持从手动导出的教务系统课程 HTML 解析课程数据，支持按学期、周次查看表格课程表。
- 支持多学期课程查看管理，支持课程增删改以应对调课情况，也可当作日程表使用。


## 开始使用

在Release下载最新版本安装并使用

TODO：更详细的使用指引

## 开发命令

- 安装依赖：`flutter pub get`
- 运行测试：`flutter test`
- 构建 Web：`flutter build web`
- Web 本地预览：`flutter run -d web-server`
- 构建 Android 调试 APK：`flutter build apk --debug`
- 构建 Android release APK：`flutter build apk --release`
- 运行 Android 设备或模拟器：`flutter run -d <device-id>`

## 项目标识

- 仓库名建议：`lzu-timetable`
- Flutter/Dart package：`lzu_timetable`
- Android applicationId：`com.jerry.lzutimetable`
