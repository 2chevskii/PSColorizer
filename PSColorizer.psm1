using namespace System
using namespace System.Text.RegularExpressions

$Regexp_Pattern = '(?:<([a-z]+)>(.*?)<\/\1>)|((?:(?!<([a-z]+)>.*<\/\4>).)+)'

$Regexp = [regex]::new($Regexp_Pattern, [RegexOptions]::IgnoreCase)

function Write-Colorized {
    [CmdletBinding(PositionalBinding = $true, HelpUri = 'https://github.com/2chevskii/PSColorizer#README')]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $true)]
        [string]$InputObject,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ValueFromRemainingArguments = $false, Position = 1)]
        [ConsoleColor]$DefaultColor
    )

    if (!$DefaultColor) {
        $DefaultColor = $Host.UI.RawUI.ForegroundColor
    }

    [MatchCollection]$matches = $Regexp.Matches($InputObject)

    if ($matches.Count -gt 0) {
        $colored_messages = @()

        foreach ($match in $matches) {
            if ($match.Groups[3].Length -gt 0) {
                $colored_messages += @{
                    'color' = $DefaultColor
                    'text'  = $match.Groups[3].Value
                }
            } else {
                $colored_messages += @{
                    'color' = $match.Groups[1].Value
                    'text'  = $match.Groups[2].Value
                }
            }
        }

        for ($i = 0; $i -lt $colored_messages.Length - 1; $i++) {
            Set-ConsoleColor -Color $colored_messages[$i]['color']
            Write-Message -Text $colored_messages[$i]['text']
        }

        Set-ConsoleColor -Color $colored_messages[$colored_messages.Length - 1]['color']
        Write-Message -Text $colored_messages[$colored_messages.Length - 1]['text'] -NewLine
        Set-ConsoleColor -Color $DefaultColor
    } else {
        Write-Message -Text $InputObject -NewLine
    }
}

function Write-Message {
    param(
        [string]$Text,
        [switch]$NewLine
    )

    if ($NewLine) {
        [Console]::WriteLine($Text)
    } else {
        [Console]::Write($Text)
    }
}

function Set-ConsoleColor {
    param(
        [ConsoleColor]$Color
    )

    [Console]::ForegroundColor = $Color
}