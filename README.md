# CZero Android 启动器

《CS 零点行动：起源》的 Android 启动器与 APK 重建工程，基于原 APK 整理。自定义启动器保留为 smali，SDL Java 层使用 SDL2 **2.32.10**，通过 `build.py` 完成 Java → DEX → smali → APK 构建，无需 Gradle 或 Android Studio。

当前适配包括：支持的设备优先请求同分辨率的 120 Hz 模式；游戏在独立的 `:game` 进程运行，退出完成引擎清理后结束游戏进程，保留启动器。ARM64 已实机验证连续退出、重新进入；ARM32 支持打包，尚未进行本轮实机验证。

## 目录

| 路径 | 用途 |
| --- | --- |
| `apk/` | Manifest、资源、assets、自定义启动器 smali 与 apktool 配置 |
| `apk/assets/extras_dir.vpk` | 随 APK 打包的附加资源，保留原文件名与启动器中的引用 |
| `java-src/` | SDL2 Java 源码及刷新率控制代码 |
| `compile-stubs/` | Java 编译时使用的自定义类声明，不会打入 APK |
| `build.py` | APK 构建入口 |
| `.cache/` | 自动生成的构建目录、日志、工具配置和输出，不提交 |
| `.tools/` | 可选的本地工具目录，不提交 |

仓库不包含原生 `.so`。引擎动态库由外部构建，在打包时通过 `--native-libs` 注入；`extras_dir.vpk` 已包含在仓库中，完整游戏资源仍需另行准备。

## 准备工具

