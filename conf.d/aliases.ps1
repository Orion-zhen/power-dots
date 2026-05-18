# 基础别名
function fishcfg { code $PROFILE } # 对应 code ~/.config/fish/
function mkfish { . $PROFILE }     # 对应 source config.fish
Set-Alias vs code
function dbd { docker build $args }
Set-Alias dcp docker-compose

# 对应 grep -> rg
if (Get-Command rg -ErrorAction SilentlyContinue) {
    Set-Alias grep rg
}

# 对应 cat -> bat
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Remove-Item -Path alias:cat -Force -ErrorAction SilentlyContinue
    New-Alias -Name cat -Value bat -Scope Global -Description "better cat"
}

# 对应 zoxide
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Remove-Item -Path alias:cd -Force -ErrorAction SilentlyContinue
    New-Alias -Name cd -Value z -Scope Global -Description "modern cd by zoxide"
}

# 对应 fastfetch
if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
    Set-Alias ff fastfetch
    Set-Alias fetch fastfetch
}

# 对应 ls, ll, la (使用 eza)
if (Get-Command eza -ErrorAction SilentlyContinue) {
    # 对应 functions/ls.fish
    function ls { 
        Remove-Item -Path alias:ls -Force -ErrorAction SilentlyContinue
        eza --icons --group-directories-first --header --long --git --no-user --no-permissions --no-time $args 
    }
    # 对应 functions/ll.fish
    function ll { eza --icons --group-directories-first --header --long --git --no-user --no-permissions $args }
    # 对应 functions/la.fish
    function la { eza --icons --group-directories-first --header --long --git --all $args }
    # 对应 functions/tree.fish
    function tree { eza --icons --group-directories-first --tree $args }
} else {
    function ll { Get-ChildItem -Verbose $args }
    function la { Get-ChildItem -Force $args }
}

# 设置一个简短的别名，比如 'winstall' 或 'ws'
Set-Alias -Name winstall -Value Install-WinGetWithTUI
