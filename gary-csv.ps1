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
    Write-Output "  $studentName : no Git directory found in subdirectory $subdir, cloning..."

    if (!(Test-path "$studentName/$subdir/")) {
      [void](New-Item -Name "$studentName/$subdir" -ItemType "directory")
    }

    git clone $gitlink $studentName/$subdir
  }
}

function CheckAndCreateFolder {
  param ([string]$folderName)

  if (-not (Test-path $folderName -PathType Container)) {
    CustomWrite "  $folderName folder does not exist. Creating it now."
    [void](New-Item -Name "$folderName" -ItemType "directory")
  }
  else {
    CustomWrite "  $folderName folder already exists"
  }
}

function ParseFile {
  param ([string]$csvFile)

  foreach ($line in [System.IO.File]::ReadLines($csvFile)) {

    # Skipping header line & others without http's
    if (-not($line.Contains("http")))
    {
      CustomWrite "--- No https found, skipping line"
      continue
    }

    [string]$studentName, [string]$gitlinksString = $line.split(",", 2)

    $gitlinks = $gitlinksString.split(",")
  
    CustomWrite ("=" * 80)
    CustomWrite "  $studentName"
    CustomWrite ("-" * 80)

    if (($gitlinks.Count -gt 0))
    {
      CheckAndCreateFolder $studentName
      
      
      if ($gitlinks.Count -eq 1) {
        CustomWrite "  Single git link candidate found."
        
        # Check if gitlink 0 seems to be valid URL
        if ($gitlinks[0].StartsWith("http")) {
          HandleGit $studentName "." $gitlinks[0]
        }
      }
      elseif ($gitlinks.Count -gt 1) {
        CustomWrite "  Multiple git link candidates found."
        
        [int32]$linkNum = 1

        foreach ($gitlink in $gitlinks) {
          # Check for quotation marks. They fuck everything up.
          if ($gitlink.StartsWith('"')) {
            $gitlink = $gitlink.Substring(1)
          }
          if ($gitlink.EndsWith('"')) {
            $gitlink = $gitlink.Substring(0, $gitlink.Length - 1)
          }
          
          # Check if seems to be valid URL
          if ($gitlink.StartsWith("http")) {
            HandleGit $studentName "git$linkNum" $gitlink
          }
          
          ++$linkNum
        }
      }
    }
    else
    {
      CustomWrite "  No git link candidates found for $studentName, skipping."
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