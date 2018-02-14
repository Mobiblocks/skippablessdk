//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, v2.2.8-b130911.1802 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2017.12.14 at 03:40:33 PM EET 
//


package com.mobiblocks.skippables.vast;

import android.support.annotation.NonNull;

import java.net.URL;
import java.util.ArrayList;
import java.util.List;


/**
 * An ad that is overlain on top of video content during playback
 * 
 * <p>Java class for NonLinearAd_InlineChild_type complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="NonLinearAd_InlineChild_type">
 *   &lt;complexContent>
 *     &lt;extension base="{http://www.iab.com/VAST}CreativeResource_NonVideo_type">
 *       &lt;sequence>
 *         &lt;element name="AdParameters" type="{http://www.iab.com/VAST}AdParameters_type" minOccurs="0"/>
 *         &lt;element name="NonLinearClickThrough" type="{http://www.w3.org/2001/XMLSchema}anyURI" minOccurs="0"/>
 *         &lt;element name="NonLinearClickTracking" maxOccurs="unbounded" minOccurs="0">
 *           &lt;complexType>
 *             &lt;simpleContent>
 *               &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>anyURI">
 *                 &lt;attribute name="id" type="{http://www.w3.org/2001/XMLSchema}string" />
 *               &lt;/extension>
 *             &lt;/simpleContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *       &lt;/sequence>
 *     &lt;/extension>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
public class NonLinearAdInlineChildType
    extends CreativeResourceNonVideoType
{

    protected AdParametersType adParameters;
    protected URL nonLinearClickThrough;
    @NonNull
    protected List<NonLinearAdInlineChildType.NonLinearClickTracking> nonLinearClickTracking;

    /**
     * Gets the value of the adParameters property.
     * 
     * @return
     *     possible object is
     *     {@link AdParametersType }
     *     
     */
    public AdParametersType getAdParameters() {
        return adParameters;
    }

    /**
     * Sets the value of the adParameters property.
     * 
     * @param value
     *     allowed object is
     *     {@link AdParametersType }
     *     
     */
    public void setAdParameters(AdParametersType value) {
        this.adParameters = value;
    }

    /**
     * Gets the value of the nonLinearClickThrough property.
     * 
     * @return
     *     possible object is
     *     {@link URL }
     *     
     */
    public URL getNonLinearClickThrough() {
        return nonLinearClickThrough;
    }

    /**
     * Sets the value of the nonLinearClickThrough property.
     * 
     * @param value
     *     allowed object is
     *     {@link URL }
     *     
     */
    public void setNonLinearClickThrough(URL value) {
        this.nonLinearClickThrough = value;
    }

    /**
     * Gets the value of the nonLinearClickTracking property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the nonLinearClickTracking property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getNonLinearClickTracking().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link NonLinearAdInlineChildType.NonLinearClickTracking }
     * 
     * 
     */
    @NonNull
    public List<NonLinearAdInlineChildType.NonLinearClickTracking> getNonLinearClickTracking() {
        return this.nonLinearClickTracking;
    }
    
    public void addNonLinearClickTracking(@NonNull NonLinearAdInlineChildType.NonLinearClickTracking nonLinearClickTracking) {
        if (this.nonLinearClickTracking == null) {
            this.nonLinearClickTracking = new ArrayList<NonLinearAdInlineChildType.NonLinearClickTracking>();
        }
        this.nonLinearClickTracking.add(nonLinearClickTracking);
    }


    /**
     * <p>Java class for anonymous complex type.
     * 
     * <p>The following schema fragment specifies the expected content contained within this class.
     * 
     * <pre>
     * &lt;complexType>
     *   &lt;simpleContent>
     *     &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>anyURI">
     *       &lt;attribute name="id" type="{http://www.w3.org/2001/XMLSchema}string" />
     *     &lt;/extension>
     *   &lt;/simpleContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    public static class NonLinearClickTracking {

        protected URL value;
        protected String id;

        /**
         * Gets the value of the value property.
         * 
         * @return
         *     possible object is
         *     {@link URL }
         *     
         */
        public URL getValue() {
            return value;
        }

        /**
         * Sets the value of the value property.
         * 
         * @param value
         *     allowed object is
         *     {@link URL }
         *     
         */
        public void setValue(URL value) {
            this.value = value;
        }

        /**
         * Gets the value of the id property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getId() {
            return id;
        }

        /**
         * Sets the value of the id property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setId(String value) {
            this.id = value;
        }

    }

}