/*
 * File: SaxParser.java
 * Package: com.mobiblocks.vast
 * Project: 
 * Generated on: Thu Dec 14 16:46:26 EET 2017
 * From schema(s): /Users/daniel/Dev/iOS/skipp/vast_gen/vast4.xsd
 * By: Xsd2SaxParser tool (Eric Blanchard)
 */

package com.mobiblocks.skippables.vast;

import android.util.SparseArray;

import java.io.CharArrayWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.List;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.xml.sax.Attributes;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;
import org.xml.sax.helpers.DefaultHandler;


/**
 * Implements a SAX parser
 */
public class SaxParser extends DefaultHandler {
    private static boolean configured = false;
    private static SAXParserFactory factory = null;
    private SAXParser saxParser = null;
    private String elementToSkip = null;
    private int skipedElementDepth = 0;
    private CharArrayWriter text = null;
    private int currentDepth = 0;

    private static List<String> supportedTags;

    private SparseArray<SaxElement> elementArray = new SparseArray<>();

    /**
     * Private constructor
     *
     * @throws SAXException
     * @throws ParserConfigurationException
     */
    private SaxParser() throws ParserConfigurationException, SAXException {
        text = new CharArrayWriter();
        saxParser = factory.newSAXParser();
    }

    /**
     * Gets a new instance of SaxParser.
     * Ensuring that the SAX parser factory has been configured only once.
     *
     * @return a <b>SaxParser</b> instance.
     * @throws SAXException
     * @throws ParserConfigurationException
     */
    public static SaxParser getInstance() throws ParserConfigurationException, SAXException {
        if (!configured) {
            configure();
        }
        return new SaxParser();
    }

    /**
     * Configures the SAX parser factory.
     * The default JRE provided SAX parser is used (controlled by
     * <code>"javax.xml.parsers.SAXParserFactory"</code> system property.
     */
    private static void configure() {

        // Use the configured SAXParserFactory
        factory = SAXParserFactory.newInstance();
        /* Customize SAX parser */
        factory.setNamespaceAware(true);
        factory.setValidating(false);
        configured = true;

        supportedTags = new ArrayList<>();
        supportedTags.add(XmlTags.CUSTOM_CLICK_TAG);
        supportedTags.add(XmlTags.NON_LINEAR_CLICK_THROUGH_TAG);
        supportedTags.add(XmlTags.CREATIVE_EXTENSIONS_TAG);
        supportedTags.add(XmlTags.IN_LINE_TAG);
        supportedTags.add(XmlTags.MEDIA_FILES_TAG);
        supportedTags.add(XmlTags.MEDIA_FILE_TAG);
        supportedTags.add(XmlTags.ICON_TAG);
        supportedTags.add(XmlTags.AD_TAG);
        supportedTags.add(XmlTags.VAST_TAG);
        supportedTags.add(XmlTags.CLICK_THROUGH_TAG);
        supportedTags.add(XmlTags.INTERACTIVE_CREATIVE_FILE_TAG);
        supportedTags.add(XmlTags.NON_LINEAR_ADS_TAG);
        supportedTags.add(XmlTags.FLASH_RESOURCE_TAG);
        supportedTags.add(XmlTags.IMPRESSION_TAG);
        supportedTags.add(XmlTags.VIEWABLE_TAG);
        supportedTags.add(XmlTags.TRACKING_TAG);
        supportedTags.add(XmlTags.DURATION_TAG);
        supportedTags.add(XmlTags.NON_LINEAR_CLICK_TRACKING_TAG);
        supportedTags.add(XmlTags.HTMLRESOURCE_TAG);
        supportedTags.add(XmlTags.IFRAME_RESOURCE_TAG);
        supportedTags.add(XmlTags.UNIVERSAL_AD_ID_TAG);
        supportedTags.add(XmlTags.CATEGORY_TAG);
        supportedTags.add(XmlTags.AD_SYSTEM_TAG);
        supportedTags.add(XmlTags.NON_LINEAR_TAG);
        supportedTags.add(XmlTags.EXTENSIONS_TAG);
        supportedTags.add(XmlTags.PRICING_TAG);
        supportedTags.add(XmlTags.JAVA_SCRIPT_RESOURCE_TAG);
        supportedTags.add(XmlTags.AD_TITLE_TAG);
        supportedTags.add(XmlTags.COMPANION_CLICK_TRACKING_TAG);
        supportedTags.add(XmlTags.VASTAD_TAG_URI_TAG);
        supportedTags.add(XmlTags.COMPANION_CLICK_THROUGH_TAG);
        supportedTags.add(XmlTags.ALT_TEXT_TAG);
        supportedTags.add(XmlTags.VIDEO_CLICKS_TAG);
        supportedTags.add(XmlTags.AD_PARAMETERS_TAG);
        supportedTags.add(XmlTags.CREATIVE_TAG);
        supportedTags.add(XmlTags.SURVEY_TAG);
        supportedTags.add(XmlTags.CREATIVES_TAG);
        supportedTags.add(XmlTags.COMPANION_ADS_TAG);
        supportedTags.add(XmlTags.CLICK_TRACKING_TAG);
        supportedTags.add(XmlTags.ADVERTISER_TAG);
        supportedTags.add(XmlTags.AD_VERIFICATIONS_TAG);
        supportedTags.add(XmlTags.ICON_VIEW_TRACKING_TAG);
        supportedTags.add(XmlTags.EXTENSION_TAG);
        supportedTags.add(XmlTags.VIEWABLE_IMPRESSION_TAG);
        supportedTags.add(XmlTags.ICONS_TAG);
        supportedTags.add(XmlTags.COMPANION_TAG);
        supportedTags.add(XmlTags.STATIC_RESOURCE_TAG);
        supportedTags.add(XmlTags.TRACKING_EVENTS_TAG);
        supportedTags.add(XmlTags.VERIFICATION_TAG);
        supportedTags.add(XmlTags.ICON_CLICKS_TAG);
        supportedTags.add(XmlTags.NOT_VIEWABLE_TAG);
        supportedTags.add(XmlTags.ICON_CLICK_TRACKING_TAG);
        supportedTags.add(XmlTags.CREATIVE_EXTENSION_TAG);
        supportedTags.add(XmlTags.ICON_CLICK_THROUGH_TAG);
        supportedTags.add(XmlTags.MEZZANINE_TAG);
        supportedTags.add(XmlTags.WRAPPER_TAG);
        supportedTags.add(XmlTags.ERROR_TAG);
        supportedTags.add(XmlTags.LINEAR_TAG);
        supportedTags.add(XmlTags.DESCRIPTION_TAG);
        supportedTags.add(XmlTags.VIEW_UNDETERMINED_TAG);
    }

