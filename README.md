# CodeCoverageGenerator
This tool will generate Code Coverage report for different modules and projects . Clone this repository in  C drive .

Below are few things that should be configured:
1. Update repositoryPath and coverageToolPath in setting.json with your local path
2. Set MSbuild path ("C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin") in path variable 
3. Confgiure module specific settings in setting.json
  
      
Run CodeCoverageGenerator.ps1 to get the reports for configured modules at CodeCoverageGenerator/Reports folder . 

### Adding new module
Make below modifications  in setting.json
1. Add a new item in modules array 
2. Update the details as per your module
3. Add module specific <moduleName>.runsettings file for code coverage of module specific projects only or use common.runsettings file to include all the projects for code coverage.
