# 1. 导入模块
Import-Module Terminal-Icons
Import-Module posh-git
Import-Module PSFzf

# 2. 配置 Git 补全 (仅补全，不修改 Prompt)
$GitPromptSettings.EnablePromptStatus = $false

# 3. 配置 PSReadLine (最像 Fish 的部分)
if (Get-Module -Name PSReadLine) {
    # --- 核心交互逻辑 ---
    # 1. 将 Tab 键绑定为 "MenuComplete" (关键修改)
    # 这会在光标下方绘制一个交互式的选择菜单，而不是直接把结果打印到屏幕上
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

    # 2. 设置补全菜单的样式
    # ListView: 列表视图 (详细，适合有描述的补全)
    # InlineView: 行内视图 (适合 Fish 风格)
    # 建议配合 Carapace 使用 ListView，能看到更多参数说明
    Set-PSReadLineOption -PredictionViewStyle InlineView

    # 3. 启用预测源
    # 让 PSReadLine 同时使用历史记录(History)和插件(Plugin, 如 Carapace)作为预测来源
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin

    # --- 视觉与体验微调 ---
    # 4. 颜色设置 (可选)
    # 让选中的项背景色变为显眼的颜色 (类似你 Fish 配置中的黄色)
    Set-PSReadLineOption -Colors @{
        Selection = "`e[30;43m"  # 黑字黄底
        InlinePrediction = "`e[38;5;246m" # 灰色预测文字
    }

    # 5. 绑定接受预测的快捷键
    # 习惯：按右箭头接受灰色的预测文字，按 Tab 呼出菜单选择参数
    Set-PSReadLineKeyHandler -Key Tab -Function AcceptSuggestion
}

if (Get-Module -Name PSFzf) {
    # 绑定 FZF 快捷键
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

# 这里的 Invoke-Expression 对应 Fish 的 eval
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

if (Get-Command atuin -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (atuin init powershell | Out-String) })
}

# FZF 配置 (对应 fzf.fish)
if (Get-Module PSFzf) {
    # 对应 fd.fish 中的 FZF_DEFAULT_COMMAND
    $env:FZF_DEFAULT_COMMAND = "fd --hidden --follow --exclude .git"
    $env:FZF_CTRL_T_COMMAND = $env:FZF_DEFAULT_COMMAND
    $env:FZF_ALT_C_COMMAND = "fd --type d --hidden --follow --exclude .git"
    
    # 绑定按键 (Ctrl+T, Ctrl+R 等)
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

# 初始化 Carapace
if (Get-Command carapace -ErrorAction SilentlyContinue) {
    # 启用 Powershell 的补全桥接
    $env:CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' 
    Invoke-Expression (& { (carapace _carapace | Out-String) })
}

# Crtl+D 退出终端
Set-PSReadlineKeyHandler -Key "Ctrl+d" -Function ViExit
# Ctrl+Z 撤销
Set-PSReadLineKeyHandler -Key "Ctrl+z" -Function Undo