    public VAST parseFromString(final String str) throws VastException {
        if (str == null || str.length() == 0) {
            return null;
        }
        
        InputSource src = new InputSource(new StringReader(str));
        try {
            parse(src);
            if (elementArray.size() == 0) {
                throw new VastException(VastError.VAST_WRAPPER_NO_VAST_ERROR_CODE);
            }

            SaxElement rootElement = elementArray.valueAt(0);

            return XmlObjectFactory.getDefaultFactory().createVAST(rootElement);
        } catch (SAXException e) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE);
        } catch (IOException e) {
            throw new VastException(VastError.VAST_UNDEFINED_ERROR_CODE);
        } catch (Exception e) {
            throw new VastException(VastError.VAST_UNDEFINED_ERROR_CODE);
        }
    }

    private void parse(InputStream is) throws SAXException, IOException {
        parse(new InputSource(is));
    }

    private void parse(InputSource is) throws SAXException, IOException {
        saxParser.parse(is, this);
    }

    /* (non-Javadoc)
     * Resolves relative path URI entities to current directory
     */
    public InputSource resolveEntity(String publicId, String systemId)
            throws SAXException {
        /* Provide an empty entity resolver */
        return new InputSource(new StringReader(""));
    }

    /* (non-Javadoc)
     */
    public void processingInstruction(String target, String data) throws SAXException {
    }

    /* (non-Javadoc)
     */
    public void skippedEntity(String name) throws SAXException {
    }

    /* (non-Javadoc)
     */
    public void startDocument() throws SAXException {
    }


    /* (non-Javadoc)
     */
    public void endDocument() throws SAXException {
    }

    /* (non-Javadoc)
     */
    public void startElement(String namespaceURI, String sName, String qName,
                             Attributes attrs) throws SAXException {
        String eName = qName; /* element name (assuming namespaceAware) */

        currentDepth++;

        if (elementToSkip != null) {
            return;
        }

        text.reset();

        if (supportedTags.contains(eName)) {
            createCurrentElement(eName, attrs);
        } else {
            /* Unknown elements fall here, so just ask to skip this unknown
             * element (and all nested elements) */
            elementToSkip = eName;
            skipedElementDepth = currentDepth;
        }
    }

//    private SaxElement getOrCreateElement(String eName, Attributes attrs) {
//        SaxElement current = elementArray.get(currentDepth);
//        if (current == null) {
//            current = new SaxElement(eName, attrs);
//            elementArray.put(currentDepth, current);
//
//            return current;
//        }
//
//        SaxElement element = new SaxElement(eName, attrs);
//
//        current.addChild(element);
//
//        return element;
//    }

    private SaxElement getCurrentElement() {
        return elementArray.get(currentDepth);
    }

    private void createCurrentElement(String eName, Attributes attrs) {

        SaxElement element = new SaxElement(eName, SaxAttributes.create(attrs));

        SaxElement parent = elementArray.get(currentDepth - 1);
        if (parent != null) {
            parent.addChild(element);
        }

        elementArray.put(currentDepth, element);
    }

    /* (non-Javadoc)
     */
    public void endElement(String namespaceURI, String sName, String qName)
            throws SAXException {
        String eName = qName; /* element name (assuming namespaceAware) */

        if (elementToSkip != null) {
            if (elementToSkip.equals(eName) && currentDepth == skipedElementDepth) {
                elementToSkip = null;
                skipedElementDepth = -1;
            }
            currentDepth--;
            return;
        }

        if (supportedTags.contains(eName)) {
            SaxElement element = getCurrentElement();
            if (element != null) {
                String text = getText();
                if (!text.isEmpty()) {
                    element.setValue(text);
                }
            }
        } else {
        }
        currentDepth--;
    }

    /* (non-Javadoc)
     * @see org.xml.sax.ContentHandler#characters(char[], int, int)
     */
    public void characters(char buf[], int offset, int len)
            throws SAXException {
        if (elementToSkip != null) {
            return;
        }
        if (len > 0) {
            text.write(buf, offset, len);
        }
    }

    /* (non-Javadoc)
     */
    public void warning(SAXParseException e) throws SAXException {
    }

    /* (non-Javadoc)
     */
    public void error(SAXParseException e) throws SAXException {
    }

    /* (non-Javadoc)
     */
    public void fatalError(SAXParseException e) throws SAXException {
        throw e;
    }

    public String getText() {
        return text.toString().trim();
    }
}
