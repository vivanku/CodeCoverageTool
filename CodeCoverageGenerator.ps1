
write-host "Starting code coverage tool"  -ForegroundColor Green
# update path in setting.json
$setting = Get-Content -Raw -Path setting.json | ConvertFrom-Json
$gitPath = $setting.repositoryPath
$testResultsFolder = "$gitPath\TestResults"
$codeCoverageFolderPath = $setting.coverageToolPath
$testSettingsFolderPath = "$codeCoverageFolderPath\TestSettings"
$reportsFolderPath = "$codeCoverageFolderPath\Reports"
$currentDateTime = $((Get-Date).ToString('dd-MM-yyyy hhmmss'))
$codeCoverageExe = "$codeCoverageFolderPath\packages\microsoft.codecoverage\16.5.0\build\netstandard1.0\CodeCoverage\CodeCoverage.exe"
$reportGeneratordll = "$codeCoverageFolderPath\packages\reportgenerator\4.5.2\tools\netcoreapp3.0\ReportGenerator.dll"

# checkout master branch and fetch latest code
cd $gitPath

write-host "Checkout master branch" -ForegroundColor Green

 git checkout 'master'

write-host "Pull Latest Code" -ForegroundColor Green

 git pull

write-host "Build Solution" -ForegroundColor Green

$solutionName = $setting.solutionName
msbuild $gitPath\$solutionName

$purgeDays = $setting.purgeDays
write-host "Purging reports older than $purgeDays day(s)"  -ForegroundColor Green

Get-ChildItem "$reportsFolderPath" -Recurse -File | Where CreationTime -lt  (Get-Date).AddDays(-$purgeDays)  | Remove-Item -Force

$modules = $setting.modules
foreach ($module in $modules)
{
    $moduleName = $module.moduleName
    $moduleRunSettingsFileName = $module.settingsFileName
    $testProjectPath = $module.testProjectPath
    $filter= $module.testFilter
    write-host "Start $moduleName Test Execution" -ForegroundColor Green
    if($module.hasToRun)
    {
        $cmd= "dotnet test $testProjectPath --no-build --settings:$testSettingsFolderPath\$moduleRunSettingsFileName --results-directory:$testResultsFolder --collect:'Code Coverage'"
        if($filter -ne "")
        {
           $cmd= "$cmd --filter '$filter'" 
        }
        write-host "$cmd" -ForegroundColor Green
        Invoke-Expression $cmd

        $recentCoverageFile = Get-ChildItem -File -Filter *.coverage -Path $testResultsFolder -Name -Recurse | Select-Object -First 1;

        write-host "$moduleName Test Execution Completed" -ForegroundColor Green

        $cmd = "$codeCoverageExe analyze  /output:$testResultsFolder\'$moduleName'.coveragexml  $testResultsFolder'\'$recentCoverageFile"
        Invoke-Expression $cmd

        write-host "$moduleName Coverage XML Generated"  -ForegroundColor Green

        $cmd="dotnet $reportGeneratordll '-reports:$testResultsFolder\$moduleName.coveragexml' '-targetdir:$reportsFolderPath\$currentDateTime\$moduleName\'"
        Invoke-Expression $cmd

        write-host "$moduleName CoverageReport Published"  -ForegroundColor Green
        Remove-Item $testResultsFolder -Recurse
    }
    else
    {
            write-host "$moduleName Test Run Disabled" -ForegroundColor Yellow
    }
}

cd $codeCoverageFolderPath
write-host 'Code Coverage Completed'  -ForegroundColor Green
