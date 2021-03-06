# Post-process bbl files generated by plainhtml.bst
#
# Carefully don't escape % characters, since this is HTML syntax we're
# mangling.
#
# $Id$
#
# Gobble the whole entry, up to </dd>
{
  :getline
  N
  s+</dd>+&+
  t processline
  b getline
}
:processline
# Remove end-of-line % characters
s/%\n *//g
# Any lines which have leading white space have been broken/wrapped by
# BibTeX.  Rejoin these, as this means the normalisation which is
# about to happen in sgml2docs (simplenorm) can be a lot less clever
# that would otherwise be necessary.  The style file plainhtml.bst
# carefully avoids putting in leading whitespace at newblock time.
s/\n  */ /g
# Delete {} and change ~ to space.
s/[{}]//g
s/~/ /g
