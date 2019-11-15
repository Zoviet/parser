<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">   
<xsl:output method="xml" indent="no" encoding="utf-8" />
<xsl:template match="*">		
			<xsl:if test="@class='_3EnfYyWuRx'">			
				<site><xsl:value-of select="@href"/></site>
			</xsl:if>				
			<xsl:apply-templates/>                 		
 </xsl:template>
</xsl:stylesheet>
