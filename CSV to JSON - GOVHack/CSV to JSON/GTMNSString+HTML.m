//
//  GTMNSString+HTML.m
//  Dealing with NSStrings that contain HTML
//
//  Copyright 2006-2008 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//

//#import "GTMDefines.h"
#import "GTMNSString+HTML.h"

typedef struct {
	CFStringRef escapeSequence;
	unichar uchar;
} HTMLEscapeMap;

// Taken from http://www.w3.org/TR/xhtml1/dtds.html#a_dtd_Special_characters
// Ordered by uchar lowest to highest for bsearching
static HTMLEscapeMap gAsciiHTMLEscapeMap[] = {
	// A.2.2. Special characters
	{ (CFStringRef)@"&quot;", 34 },
	{ (CFStringRef)@"&amp;", 38 },
	{ (CFStringRef)@"&apos;", 39 },
	{ (CFStringRef)@"&lt;", 60 },
	{ (CFStringRef)@"&gt;", 62 },
	
    // A.2.1. Latin-1 characters
	{ (CFStringRef)@"&nbsp;", 160 }, 
	{ (CFStringRef)@"&iexcl;", 161 }, 
	{ (CFStringRef)@"&cent;", 162 }, 
	{ (CFStringRef)@"&pound;", 163 }, 
	{ (CFStringRef)@"&curren;", 164 }, 
	{ (CFStringRef)@"&yen;", 165 }, 
	{ (CFStringRef)@"&brvbar;", 166 }, 
	{ (CFStringRef)@"&sect;", 167 }, 
	{ (CFStringRef)@"&uml;", 168 }, 
	{ (CFStringRef)@"&copy;", 169 }, 
	{ (CFStringRef)@"&ordf;", 170 }, 
	{ (CFStringRef)@"&laquo;", 171 }, 
	{ (CFStringRef)@"&not;", 172 }, 
	{ (CFStringRef)@"&shy;", 173 }, 
	{ (CFStringRef)@"&reg;", 174 }, 
	{ (CFStringRef)@"&macr;", 175 }, 
	{ (CFStringRef)@"&deg;", 176 }, 
	{ (CFStringRef)@"&plusmn;", 177 }, 
	{ (CFStringRef)@"&sup2;", 178 }, 
	{ (CFStringRef)@"&sup3;", 179 }, 
	{ (CFStringRef)@"&acute;", 180 }, 
	{ (CFStringRef)@"&micro;", 181 }, 
	{ (CFStringRef)@"&para;", 182 }, 
	{ (CFStringRef)@"&middot;", 183 }, 
	{ (CFStringRef)@"&cedil;", 184 }, 
	{ (CFStringRef)@"&sup1;", 185 }, 
	{ (CFStringRef)@"&ordm;", 186 }, 
	{ (CFStringRef)@"&raquo;", 187 }, 
	{ (CFStringRef)@"&frac14;", 188 }, 
	{ (CFStringRef)@"&frac12;", 189 }, 
	{ (CFStringRef)@"&frac34;", 190 }, 
	{ (CFStringRef)@"&iquest;", 191 }, 
	{ (CFStringRef)@"&Agrave;", 192 }, 
	{ (CFStringRef)@"&Aacute;", 193 }, 
	{ (CFStringRef)@"&Acirc;", 194 }, 
	{ (CFStringRef)@"&Atilde;", 195 }, 
	{ (CFStringRef)@"&Auml;", 196 }, 
	{ (CFStringRef)@"&Aring;", 197 }, 
	{ (CFStringRef)@"&AElig;", 198 }, 
	{ (CFStringRef)@"&Ccedil;", 199 }, 
	{ (CFStringRef)@"&Egrave;", 200 }, 
	{ (CFStringRef)@"&Eacute;", 201 }, 
	{ (CFStringRef)@"&Ecirc;", 202 }, 
	{ (CFStringRef)@"&Euml;", 203 }, 
	{ (CFStringRef)@"&Igrave;", 204 }, 
	{ (CFStringRef)@"&Iacute;", 205 }, 
	{ (CFStringRef)@"&Icirc;", 206 }, 
	{ (CFStringRef)@"&Iuml;", 207 }, 
	{ (CFStringRef)@"&ETH;", 208 }, 
	{ (CFStringRef)@"&Ntilde;", 209 }, 
	{ (CFStringRef)@"&Ograve;", 210 }, 
	{ (CFStringRef)@"&Oacute;", 211 }, 
	{ (CFStringRef)@"&Ocirc;", 212 }, 
	{ (CFStringRef)@"&Otilde;", 213 }, 
	{ (CFStringRef)@"&Ouml;", 214 }, 
	{ (CFStringRef)@"&times;", 215 }, 
	{ (CFStringRef)@"&Oslash;", 216 }, 
	{ (CFStringRef)@"&Ugrave;", 217 }, 
	{ (CFStringRef)@"&Uacute;", 218 }, 
	{ (CFStringRef)@"&Ucirc;", 219 }, 
	{ (CFStringRef)@"&Uuml;", 220 }, 
	{ (CFStringRef)@"&Yacute;", 221 }, 
	{ (CFStringRef)@"&THORN;", 222 }, 
	{ (CFStringRef)@"&szlig;", 223 }, 
	{ (CFStringRef)@"&agrave;", 224 }, 
	{ (CFStringRef)@"&aacute;", 225 }, 
	{ (CFStringRef)@"&acirc;", 226 }, 
	{ (CFStringRef)@"&atilde;", 227 }, 
	{ (CFStringRef)@"&auml;", 228 }, 
	{ (CFStringRef)@"&aring;", 229 }, 
	{ (CFStringRef)@"&aelig;", 230 }, 
	{ (CFStringRef)@"&ccedil;", 231 }, 
	{ (CFStringRef)@"&egrave;", 232 }, 
	{ (CFStringRef)@"&eacute;", 233 }, 
	{ (CFStringRef)@"&ecirc;", 234 }, 
	{ (CFStringRef)@"&euml;", 235 }, 
	{ (CFStringRef)@"&igrave;", 236 }, 
	{ (CFStringRef)@"&iacute;", 237 }, 
	{ (CFStringRef)@"&icirc;", 238 }, 
	{ (CFStringRef)@"&iuml;", 239 }, 
	{ (CFStringRef)@"&eth;", 240 }, 
	{ (CFStringRef)@"&ntilde;", 241 }, 
	{ (CFStringRef)@"&ograve;", 242 }, 
	{ (CFStringRef)@"&oacute;", 243 }, 
	{ (CFStringRef)@"&ocirc;", 244 }, 
	{ (CFStringRef)@"&otilde;", 245 }, 
	{ (CFStringRef)@"&ouml;", 246 }, 
	{ (CFStringRef)@"&divide;", 247 }, 
	{ (CFStringRef)@"&oslash;", 248 }, 
	{ (CFStringRef)@"&ugrave;", 249 }, 
	{ (CFStringRef)@"&uacute;", 250 }, 
	{ (CFStringRef)@"&ucirc;", 251 }, 
	{ (CFStringRef)@"&uuml;", 252 }, 
	{ (CFStringRef)@"&yacute;", 253 }, 
	{ (CFStringRef)@"&thorn;", 254 }, 
	{ (CFStringRef)@"&yuml;", 255 },
	
	// A.2.2. Special characters cont'd
	{ (CFStringRef)@"&OElig;", 338 },
	{ (CFStringRef)@"&oelig;", 339 },
	{ (CFStringRef)@"&Scaron;", 352 },
	{ (CFStringRef)@"&scaron;", 353 },
	{ (CFStringRef)@"&Yuml;", 376 },
	
	// A.2.3. Symbols
	{ (CFStringRef)@"&fnof;", 402 }, 
	
	// A.2.2. Special characters cont'd
	{ (CFStringRef)@"&circ;", 710 },
	{ (CFStringRef)@"&tilde;", 732 },
	
	// A.2.3. Symbols cont'd
	{ (CFStringRef)@"&Alpha;", 913 }, 
	{ (CFStringRef)@"&Beta;", 914 }, 
	{ (CFStringRef)@"&Gamma;", 915 }, 
	{ (CFStringRef)@"&Delta;", 916 }, 
	{ (CFStringRef)@"&Epsilon;", 917 }, 
	{ (CFStringRef)@"&Zeta;", 918 }, 
	{ (CFStringRef)@"&Eta;", 919 }, 
	{ (CFStringRef)@"&Theta;", 920 }, 
	{ (CFStringRef)@"&Iota;", 921 }, 
	{ (CFStringRef)@"&Kappa;", 922 }, 
	{ (CFStringRef)@"&Lambda;", 923 }, 
	{ (CFStringRef)@"&Mu;", 924 }, 
	{ (CFStringRef)@"&Nu;", 925 }, 
	{ (CFStringRef)@"&Xi;", 926 }, 
	{ (CFStringRef)@"&Omicron;", 927 }, 
	{ (CFStringRef)@"&Pi;", 928 }, 
	{ (CFStringRef)@"&Rho;", 929 }, 
	{ (CFStringRef)@"&Sigma;", 931 }, 
	{ (CFStringRef)@"&Tau;", 932 }, 
	{ (CFStringRef)@"&Upsilon;", 933 }, 
	{ (CFStringRef)@"&Phi;", 934 }, 
	{ (CFStringRef)@"&Chi;", 935 }, 
	{ (CFStringRef)@"&Psi;", 936 }, 
	{ (CFStringRef)@"&Omega;", 937 }, 
	{ (CFStringRef)@"&alpha;", 945 }, 
	{ (CFStringRef)@"&beta;", 946 }, 
	{ (CFStringRef)@"&gamma;", 947 }, 
	{ (CFStringRef)@"&delta;", 948 }, 
	{ (CFStringRef)@"&epsilon;", 949 }, 
	{ (CFStringRef)@"&zeta;", 950 }, 
	{ (CFStringRef)@"&eta;", 951 }, 
	{ (CFStringRef)@"&theta;", 952 }, 
	{ (CFStringRef)@"&iota;", 953 }, 
	{ (CFStringRef)@"&kappa;", 954 }, 
	{ (CFStringRef)@"&lambda;", 955 }, 
	{ (CFStringRef)@"&mu;", 956 }, 
	{ (CFStringRef)@"&nu;", 957 }, 
	{ (CFStringRef)@"&xi;", 958 }, 
	{ (CFStringRef)@"&omicron;", 959 }, 
	{ (CFStringRef)@"&pi;", 960 }, 
	{ (CFStringRef)@"&rho;", 961 }, 
	{ (CFStringRef)@"&sigmaf;", 962 }, 
	{ (CFStringRef)@"&sigma;", 963 }, 
	{ (CFStringRef)@"&tau;", 964 }, 
	{ (CFStringRef)@"&upsilon;", 965 }, 
	{ (CFStringRef)@"&phi;", 966 }, 
	{ (CFStringRef)@"&chi;", 967 }, 
	{ (CFStringRef)@"&psi;", 968 }, 
	{ (CFStringRef)@"&omega;", 969 }, 
	{ (CFStringRef)@"&thetasym;", 977 }, 
	{ (CFStringRef)@"&upsih;", 978 }, 
	{ (CFStringRef)@"&piv;", 982 }, 
	
	// A.2.2. Special characters cont'd
	{ (CFStringRef)@"&ensp;", 8194 },
	{ (CFStringRef)@"&emsp;", 8195 },
	{ (CFStringRef)@"&thinsp;", 8201 },
	{ (CFStringRef)@"&zwnj;", 8204 },
	{ (CFStringRef)@"&zwj;", 8205 },
	{ (CFStringRef)@"&lrm;", 8206 },
	{ (CFStringRef)@"&rlm;", 8207 },
	{ (CFStringRef)@"&ndash;", 8211 },
	{ (CFStringRef)@"&mdash;", 8212 },
	{ (CFStringRef)@"&lsquo;", 8216 },
	{ (CFStringRef)@"&rsquo;", 8217 },
	{ (CFStringRef)@"&sbquo;", 8218 },
	{ (CFStringRef)@"&ldquo;", 8220 },
	{ (CFStringRef)@"&rdquo;", 8221 },
	{ (CFStringRef)@"&bdquo;", 8222 },
	{ (CFStringRef)@"&dagger;", 8224 },
	{ (CFStringRef)@"&Dagger;", 8225 },
    // A.2.3. Symbols cont'd  
	{ (CFStringRef)@"&bull;", 8226 }, 
	{ (CFStringRef)@"&hellip;", 8230 }, 
	
	// A.2.2. Special characters cont'd
	{ (CFStringRef)@"&permil;", 8240 },
	
	// A.2.3. Symbols cont'd  
	{ (CFStringRef)@"&prime;", 8242 }, 
	{ (CFStringRef)@"&Prime;", 8243 }, 
	
	// A.2.2. Special characters cont'd
	{ (CFStringRef)@"&lsaquo;", 8249 },
	{ (CFStringRef)@"&rsaquo;", 8250 },
	
	// A.2.3. Symbols cont'd  
	{ (CFStringRef)@"&oline;", 8254 }, 
	{ (CFStringRef)@"&frasl;", 8260 }, 
	
	// A.2.2. Special characters cont'd
	{ (CFStringRef)@"&euro;", 8364 },
	
	// A.2.3. Symbols cont'd  
	{ (CFStringRef)@"&image;", 8465 },
	{ (CFStringRef)@"&weierp;", 8472 }, 
	{ (CFStringRef)@"&real;", 8476 }, 
	{ (CFStringRef)@"&trade;", 8482 }, 
	{ (CFStringRef)@"&alefsym;", 8501 }, 
	{ (CFStringRef)@"&larr;", 8592 }, 
	{ (CFStringRef)@"&uarr;", 8593 }, 
	{ (CFStringRef)@"&rarr;", 8594 }, 
	{ (CFStringRef)@"&darr;", 8595 }, 
	{ (CFStringRef)@"&harr;", 8596 }, 
	{ (CFStringRef)@"&crarr;", 8629 }, 
	{ (CFStringRef)@"&lArr;", 8656 }, 
	{ (CFStringRef)@"&uArr;", 8657 }, 
	{ (CFStringRef)@"&rArr;", 8658 }, 
	{ (CFStringRef)@"&dArr;", 8659 }, 
	{ (CFStringRef)@"&hArr;", 8660 }, 
	{ (CFStringRef)@"&forall;", 8704 }, 
	{ (CFStringRef)@"&part;", 8706 }, 
	{ (CFStringRef)@"&exist;", 8707 }, 
	{ (CFStringRef)@"&empty;", 8709 }, 
	{ (CFStringRef)@"&nabla;", 8711 }, 
	{ (CFStringRef)@"&isin;", 8712 }, 
	{ (CFStringRef)@"&notin;", 8713 }, 
	{ (CFStringRef)@"&ni;", 8715 }, 
	{ (CFStringRef)@"&prod;", 8719 }, 
	{ (CFStringRef)@"&sum;", 8721 }, 
	{ (CFStringRef)@"&minus;", 8722 }, 
	{ (CFStringRef)@"&lowast;", 8727 }, 
	{ (CFStringRef)@"&radic;", 8730 }, 
	{ (CFStringRef)@"&prop;", 8733 }, 
	{ (CFStringRef)@"&infin;", 8734 }, 
	{ (CFStringRef)@"&ang;", 8736 }, 
	{ (CFStringRef)@"&and;", 8743 }, 
	{ (CFStringRef)@"&or;", 8744 }, 
	{ (CFStringRef)@"&cap;", 8745 }, 
	{ (CFStringRef)@"&cup;", 8746 }, 
	{ (CFStringRef)@"&int;", 8747 }, 
	{ (CFStringRef)@"&there4;", 8756 }, 
	{ (CFStringRef)@"&sim;", 8764 }, 
	{ (CFStringRef)@"&cong;", 8773 }, 
	{ (CFStringRef)@"&asymp;", 8776 }, 
	{ (CFStringRef)@"&ne;", 8800 }, 
	{ (CFStringRef)@"&equiv;", 8801 }, 
	{ (CFStringRef)@"&le;", 8804 }, 
	{ (CFStringRef)@"&ge;", 8805 }, 
	{ (CFStringRef)@"&sub;", 8834 }, 
	{ (CFStringRef)@"&sup;", 8835 }, 
	{ (CFStringRef)@"&nsub;", 8836 }, 
	{ (CFStringRef)@"&sube;", 8838 }, 
	{ (CFStringRef)@"&supe;", 8839 }, 
	{ (CFStringRef)@"&oplus;", 8853 }, 
	{ (CFStringRef)@"&otimes;", 8855 }, 
	{ (CFStringRef)@"&perp;", 8869 }, 
	{ (CFStringRef)@"&sdot;", 8901 }, 
	{ (CFStringRef)@"&lceil;", 8968 }, 
	{ (CFStringRef)@"&rceil;", 8969 }, 
	{ (CFStringRef)@"&lfloor;", 8970 }, 
	{ (CFStringRef)@"&rfloor;", 8971 }, 
	{ (CFStringRef)@"&lang;", 9001 }, 
	{ (CFStringRef)@"&rang;", 9002 }, 
	{ (CFStringRef)@"&loz;", 9674 }, 
	{ (CFStringRef)@"&spades;", 9824 }, 
	{ (CFStringRef)@"&clubs;", 9827 }, 
	{ (CFStringRef)@"&hearts;", 9829 }, 
	{ (CFStringRef)@"&diams;", 9830 }
};