| 工具 | 使用版本 / 所需内容 |
| --- | --- |
| [Python](https://www.python.org/downloads/) | 3.9 或更高版本，无额外 pip 依赖 |
| [JDK](https://adoptium.net/temurin/releases/?version=17) | JDK 17，需包含 `java`、`javac` |
| [Android SDK Command-Line Tools](https://developer.android.com/studio#command-tools) | 安装 Platform API 35 与 Build-Tools 35.0.0 |
| [apktool](https://github.com/iBotPeaches/Apktool/releases/tag/v2.12.1) | `apktool_2.12.1.jar` |

安装 SDK 包可使用 Command-Line Tools 的 [sdkmanager](https://developer.android.com/tools/sdkmanager)：

```sh
sdkmanager "platforms;android-35" "build-tools;35.0.0"
```

构建使用 SDK 中的 `android.jar`、`lib/d8.jar`、`core-lambda-stubs.jar`；对齐使用同一套 Build-Tools 的 `zipalign`。

### 工具路径

可通过参数指定已有安装。下面的目录为占位符，请替换成自己的工具路径；命令可在项目根目录执行：

```sh
python build.py --java-home "JDK目录" --android-jar "SDK目录/platforms/android-35/android.jar" --d8-jar "SDK目录/build-tools/35.0.0/lib/d8.jar" --apktool "工具目录/apktool_2.12.1.jar" --native-libs "native-libs" --output "dist/csczs-unsigned.apk"
```

也可按以下布局放置工具，脚本会自动发现项目下的 `.tools/`：

```text
.tools/
├── jdk/<JDK目录>/bin/java[.exe]
├── jdk/<JDK目录>/bin/javac[.exe]
├── platforms/android-35/android.jar
├── build-tools/35.0.0/lib/d8.jar
├── build-tools/35.0.0/core-lambda-stubs.jar
└── apktool_2.12.1.jar
```

请保留各工具的完整安装目录，上面仅列出脚本需要定位的文件。工具放在其他位置时可使用 `--tools-dir` 指定；`JAVA_HOME`、`ANDROID_HOME` / `ANDROID_SDK_ROOT`、`APKTOOL_JAR` 等环境变量也可使用。全部选项见 `python build.py --help`。

## 注入动态库并构建

按 ABI 准备完整的引擎库集合，可只提供需要打包的一种架构：

```text
native-libs/
├── armeabi-v7a/
│   ├── libSDL2.so
│   ├── liblauncher.so
│   ├── libengine.so
│   └── 其余依赖的 .so
└── arm64-v8a/
    ├── libSDL2.so
    ├── liblauncher.so
    ├── libengine.so
    └── 其余依赖的 .so
```

`--native-libs` 也接受外面多一层 `lib/` 的布局，或直接指向某个 ABI 目录；`arm`、`aarch64` 可分别作为两个 ABI 的别名。脚本会检查 ELF 架构，并打包对应目录下的所有 `.so`。

`libSDL2.so` 必须匹配本项目 SDL2 **2.32.10** 的 Java/JNI 接口，其余库也需来自兼容的引擎构建。脚本只检查文件结构与架构，动态库是否能共同运行仍需实机验证。

工具已配置后，执行：

```sh
python build.py --native-libs native-libs --output dist/csczs-unsigned.apk
```

产物为未签名 APK，旁边的 `.build.json` 记录哈希、ABI 和构建目录。未指定 `--output` 时，默认写入 `.cache/dist/`；输出文件已存在时需换一个名称或先处理旧文件。

只检查 Java 和 APK 资源构建时，可执行 `python build.py`。此时默认产物名称带有 `pending-native`，没有动态库，不能启动游戏。

Manifest 的 `minSdkVersion` 为 19，`targetSdkVersion` 为 24。实际最低 Android 版本还取决于注入的原生库；当前配套 SDL2 库按 API 21 构建。

### 游戏 Build 编号与 APK 名称

APK 的版本名与默认文件名使用游戏内 `version` 命令输出的 `Build:` 编号。将该输出保存为文本后，可直接传入：

```sh
python build.py --native-libs native-libs --version-log game-version.log
```

也可用 `--build-number 编号` 显式指定。自动打包时，可随动态库提供 `native-libs/build-number.txt`，文件内容为该编号，脚本会自动读取，无需修改 APK 源码。多个 ABI 的目录也可各自携带此文件；编号不一致时停止构建。

例如，游戏编号为 923 且只传入 ARM64 动态库时，APK 版本名为 `Build 923`，默认文件名为 `csczs-build 923-arm64-v8a-unsigned.apk`。文件名统一小写，`build` 和编号之间保留一个空格。显式指定 `--output` 时保留指定文件名。编号只写入暂存工程，不会改动源码中的版本模板。

未提供编号时，版本名为 `Development`，默认文件名包含 `development`。脚本不会用打包日期或启动器 Git 提交数猜测游戏版本。编号应来自本次打包的引擎构建；后续工作流可以把同源编号与动态库一起交给本脚本，APK 仍为未签名产物。

## 对齐、签名和安装

`build.py` 本身输出未签名 APK；引擎仓库的 GitHub Actions 会继续执行对齐、公开测试签名和校验，并分别上传 ARM32、ARM64 成品，例如 `csczs-build 923-arm64-v8a-signed.apk`。下载安装即可，无需再用 MT 签名。lib 下载包的名称不带 Build 编号。

工作流使用 [AOSP 官方公开 testkey](https://android.googlesource.com/platform/build/+/refs/tags/android-15.0.0_r1/target/product/security/)，在运行时下载并校验哈希，不需要 GitHub Secrets，也不会读取或上传你的个人签名密钥。两种架构和后续构建使用同一个证书，证书 SHA-256 为：

```text
a40da80a59d170caa950cf15c18c454d47a39b26989d8b640ecd745ba71bf5dc
```

这套密钥本来就是公开的，任何人都能用它签名，不作为发布者身份凭据。覆盖安装要求已安装版本的证书相同；使用同一 AOSP testkey 的 MT 签名版本可以保持更新兼容，其他签名需另行处理。

如果本地构建后希望手动签名，将 Build-Tools 目录加入 `PATH` 后，可先对齐 APK：

```sh
zipalign -P 16 -f 4 dist/csczs-unsigned.apk dist/csczs-aligned.apk
```

随后可使用 MT 管理器手动签名并安装。按照 [zipalign](https://developer.android.com/tools/zipalign) 的要求，先对齐再签名，签名后不再修改 APK；覆盖安装现有应用时需沿用原签名。

## 修改入口

- 启动流程、进程与权限：`apk/AndroidManifest.xml`、`java-src/org/libsdl/app/SDLActivity.java`。
- 启动器与路径、参数处理：`apk/smali/me/nillerusr/`、`apk/smali/com/valvesoftware/ValveActivity2.smali`。
- 120 Hz 请求：`java-src/com/valvesoftware/RefreshRateController.java`，实际刷新率由设备支持的模式与系统策略决定。
- 应用包名、版本号和 SDK 声明：`apk/apktool.yml`；实际打包的包名由 `renameManifestPackage` 指定。

构建会在 `.cache/` 内合并生成的 SDL smali，`apk/` 中的自定义 smali 和原始资源保持为构建输入。

## 第三方内容

SDL2 Java 代码基于 [SDL 官方 release-2.32.10](https://github.com/libsdl-org/SDL/tree/release-2.32.10)，并进行了上述启动流程、刷新率与进程退出适配；其许可见 [LICENSES/SDL2.txt](LICENSES/SDL2.txt)。`apk/assets/` 中的字体保留了文件内嵌的版权与许可声明。第三方代码和资源的原有版权及许可继续适用。
