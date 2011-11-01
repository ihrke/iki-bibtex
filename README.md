# bibtex for ikiwiki #

This [ikiwiki]-plugin provides a 
  
    [[!bibtex ]]
	 
directive for [ikiwiki]. 

So far, it can display a raw or formatted bibtex-entry from a 
bibtex-file (either checked into ikiwiki, or not).

[ikiwiki]: http://ikiwiki.info/

Features:

* supports websetup

## Examples ##

Output from file mybib.bib, bibtex key 'key1' in a citation-like
format (authors (year): journal. volume (number), pages.).

    [[!bibtex file="mybib.bib" key="key1" format="citation"]]


