# 课程表

Flutter 课程表应用，当前支持 Web 和 Android。应用从教务系统课程 HTML 解析课程数据，支持按学期、周次查看表格课程表。课程表的添加、修改、删除统一在“管理课程表”页面完成，添加与修改都支持粘贴或上传 HTML 并预览。

Android 端还支持“教务系统导入”：在管理页选择“添加”后进入内嵌教务系统页面，用户自行完成 SSO 登录、选择学期并查询，再点击“识别当前页面”。识别后仍需填写第一周星期一日期并确认添加。Web 端受浏览器同源策略限制，继续使用粘贴或上传 HTML 导入。

教务系统账号和密码仅在官方 SSO 页面内输入，应用不会读取或保存。导入页的“保留登录状态”开关默认开启；关闭后离开该页面会清除应用内 WebView Cookie。

教务系统当前登录跳转链包含 `jwk.lzu.edu.cn` 的 HTTP 页面，Android 仅对此白名单域名放行明文流量；应用未启用全局明文 HTTP。

## 开发命令

- 安装依赖：`flutter pub get`
- 运行测试：`flutter test`
- 构建 Web：`flutter build web`
- Web 本地预览：`flutter run -d web-server`
- 构建 Android 调试 APK：`flutter build apk --debug`
- 运行 Android 设备或模拟器：`flutter run -d <device-id>`

## 数据

应用初次安装不包含任何内置课表。原始教务系统 HTML 样例仅保存在仓库的 `assets/raw/` 中，供解析测试使用，未打包进 Web 或 Android 应用。用户导入时先解析 HTML，随后只在本地保存课程表的结构化 JSON；周次表达会展开为逐周的独立节次，JSON 中不保留周次规则文本。修改课表时可直接复用 JSON，只有需要重新解析课程时才重新提供 HTML。

## Android

Android 包名为 `com.jerry.course_schedule`，启动器名称为“课程表”。
