#!/bin/sh

# Initialize CGI session
cgi=$(cgi-init)

# Read parameters from URL
publication=$(cgi-param "$cgi" publication)
document=$(cgi-param "$cgi" document)
non_applic=$(cgi-param "$cgi" non-applic)
units=$(cgi-param "$cgi" units)
unit_format=$(cgi-param "$cgi" unit-format)
comments=$(cgi-param "$cgi" comments)

# Default values for parameters
non_applic=${non_applic:-hide}
units=${units:-SI}
unit_format=${units:-SI}
comments=${comments:-hide}

# Create temp directories and files
tmp=$(mktemp -d)   # Temp directory for support files
props=$(mktemp)    # Temp file for properties list
pct=$(mktemp)      # Temp file for PCT
filtered=$(mktemp) # Temp file for filtered object

# Create an empty PCT
cat <<EOF > "$pct"
<products>
<product id="filters"/>
</products>
EOF

# Read assigns from parameters and add to PCT
pct_assign() {
	app_i=$(echo "$1" | cut -d : -f 1)
	app_t=$(echo "$1" | cut -d : -f 2)
	app_v=$(cat "$2")

	printf "DEBUG: %s : %s = %s\n" "$app_i" "$app_t" "$app_v" >&2

	xml-transform -s configure.xsl -p "ident='$app_i'" -p "type='$app_t'" -p "value='$app_v'" -f "$pct"
}

find "$cgi/params" -type f | while read param
do
	key=$(urlencode -d $(basename "$param"))

	case "$key" in
		# Ignore known parameters
		publication|document|non-applic|units|unit-format|comments)
			;;
		*)
			pct_assign "$key" "$param"
			;;
	esac
done

# Base arguments for s1kd-instance
s1kd_instance='s1kd-instance -SZ'

case "$non_applic" in
	hide)
		s1kd_instance="$s1kd_instance -A"
		;;
	show)
		s1kd_instance="$s1kd_instance -T"
		;;
esac

# Print CGI headers
cgi-header 'Content-type: application/xhtml+xml'

# Start HTML
cat <<EOF
<?xml version="1.0"?>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width"/>
<link rel="stylesheet" type="text/css" href="style.css"/>
<script type="text/javascript" src="script.js"/>
EOF

# Fetch the object
object=$(sh get-object.sh "$document" "$tmp")
object_status=$?

# Generate list of properties for the object
sh get-properties.sh "$object" "$tmp" > "$props"

# Get title of object
title=$(s1kd-metadata -n title "$object")
title=${title:-S1000D Viewer}

# Set page title
cat <<EOF
<title>$title</title>
EOF

# End of header
cat <<EOF
</head>
<body>
EOF

# Generate configuration menu
if test -n "$publication"
then
	cat <<-EOF
	<div class="menu-float">
	EOF
else
	cat <<-EOF
	<div class="menu">
	EOF
fi

cat <<EOF
<form action="view.cgi">
EOF

xml-transform \
	-s menu.xsl \
	-p "publication='$publication'" \
	-p "document='$document'" \
	-p "pct='$pct'" \
	-p "non-applic='$non_applic'" \
	-p "units='$units'" \
	-p "unit-format='$unit_format'" \
	-p "comments='$comments'" \
	"$props"

cat <<EOF
</form>
</div>
EOF

# Generate publication TOC
if test -n "$publication"
then
	pm_object=$(sh get-object.sh "$publication" "$tmp")
	
	if test "$?" -eq 0
	then
		cat <<-EOF
		<div class="pub-toc">
		EOF

		xml-transform -s html.xsl \
			-p "publication='$publication'" \
			"$pm_object"

		cat <<-EOF
		</div>
		EOF
	fi

	sh free-object.sh "$pm_object"

	cat <<-EOF
	<div class="main-float">
	EOF
else
	cat <<-EOF
	<div class="main">
	EOF
fi

# Check if object was found
if test "$object_status" -eq 0
then
	# Filter the object
	rm "$filtered"
	$s1kd_instance -P "$pct" -p filters -o "$filtered" -w "$object"

	# Check if the object was applicable to the selected filters
	if test -e "$filtered"
	then
		# Transform the object:
		#   1. Re-generate display text
		#   2. Convert units of measure
		#   #. Transform to HTML
		s1kd-aspp -d "$tmp" -cg "$filtered" \
		| s1kd-uom -s "$units" -p "$unit_format" \
		| xml-transform -s html.xsl \
			-p "publication='$publication'" \
			-p "pct='$pct'" \
			-p "non-applic='$non_applic'" \
			-p "units='$units'" \
			-p "unit-format='$unit_format'" \
			-p "comments='$comments'"
	else
		cat <<-EOF
		<div class="error">This document is not applicable to the selected filters.</div>
		EOF
	fi
else
	cat <<-EOF
	<div class="error">Document not found.</div>
	EOF
fi

# End HTML
cat <<EOF
</div>
</body>
</html>
EOF

# Clean up object
sh free-object.sh "$object"

# Clean up temp directories and files
rm -r "$tmp"
rm "$filtered"
rm "$props"
rm "$pct"

# Clean up CGI session
cgi-free "$cgi"
