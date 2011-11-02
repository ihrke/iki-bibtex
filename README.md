# bibtex for ikiwiki #

This [ikiwiki]-plugin provides a 
  
    [[!bibtex ]]
	 
directive for [ikiwiki]. 

So far, it can display a raw or formatted bibtex-entry from a 
bibtex-file (either checked into ikiwiki, or not).

[ikiwiki]: http://ikiwiki.info/

Features:

* supports websetup

## Requirements ##

* [Text::BibTeX] - available from CPAN

[Text::BibTeX]: http://search.cpan.org/~ambs/Text-BibTeX-0.61/lib/Text/BibTeX.pm

## Examples ##

Output from file mybib.bib, bibtex key 'key1' in a citation-like
format (authors (year): journal. volume (number), pages.).

    [[!bibtex file="mybib.bib" key="key1" format="citation"]]

Combine with toggle-plugin to optionally display the raw bibtex

    [[!bibtex key="Ihrke2011"]] [[!toggle id="bibtexentry" text="(entry)"]]
    [[!toggleable  id="bibtexentry" text="""
    [[!bibtex key="Ihrke2011" format="raw"]]
    [[!toggle id="bibtexentry" text="(hide)"]]
    """]]
    

