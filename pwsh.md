### get directories file sizes in kilobytes
`dir | % {[int]($_.length / 1kb)}`

### replace directories file names
`dir | rename-item -newname {$_.name -replace "<find>", "<replace>"}`