# 课程表

Flutter 课程表应用，当前支持 Web 和 Android。应用从教务系统课程 HTML 解析课程数据，支持按学期、周次查看表格课程表。课程表的添加、修改、删除统一在“管理课程表”页面完成，添加与修改都支持粘贴或上传 HTML 并预览。

## 开发命令

- 安装依赖：`flutter pub get`
- 运行测试：`flutter test`
- 构建 Web：`flutter build web`
- Web 本地预览：`flutter run -d web-server`
- 构建 Android 调试 APK：`flutter build apk --debug`
- 运行 Android 设备或模拟器：`flutter run -d <device-id>`

## 数据

原始教务系统 HTML 样例保存在 `assets/raw/`。课程导入流程复用同一套解析服务，避免手工维护派生数据。

## Android

Android 包名为 `com.jerry.course_schedule`，启动器名称为“课程表”。
