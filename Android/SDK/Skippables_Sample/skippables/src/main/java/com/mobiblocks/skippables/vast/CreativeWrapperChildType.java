//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, v2.2.8-b130911.1802 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2017.12.14 at 03:40:33 PM EET 
//


package com.mobiblocks.skippables.vast;

import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import java.util.ArrayList;
import java.util.List;


/**
 * <p>Java class for Creative_WrapperChild_type complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="Creative_WrapperChild_type">
 *   &lt;complexContent>
 *     &lt;extension base="{http://www.iab.com/VAST}Creative_Base_type">
 *       &lt;sequence>
 *         &lt;element name="CompanionAds" type="{http://www.iab.com/VAST}CompanionAds_Collection_type" minOccurs="0"/>
 *         &lt;element name="Linear" type="{http://www.iab.com/VAST}Linear_WrapperChild_type" minOccurs="0"/>
 *         &lt;element name="NonLinearAds" minOccurs="0">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;element name="TrackingEvents" type="{http://www.iab.com/VAST}TrackingEvents_type" minOccurs="0"/>
 *                   &lt;element name="NonLinear" type="{http://www.iab.com/VAST}NonLinearAd_Base_type" maxOccurs="unbounded" minOccurs="0"/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
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
public class CreativeWrapperChildType
    extends CreativeBaseType
{

    protected CompanionAdsCollectionType companionAds;
    protected LinearWrapperChildType linear;
    protected CreativeWrapperChildType.NonLinearAds nonLinearAds;

    /**
     * Gets the value of the companionAds property.
     * 
     * @return
     *     possible object is
     *     {@link CompanionAdsCollectionType }
     *     
     */
    public CompanionAdsCollectionType getCompanionAds() {
        return companionAds;
    }

    /**
     * Sets the value of the companionAds property.
     * 
     * @param value
     *     allowed object is
     *     {@link CompanionAdsCollectionType }
     *     
     */
    public void setCompanionAds(CompanionAdsCollectionType value) {
        this.companionAds = value;
    }

    /**
     * Gets the value of the linear property.
     * 
     * @return
     *     possible object is
     *     {@link LinearWrapperChildType }
     *     
     */
    public LinearWrapperChildType getLinear() {
        return linear;
    }

    /**
     * Sets the value of the linear property.
     * 
     * @param value
     *     allowed object is
     *     {@link LinearWrapperChildType }
     *     
     */
    public void setLinear(LinearWrapperChildType value) {
        this.linear = value;
    }

    /**
     * Gets the value of the nonLinearAds property.
     * 
     * @return
     *     possible object is
     *     {@link CreativeWrapperChildType.NonLinearAds }
     *     
     */
    public CreativeWrapperChildType.NonLinearAds getNonLinearAds() {
        return nonLinearAds;
    }

    /**
     * Sets the value of the nonLinearAds property.
     * 
     * @param value
     *     allowed object is
     *     {@link CreativeWrapperChildType.NonLinearAds }
     *     
     */
    public void setNonLinearAds(CreativeWrapperChildType.NonLinearAds value) {
        this.nonLinearAds = value;
    }


    /**
     * <p>Java class for anonymous complex type.
     * 
     * <p>The following schema fragment specifies the expected content contained within this class.
     * 
     * <pre>
     * &lt;complexType>
     *   &lt;complexContent>
     *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
     *       &lt;sequence>
     *         &lt;element name="TrackingEvents" type="{http://www.iab.com/VAST}TrackingEvents_type" minOccurs="0"/>
     *         &lt;element name="NonLinear" type="{http://www.iab.com/VAST}NonLinearAd_Base_type" maxOccurs="unbounded" minOccurs="0"/>
     *       &lt;/sequence>
     *     &lt;/restriction>
     *   &lt;/complexContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    public static class NonLinearAds {

        @Nullable
        protected TrackingEventsType trackingEvents;
        @Nullable
        protected List<NonLinearAdBaseType> nonLinear;

        /**
         * Gets the value of the trackingEvents property.
         * 
         * @return
         *     possible object is
         *     {@link TrackingEventsType }
         *     
         */
        @Nullable
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
        public void setTrackingEvents(@NonNull TrackingEventsType value) {
            this.trackingEvents = value;
        }

        /**
         * Gets the value of the nonLinear property.
         * 
         * <p>
         * This accessor method returns a reference to the live list,
         * not a snapshot. Therefore any modification you make to the
         * returned list will be present inside the JAXB object.
         * This is why there is not a <CODE>set</CODE> method for the nonLinear property.
         * 
         * <p>
         * For example, to add a new item, do as follows:
         * <pre>
         *    getNonLinear().add(newItem);
         * </pre>
         * 
         * 
         * <p>
         * Objects of the following type(s) are allowed in the list
         * {@link NonLinearAdBaseType }
         * 
         * 
         */
        @Nullable
        public List<NonLinearAdBaseType> getNonLinear() {
            return this.nonLinear;
        }

        public void addNonLinear(NonLinearAdBaseType nonLinear) {
            if (this.nonLinear == null) {
                this.nonLinear = new ArrayList<NonLinearAdBaseType>();
            }
            this.nonLinear.add(nonLinear);
        }
    }

}
