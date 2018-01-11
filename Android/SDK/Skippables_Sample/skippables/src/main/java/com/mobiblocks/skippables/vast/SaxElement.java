package com.mobiblocks.skippables.vast;

import org.xml.sax.SAXException;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;

/**
 * Created by daniel on 12/18/17.
 * <p>
 * Copyright Mobiblocks 2017. All rights reserved.
 */

class SaxElement {
    private final String name;
    private String value;
    private final SaxAttributes attributes;
    private final ArrayList<SaxElement> childs;

    public SaxElement(String name, SaxAttributes attributes) {
        this.name = name;
        this.attributes = attributes;
        
        this.childs = new ArrayList<>();
    }

    public String getName() {
        return name;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public URL getUrlValue() throws SAXException {
        if (value == null || value.isEmpty()) {
            return null;
        }

        try {
            return new URL(value);
        } catch (MalformedURLException e) {
            throw new SAXException(e);
        }
    }

    public Double getDoubleObjectValue() throws SAXException {
        if (value == null || value.isEmpty()) {
            return null;
        }

        try {
            return Double.valueOf(value);
        } catch (NumberFormatException e) {
            throw new SAXException(e);
        }
    }

    public SaxAttributes getAttributes() {
        return attributes;
    }

    public ArrayList<SaxElement> getChilds() {
        return childs;
    }
    
    public void addChild(SaxElement element) {
        childs.add(element);
    }

    public boolean is(String name) {
        return this.name.equalsIgnoreCase(name);
    }

    public boolean isNot(String name) {
        return !this.name.equalsIgnoreCase(name);
    }

    @Override
    public String toString() {
        return "SaxElement{" +
                "name='" + name + '\'' +
                '}';
    }
}
