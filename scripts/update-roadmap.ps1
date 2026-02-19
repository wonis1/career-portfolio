$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$targetFile = Join-Path $root "CLASS_TRAINING.md"

$startDate = [datetime]"2025-12-18"
$endDate = [datetime]"2026-06-29"
$today = (Get-Date).Date

$totalDays = [int](($endDate - $startDate).TotalDays + 1)
$elapsedRaw = [int](($today - $startDate).TotalDays + 1)

if ($elapsedRaw -lt 0) {
    $elapsed = 0
} elseif ($elapsedRaw -gt $totalDays) {
    $elapsed = $totalDays
} else {
    $elapsed = $elapsedRaw
}

$remaining = $totalDays - $elapsed
$percent = if ($totalDays -eq 0) { 100.0 } else { [math]::Round(($elapsed / $totalDays) * 100, 1) }

$barWidth = 25
$filled = [int][math]::Round(($percent / 100) * $barWidth, 0)
if ($filled -lt 0) { $filled = 0 }
if ($filled -gt $barWidth) { $filled = $barWidth }
$empty = $barWidth - $filled
$bar = ("#" * $filled) + ("-" * $empty)

$content = Get-Content -Raw -Encoding UTF8 $targetFile

$sectionLines = @(
    "## 과정 로드맵 (2025-12-18 ~ 2026-06-29)",
    "",
    "기준일: **$($today.ToString('yyyy-MM-dd'))**  ",
    "전체 기간: **${totalDays}일**  ",
    "경과: **${elapsed}일 (약 $percent%)**  ",
    "잔여: **${remaining}일**",
    "",
    "### Progress",
    "[$bar] $percent%",
    "",
    "### Timeline",
    "- 2025-12-18: 과정 시작",
    "- $($today.ToString('yyyy-MM-dd')): 현재 지점 (진행률 약 $percent%)",
    "- 2026-06-29: 과정 종료",
    "",
    "### Month View",
    "- 2025-12: 시작/적응",
    "- 2026-01: 기초 역량 강화",
    "- 2026-02: 현재 진행 구간",
    "- 2026-03 ~ 2026-04: 심화 학습/프로젝트 집중",
    "- 2026-05 ~ 2026-06: 완성도 강화/마무리"
)

$roadmapSection = ($sectionLines -join "`r`n")
$pattern = "(?s)<!-- ROADMAP:START -->.*?<!-- ROADMAP:END -->"
$replacement = "<!-- ROADMAP:START -->`r`n$roadmapSection`r`n<!-- ROADMAP:END -->"
$updated = [regex]::Replace($content, $pattern, $replacement)

if ($updated -eq $content) {
    throw "ROADMAP markers not found. Ensure CLASS_TRAINING.md contains <!-- ROADMAP:START --> and <!-- ROADMAP:END -->."
}

Set-Content -Path $targetFile -Value $updated -Encoding UTF8
Write-Output "Updated roadmap: $($today.ToString('yyyy-MM-dd')) / $percent%"
