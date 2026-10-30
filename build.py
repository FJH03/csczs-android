#!/usr/bin/env python3
"""Rebuild the APK-derived CZero Android project; native libraries are optional."""
from pathlib import Path
import argparse
import hashlib
import json
import os
import re
import shutil
import struct
import subprocess
import sys
import tempfile
import zipfile

ROOT = Path(__file__).resolve().parent
VERSION = "2.32.10"
ABIS = {"armeabi-v7a": (1, 40), "arm64-v8a": (2, 183)}
ALIASES = {"arm": "armeabi-v7a", "aarch64": "arm64-v8a", **{x: x for x in ABIS}}


def fail(message):
    raise SystemExit(message)


def file_option(value, label):
    if not value or not Path(value).is_file():
        fail("Missing " + label + "; pass the corresponding option or --tools-dir.")
    return Path(value).resolve()


def find_tools(args):
    config_path = ROOT / ".cache" / "tools.json"
    config = json.loads(config_path.read_text(encoding="utf-8")) if config_path.is_file() else {}
    tools_dir = args.tools_dir or config.get("tools_dir") or os.environ.get("CSCZS_TOOLS_DIR") or (ROOT / ".tools" if (ROOT / ".tools").is_dir() else None)
    roots = [Path(tools_dir).resolve()] if tools_dir else []
    roots += [p / "ready" for p in list(roots) if (p / "ready").is_dir()]
    sdk = os.environ.get("ANDROID_HOME") or os.environ.get("ANDROID_SDK_ROOT")
    if sdk:
        roots.append(Path(sdk).resolve())

    def discover(patterns):
        found = []
        for root in roots:
            for pattern in patterns:
                found.extend(p for p in root.glob(pattern) if p.is_file())
        # Prefer newer SDK version numbers when several versions are installed.
        return max(found, key=lambda p: tuple(int(x) for x in re.findall(r"\d+", str(p)))) if found else None

    suffix = ".exe" if os.name == "nt" else ""
    java_home = args.java_home or config.get("java_home") or os.environ.get("JAVA_HOME")
    java = Path(java_home) / "bin" / ("java" + suffix) if java_home else discover(["jdk/*/bin/java" + suffix, "*/bin/java" + suffix])
    javac = Path(java_home) / "bin" / ("javac" + suffix) if java_home else discover(["jdk/*/bin/javac" + suffix, "*/bin/javac" + suffix])
    java = file_option(java or shutil.which("java"), "Java (JDK 17)")
    javac = file_option(javac or shutil.which("javac"), "javac (JDK 17)")
    android = file_option(args.android_jar or config.get("android_jar") or os.environ.get("ANDROID_JAR") or discover(["platform/android-*/android.jar", "platforms/android-*/android.jar"]), "Android SDK android.jar (API 35)")
    d8 = file_option(args.d8_jar or config.get("d8_jar") or os.environ.get("D8_JAR") or discover(["build_tools/*/lib/d8.jar", "build-tools/*/lib/d8.jar"]), "Android build-tools d8.jar")
    apktool = file_option(args.apktool or config.get("apktool") or os.environ.get("APKTOOL_JAR") or discover(["apktool*.jar"]), "apktool 2.12.1 JAR")
    lambdas = file_option(args.lambda_stubs or config.get("lambda_stubs") or d8.parent.parent / "core-lambda-stubs.jar", "build-tools core-lambda-stubs.jar")
    return java, javac, android, d8, apktool, lambdas


