$fileLoc = "C:\Users\jxb0277s\Desktop\scripts\linux compare\"
$root = $fileLoc + "root.txt"
$email = $fileLoc + "email.txt"
$subpattern = "subject"
$serverlist = $fileLoc + "serverlist.txt"
$nomatch = $fileLoc + "nomatch.txt"
$output = $fileLoc + "output.txt"
$output2 = $fileLoc + "root.txt"

function clearfiles{
    Clear-Content $output
    Clear-Content $output2
    Clear-Content $nomatch
}

clearfiles

function openup{
    Get-Content $nomatch | ForEach-Object {
        $server = $_
        Write-Host "Opening server:  " $server

        Get-VM $server | Open-VMConsoleWindow
    }
}

function parse{
    (Get-Content $email) | ForEach-Object {
        $thisline = $_
        Write-Host ("This line in input is " + $thisline)
        if ($thisline -like ("*subject*")){
            Write-Host("Ignoring Subject Line")
        }
        else {
            if ($thisline -like ("*`t*")){
                Write-Host("I found a tab in this line.")
                $pos = $thisline.IndexOf("`t")
                $rightPart = $thisline.Substring($pos+1)

                If(!(Test-Path $output -PathType Leaf)){
    #               Write-Host "No file"
                    Out-File $output
                    Add-Content $output $rightPart
                }
                else{
                    #Write-Host "File found"
                    Add-Content $output $rightPart
                }
            }
        }
    }
}

function parse2{
    (Get-Content $output) | ForEach-Object {
        $thisline2 = $_
        Write-Host ("This line in input is " + $thisline2)
        if ($thisline2 -like ("*subject*")){
            Write-Host("Ignoring Subject Line")
        }
        else {
            if ($thisline2 -like ("*.*") -or $thisline2 -like ("* *")){
                Write-Host("I found a tab or period in this line.")
                
                if($thisline2 -like ("*.*")){
                    $pos2 = $thisline2.IndexOf(".")
                    $rightPart2 = $thisline2.Substring($pos2)
                    $leftPart = $thisline2.Substring(0,$pos2)
                }
                elseif($thisline2 -like ("* *")){
                    $pos2 = $thisline2.IndexOf(" ")
                    $rightPart2 = $thisline2.Substring($pos2)
                    $leftPart = $thisline2.Substring(0,$pos2)               
                }


                If(!(Test-Path $output2 -PathType Leaf)){
    #               Write-Host "No file"
                    Out-File $output2
                    Add-Content $output2 $leftPart
                }
                else{
                    #Write-Host "File found"
                    Add-Content $output2 $leftPart
                }
            }
        }
    }    
}
#removesubject
parse
parse2

function comparefiles{
    $serverName = @()
    Write-Host("The length of serverName is " + $serverName.Length)
    Get-Content $serverlist | ForEach-Object {
    $serverName += $_.ToUpper()
    }
        
    Get-Content $root | ForEach-Object {
        $rootserver = $_.ToUpper()
        #Write-Host $rootserver
        for ($i=0; $i -lt $serverName.length; $i ++){
            #Write-Host $serverName[$i]
            if($serverName[$i].contains($rootserver)){
                $serverName[$i] = ""
            }                
        }
    }
    for ($i=0; $i -lt $serverName.length; $i ++){
        if ($serverName[$i] -ne ""){
            Add-Content $nomatch $serverName[$i]
        }
    }
    #Write-Host("The mismatched servers are " + $serverName)
    Write-Host("The ending length of serverName is " + $serverName.Length)
}

comparefiles
openup