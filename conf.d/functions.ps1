# 对应 pyvenv.fish
function pyvenv {
    param([string]$Name = ".venv")
    if (Test-Path $Name) {
        Write-Host "虚拟环境 $Name 已存在" -ForegroundColor Yellow
        return
    }
    python -m venv $Name
    # 激活
    if (Test-Path "$Name\Scripts\Activate.ps1") {
        . "$Name\Scripts\Activate.ps1"
    }
}

# 对应 venv.fish (自动向上查找并激活)
function venv {
    param([string]$Name = ".venv")
    
    # 获取当前路径（.Path 确保是字符串）
    $currentDir = (Get-Location).Path
    $found = $false
    
    # 修复：将 $null 放在左侧
    while ($null -ne $currentDir) {
        $activatePath = Join-Path $currentDir "$Name\Scripts\Activate.ps1"
        
        if (Test-Path $activatePath) {
            Write-Host "Activating venv in $activatePath" -ForegroundColor Green
            . $activatePath
            $found = $true
            break
        }
        
        # 获取父目录
        $parent = Split-Path $currentDir -Parent
        
        # 如果父目录为空（已到根目录的上一级）或与当前目录相同（根目录），则停止
        if ([string]::IsNullOrEmpty($parent) -or $parent -eq $currentDir) {
            break
        }
        
        $currentDir = $parent
    }
    
    if (-not $found) {
        Write-Host "No python venv found" -ForegroundColor Red
    }
}

function setprx {
    param(
        [string]$IP,
        [string]$Port
    )
    
    if ($args.Count -eq 2) {
        $env:HTTP_PROXY = "http://$($args[0]):$($args[1])"
        $env:HTTPS_PROXY = "http://$($args[0]):$($args[1])"
        Write-Host "Proxy set to $($args[0]):$($args[1])" -ForegroundColor Green
    }
    elseif ($args.Count -eq 1) {
        $env:HTTP_PROXY = "http://127.0.0.1:$($args[0])"
        $env:HTTPS_PROXY = "http://127.0.0.1:$($args[0])"
        Write-Host "Proxy set to 127.0.0.1:$($args[0])" -ForegroundColor Green
    }
    else {
        Write-Host "Usage: setprx [IP] [PORT]"
        Write-Host "or     setprx [PORT]"
    }
}

function unprx {
    Remove-Item Env:\HTTP_PROXY -ErrorAction SilentlyContinue
    Remove-Item Env:\HTTPS_PROXY -ErrorAction SilentlyContinue
    Write-Host "Proxy unset" -ForegroundColor Yellow
}

function Install-WinGetWithTUI {
    <#
    .SYNOPSIS
        Winget TUI 安装器。
    .DESCRIPTION
        直接解析 winget.exe 的文本输出，避开 Find-WinGetPackage 的性能黑洞。
        速度提升 10 倍以上。
    #>
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Query
    )

    # 1. 设置编码，防止中文乱码 (根据系统可能不需要，但加上保险)
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

    Write-Host "🔍 正在搜索 '$Query' ..." -ForegroundColor Cyan

    # 2. 直接调用 winget.exe 获取纯文本，速度最快
    # --accept-source-agreements 避免首次运行的弹窗卡住脚本
    $rawOutput = winget search $Query --accept-source-agreements 2>&1

    # 3. 快速解析文本
    # winget 的输出格式通常是：Name (空格) Id (空格) Version (空格) Source
    # 我们跳过表头（前2-3行），用正则提取
    $results = $rawOutput | ForEach-Object {
        $line = $_.ToString().Trim()
        
        # 简单的正则：匹配至少两个空格作为分隔符
        # 捕获组: 1=Name, 2=Id, 3=Version, 4=Source(可选)
        if ($line -match '^(.+?)\s{2,}(.+?)\s{2,}(.+?)(?:\s{2,}(.+))?$') {
            $name = $matches[1]
            $id   = $matches[2]
            
            # 过滤掉表头（Name 和 Id 相同的行，或者分隔线）
            if ($name -ne 'Name' -and $name -notmatch '^-+$') {
                [PSCustomObject]@{
                    Name    = $name
                    Id      = $id
                    Version = $matches[3]
                    Source  = if ($matches[4]) { $matches[4] } else { "Unknown" }
                }
            }
        }
    }

    if (-not $results) {
        Write-Warning "未找到与 '$Query' 相关的包，或解析失败。"
        return
    }

    # 4. TUI 展示
    $selected = $results | Out-ConsoleGridView -Title "WinGet 搜索: '$Query'" -OutputMode Single

    # 5. 安装逻辑
    if ($selected) {
        Write-Host "🚀 正在安装: $($selected.Name)" -ForegroundColor Green

        $installCmd = "winget install --id '$($selected.Id)' -e" # -e 表示精确匹配 ID
        Invoke-Expression $installCmd
    }
    # else {
    #     Write-Host "❌ 用户取消了操作。" -ForegroundColor Yellow
    # }
}
