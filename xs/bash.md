# grep

<!-- only match lines that are 255 characters or less
     helps exclude output-clogging minified files etc -->
grep -r -x '.\{1,255\}<search-string>.\{1,255\}' *

# curl

<!-- download a media asset from a semi-trixy webpage -->

1. open devtools network tab, disable cache, all types
2. filter for something like '.mp4' or expected media extension
3. refresh page and watch for first signficant looking match
4. often will be in parts, perhaps typescript assets or media chunks like below
5. right click the first loaded chunk --> copy --> copy as curl
6. either way, may be able to clean up the url arguments a bit for example removing '&bytestart' and '&byteend' from the first of a series of mp4 chunks like below allows the full download in one go.
7. finally if you want to save the file add '-o <out.mp4>'

<!-- this example is for an instagram reel -->

curl `https://instagram.fwlg1-2.fna.fbcdn.net/v/t66.30100-16/121294679_207575461600155_5544743404688062504_n.mp4?_nc_ht=instagram.fwm=ALQROFkBAAAA&ccb=7-5&oh=00_AT9PMnGxPGFOXo2-qbrZnMmke6dKVU_U1OYRMvno5I-v6w&oe=6320D38D&_nc_sid=30a2ef` \
 -H '<header-1>'
-H '<...>'
-H '<header-n>'
--compressed -o <out.mp4>

# tee

Read from standard input and write to standard output and files (or commands).
More information: https://www.gnu.org/software/coreutils/tee

- Copy standard input to each file, and also to standard output:
  `echo "example" | tee path/to/file`

- Append to the given files, do not overwrite:
  `echo "example" | tee -a path/to/file`

- Print standard input to the terminal, and also pipe it into another program for further processing:
  `echo "example" | tee /dev/tty | xargs printf "[%s]"`

- Create a directory called "example", count the number of characters in "example" and write "example" to the terminal:
  `echo "example" | tee >(xargs mkdir) >(wc -c)`
