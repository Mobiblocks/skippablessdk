package com.mobiblocks.skippables.vast;

import org.xml.sax.Attributes;
import org.xml.sax.SAXException;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.HashMap;
import java.util.Set;

/**
 * Created by daniel on 12/18/17.
 * <p>
 * Copyright Mobiblocks 2017. All rights reserved.
 */

class SaxAttributes {
    
    private HashMap<String, String> map = new HashMap<>();

    private void put(String qName, String value) {
        map.put(qName, value);
    }
    
    public static SaxAttributes create(Attributes attributes) {
        SaxAttributes saxAttributes = new SaxAttributes();

        for (int i = 0; i < attributes.getLength(); i++) {
            saxAttributes.put(attributes.getQName(i), attributes.getValue(i));
        }

        return saxAttributes;
    }
    
    public Set<String> keySet() {
        return map.keySet();
    }

    public String getValue(String key) {
        return map.get(key);
    }

    public URL getUrlValue(String key) throws SAXException {
        String value = getValue(key);
        if (value == null || value.isEmpty()) {
            return null;
        }

        try {
            return new URL(value);
        } catch (MalformedURLException e) {
            throw new SAXException(e);
        }
    }

    public int getIntValue(String key) throws SAXException {
        String value = getValue(key);
        if (value == null || value.isEmpty()) {
            return 0;
        }

        try {
            return Integer.parseInt(value, 10);
        } catch (NumberFormatException e) {
            throw new SAXException(e);
        }
    }
    
    public boolean getBoolValue(String key) {
        String value = getValue(key);
        
        return Boolean.parseBoolean(value);
    }

    public Double getDoubleObjectValue(String key) throws SAXException {
        String value = getValue(key);
        if (value == null || value.isEmpty()) {
            return null;
        }

        try {
            return Double.valueOf(value);
        } catch (NumberFormatException e) {
            throw new SAXException(e);
        }
    }

    public Float getFloatObject(String key) throws SAXException {
        String value = getValue(key);
        if (value == null || value.isEmpty()) {
            return null;
        }

        try {
            return Float.valueOf(value);
        } catch (NumberFormatException e) {
            throw new SAXException(e);
        }
    }
}
