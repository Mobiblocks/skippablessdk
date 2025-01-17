//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, v2.2.8-b130911.1802 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2017.12.14 at 03:40:33 PM EET 
//


package com.mobiblocks.skippables.vast;

import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;


/**
 * <p>Java class for CompanionAd_type complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="CompanionAd_type">
 *   &lt;complexContent>
 *     &lt;extension base="{http://www.iab.com/VAST}CreativeResource_NonVideo_type">
 *       &lt;sequence>
 *         &lt;element name="AdParameters" type="{http://www.iab.com/VAST}AdParameters_type" minOccurs="0"/>
 *         &lt;element name="AltText" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="CompanionClickThrough" type="{http://www.w3.org/2001/XMLSchema}anyURI" minOccurs="0"/>
 *         &lt;element name="CompanionClickTracking" maxOccurs="unbounded" minOccurs="0">
 *           &lt;complexType>
 *             &lt;simpleContent>
 *               &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>anyURI">
 *                 &lt;attribute name="id" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
 *               &lt;/extension>
 *             &lt;/simpleContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="CreativeExtensions" type="{http://www.iab.com/VAST}CreativeExtensions_type" minOccurs="0"/>
 *         &lt;element name="TrackingEvents" type="{http://www.iab.com/VAST}TrackingEvents_type" minOccurs="0"/>
 *       &lt;/sequence>
 *       &lt;attribute name="id" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="width" use="required" type="{http://www.w3.org/2001/XMLSchema}integer" />
 *       &lt;attribute name="height" use="required" type="{http://www.w3.org/2001/XMLSchema}integer" />
 *       &lt;attribute name="assetWidth" type="{http://www.w3.org/2001/XMLSchema}integer" />
 *       &lt;attribute name="assetHeight" type="{http://www.w3.org/2001/XMLSchema}integer" />
 *       &lt;attribute name="expandedWidth" type="{http://www.w3.org/2001/XMLSchema}integer" />
 *       &lt;attribute name="expandedHeight" type="{http://www.w3.org/2001/XMLSchema}integer" />
 *       &lt;attribute name="apiFramework" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="adSlotID" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="pxratio" type="{http://www.w3.org/2001/XMLSchema}decimal" />
 *     &lt;/extension>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
public class CompanionAdType
    extends CreativeResourceNonVideoType
{

    protected AdParametersType adParameters;
    protected String altText;
    protected URL companionClickThrough;
    @Nullable
    protected List<CompanionAdType.CompanionClickTracking> companionClickTracking;
    protected CreativeExtensionsType creativeExtensions;
    protected TrackingEventsType trackingEvents;
    protected String id;
    @NonNull
    protected int width;
    @NonNull
    protected int height;
    protected int assetWidth;
    protected int assetHeight;
    protected int expandedWidth;
    protected int expandedHeight;
    protected String apiFramework;
    protected String adSlotID;
    protected Float pxratio;

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
     * Gets the value of the altText property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAltText() {
        return altText;
    }

    /**
     * Sets the value of the altText property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAltText(String value) {
        this.altText = value;
    }

    /**
     * Gets the value of the companionClickThrough property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public URL getCompanionClickThrough() {
        return companionClickThrough;
    }

    /**
     * Sets the value of the companionClickThrough property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCompanionClickThrough(URL value) {
        this.companionClickThrough = value;
    }

    /**
     * Gets the value of the companionClickTracking property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the companionClickTracking property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getCompanionClickTracking().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link CompanionAdType.CompanionClickTracking }
     * 
     * 
     */
    @Nullable
    public List<CompanionAdType.CompanionClickTracking> getCompanionClickTracking() {
        return this.companionClickTracking;
    }
    public void addCompanionClickTracking(CompanionAdType.CompanionClickTracking companionClickTracking) {
        if (this.companionClickTracking == null) {
            this.companionClickTracking = new ArrayList<>();
        }
        this.companionClickTracking.add(companionClickTracking);
    }

    /**
     * Gets the value of the creativeExtensions property.
     * 
     * @return
     *     possible object is
     *     {@link CreativeExtensionsType }
     *     
     */
    public CreativeExtensionsType getCreativeExtensions() {
        return creativeExtensions;
    }

    /**
     * Sets the value of the creativeExtensions property.
     * 
     * @param value
     *     allowed object is
     *     {@link CreativeExtensionsType }
     *     
     */
    public void setCreativeExtensions(CreativeExtensionsType value) {
        this.creativeExtensions = value;
    }

    /**
     * Gets the value of the trackingEvents property.
     * 
     * @return
     *     possible object is
     *     {@link TrackingEventsType }
     *     
     */
    public TrackingEventsType getTrackingEvents() {
        return trackingEvents;
    }

    /**
     * Sets the value of the trackingEvents property.
     * 
     * @param value
     *     allowed object is
     *     {@link TrackingEventsType }
     *     
     */
    public void setTrackingEvents(TrackingEventsType value) {
        this.trackingEvents = value;
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

    /**
     * Gets the value of the width property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public int getWidth() {
        return width;
    }

    /**
     * Sets the value of the width property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setWidth(int value) {
        this.width = value;
    }

    /**
     * Gets the value of the height property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public int getHeight() {
        return height;
    }

    /**
     * Sets the value of the height property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setHeight(int value) {
        this.height = value;
    }

    /**
     * Gets the value of the assetWidth property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public int getAssetWidth() {
        return assetWidth;
    }

    /**
     * Sets the value of the assetWidth property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setAssetWidth(int value) {
        this.assetWidth = value;
    }

    /**
     * Gets the value of the assetHeight property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public int getAssetHeight() {
        return assetHeight;
    }

    /**
     * Sets the value of the assetHeight property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setAssetHeight(int value) {
        this.assetHeight = value;
    }

    /**
     * Gets the value of the expandedWidth property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public int getExpandedWidth() {
        return expandedWidth;
    }

    /**
     * Sets the value of the expandedWidth property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setExpandedWidth(int value) {
        this.expandedWidth = value;
    }

    /**
     * Gets the value of the expandedHeight property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public int getExpandedHeight() {
        return expandedHeight;
    }

    /**
     * Sets the value of the expandedHeight property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setExpandedHeight(int value) {
        this.expandedHeight = value;
    }

    /**
     * Gets the value of the apiFramework property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getApiFramework() {
        return apiFramework;
    }

    /**
     * Sets the value of the apiFramework property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setApiFramework(String value) {
        this.apiFramework = value;
    }

    /**
     * Gets the value of the adSlotID property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAdSlotID() {
        return adSlotID;
    }

    /**
     * Sets the value of the adSlotID property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAdSlotID(String value) {
        this.adSlotID = value;
    }

    /**
     * Gets the value of the pxratio property.
     * 
     * @return
     *     possible object is
     *     {@link BigDecimal }
     *     
     */
    public Float getPxratio() {
        return pxratio;
    }

    /**
     * Sets the value of the pxratio property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigDecimal }
     *     
     */
    public void setPxratio(Float value) {
        this.pxratio = value;
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
     *       &lt;attribute name="id" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
     *     &lt;/extension>
     *   &lt;/simpleContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    public static class CompanionClickTracking {

        protected URL value;
        @NonNull
        protected String id;

        /**
         * Gets the value of the value property.
         * 
         * @return
         *     possible object is
         *     {@link String }
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
         *     {@link String }
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
