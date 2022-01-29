# GARY GITTER
# v3

#region VARIABLES

Write-Host $args

$currentDirectory = Get-Location
$csvFile = Join-Path $currentDirectory "gitlist.csv"

#TODO: Allow user to specify csv file as commandline argument

#endregion

#region FUNCTIONS
function CustomWrite {
  param ([string]$text)
  Write-Host $text -ForegroundColor Yellow
}

function HandleGit {
  param ([string]$studentName, [string]$subdir, [string]$gitlink)

  $gitlink = $gitlink.Trim();

  # Check if we should pull or clone based on whether .git folder exists
  if (Test-Path "$studentName/$subdir/.git" -PathType Container) {
    CustomWrite "  $studentName/$subdir Git directory found, pulling..."

    Set-Location -Path "$studentName/$subdir"
    git pull

    # Go back to main folder
    if (Compare-Object $subdir ".") {
      Set-Location -Path "../.."
    }
    else {
      Set-Location -Path ".."
    }
  }
  else {
    Write-Output "  $studentName no Git directory found in subdirectory $subdir, cloning..."

    if (!(Test-path "$studentName/$subdir/")) {
      [void](New-Item -Name "$studentName/$subdir" -ItemType "directory")
    }

    git clone $gitlink $studentName/$subdir
  }
}

function CheckAndCreateFolder {
  param ([string]$folderName)

  if (-not (Test-path $folderName -PathType Container)) {
    CustomWrite "  $folderName folder does not exist"
    [void](New-Item -Name "$folderName" -ItemType "directory")
  }
  else {
    CustomWrite "  $folderName folder already exists"
  }
}

function ParseFile {
  param ([string]$csvFile)

  foreach ($line in [System.IO.File]::ReadLines($csvFile)) {

    [string]$studentName, [string]$gitlink1, [string]$gitlink2 = $line.split(",")
  
    CustomWrite ("=" * 80)
    CustomWrite "  $studentName"
    CustomWrite ("-" * 80)
  
  
    if ($gitlink1.StartsWith("http") -or $gitlink2.StartsWith("http")) {
  
      # Check if student's folder exists
      CheckAndCreateFolder $studentName

      # Check whether to use git1 & git2 subfolders
      if ($gitlink1.StartsWith("http") -and -not $gitlink2.StartsWith("http")) {
        HandleGit $studentName "." $gitlink1
      }
      elseif ($gitlink1.StartsWith("http")) {
        HandleGit $studentName "git1" $gitlink1
      }
  
      if ($gitlink2.StartsWith("http")) {
        HandleGit $studentName "git2" $gitlink2
      }

      # TODO: Make more general, allow arbitrary number of git repos per user
      
    }
    else {
      CustomWrite "  Skipping $studentName, has no git link"
    }
  }
}

#endregion

if (!(Test-Path($csvFile))) {
  Write-Output "Can't find gitlist.csv, exiting"
  $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
  Exit
}

# -- MAIN PROGRAM
ParseFile $csvFile

read-host "`nPress ENTER to continue..."