# 将Perfect Cut部署到Vercel

这个指南将帮助你将Perfect Cut Flutter游戏部署到Vercel，使其可以在网页浏览器中访问。

## 准备工作

1. 确保你已经有一个[Vercel账户](https://vercel.com/signup)
2. 确保你的项目已推送到GitHub仓库
3. 确保项目中已包含`vercel.json`配置文件

## 部署步骤

### 1. 构建Flutter Web应用

如果你需要重新构建应用，请运行以下命令：

```bash
cd perfect_cut
flutter clean
flutter pub get
flutter build web
```

### 2. 在Vercel上部署

#### 通过Vercel CLI部署

1. 安装Vercel CLI：
   ```bash
   npm i -g vercel
   ```

2. 进入项目目录并运行：
   ```bash
   cd perfect_cut
   vercel
   ```

3. 按照提示完成部署设置。

#### 通过Vercel网站部署

1. 访问[Vercel Dashboard](https://vercel.com/dashboard)
2. 点击"New Project"
3. 导入你的GitHub仓库
4. 在配置页面上：
   - 框架预设选择"Other"
   - 构建命令留空（我们已经预先构建了web版本）
   - 输出目录保持默认
5. 点击"Deploy"按钮

## 验证部署

部署完成后，Vercel将提供一个URL（例如`https://perfect-cut.vercel.app`）。访问这个URL确认游戏可以正常运行。

## 自定义域名（可选）

如果你希望使用自定义域名：

1. 在Vercel项目页面，点击"Domains"
2. 添加你的自定义域名并按照指示设置DNS记录

## 部署问题排查

如果遇到部署问题：

- 确保`vercel.json`配置正确
- 检查`build/web`目录是否包含完整的web构建文件
- 查看Vercel部署日志了解详细错误信息

## 更新部署

每当你更新代码并想重新部署时：

1. 重新构建web版本：`flutter build web`
2. 将更改推送到GitHub
3. Vercel将自动检测更改并重新部署

若有任何问题，请参考[Vercel文档](https://vercel.com/docs)或[Flutter Web部署文档](https://flutter.dev/docs/deployment/web)。 