// Taken from http://www.w3.org/TR/xhtml1/dtds.html#a_dtd_Special_characters
// This is table A.2.2 Special Characters
static HTMLEscapeMap gUnicodeHTMLEscapeMap[] = {
	// C0 Controls and Basic Latin
	{ (CFStringRef)@"&quot;", 34 },
	{ (CFStringRef)@"&amp;", 38 },
	{ (CFStringRef)@"&apos;", 39 },
	{ (CFStringRef)@"&lt;", 60 },
	{ (CFStringRef)@"&gt;", 62 },
	
	// Latin Extended-A
	{ (CFStringRef)@"&OElig;", 338 },
	{ (CFStringRef)@"&oelig;", 339 },
	{ (CFStringRef)@"&Scaron;", 352 },
	{ (CFStringRef)@"&scaron;", 353 },
	{ (CFStringRef)@"&Yuml;", 376 },
	
	// Spacing Modifier Letters
	{ (CFStringRef)@"&circ;", 710 },
	{ (CFStringRef)@"&tilde;", 732 },
    
	// General Punctuation
	{ (CFStringRef)@"&ensp;", 8194 },
	{ (CFStringRef)@"&emsp;", 8195 },
	{ (CFStringRef)@"&thinsp;", 8201 },
	{ (CFStringRef)@"&zwnj;", 8204 },
	{ (CFStringRef)@"&zwj;", 8205 },
	{ (CFStringRef)@"&lrm;", 8206 },
	{ (CFStringRef)@"&rlm;", 8207 },
	{ (CFStringRef)@"&ndash;", 8211 },
	{ (CFStringRef)@"&mdash;", 8212 },
	{ (CFStringRef)@"&lsquo;", 8216 },
	{ (CFStringRef)@"&rsquo;", 8217 },
	{ (CFStringRef)@"&sbquo;", 8218 },
	{ (CFStringRef)@"&ldquo;", 8220 },
	{ (CFStringRef)@"&rdquo;", 8221 },
	{ (CFStringRef)@"&bdquo;", 8222 },
	{ (CFStringRef)@"&dagger;", 8224 },
	{ (CFStringRef)@"&Dagger;", 8225 },
	{ (CFStringRef)@"&permil;", 8240 },
	{ (CFStringRef)@"&lsaquo;", 8249 },
	{ (CFStringRef)@"&rsaquo;", 8250 },
	{ (CFStringRef)@"&euro;", 8364 },
};