def native_directories(root):
    root = Path(root).resolve()
    if not root.is_dir():
        fail("Native library directory does not exist: " + str(root))
    if root.name in ALIASES:
        directories = [root]
    else:
        if (root / "lib").is_dir():
            root = root / "lib"
        directories = [p for p in root.iterdir() if p.is_dir() and p.name in ALIASES]
    result = {}
    for directory in directories:
        abi = ALIASES[directory.name]
        if abi in result:
            fail("Duplicate native directories for " + abi)
        files = sorted(directory.glob("*.so"))
        required = {"libSDL2.so", "liblauncher.so", "libengine.so"}
        missing = required - {p.name for p in files}
        if missing:
            fail(abi + " needs a complete engine library set; missing " + ", ".join(sorted(missing)))
        for file in files:
            with file.open("rb") as source:
                header = source.read(20)
            if len(header) < 20 or header[:4] != b"\x7fELF" or header[5] != 1:
                fail("Expected little-endian Android ELF library: " + str(file))
            if (header[4], struct.unpack_from("<H", header, 18)[0]) != ABIS[abi]:
                fail("Library ABI does not match " + abi + ": " + str(file))
        result[abi] = files
    if not result:
        fail("No armeabi-v7a/arm64-v8a (or arm/aarch64) native directories found.")
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tools-dir", help="Portable tool folder or its ready/ directory")
    parser.add_argument("--java-home")
    parser.add_argument("--android-jar")
    parser.add_argument("--d8-jar")
    parser.add_argument("--apktool")
    parser.add_argument("--lambda-stubs")
    parser.add_argument("--native-libs", help="Complete engine libraries grouped by Android ABI")
    parser.add_argument("--output", help="Unsigned APK output; default is under .cache/dist")
    args = parser.parse_args()
    java, javac, android, d8, apktool, lambdas = find_tools(args)
    native = native_directories(args.native_libs) if args.native_libs else {}
    cache = ROOT / ".cache"
    cache.mkdir(exist_ok=True)
    work = Path(tempfile.mkdtemp(prefix="build-", dir=cache)).resolve()
    logs = work / "logs"
    logs.mkdir()
    framework = cache / "framework"
    environment = os.environ.copy()
    environment["JAVA_HOME"] = str(java.parent.parent)
    environment["PATH"] = str(java.parent) + os.pathsep + environment.get("PATH", "")

    def run(label, command):
        print(label, flush=True)
        result = subprocess.run([str(p) for p in command], cwd=ROOT, env=environment, capture_output=True)
        output = result.stdout + result.stderr
        (logs / (label + ".log")).write_bytes(output)
        if result.returncode:
            fail(output.decode("utf-8", errors="replace")[-8000:] + "\nLogs: " + str(logs))

    stage = work / "apk"
    shutil.copytree(ROOT / "apk", stage)
    # Keep source files immutable: all Java compilation and smali replacement happen in .cache.
    classes, dex = work / "classes", work / "dex"
    classes.mkdir()
    dex.mkdir()
    sources = sorted((ROOT / "java-src").rglob("*.java")) + sorted((ROOT / "compile-stubs").rglob("*.java"))
    response = work / "javac-arguments.txt"
    response.write_text("\n".join('"' + str(p).replace("\\", "/") + '"' for p in sources), encoding="utf-8")
    run("javac-sdl", [javac, "-source", "8", "-target", "8", "-encoding", "UTF-8", "-bootclasspath", os.pathsep.join([str(lambdas), str(android)]), "-d", classes, "@" + str(response)])
    jar = work / "sdl-java.jar"
    with zipfile.ZipFile(jar, "w", zipfile.ZIP_DEFLATED) as archive:
        for path in sorted(classes.rglob("*.class")):
            name = path.relative_to(classes).as_posix()
            if name.startswith("org/libsdl/app/") or name.startswith("com/valvesoftware/RefreshRateController"):
                archive.write(path, name)
    run("d8-sdl", [java, "-cp", d8, "com.android.tools.r8.D8", "--release", "--min-api", "19", "--lib", android, "--output", dex, jar])
    mini = work / "sdl-dex.apk"
    with zipfile.ZipFile(mini, "w", zipfile.ZIP_DEFLATED) as archive:
        archive.write(stage / "AndroidManifest.xml", "AndroidManifest.xml")
        archive.write(dex / "classes.dex", "classes.dex")
    replacement = work / "sdl-smali"
    run("decode-sdl-dex", [java, "-jar", apktool, "d", "-r", "-p", framework, mini, "-o", replacement])
    for smali in stage.glob("smali*"):
        if smali.is_dir() and re.fullmatch(r"smali(?:_classes\d+)?", smali.name):
            old = (smali / "org" / "libsdl" / "app").resolve()
            if old.exists():
                assert old.is_relative_to(stage.resolve())
                shutil.rmtree(old)
    shutil.copytree(replacement / "smali" / "org" / "libsdl" / "app", stage / "smali" / "org" / "libsdl" / "app")
    helpers = stage / "smali" / "com" / "valvesoftware"
    for source in (replacement / "smali" / "com" / "valvesoftware").glob("RefreshRateController*.smali"):
        shutil.copy2(source, helpers / source.name)
    # Never package the compile-time placeholders for these original custom classes.
    assert not (replacement / "smali" / "com" / "valvesoftware" / "ValveActivity2.smali").exists()
    assert not (replacement / "smali" / "me" / "nillerusr" / "DirchActivity.smali").exists()
    copied = []
    version_hints = {}
    for abi, files in native.items():
        destination = stage / "lib" / abi
        destination.mkdir(parents=True)
        for source in files:
            shutil.copy2(source, destination / source.name)
            copied.append("lib/" + abi + "/" + source.name)
        version_hints[abi] = VERSION.encode("ascii") in next(p for p in files if p.name == "libSDL2.so").read_bytes()
    suffix = "" if native else "-pending-native"
    output = Path(args.output).resolve() if args.output else ROOT / ".cache" / "dist" / ("csczs-SDL" + VERSION + suffix + "-unsigned.apk")
    output.parent.mkdir(parents=True, exist_ok=True)
    if output.exists():
        fail("Output already exists; choose another --output path: " + str(output))
    run("apktool-build", [java, "-jar", apktool, "b", "-p", framework, stage, "-o", output])
    with zipfile.ZipFile(output) as archive:
        assert archive.testzip() is None
        actual_native = sorted(n for n in archive.namelist() if n.startswith("lib/") and n.endswith(".so"))
        assert actual_native == sorted(copied)
        assert "classes.dex" in archive.namelist()
    report = {
        "output": str(output), "sha256": hashlib.sha256(output.read_bytes()).hexdigest(),
        "sdl_java_version": VERSION, "min_sdk": 19, "target_sdk": 24,
        "unsigned": True, "abis": sorted(native), "native_libraries": copied,
        "pending_native_libraries": not bool(native), "native_sdl_version_string_hints": version_hints,
        "native_version_and_runtime_compatibility_must_be_verified": True,
        "status": "UNSIGNED; matching SDL2/engine native libraries required" if not native else "UNSIGNED; supplied native compatibility not runtime-tested",
        "work_directory": str(work),
    }
    report_path = output.with_suffix(".build.json")
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(report, ensure_ascii=False, indent=2))
    if not native:
        print("PENDING NATIVE: this APK contains no .so files and cannot run the game yet.")


if __name__ == "__main__":
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(errors="backslashreplace")
    main()
