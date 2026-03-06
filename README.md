# Seedbox 自动化安装脚本

> **自用版本** - 基于 [inexistence](https://github.com/Aniverse/inexistence) 项目优化  
> 专注于 Debian 13 兼容性和现代化功能

## 🎉 2026.03.06 重大更新

### Debian 13 完全兼容
- ✅ 完全支持 Debian 11/12/13 (bullseye/bookworm/trixie)
- ✅ 更新 APT 源配置，支持新安全源格式
- ✅ 添加 `non-free-firmware` 组件支持
- ✅ 完全移除 Python 2.7 支持，统一使用 Python 3
- ✅ 保持对 Debian 9/10 和 Ubuntu 16.04/18.04 的向后兼容

### 🚀 新增 autobrr 功能
- ✅ 全新的 autobrr 安装和配置脚本
- ✅ 支持 IRC announce 监控和 RSS 订阅
- ✅ 完整的 Web UI 管理（默认端口 7474）
- ✅ 支持多个下载客户端集成
- ✅ 完全使用 Python 3，兼容 Debian 11/12/13

### 📝 其他改进
- ✅ 修复 Deluge 安装脚本语法错误
- ✅ 更新所有依赖和版本检测
- ✅ 完善的测试套件（171 个测试，100% 通过）

---

## 系统要求

### 支持的操作系统
- **Debian** 9/10/11/12/13（推荐 Debian 12/13）
- **Ubuntu** 16.04/18.04（推荐 18.04）
- 仅支持 **x86_64 (amd64)** 架构

### 硬件要求
- **内存**: 最小 512MB（推荐 2GB+）
- **磁盘**: 最小 2GB（推荐 10GB+）
- **网络**: 需要访问 GitHub 和官方软件源

### 虚拟化支持
- ✅ KVM（推荐）
- ✅ 独立服务器
- ⚠️ OpenVZ/Xen（可能有问题）

---

## 快速开始

### 一键安装（推荐）

```bash
bash <(wget --no-check-certificate -qO- https://github.com/HommeAAA/seedbox/raw/master/inexistence.sh) \
-y --tweaks --bbr --rclone --no-system-upgrade --flexget --autobrr --tr-deb --filebrowser \
--de 1.3.15 --rt 0.9.8 --qb 4.3.9 -u 你的用户名 -p 你的密码
```

### 交互式安装

```bash
bash <(wget --no-check-certificate -qO- https://github.com/HommeAAA/seedbox/raw/master/inexistence.sh)
```

---

## 常见使用场景

### 场景 1：最小化安装（适合小内存 VPS）

```bash
bash <(wget --no-check-certificate -qO- https://github.com/HommeAAA/seedbox/raw/master/inexistence.sh) \
-y --qb 4.3.9 --no-de --no-rt --no-tr --flexget --autobrr \
--tweaks --swap --mt-half -u username -p password123
```

**适合**: 1GB 内存 VPS，只安装必要组件

### 场景 2：标准安装（推荐）

```bash
bash <(wget --no-check-certificate -qO- https://github.com/HommeAAA/seedbox/raw/master/inexistence.sh) \
-y --qb 4.3.9 --de 1.3.15 --rt 0.9.8 --flexget --autobrr --filebrowser \
--tweaks --bbr -u username -p password123
```

**适合**: 2GB+ 内存 VPS，完整功能

### 场景 3：Debian 13 专用安装

```bash
bash <(wget --no-check-certificate -qO- https://github.com/HommeAAA/seedbox/raw/master/inexistence.sh) \
-y --qb 4.3.9 --de 2.0.3 --rt 0.9.8 --flexget --autobrr --filebrowser \
--tweaks --bbr -u username -p password123
```

**适合**: Debian 13 系统，使用最新版本软件

### 场景 4：只安装 autobrr

```bash
bash <(wget --no-check-certificate -qO- https://github.com/HommeAAA/seedbox/raw/master/inexistence.sh) \
-y --autobrr --no-qb --no-de --no-rt --no-tr --no-flexget --no-filebrowser \
--tweaks -u username -p password123
```

**适合**: 已有 BT 客户端，只需要 autobrr 自动化工具

---

## 命令行参数说明

### 通用参数
- `-y` - 跳过所有确认提示，无交互安装
- `-u <username>` - 设置用户名（4-16 位，字母开头）
- `-p <password>` - 设置密码（至少 8 位，包含字母和数字）
- `-s` - 跳过系统支持检查
- `--no-source-change` - 不更换软件源

### BT 客户端参数
- `--qb <version>` - 安装 qBittorrent（如：--qb 4.3.9）
- `--qb-static` - 使用静态编译版本
- `--no-qb` - 不安装 qBittorrent
- `--de <version>` - 安装 Deluge（如：--de 1.3.15）
- `--no-de` - 不安装 Deluge
- `--rt <version>` - 安装 rTorrent（如：--rt 0.9.8）
- `--no-rt` - 不安装 rTorrent
- `--tr-deb` - 安装 Transmission（deb 版本）
- `--no-tr` - 不安装 Transmission

### 自动化工具参数
- `--flexget` - 安装 FlexGet
- `--no-flexget` - 不安装 FlexGet
- `--autobrr` - 安装 autobrr（🆕 推荐）
- `--no-autobrr` - 不安装 autobrr

### 系统优化参数
- `--tweaks` - 启用系统优化（默认启用）
- `--no-tweaks` - 禁用系统优化
- `--bbr` - 启用 BBR 拥塞控制
- `--no-bbr` - 禁用 BBR
- `--swap` - 启用 swap
- `--no-swap` - 禁用 swap
- `--rclone` - 安装 rclone 和 gclone
- `--tools` - 安装额外工具（mediainfo、mkvtoolnix、ffmpeg 等）

### 其他工具参数
- `--filebrowser` - 安装 FileBrowser Enhanced
- `--no-filebrowser` - 不安装 FileBrowser
- `--flood` - 安装 Flood（rTorrent WebUI）
- `--vnc` - 安装 VNC 远程桌面
- `--x2go` - 安装 X2Go 远程桌面
- `--wine` - 安装 Wine
- `--mono` - 安装 Mono

### 编译参数
- `--mt-single` - 单线程编译
- `--mt-double` - 双线程编译
- `--mt-half` - 使用一半 CPU 线程编译
- `--mt-max` - 使用全部 CPU 线程编译（默认）

### libtorrent 参数
- `--lt RC_1_1` - 使用 libtorrent RC_1_1（默认）
- `--lt RC_1_0` - 使用 libtorrent RC_1_0
- `--lt system` - 使用系统自带版本
- `--lt <version>` - 使用指定版本

---

## 功能模块说明

### BT 客户端

#### 1. qBittorrent
- 静态编译版本，安装快速
- 支持 4.x 版本
- WebUI 界面

#### 2. Deluge
- 支持 1.3.x 和 2.0.3 版本
- 1.3.15 为稳定版本
- 2.0.3 使用 Python 3
- 预装常用插件

#### 3. rTorrent
- 支持 0.9.x 版本
- ruTorrent WebUI
- Flood 可选安装
- 支持 IPv6

#### 4. Transmission
- deb 版本安装
- 增强版 WebUI

### 自动化工具

#### 1. FlexGet
- 强大的 RSS 自动化工具
- WebUI 管理界面
- daemon 模式运行

#### 2. autobrr 🆕
- **现代化下载自动化工具**
- 支持 75+ 私有 PT 站点的 IRC announce 监控
- 实时抓取种子，参与初始 swarm
- 支持 Torznab、Newznab 和标准 RSS
- 集成多个下载客户端
- Web UI 管理界面（http://ip:7474）
- 支持通知（Discord、Telegram 等）

### 其他工具

#### 1. FileBrowser Enhanced
- 网页文件管理器
- 支持 mediainfo、截图、制作种子
- Docker 版本

#### 2. rclone
- 网盘同步工具
- 包含 gclone

#### 3. 系统优化
- vnstat 流量统计
- 时区设置
- BBR 加速
- swap 管理

---

## 安装后访问

### WebUI 地址

- **qBittorrent**: http://ip:8080
- **Deluge**: http://ip:8112
- **rTorrent/ruTorrent**: http://ip/rutorrent
- **Transmission**: http://ip:9091
- **FlexGet**: http://ip:9566
- **autobrr**: http://ip:7474
- **FileBrowser**: http://ip:7575

### 服务管理

```bash
# qBittorrent
systemctl status qbittorrent@username

# Deluge
systemctl status deluged@username
systemctl status deluge-web@username

# rTorrent
systemctl status rtorrent@username

# Transmission
systemctl status transmission@username

# FlexGet
systemctl status flexget@username

# autobrr
systemctl status autobrr@username

# FileBrowser
systemctl status filebrowser@username
```

---

## 注意事项

### 安装前
1. **推荐全新安装系统后使用**
2. 需要 root 权限运行
3. 确保网络畅通，能访问 GitHub
4. 建议内存 2GB+

### 安装中
1. 安装时间约 20-40 分钟
2. 编译过程可能需要较长时间
3. 内存不足时自动启用 swap

### 安装后
1. 记住各服务的 WebUI 地址和端口
2. 配置文件位置：
   - qBittorrent: `~/.config/qBittorrent/`
   - Deluge: `~/.config/deluge/`
   - rTorrent: `~/.rtorrent.rc`
   - FlexGet: `~/.config/flexget/`
   - autobrr: `~/.config/autobrr/`
3. 日志位置：`/var/log/inexistence/`

---

## 故障排除

### 常见问题

1. **安装失败**
   - 检查日志：`cat /var/log/inexistence/inexistence.log`
   - 确认系统版本支持
   - 检查网络连接

2. **服务无法启动**
   - 检查服务状态：`systemctl status service@username`
   - 查看服务日志：`journalctl -u service@username`
   - 检查端口占用：`netstat -tulpn | grep port`

3. **WebUI 无法访问**
   - 检查防火墙设置
   - 确认服务已启动
   - 检查端口是否正确

4. **autobrr 无法连接 IRC**
   - 检查网络连接
   - 确认 IRC 服务器地址
   - 查看 autobrr 日志

---

## 测试报告

本项目包含完整的测试套件：

- **单元测试**: 88 个测试，100% 通过
- **集成测试**: 55 个测试，100% 通过
- **端到端测试**: 28 个测试，100% 通过
- **本地模拟测试**: 49 个测试，100% 通过

详细测试报告请查看：
- [TEST_REPORT.md](TEST_REPORT.md)
- [E2E_TEST_REPORT.md](E2E_TEST_REPORT.md)
- [COMPREHENSIVE_REVIEW.md](COMPREHENSIVE_REVIEW.md)

---

## 更新日志

### 2026.03.06
- ✅ 添加 Debian 13 完全支持
- ✅ 新增 autobrr 功能
- ✅ 移除 Python 2.7 支持
- ✅ 更新 APT 源配置
- ✅ 修复 Deluge 安装脚本
- ✅ 完善测试套件

### 2021.07.30
- 原项目最后更新

---

## 致谢

本项目基于以下开源项目：
- [inexistence](https://github.com/Aniverse/inexistence) - 原始项目
- [QuickBox Lite](https://github.com/amefs/quickbox-lite)
- [swizzin](https://swizzin.ltd)
- [autobrr](https://github.com/autobrr/autobrr)

---

## 许可证

本项目继承原项目的开源许可证。

---

## 免责声明

本脚本仅供学习和个人使用。使用本脚本产生的任何问题，作者不承担责任。请遵守当地法律法规和 PT 站点规则。
