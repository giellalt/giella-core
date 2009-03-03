<?xml version="1.0"?>
<!--+
    | 
    | The parameter: language pair, and date
    | Usage: java -Xmx2048m net.sf.saxon.Transform -it main generate_infofile.xsl S_LANG=LANG T_LANG=LANG DATE=DATE
    | 
    +-->



<!-- java -Xmx2048m net.sf.saxon.Transform -it main generate_makefile.xsl S_LANG=sme T_LANG=nob DICT_PATH=../bin/mac_smenob.xml > gogo.mf -->


<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:d="http://www.apple.com/DTDs/DictionaryService-1.0.rng"
    xmlns:myFct="nightbar"
    exclude-result-prefixes="xs myFct">

  <xsl:import href="mapLang.xsl"/>

  <xsl:strip-space elements="*"/>
  <xsl:output method="text"
	      encoding="UTF-8"/>
  
  <xsl:param name="S_LANG" select="'xxx'"/>
  <xsl:param name="T_LANG" select="'xxx'"/>
  <xsl:param name="DICT_PATH" select="'mac_smenob.xml'"/>
  <xsl:variable name="DICT_NAME" select="concat(myFct:capitalize-first(myFct:mapLang($S_LANG)), '-', myFct:mapLang($T_LANG), ' ordbok')"/>
  <xsl:variable name="INFO_PLIST" select="concat($S_LANG, $T_LANG, 'Info.plist')"/>
  <xsl:variable name="CSS_FILE" select="concat($S_LANG, $T_LANG, 'Dictionary.css')"/>
  
  <xsl:template match="/" name="main">
    <xsl:text>
#
# Makefile
#
#
#

###########################

# You need to edit these values.

DICT_NAME               =       "</xsl:text>
    <xsl:value-of select="$DICT_NAME"/>
    <xsl:text>"
DICT_SRC_PATH           =       </xsl:text>
    <xsl:value-of select="$DICT_PATH"/>
    <xsl:text>
CSS_PATH                =       </xsl:text>
    <xsl:value-of select="$CSS_FILE"/>
    <xsl:text>
PLIST_PATH              =       </xsl:text>
    <xsl:value-of select="$INFO_PLIST"/>
    <xsl:text>

# DICT_BUILD_OPTS               =
# Suppress adding supplementary key.
DICT_BUILD_OPTS         =       -s 0    # Suppress adding supplementary key.

###########################

# The DICT_BUILD_TOOL_DIR value is used also in "build_dict.sh" script.
# You need to set it when you invoke the script directly.

DICT_BUILD_TOOL_DIR     =       "/Developer/Extras/Dictionary Development Kit"
DICT_BUILD_TOOL_BIN     =       "$(DICT_BUILD_TOOL_DIR)/bin"

###########################

DICT_DEV_KIT_OBJ_DIR    =       ./objects
export  DICT_DEV_KIT_OBJ_DIR

DESTINATION_FOLDER      =       ~/Library/Dictionaries
RM                      =       /bin/rm

###########################

all:
	"$(DICT_BUILD_TOOL_BIN)/build_dict.sh" $(DICT_BUILD_OPTS) $(DICT_NAME) $(DICT_SRC_PATH) $(CSS_PATH) $(PLIST_PATH)
	echo "Done."


install:
	echo "Installing into $(DESTINATION_FOLDER)".
	mkdir -p $(DESTINATION_FOLDER)
	ditto --noextattr --norsrc $(DICT_DEV_KIT_OBJ_DIR)/$(DICT_NAME).dictionary  $(DESTINATION_FOLDER)/$(DICT_NAME).dictionary
	touch $(DESTINATION_FOLDER)
	echo "Done."
	echo "To test the new dictionary, try Dictionary.app."

clean:
	$(RM) -rf $(DICT_DEV_KIT_OBJ_DIR)

    </xsl:text>
    
  </xsl:template>
  
</xsl:stylesheet>
