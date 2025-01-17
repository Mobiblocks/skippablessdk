//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, v2.2.8-b130911.1802 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2017.12.14 at 03:40:33 PM EET 
//


package com.mobiblocks.skippables.vast;

import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import java.net.URL;
import java.util.ArrayList;
import java.util.List;


/**
 * 
 * 				A base creative resource type (sec 3.13) for non-video creative content.
 * 				This specifies static, IFrame, or HTML content, or a combination thereof
 * 			
 * 
 * <p>Java class for CreativeResource_NonVideo_type complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="CreativeResource_NonVideo_type">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="HTMLResource" type="{http://www.iab.com/VAST}HTMLResource_type" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element name="IFrameResource" type="{http://www.w3.org/2001/XMLSchema}anyURI" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element name="StaticResource" maxOccurs="unbounded" minOccurs="0">
 *           &lt;complexType>
 *             &lt;simpleContent>
 *               &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>anyURI">
 *                 &lt;attribute name="creativeType" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
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
public class CreativeResourceNonVideoType {

    @Nullable
    protected List<HTMLResourceType> htmlResource;
    @Nullable
    protected List<URL> iFrameResource;
    @Nullable
    protected List<CreativeResourceNonVideoType.StaticResource> staticResource;

    /**
     * Gets the value of the htmlResource property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the htmlResource property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getHTMLResource().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link HTMLResourceType }
     * 
     * 
     */
    @Nullable
    public List<HTMLResourceType> getHTMLResource() {
        return this.htmlResource;
    }
    
    public void addHTMLResource(@NonNull HTMLResourceType htmlResource) {
        if (this.htmlResource == null) {
            this.htmlResource = new ArrayList<>();
        }
        
        this.htmlResource.add(htmlResource);
    }

    /**
     * Gets the value of the iFrameResource property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the iFrameResource property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getIFrameResource().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link String }
     * 
     * 
     */
    @Nullable
    public List<URL> getIFrameResource() {
        return this.iFrameResource;
    }

    public void addIFrameResource(@NonNull URL iFrameResource) {
        if (this.iFrameResource == null) {
            this.iFrameResource = new ArrayList<>();
        }

        this.iFrameResource.add(iFrameResource);
    }

    /**
     * Gets the value of the staticResource property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the staticResource property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getStaticResource().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link CreativeResourceNonVideoType.StaticResource }
     * 
     * 
     */
    @Nullable
    public List<CreativeResourceNonVideoType.StaticResource> getStaticResource() {
        return this.staticResource;
    }

    public void addStaticResource(@NonNull CreativeResourceNonVideoType.StaticResource staticResource) {
        if (this.staticResource == null) {
            this.staticResource = new ArrayList<>();
        }

        this.staticResource.add(staticResource);
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
     *       &lt;attribute name="creativeType" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
     *     &lt;/extension>
     *   &lt;/simpleContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    public static class StaticResource {

        protected URL value;
        @NonNull
        protected String creativeType;

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
         * Gets the value of the creativeType property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getCreativeType() {
            return creativeType;
        }

        /**
         * Sets the value of the creativeType property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setCreativeType(String value) {
            this.creativeType = value;
        }

    }

}
