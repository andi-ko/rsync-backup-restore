$backupPath = "R:\Profildaten\";
$diffPath = "R:\Backup.Profildaten\";
$restorePath = "E:\Temp\Restore\";

$targetDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss" -Date "2018-01-01 12:31:42";

# restore items younger than target date

Get-ChildItem -Path $backupPath -Recurse | % {                       

    if ($_.LastWriteTime -le $targetDate -and $_.CreationTime -le $targetDate) {
            
        $currentFolderName = [System.IO.Path]::GetDirectoryName($_.FullName);

        Write-Host $currentFolderName;

        $currentSubDirectoryName = $currentFolderName.Substring($backupPath.Length-1);

        $destinationDir = "$restorePath" + "$currentSubDirectoryName"

        If(!(test-path $destinationDir)) {
                
            New-Item -ItemType Directory -Force -Path $destinationDir;
        }

        Copy-Item $_.FullName -Force -Destination $destinationDir;
    }
}

# iterate diffs older than target date in descending order

Get-ChildItem -Path $diffPath -Directory | Sort-Object -Descending | % {    

    $currentDiff = $_;

    if ($_.CreationTime -gt $targetDate) {

        # restore diff items younger than target date

        Get-ChildItem -Path $($_.FullName) -Recurse | % {                       

            if ($_.LastWriteTime -le $targetDate -and $_.CreationTime -le $targetDate) {
            
                $currentFolderName = [System.IO.Path]::GetDirectoryName($_.FullName);

                $currentSubDirectoryName = $currentFolderName.Substring($currentDiff.FullName.Length-1);

                $destinationDir = "$restorePath" + "$currentSubDirectoryName"

                If(!(test-path $destinationDir)) {
                
                    New-Item -ItemType Directory -Force -Path $destinationDir;
                }

                Write-Host $_.FullName;

                Copy-Item $_.FullName -Force -Destination $destinationDir;
            }
        }
    }
}