// Utility function for Bsearching table above
static int EscapeMapCompare(const void *ucharVoid, const void *mapVoid) {
	const unichar *uchar = (const unichar*)ucharVoid;
	const HTMLEscapeMap *map = (const HTMLEscapeMap*)mapVoid;
	int val;
	if (*uchar > map->uchar) {
		val = 1;
	} else if (*uchar < map->uchar) {
		val = -1;
	} else {
		val = 0;
	}
	return val;
}

@implementation NSString (GTMNSStringHTMLAdditions)

- (NSString *)gtm_stringByEscapingHTMLUsingTable:(HTMLEscapeMap*)table 
                                          ofSize:(NSUInteger)size 
                                 escapingUnicode:(BOOL)escapeUnicode {  
	NSUInteger length = [self length];
	if (!length) {
		return self;
	}
	
	NSMutableString *finalString = [NSMutableString string];
	NSMutableData *data2 = [NSMutableData dataWithCapacity:sizeof(unichar) * length];
	
	// this block is common between GTMNSString+HTML and GTMNSString+XML but
	// it's so short that it isn't really worth trying to share.
	const unichar *buffer = CFStringGetCharactersPtr((__bridge_retained CFStringRef)self);
	if (!buffer) {
		// We want this buffer to be autoreleased.
		NSMutableData *data = [NSMutableData dataWithLength:length * sizeof(UniChar)];
		if (!data) {
			// COV_NF_START  - Memory fail case
//			_GTMDevLog(@"couldn't alloc buffer");
			return nil;
			// COV_NF_END
		}
		[self getCharacters:[data mutableBytes]];
		buffer = [data bytes];
	}
	
	if (!buffer || !data2) {
		// COV_NF_START
//		_GTMDevLog(@"Unable to allocate buffer or data2");
		return nil;
		// COV_NF_END
	}
	
	unichar *buffer2 = (unichar *)[data2 mutableBytes];
	
	NSUInteger buffer2Length = 0;
	
	for (NSUInteger i = 0; i < length; ++i) {
		HTMLEscapeMap *val = bsearch(&buffer[i], table, 
									 size / sizeof(HTMLEscapeMap), 
									 sizeof(HTMLEscapeMap), EscapeMapCompare);
		if (val || (escapeUnicode && buffer[i] > 127)) {
			if (buffer2Length) {
				CFStringAppendCharacters((__bridge_retained CFMutableStringRef)finalString, 
										 buffer2, 
										 buffer2Length);
				buffer2Length = 0;
			}
			if (val) {
				[finalString appendString:(__bridge_transfer NSString*) val->escapeSequence];
			}
			else {
//				_GTMDevAssert(escapeUnicode && buffer[i] > 127, @"Illegal Character");
				[finalString appendFormat:@"&#%d;", buffer[i]];
			}
		} else {
			buffer2[buffer2Length] = buffer[i];
			buffer2Length += 1;
		}
	}
	if (buffer2Length) {
		CFStringAppendCharacters((__bridge_retained CFMutableStringRef)finalString, 
								 buffer2, 
								 buffer2Length);
	}
	return finalString;
}

