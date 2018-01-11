//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, v2.2.8-b130911.1802 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2017.12.14 at 03:40:33 PM EET 
//


package com.mobiblocks.skippables.vast;

import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import java.math.BigInteger;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import javax.xml.datatype.XMLGregorianCalendar;


/**
 * Video formatted ad that plays linearly
 * 
 * <p>Java class for Linear_InlineChild_type complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="Linear_InlineChild_type">
 *   &lt;complexContent>
 *     &lt;extension base="{http://www.iab.com/VAST}Linear_Base_type">
 *       &lt;sequence>
 *         &lt;element name="AdParameters" type="{http://www.iab.com/VAST}AdParameters_type" minOccurs="0"/>
 *         &lt;element name="Duration" type="{http://www.w3.org/2001/XMLSchema}time"/>
 *         &lt;element name="MediaFiles">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;element name="MediaFile" maxOccurs="unbounded">
 *                     &lt;complexType>
 *                       &lt;simpleContent>
 *                         &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>anyURI">
 *                           &lt;attribute name="id" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                           &lt;attribute name="delivery" use="required">
 *                             &lt;simpleType>
 *                               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}token">
 *                                 &lt;enumeration value="streaming"/>
 *                                 &lt;enumeration value="progressive"/>
 *                               &lt;/restriction>
 *                             &lt;/simpleType>
 *                           &lt;/attribute>
 *                           &lt;attribute name="type" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                           &lt;attribute name="width" use="required" type="{http://www.w3.org/2001/XMLSchema}integer" />
 *                           &lt;attribute name="height" use="required" type="{http://www.w3.org/2001/XMLSchema}integer" />
 *                           &lt;attribute name="codec" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                           &lt;attribute name="bitrate" type="{http://www.w3.org/2001/XMLSchema}integer" />
 *                           &lt;attribute name="minBitrate" type="{http://www.w3.org/2001/XMLSchema}integer" />
 *                           &lt;attribute name="maxBitrate" type="{http://www.w3.org/2001/XMLSchema}integer" />
 *                           &lt;attribute name="scalable" type="{http://www.w3.org/2001/XMLSchema}boolean" />
 *                           &lt;attribute name="maintainAspectRatio" type="{http://www.w3.org/2001/XMLSchema}boolean" />
 *                           &lt;attribute name="apiFramework" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                         &lt;/extension>
 *                       &lt;/simpleContent>
 *                     &lt;/complexType>
 *                   &lt;/element>
 *                   &lt;element name="Mezzanine" type="{http://www.w3.org/2001/XMLSchema}anyURI" minOccurs="0"/>
 *                   &lt;element name="InteractiveCreativeFile" maxOccurs="unbounded" minOccurs="0">
 *                     &lt;complexType>
 *                       &lt;simpleContent>
 *                         &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>anyURI">
 *                           &lt;attribute name="type" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                           &lt;attribute name="apiFramework" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                         &lt;/extension>
 *                       &lt;/simpleContent>
 *                     &lt;/complexType>
 *                   &lt;/element>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="VideoClicks" type="{http://www.iab.com/VAST}VideoClicks_InlineChild_type" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/extension>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
public class LinearInlineChildType
    extends LinearBaseType
{

    protected AdParametersType adParameters;
    @NonNull
    protected String duration;
    @NonNull
    protected LinearInlineChildType.MediaFiles mediaFiles;
    protected VideoClicksInlineChildType videoClicks;

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
     * Gets the value of the duration property.
     * 
     * @return
     *     possible object is
     *     {@link XMLGregorianCalendar }
     *     
     */
    public String getDuration() {
        return duration;
    }

    /**
     * Sets the value of the duration property.
     * 
     * @param value
     *     allowed object is
     *     {@link XMLGregorianCalendar }
     *     
     */
    public void setDuration(String value) {
        this.duration = value;
    }

    /**
     * Gets the value of the mediaFiles property.
     * 
     * @return
     *     possible object is
     *     {@link LinearInlineChildType.MediaFiles }
     *     
     */
    public LinearInlineChildType.MediaFiles getMediaFiles() {
        return mediaFiles;
    }

    /**
     * Sets the value of the mediaFiles property.
     * 
     * @param value
     *     allowed object is
     *     {@link LinearInlineChildType.MediaFiles }
     *     
     */
    public void setMediaFiles(LinearInlineChildType.MediaFiles value) {
        this.mediaFiles = value;
    }

    /**
     * Gets the value of the videoClicks property.
     * 
     * @return
     *     possible object is
     *     {@link VideoClicksInlineChildType }
     *     
     */
    public VideoClicksInlineChildType getVideoClicks() {
        return videoClicks;
    }

    /**
     * Sets the value of the videoClicks property.
     * 
     * @param value
     *     allowed object is
     *     {@link VideoClicksInlineChildType }
     *     
     */
    public void setVideoClicks(VideoClicksInlineChildType value) {
        this.videoClicks = value;
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
     *         &lt;element name="MediaFile" maxOccurs="unbounded">
     *           &lt;complexType>
     *             &lt;simpleContent>
     *               &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>anyURI">
     *                 &lt;attribute name="id" type="{http://www.w3.org/2001/XMLSchema}string" />
     *                 &lt;attribute name="delivery" use="required">
     *                   &lt;simpleType>
     *                     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}token">
     *                       &lt;enumeration value="streaming"/>
     *                       &lt;enumeration value="progressive"/>
     *                     &lt;/restriction>
     *                   &lt;/simpleType>
     *                 &lt;/attribute>
     *                 &lt;attribute name="type" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
     *                 &lt;attribute name="width" use="required" type="{http://www.w3.org/2001/XMLSchema}integer" />
     *                 &lt;attribute name="height" use="required" type="{http://www.w3.org/2001/XMLSchema}integer" />
     *                 &lt;attribute name="codec" type="{http://www.w3.org/2001/XMLSchema}string" />
     *                 &lt;attribute name="bitrate" type="{http://www.w3.org/2001/XMLSchema}integer" />
     *                 &lt;attribute name="minBitrate" type="{http://www.w3.org/2001/XMLSchema}integer" />
     *                 &lt;attribute name="maxBitrate" type="{http://www.w3.org/2001/XMLSchema}integer" />
     *                 &lt;attribute name="scalable" type="{http://www.w3.org/2001/XMLSchema}boolean" />
     *                 &lt;attribute name="maintainAspectRatio" type="{http://www.w3.org/2001/XMLSchema}boolean" />
     *                 &lt;attribute name="apiFramework" type="{http://www.w3.org/2001/XMLSchema}string" />
     *               &lt;/extension>
     *             &lt;/simpleContent>
     *           &lt;/complexType>
     *         &lt;/element>
     *         &lt;element name="Mezzanine" type="{http://www.w3.org/2001/XMLSchema}anyURI" minOccurs="0"/>
     *         &lt;element name="InteractiveCreativeFile" maxOccurs="unbounded" minOccurs="0">
     *           &lt;complexType>
     *             &lt;simpleContent>
     *               &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>anyURI">
     *                 &lt;attribute name="type" type="{http://www.w3.org/2001/XMLSchema}string" />
     *                 &lt;attribute name="apiFramework" type="{http://www.w3.org/2001/XMLSchema}string" />
     *               &lt;/extension>
     *             &lt;/simpleContent>
     *           &lt;/complexType>
     *         &lt;/element>
     *       &lt;/sequence>
     *     &lt;/restriction>
     *   &lt;/complexContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    public static class MediaFiles {

        @NonNull
        protected List<LinearInlineChildType.MediaFiles.MediaFile> mediaFile = new ArrayList<>();
        protected URL mezzanine;
        protected List<LinearInlineChildType.MediaFiles.InteractiveCreativeFile> interactiveCreativeFile;

        /**
         * Gets the value of the mediaFile property.
         * 
         * <p>
         * This accessor method returns a reference to the live list,
         * not a snapshot. Therefore any modification you make to the
         * returned list will be present inside the JAXB object.
         * This is why there is not a <CODE>set</CODE> method for the mediaFile property.
         * 
         * <p>
         * For example, to add a new item, do as follows:
         * <pre>
         *    getMediaFile().add(newItem);
         * </pre>
         * 
         * 
         * <p>
         * Objects of the following type(s) are allowed in the list
         * {@link LinearInlineChildType.MediaFiles.MediaFile }
         * 
         * 
         */
        @NonNull
        public List<LinearInlineChildType.MediaFiles.MediaFile> getMediaFile() {
            return this.mediaFile;
        }
        
        public void addMediaFile(@NonNull LinearInlineChildType.MediaFiles.MediaFile mediaFile) {
            this.mediaFile.add(mediaFile);
        }

        /**
         * Gets the value of the mezzanine property.
         * 
         * @return
         *     possible object is
         *     {@link URL }
         *     
         */
        public URL getMezzanine() {
            return mezzanine;
        }

        /**
         * Sets the value of the mezzanine property.
         * 
         * @param value
         *     allowed object is
         *     {@link URL }
         *     
         */
        public void setMezzanine(URL value) {
            this.mezzanine = value;
        }

        /**
         * Gets the value of the interactiveCreativeFile property.
         * 
         * <p>
         * This accessor method returns a reference to the live list,
         * not a snapshot. Therefore any modification you make to the
         * returned list will be present inside the JAXB object.
         * This is why there is not a <CODE>set</CODE> method for the interactiveCreativeFile property.
         * 
         * <p>
         * For example, to add a new item, do as follows:
         * <pre>
         *    getInteractiveCreativeFile().add(newItem);
         * </pre>
         * 
         * 
         * <p>
         * Objects of the following type(s) are allowed in the list
         * {@link LinearInlineChildType.MediaFiles.InteractiveCreativeFile }
         * 
         * 
         */
        @Nullable
        public List<LinearInlineChildType.MediaFiles.InteractiveCreativeFile> getInteractiveCreativeFile() {
            return this.interactiveCreativeFile;
        }
        
        public void addInteractiveCreativeFile(@NonNull LinearInlineChildType.MediaFiles.InteractiveCreativeFile interactiveCreativeFile) {
            if (this.interactiveCreativeFile == null) {
                this.interactiveCreativeFile = new ArrayList<>();
            }
            this.interactiveCreativeFile.add(interactiveCreativeFile);
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
         *       &lt;attribute name="type" type="{http://www.w3.org/2001/XMLSchema}string" />
         *       &lt;attribute name="apiFramework" type="{http://www.w3.org/2001/XMLSchema}string" />
         *     &lt;/extension>
         *   &lt;/simpleContent>
         * &lt;/complexType>
         * </pre>
         * 
         * 
         */
        public static class InteractiveCreativeFile {

            protected URL value;
            protected String type;
            protected String apiFramework;

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
             * Gets the value of the type property.
             * 
             * @return
             *     possible object is
             *     {@link String }
             *     
             */
            public String getType() {
                return type;
            }

            /**
             * Sets the value of the type property.
             * 
             * @param value
             *     allowed object is
             *     {@link String }
             *     
             */
            public void setType(String value) {
                this.type = value;
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
         *       &lt;attribute name="delivery" use="required">
         *         &lt;simpleType>
         *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}token">
         *             &lt;enumeration value="streaming"/>
         *             &lt;enumeration value="progressive"/>
         *           &lt;/restriction>
         *         &lt;/simpleType>
         *       &lt;/attribute>
         *       &lt;attribute name="type" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
         *       &lt;attribute name="width" use="required" type="{http://www.w3.org/2001/XMLSchema}integer" />
         *       &lt;attribute name="height" use="required" type="{http://www.w3.org/2001/XMLSchema}integer" />
         *       &lt;attribute name="codec" type="{http://www.w3.org/2001/XMLSchema}string" />
         *       &lt;attribute name="bitrate" type="{http://www.w3.org/2001/XMLSchema}integer" />
         *       &lt;attribute name="minBitrate" type="{http://www.w3.org/2001/XMLSchema}integer" />
         *       &lt;attribute name="maxBitrate" type="{http://www.w3.org/2001/XMLSchema}integer" />
         *       &lt;attribute name="scalable" type="{http://www.w3.org/2001/XMLSchema}boolean" />
         *       &lt;attribute name="maintainAspectRatio" type="{http://www.w3.org/2001/XMLSchema}boolean" />
         *       &lt;attribute name="apiFramework" type="{http://www.w3.org/2001/XMLSchema}string" />
         *     &lt;/extension>
         *   &lt;/simpleContent>
         * &lt;/complexType>
         * </pre>
         * 
         * 
         */
        public static class MediaFile {

            protected URL value;
            protected String id;
            @NonNull
            protected String delivery;
            @NonNull
            protected String type;
            @NonNull
            protected int width;
            @NonNull
            protected int height;
            protected String codec;
            protected int bitrate;
            protected int minBitrate;
            protected int maxBitrate;
            protected Boolean scalable;
            protected Boolean maintainAspectRatio;
            protected String apiFramework;

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

            /**
             * Gets the value of the delivery property.
             * 
             * @return
             *     possible object is
             *     {@link String }
             *     
             */
            public String getDelivery() {
                return delivery;
            }

            /**
             * Sets the value of the delivery property.
             * 
             * @param value
             *     allowed object is
             *     {@link String }
             *     
             */
            public void setDelivery(String value) {
                this.delivery = value;
            }

            /**
             * Gets the value of the type property.
             * 
             * @return
             *     possible object is
             *     {@link String }
             *     
             */
            public String getType() {
                return type;
            }

            /**
             * Sets the value of the type property.
             * 
             * @param value
             *     allowed object is
             *     {@link String }
             *     
             */
            public void setType(String value) {
                this.type = value;
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
             * Gets the value of the codec property.
             * 
             * @return
             *     possible object is
             *     {@link String }
             *     
             */
            public String getCodec() {
                return codec;
            }

            /**
             * Sets the value of the codec property.
             * 
             * @param value
             *     allowed object is
             *     {@link String }
             *     
             */
            public void setCodec(String value) {
                this.codec = value;
            }

            /**
             * Gets the value of the bitrate property.
             * 
             * @return
             *     possible object is
             *     {@link BigInteger }
             *     
             */
            public int getBitrate() {
                return bitrate;
            }

            /**
             * Sets the value of the bitrate property.
             * 
             * @param value
             *     allowed object is
             *     {@link BigInteger }
             *     
             */
            public void setBitrate(int value) {
                this.bitrate = value;
            }

            /**
             * Gets the value of the minBitrate property.
             * 
             * @return
             *     possible object is
             *     {@link BigInteger }
             *     
             */
            public int getMinBitrate() {
                return minBitrate;
            }

            /**
             * Sets the value of the minBitrate property.
             * 
             * @param value
             *     allowed object is
             *     {@link BigInteger }
             *     
             */
            public void setMinBitrate(int value) {
                this.minBitrate = value;
            }

            /**
             * Gets the value of the maxBitrate property.
             * 
             * @return
             *     possible object is
             *     {@link BigInteger }
             *     
             */
            public int getMaxBitrate() {
                return maxBitrate;
            }

            /**
             * Sets the value of the maxBitrate property.
             * 
             * @param value
             *     allowed object is
             *     {@link BigInteger }
             *     
             */
            public void setMaxBitrate(int value) {
                this.maxBitrate = value;
            }

            /**
             * Gets the value of the scalable property.
             * 
             * @return
             *     possible object is
             *     {@link Boolean }
             *     
             */
            public Boolean isScalable() {
                return scalable;
            }

            /**
             * Sets the value of the scalable property.
             * 
             * @param value
             *     allowed object is
             *     {@link Boolean }
             *     
             */
            public void setScalable(Boolean value) {
                this.scalable = value;
            }

            /**
             * Gets the value of the maintainAspectRatio property.
             * 
             * @return
             *     possible object is
             *     {@link Boolean }
             *     
             */
            public Boolean isMaintainAspectRatio() {
                return maintainAspectRatio;
            }

            /**
             * Sets the value of the maintainAspectRatio property.
             * 
             * @param value
             *     allowed object is
             *     {@link Boolean }
             *     
             */
            public void setMaintainAspectRatio(Boolean value) {
                this.maintainAspectRatio = value;
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

        }

    }

}
