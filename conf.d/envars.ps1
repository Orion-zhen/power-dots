# 对应 envars.fish
$env:LANG = "zh_CN.UTF-8"
$env:NO_PROXY = "localhost,127.0.0.1"

# 模型路径
if (Test-Path "$HOME\models") {
    $env:MODELS = "$HOME\models"
}
else {
    $env:MODELS = "$HOME"
}

# Editor 设置逻辑复刻
if ($env:SSH_TTY) {
    $env:EDITOR = "nvim"
}
elseif (Get-Command code -ErrorAction SilentlyContinue) {
    $env:EDITOR = "code" # code 在 Windows 上不需要 -w 也能工作得很好，视情况而定
}
else {
    $env:EDITOR = "nvim"
}

# 对应 mirrors.fish (国内镜像)
# PowerShell 设置环境变量不需要 export，直接赋值即可
$env:HF_ENDPOINT = "https://hf-mirror.com"
$env:PUB_HOSTED_URL = "https://pub.flutter-io.cn"
$env:FLUTTER_STORAGE_BASE_URL = "https://storage.flutter-io.cn"
$env:RUSTUP_UPDATE_ROOT = "https://mirrors.cernet.edu.cn/rustup/rustup"
$env:RUSTUP_DIST_SERVER = "https://mirrors.cernet.edu.cn/rustup"
# Node/NVM 在 Windows 上通常不需要手动设 URL，如果用 nvm-windows 可以在其 setting.xml 里设

# 对应 path.fish
# Windows 环境变量自动分号分隔，直接追加
$env:PATH += ";$HOME\.local\bin"
$env:PATH += ";$HOME\.cargo\bin"