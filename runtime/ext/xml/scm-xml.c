/* ***** BEGIN LICENSE BLOCK *****
 * Roadsend PHP Compiler Runtime Libraries
 * Copyright (C) 2007 Roadsend, Inc.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation; either version 2.1
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
 * ***** END LICENSE BLOCK ***** */

#include <libxml/parser.h>
#include <bigloo.h>

// defined and exported by xml.scm
// ie, these are scheme funtions generated by bigloo
extern xmlEntityPtr get_entity(void *, xmlChar*);
extern obj_t ext_entity_handler(void *,	xmlChar *, int, xmlChar *, xmlChar *, xmlChar *);
extern obj_t notation_handler(void *, xmlChar *, xmlChar *, xmlChar *);
extern obj_t unparsed_entity_handler(void *, xmlChar *, xmlChar *, xmlChar *, xmlChar *);
extern obj_t start_element_handler(void *, xmlChar *, xmlChar **);
extern obj_t end_element_handler(void *, xmlChar *);
extern obj_t char_handler(void *, xmlChar *, int);
extern obj_t pi_handler(void *, xmlChar *, xmlChar *);
extern obj_t comment_handler(void *, xmlChar *);


// hard coded structure definition of callbacks
xmlSAXHandler scmHandlerStruct = {
    NULL, /* internalSubset */
    NULL, /* isStandalone */
    NULL, /* hasInternalSubset */
    NULL, /* hasExternalSubset */
    NULL, /* resolveEntity */
    get_entity, /* getEntity */
    ext_entity_handler, /* entityDecl */
    notation_handler, /* notationDecl */
    NULL, /* attributeDecl */
    NULL, /* elementDecl */
    unparsed_entity_handler, /* unparsedEntityDecl */
    NULL, /* setDocumentLocator */
    NULL, /* startDocument */
    NULL, /* endDocument */
    start_element_handler, /* startElement */
    end_element_handler, /* endElement */
    NULL, /* reference */
    char_handler, /* characters */
    NULL, /* ignorableWhitespace */
    pi_handler, /* processingInstruction */
    comment_handler, /* comment */
    NULL, /* xmlParserWarning */
    NULL, /* xmlParserError */
    NULL, /* xmlParserError */
    NULL, /* getParameterEntity */
    NULL, /* cdataBlock; */
    NULL,  /* externalSubset; */
    1
};

// prototypes
obj_t xmlstring_to_bstring( xmlChar *c_string );
obj_t xmlstring_to_bstring_len( xmlChar *c_string, int len );

// callbacks
xmlSAXHandlerPtr scmHandlerPtr = &scmHandlerStruct;


obj_t
xmlstring_to_bstring( xmlChar *c_string ) {
   return xmlstring_to_bstring_len( c_string, c_string ? xmlStrlen( c_string ) : 0 );
}

obj_t
xmlstring_to_bstring_len( xmlChar *c_string, int len ) {

   return string_to_bstring_len(c_string, len);

/*
   obj_t string = GC_MALLOC_ATOMIC( STRING_SIZE + len );
   char *dst;
   
   if( !c_string ) c_string = "";

#if( !defined( TAG_STRING ) )
   string->string_t.header = MAKE_HEADER( STRING_TYPE, 0 );
#endif	
   string->string_t.length = len;

   dst = (char *)&(string->string_t.char0);
   for( ; len > 0; len-- )
      *dst++ = *c_string++;
  
   *dst = '\0';
   
   return BGL_HEAP_DEBUG_MARK_OBJ( BSTRING( string ) );
*/
   
}