- (NSString *)gtm_stringByEscapingForHTML {
	return [self gtm_stringByEscapingHTMLUsingTable:gUnicodeHTMLEscapeMap 
											 ofSize:sizeof(gUnicodeHTMLEscapeMap) 
									escapingUnicode:NO];
} // gtm_stringByEscapingHTML

- (NSString *)gtm_stringByEscapingForAsciiHTML {
	return [self gtm_stringByEscapingHTMLUsingTable:gAsciiHTMLEscapeMap 
											 ofSize:sizeof(gAsciiHTMLEscapeMap) 
									escapingUnicode:YES];
} // gtm_stringByEscapingAsciiHTML

- (NSString *)gtm_stringByUnescapingFromHTML {
	NSRange range = NSMakeRange(0, [self length]);
	NSRange subrange = [self rangeOfString:@"&" options:NSBackwardsSearch range:range];
	
	// if no ampersands, we've got a quick way out
	if (subrange.length == 0) return self;
	NSMutableString *finalString = [NSMutableString stringWithString:self];
	do {
		NSRange semiColonRange = NSMakeRange(subrange.location, NSMaxRange(range) - subrange.location);
		semiColonRange = [self rangeOfString:@";" options:0 range:semiColonRange];
		range = NSMakeRange(0, subrange.location);
		// if we don't find a semicolon in the range, we don't have a sequence
		if (semiColonRange.location == NSNotFound) {
			continue;
		}
		NSRange escapeRange = NSMakeRange(subrange.location, semiColonRange.location - subrange.location + 1);
		NSString *escapeString = [self substringWithRange:escapeRange];
		NSUInteger length = [escapeString length];
		// a squence must be longer than 3 (&lt;) and less than 11 (&thetasym;)
		if (length > 3 && length < 11) {
			if ([escapeString characterAtIndex:1] == '#') {
				unichar char2 = [escapeString characterAtIndex:2];
				if (char2 == 'x' || char2 == 'X') {
					// Hex escape squences &#xa3;
					NSString *hexSequence = [escapeString substringWithRange:NSMakeRange(3, length - 4)];
					NSScanner *scanner = [NSScanner scannerWithString:hexSequence];
					unsigned value;
					if ([scanner scanHexInt:&value] && 
						value < USHRT_MAX &&
						value > 0 
						&& [scanner scanLocation] == length - 4) {
						unichar uchar = value;
						NSString *charString = [NSString stringWithCharacters:&uchar length:1];
						[finalString replaceCharactersInRange:escapeRange withString:charString];
					}
					
				} else {
					// Decimal Sequences &#123;
					NSString *numberSequence = [escapeString substringWithRange:NSMakeRange(2, length - 3)];
					NSScanner *scanner = [NSScanner scannerWithString:numberSequence];
					int value;
					if ([scanner scanInt:&value] && 
						value < USHRT_MAX &&
						value > 0 
						&& [scanner scanLocation] == length - 3) {
						unichar uchar = value;
						NSString *charString = [NSString stringWithCharacters:&uchar length:1];
						[finalString replaceCharactersInRange:escapeRange withString:charString];
					}
				}
			} else {
				// "standard" sequences
				for (unsigned i = 0; i < sizeof(gAsciiHTMLEscapeMap) / sizeof(HTMLEscapeMap); ++i) {
					if ([escapeString isEqualToString:(__bridge_transfer NSString*)gAsciiHTMLEscapeMap[i].escapeSequence]) {
						[finalString replaceCharactersInRange:escapeRange withString:[NSString stringWithCharacters:&gAsciiHTMLEscapeMap[i].uchar length:1]];
						break;
					}
				}
			}
		}
	} while ((subrange = [self rangeOfString:@"&" options:NSBackwardsSearch range:range]).length != 0);
	return finalString;
} // gtm_stringByUnescapingHTML



@end