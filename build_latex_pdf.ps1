'''
This script rebuilds the pdf every time this is run. 
There is no consideration given to whether the input files where changed or not.
Such "performance considerations" may be incorporated later.
'''

$filename_base=$args[0]
if (-not $filename_base)
{
    $filename_base = "business_plan" # default tex file basename
}

Write-Host "Building Document '$filename_base'"

$output_dir = "$filename_base-output"
if ( -not (Test-Path -Path $output_dir) )
{
    New-Item -ItemType Directory -Path $output_dir
}

Write-Host "Building tex files from input markdown"
[string[]]$markdown_location = (Get-Content -Path '.\input_markdown_location.txt')
if ( -not (Test-Path -Path $markdown_location) )
{
    Write-Host "Cannot find location in 'input_markdown_location.txt': $markdown_location"!
    Exit
}
Write-Host "location stored = $markdown_location"

[string[]]$input_file_basenames = (Get-Content -Path '.\input_sections_list.txt')

$markdown_filenames = New-Object System.Collections.ArrayList
$tex_filenames = New-Object System.Collections.ArrayList
ForEach ($basename in $input_file_basenames) {
    $markdown_file_path = "$markdown_location\$basename.md"
    
    if ( -not (Test-Path -Path $markdown_file_path) )
    {
        Write-Host "Could not find $markdown_file_path"
        New-Item -ItemType File -Path $markdown_file_path
    }

    $markdown_filenames.Add("$markdown_file_path")
    pandoc -o "$output_dir\$basename.tex" "$markdown_file_path"
    Write-Host "Created "$output_dir\$basename.tex" from "$markdown_file_path""
}
Write-Host "input markdown files = $markdown_filenames"

Write-Host "Executing command: 'pdflatex -halt-on-error -output-directory $output_dir $filename_base.tex'"

Set-PSDebug -Trace 1
pdflatex -halt-on-error -output-directory "$output_dir" "$filename_base.tex"
Set-PSDebug -Trace 0
