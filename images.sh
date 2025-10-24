wget -O page.html "https://brandportal.infineon.com/media-pool/"
grep -Eoi "(https?|ftp)://[^\s/$.?#].[^\s]*\.(jpg|png|gif|svg)" page.html | sort -u > image_urls.txt

wget -i image_urls.txt -P images_folder/