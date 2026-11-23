param([switch]$UseLearnerTests)

$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$work = Join-Path $root ('.replay/' + [guid]::NewGuid().ToString('N'))
$project = 'tests/Checkout.Tests/Checkout.Tests.csproj'
$feature = 'src/Checkout/ShippingPolicy.cs'
$testFile = 'tests/Checkout.Tests/ShippingPolicyTests.cs'
$reference = Get-Content (Join-Path $root 'reference/ShippingPolicy.cs.txt') -Raw
$testSource = Join-Path $root 'reference/ShippingPolicyTests.cs.txt'
if ($UseLearnerTests) {
    $testSource = Join-Path $root $testFile
    if (!(Test-Path $testSource)) {
        throw "Write $testFile first. No learner test file was found."
    }
}

function Run-Phase([string]$name, [bool]$expectSuccess) {
    & dotnet test $project --nologo --verbosity quiet --logger "trx;LogFileName=$name.trx" --results-directory TestResults | Out-Host
    $exit = $LASTEXITCODE
    if (($exit -eq 0) -ne $expectSuccess) {
        throw "$name returned unexpected exit code $exit."
    }
    $report = Join-Path 'TestResults' "$name.trx"
    if (!(Test-Path $report)) { throw "$name produced no test report; a build failure is not a red test." }
    [xml]$trx = Get-Content $report -Raw
    $counts = $trx.TestRun.ResultSummary.Counters
    if ([int]$counts.notExecuted -ne 0 -or [int]$counts.executed -ne [int]$counts.total) {
        throw "$name skipped or did not execute tests."
    }
    $baselineFailures = @($trx.TestRun.Results.UnitTestResult | Where-Object {
        $_.outcome -ne 'Passed' -and $_.testName -match 'OrderTotalsTests'
    })
    if ($baselineFailures.Count -ne 0) { throw "$name broke existing behavior." }
    Write-Host "$name : total=$($counts.total) passed=$($counts.passed) failed=$($counts.failed)"
    return $counts
}

New-Item $work -ItemType Directory -Force | Out-Null
Push-Location $work
try {
    Copy-Item (Join-Path $root 'global.json') .
    foreach ($folder in 'src/Checkout', 'tests/Checkout.Tests') {
        New-Item $folder -ItemType Directory -Force | Out-Null
        Copy-Item (Join-Path $root "$folder/*.csproj") $folder
    }
    Copy-Item (Join-Path $root 'src/Checkout/Money.cs') 'src/Checkout'
    Copy-Item (Join-Path $root 'src/Checkout/OrderTotals.cs') 'src/Checkout'
    Copy-Item (Join-Path $root 'tests/Checkout.Tests/OrderTotalsTests.cs') 'tests/Checkout.Tests'
    @'
namespace Checkout;
public static class ShippingPolicy
{
    public static decimal Calculate(decimal subtotal, bool express) =>
        throw new NotImplementedException("Workshop seam");
}
'@ | Set-Content $feature

    $baseline = Run-Phase 'baseline' $true
    if ([int]$baseline.total -ne 8) { throw 'Expected eight baseline cases.' }
    Copy-Item $testSource $testFile
    $red = Run-Phase 'red' $false
    $newCases = [int]$red.total - 8
    if ($newCases -lt 12 -or [int]$red.failed -ne $newCases) {
        throw 'Need at least twelve new cases, all failing against the stub.'
    }
    if (!$UseLearnerTests -and $newCases -ne 12) { throw 'Reference case count changed.' }

    $reference | Set-Content $feature
    $green = Run-Phase 'green' $true
    if ([int]$green.total -ne [int]$red.total) { throw 'Test count changed between red and green.' }

    $mutations = [ordered]@{
        'exclusive-threshold' = @('roundedSubtotal >= 50m', 'roundedSubtotal > 50m')
        'missing-rounding' = @('var roundedSubtotal = Money.Round(subtotal);', 'var roundedSubtotal = subtotal;')
        'free-express' = @('if (express)', 'if (express && roundedSubtotal < 50m)')
        'late-validation' = @('if (subtotal < 0)', 'if (Money.Round(subtotal) < 0)')
        'wrong-parameter' = @('nameof(subtotal)', 'nameof(express)')
    }
    foreach ($name in $mutations.Keys) {
        $change = $mutations[$name]
        if (!$reference.Contains($change[0])) { throw "Mutation anchor missing: $name" }
        $reference.Replace($change[0], $change[1]) | Set-Content $feature
        $result = Run-Phase $name $false
        if ([int]$result.total -ne [int]$green.total -or [int]$result.failed -lt 1) {
            throw "$name was not detected by the unchanged test suite."
        }
    }
    $reference | Set-Content $feature
    $restored = Run-Phase 'restored' $true
    if ([int]$restored.total -ne [int]$green.total) { throw 'Restored test count changed.' }
    Write-Host 'Replay passed: red tests, reference implementation, five detected mutations, restored green.'
}
finally {
    Pop-Location
    Remove-Item $work -Recurse -Force
}
