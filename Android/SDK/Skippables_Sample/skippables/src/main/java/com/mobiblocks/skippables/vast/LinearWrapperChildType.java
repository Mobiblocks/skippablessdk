//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, v2.2.8-b130911.1802 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2017.12.14 at 03:40:33 PM EET 
//


package com.mobiblocks.skippables.vast;

/**
 * Video formatted ad that plays linearly
 * 
 * <p>Java class for Linear_WrapperChild_type complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="Linear_WrapperChild_type">
 *   &lt;complexContent>
 *     &lt;extension base="{http://www.iab.com/VAST}Linear_Base_type">
 *       &lt;sequence>
 *         &lt;element name="VideoClicks" type="{http://www.iab.com/VAST}VideoClicks_Base_type" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/extension>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
public class LinearWrapperChildType
    extends LinearBaseType
{

    protected VideoClicksBaseType videoClicks;

    /**
     * Gets the value of the videoClicks property.
     * 
     * @return
     *     possible object is
     *     {@link VideoClicksBaseType }
     *     
     */
    public VideoClicksBaseType getVideoClicks() {
        return videoClicks;
    }

    /**
     * Sets the value of the videoClicks property.
     * 
     * @param value
     *     allowed object is
     *     {@link VideoClicksBaseType }
     *     
     */
    public void setVideoClicks(VideoClicksBaseType value) {
        this.videoClicks = value;
    }

}
