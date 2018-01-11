package com.mobiblocks.skippables.vast;

import android.util.Log;

import com.mobiblocks.skippables.BuildConfig;

import org.xml.sax.SAXException;

import java.util.Map;

/**
 * Created by daniel on 12/18/17.
 * <p>
 * Copyright Mobiblocks 2017. All rights reserved.
 */

class XmlObjectFactory {

    private static XmlObjectFactory defaultFactory = new XmlObjectFactory();

    public static XmlObjectFactory getDefaultFactory() {
        return defaultFactory;
    }

    private static void LogD(String message) {
        if (BuildConfig.DEBUG) {
            Log.d("VastXml", message);
        }
    }

    /**
     * Create a new ObjectFactory that can be used to create new instances of schema derived classes for package: com.mobiblocks.skippables.vast
     */
    private XmlObjectFactory() {
    }

    /**
     * Create an instance of {@link VAST }
     */
    public VAST createVAST(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.VAST_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid vast element");
        }

        SaxAttributes attrs = saxElement.getAttributes();
        VAST vast = new VAST();
        vast.setVersion(attrs.getValue(XmlAttrs.VERSION_ATTR));

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.ERROR_TAG)) {
                vast.setError(child.getUrlValue());
            } else if (child.is(XmlTags.AD_TAG)) {
                vast.addAd(createVASTAd(child));
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return vast;
    }

    /**
     * Create an instance of {@link VAST.Ad }
     */
    public VAST.Ad createVASTAd(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.AD_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.AD_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        VAST.Ad ad = new VAST.Ad();
        ad.setId(attrs.getValue(XmlAttrs.ID_ATTR));
        ad.setSequence(attrs.getIntValue(XmlAttrs.SEQUENCE_ATTR));
        ad.setConditionalAd(attrs.getBoolValue(XmlAttrs.CONDITIONAL_AD_ATTR));

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.IN_LINE_TAG)) {
                ad.setInLine(createInlineType(child));
            } else if (child.is(XmlTags.WRAPPER_TAG)) {
                ad.setWrapper(createWrapperType(child));
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return ad;
    }

    /**
     * Create an instance of {@link InlineType }
     */
    public InlineType createInlineType(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.IN_LINE_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.IN_LINE_TAG + " element");
        }

        InlineType inline = new InlineType();

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.AD_SYSTEM_TAG)) {
                inline.setAdSystem(createAdDefinitionBaseTypeAdSystem(child));
            } else if (child.is(XmlTags.AD_TITLE_TAG)) {
                inline.setAdTitle(child.getValue());
            } else if (child.is(XmlTags.IMPRESSION_TAG)) {
                inline.addImpression(createImpressionType(child));
            } else if (child.is(XmlTags.CATEGORY_TAG)) {
                inline.addCategory(createInlineTypeCategory(child));
            } else if (child.is(XmlTags.DESCRIPTION_TAG)) {
                inline.setDescription(child.getValue());
            } else if (child.is(XmlTags.ADVERTISER_TAG)) {
                inline.setAdvertiser(child.getValue());
            } else if (child.is(XmlTags.PRICING_TAG)) {
                inline.setPricing(createAdDefinitionBaseTypePricing(child));
            } else if (child.is(XmlTags.SURVEY_TAG)) {
                inline.setSurvey(createInlineTypeSurvey(child));
            } else if (child.is(XmlTags.ERROR_TAG)) {
                inline.setError(child.getUrlValue());
            } else if (child.is(XmlTags.VIEWABLE_IMPRESSION_TAG)) {
                inline.setViewableImpression(createViewableImpressionType(child));
            } else if (child.is(XmlTags.AD_VERIFICATIONS_TAG)) {
                inline.setAdVerifications(createAdVerificationsInlineType(child));
            } else if (child.is(XmlTags.EXTENSIONS_TAG)) {
                inline.setExtensions(createAdDefinitionBaseTypeExtensions(child));
            } else if (child.is(XmlTags.CREATIVES_TAG)) {
                inline.setCreatives(createInlineTypeCreatives(child));
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return inline;
    }

    /**
     * Create an instance of {@link WrapperType }
     */
    public WrapperType createWrapperType(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.WRAPPER_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.WRAPPER_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        WrapperType wrapper = new WrapperType();
        wrapper.setFollowAdditionalWrappers(attrs.getBoolValue(XmlAttrs.FOLLOW_ADDITIONAL_WRAPPERS_ATTR));
        wrapper.setAllowMultipleAds(attrs.getBoolValue(XmlAttrs.ALLOW_MULTIPLE_ADS_ATTR));
        wrapper.setFallbackOnNoAd(attrs.getBoolValue(XmlAttrs.FALLBACK_ON_NO_AD_ATTR));

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.IMPRESSION_TAG)) {
                wrapper.addImpression(createImpressionType(child));
            } else if (child.is(XmlTags.VASTAD_TAG_URI_TAG)) {
                wrapper.setVASTAdTagURI(child.getUrlValue());
            } else if (child.is(XmlTags.AD_SYSTEM_TAG)) {
                wrapper.setAdSystem(createAdDefinitionBaseTypeAdSystem(child));
            } else if (child.is(XmlTags.PRICING_TAG)) {
                wrapper.setPricing(createAdDefinitionBaseTypePricing(child));
            } else if (child.is(XmlTags.ERROR_TAG)) {
                wrapper.setError(child.getUrlValue());
            } else if (child.is(XmlTags.VIEWABLE_IMPRESSION_TAG)) {
                wrapper.setViewableImpression(createViewableImpressionType(child));
            } else if (child.is(XmlTags.AD_VERIFICATIONS_TAG)) {
                wrapper.setAdVerifications(createAdVerificationsWrapperType(child));
            } else if (child.is(XmlTags.EXTENSIONS_TAG)) {
                wrapper.setExtensions(createAdDefinitionBaseTypeExtensions(child));
            } else if (child.is(XmlTags.CREATIVES_TAG)) {
                wrapper.setCreatives(createWrapperTypeCreatives(child));
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return wrapper;
    }

    /**
     * Create an instance of {@link AdDefinitionBaseType.AdSystem }
     */
    public AdDefinitionBaseType.AdSystem createAdDefinitionBaseTypeAdSystem(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.AD_SYSTEM_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.AD_SYSTEM_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        AdDefinitionBaseType.AdSystem adSystem = new AdDefinitionBaseType.AdSystem();
        adSystem.setVersion(attrs.getValue(XmlAttrs.VERSION_ATTR));
        adSystem.setValue(saxElement.getValue());

        return adSystem;
    }

    /**
     * Create an instance of {@link ImpressionType }
     */
    public ImpressionType createImpressionType(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.IMPRESSION_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.IMPRESSION_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        ImpressionType impression = new ImpressionType();
        impression.setId(attrs.getValue(XmlAttrs.ID_ATTR));
        impression.setValue(saxElement.getUrlValue());

        return impression;
    }

    /**
     * Create an instance of {@link InlineType.Category }
     */
    public InlineType.Category createInlineTypeCategory(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.CATEGORY_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.CATEGORY_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        InlineType.Category category = new InlineType.Category();
        category.setAuthority(attrs.getUrlValue(XmlAttrs.AUTHORITY_ATTR));
        category.setValue(saxElement.getValue());

        return category;
    }

    /**
     * Create an instance of {@link AdDefinitionBaseType.Pricing }
     */
    public AdDefinitionBaseType.Pricing createAdDefinitionBaseTypePricing(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.PRICING_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.PRICING_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        AdDefinitionBaseType.Pricing pricing = new AdDefinitionBaseType.Pricing();
        pricing.setModel(attrs.getValue(XmlAttrs.MODEL_ATTR));
        pricing.setCurrency(attrs.getValue(XmlAttrs.CURRENCY_ATTR));
        pricing.setValue(saxElement.getDoubleObjectValue());

        return pricing;
    }

    /**
     * Create an instance of {@link InlineType.Survey }
     */
    public InlineType.Survey createInlineTypeSurvey(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.SURVEY_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.SURVEY_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        InlineType.Survey survey = new InlineType.Survey();
        survey.setType(attrs.getValue(XmlAttrs.TYPE_ATTR));
        survey.setValue(saxElement.getUrlValue());

        return survey;
    }

    /**
     * Create an instance of {@link ViewableImpressionType }
     */
    public ViewableImpressionType createViewableImpressionType(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.VIEWABLE_IMPRESSION_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.VIEWABLE_IMPRESSION_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();
        ViewableImpressionType impression = new ViewableImpressionType();
        impression.setId(attrs.getValue(XmlAttrs.ID_ATTR));

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.VIEWABLE_TAG)) {
                impression.addViewable(child.getUrlValue());
            } else if (child.is(XmlTags.NOT_VIEWABLE_TAG)) {
                impression.addNotViewable(child.getUrlValue());
            } else if (child.is(XmlTags.VIEW_UNDETERMINED_TAG)) {
                impression.addViewUndetermined(child.getUrlValue());
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return impression;
    }

    /**
     * Create an instance of {@link AdVerificationsInlineType }
     */
    public AdVerificationsInlineType createAdVerificationsInlineType(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.AD_VERIFICATIONS_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.AD_VERIFICATIONS_TAG + " element");
        }

        AdVerificationsInlineType adVerifications = new AdVerificationsInlineType();

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.VERIFICATION_TAG)) {
                adVerifications.addVerification(createVerificationInlineType(child));
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return adVerifications;
    }

    /**
     * Create an instance of {@link VerificationInlineType }
     */
    public VerificationInlineType createVerificationInlineType(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.VERIFICATION_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.VERIFICATION_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        VerificationInlineType verification = new VerificationInlineType();
        verification.setVendor(attrs.getValue(XmlAttrs.VENDOR_ATTR));

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.JAVA_SCRIPT_RESOURCE_TAG)) {
                verification.addJavaScriptResource(createVerificationInlineTypeJavaScriptResource(child));
            } else if (child.is(XmlTags.FLASH_RESOURCE_TAG)) {
                verification.addFlashResource(createVerificationInlineTypeFlashResource(child));
            } else if (child.is(XmlTags.VIEWABLE_IMPRESSION_TAG)) {
                verification.setViewableImpression(createVerificationInlineTypeViewableImpression(child));
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return verification;
    }

    /**
     * Create an instance of {@link VerificationInlineType.JavaScriptResource }
     */
    public VerificationInlineType.JavaScriptResource createVerificationInlineTypeJavaScriptResource(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.JAVA_SCRIPT_RESOURCE_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.JAVA_SCRIPT_RESOURCE_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        VerificationInlineType.JavaScriptResource javaScriptResource = new VerificationInlineType.JavaScriptResource();
        javaScriptResource.setApiFramework(attrs.getValue(XmlAttrs.API_FRAMEWORK_ATTR));
        javaScriptResource.setValue(saxElement.getUrlValue());

        return javaScriptResource;
    }

    /**
     * Create an instance of {@link VerificationInlineType.FlashResource }
     */
    public VerificationInlineType.FlashResource createVerificationInlineTypeFlashResource(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.FLASH_RESOURCE_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.FLASH_RESOURCE_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        VerificationInlineType.FlashResource flashResource = new VerificationInlineType.FlashResource();
        flashResource.setApiFramework(attrs.getValue(XmlAttrs.API_FRAMEWORK_ATTR));
        flashResource.setValue(saxElement.getUrlValue());

        return flashResource;
    }

    /**
     * Create an instance of {@link VerificationInlineType.ViewableImpression }
     */
    public VerificationInlineType.ViewableImpression createVerificationInlineTypeViewableImpression(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.VIEWABLE_IMPRESSION_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.VIEWABLE_IMPRESSION_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        VerificationInlineType.ViewableImpression viewableImpression = new VerificationInlineType.ViewableImpression();
        viewableImpression.setId(attrs.getValue(XmlAttrs.ID_ATTR));
        viewableImpression.setValue(saxElement.getUrlValue());

        return viewableImpression;
    }

    /**
     * Create an instance of {@link AdDefinitionBaseType.Extensions }
     */
    public AdDefinitionBaseType.Extensions createAdDefinitionBaseTypeExtensions(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.EXTENSIONS_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.EXTENSIONS_TAG + " element");
        }

        AdDefinitionBaseType.Extensions extensions = new AdDefinitionBaseType.Extensions();

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.EXTENSION_TAG)) {
                extensions.addExtension(createAdDefinitionBaseTypeExtensionsExtension(child));
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return extensions;
    }

    /**
     * Create an instance of {@link AdDefinitionBaseType.Extensions.Extension }
     */
    public AdDefinitionBaseType.Extensions.Extension createAdDefinitionBaseTypeExtensionsExtension(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.EXTENSION_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.EXTENSION_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        AdDefinitionBaseType.Extensions.Extension extension = new AdDefinitionBaseType.Extensions.Extension();
        extension.setType(attrs.getValue(XmlAttrs.TYPE_ATTR));
        extension.setValue(saxElement.getValue());

        return extension;
    }

    /**
     * Create an instance of {@link InlineType.Creatives }
     */
    public InlineType.Creatives createInlineTypeCreatives(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.CREATIVES_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.CREATIVES_TAG + " element");
        }

        InlineType.Creatives creatives = new InlineType.Creatives();

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.CREATIVE_TAG)) {
                creatives.addCreative(createCreativeInlineChildType(child));
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return creatives;
    }

    /**
     * Create an instance of {@link CreativeInlineChildType }
     */
    public CreativeInlineChildType createCreativeInlineChildType(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.CREATIVE_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.CREATIVE_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        CreativeInlineChildType creative = new CreativeInlineChildType();
        creative.setId(attrs.getValue(XmlAttrs.ID_ATTR));
        creative.setSequence(attrs.getIntValue(XmlAttrs.SEQUENCE_ATTR));
        creative.setAdId(attrs.getValue(XmlAttrs.AD_ID_ATTR));
        creative.setApiFramework(attrs.getValue(XmlAttrs.API_FRAMEWORK_ATTR));

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.UNIVERSAL_AD_ID_TAG)) {
                creative.setUniversalAdId(createCreativeInlineChildTypeUniversalAdId(child));
            } else if (child.is(XmlTags.CREATIVE_EXTENSIONS_TAG)) {
                creative.setCreativeExtensions(createCreativeExtensionsType(child));
            } else if (child.is(XmlTags.LINEAR_TAG)) {
                creative.setLinear(createLinearInlineChildType(child));
            } else if (child.is(XmlTags.NON_LINEAR_ADS_TAG)) {
                creative.setNonLinearAds(createCreativeInlineChildTypeNonLinearAds(child));
            } else if (child.is(XmlTags.COMPANION_ADS_TAG)) {
                creative.setCompanionAds(createCompanionAdsCollectionType(child));
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return creative;
    }

    /**
     * Create an instance of {@link CreativeInlineChildType.UniversalAdId }
     */
    public CreativeInlineChildType.UniversalAdId createCreativeInlineChildTypeUniversalAdId(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.UNIVERSAL_AD_ID_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.UNIVERSAL_AD_ID_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        CreativeInlineChildType.UniversalAdId universalAdId = new CreativeInlineChildType.UniversalAdId();
        universalAdId.setIdRegistry(attrs.getValue(XmlAttrs.ID_REGISTRY_ATTR));
        universalAdId.setIdValue(attrs.getValue(XmlAttrs.ID_VALUE_ATTR));
        universalAdId.setValue(saxElement.getValue());

        return universalAdId;
    }

    /**
     * Create an instance of {@link CreativeExtensionsType }
     */
    public CreativeExtensionsType createCreativeExtensionsType(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.CREATIVE_EXTENSIONS_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.CREATIVE_EXTENSIONS_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        CreativeExtensionsType extensions = new CreativeExtensionsType();

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.CREATIVE_EXTENSION_TAG)) {
                extensions.addCreativeExtension(createCreativeExtensionsTypeCreativeExtension(child));
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return extensions;
    }

    /**
     * Create an instance of {@link CreativeExtensionsType.CreativeExtension }
     */
    public CreativeExtensionsType.CreativeExtension createCreativeExtensionsTypeCreativeExtension(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.CREATIVE_EXTENSION_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.CREATIVE_EXTENSION_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        CreativeExtensionsType.CreativeExtension extension = new CreativeExtensionsType.CreativeExtension();
        extension.setType(attrs.getValue(XmlAttrs.TYPE_ATTR));
        extension.setValue(saxElement.getValue());

        Map<String, String> otherAttrs = extension.getOtherAttributes();
        for (String key : attrs.keySet()) {
            if (XmlAttrs.TYPE_ATTR.equalsIgnoreCase(key)) {
                continue;
            }

            otherAttrs.put(key, attrs.getValue(key));
        }

        return extension;
    }

    /**
     * Create an instance of {@link LinearInlineChildType }
     */
    public LinearInlineChildType createLinearInlineChildType(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.LINEAR_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.LINEAR_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        LinearInlineChildType linear = new LinearInlineChildType();
        linear.setSkipoffset(attrs.getValue(XmlAttrs.SKIPOFFSET_ATTR));

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.DURATION_TAG)) {
                linear.setDuration(child.getValue());
            } else if (child.is(XmlTags.AD_PARAMETERS_TAG)) {
                linear.setAdParameters(createAdParametersType(child));
            } else if (child.is(XmlTags.MEDIA_FILES_TAG)) {
                linear.setMediaFiles(createLinearInlineChildTypeMediaFiles(child));
            } else if (child.is(XmlTags.VIDEO_CLICKS_TAG)) {
                linear.setVideoClicks(createVideoClicksInlineChildType(child));
            } else if (child.is(XmlTags.TRACKING_EVENTS_TAG)) {
                linear.setTrackingEvents(createTrackingEventsType(child));
            } else if (child.is(XmlTags.ICONS_TAG)) {
                linear.setIcons(createLinearBaseTypeIcons(child));
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return linear;
    }

    /**
     * Create an instance of {@link AdParametersType }
     */
    public AdParametersType createAdParametersType(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.AD_PARAMETERS_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.AD_PARAMETERS_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        AdParametersType parameters = new AdParametersType();
        parameters.setXmlEncoded(attrs.getBoolValue(XmlAttrs.XML_ENCODED_ATTR));
        parameters.setValue(saxElement.getValue());

        return parameters;
    }

    /**
     * Create an instance of {@link LinearInlineChildType.MediaFiles }
     */
    public LinearInlineChildType.MediaFiles createLinearInlineChildTypeMediaFiles(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.MEDIA_FILES_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.MEDIA_FILES_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        LinearInlineChildType.MediaFiles mediaFiles = new LinearInlineChildType.MediaFiles();

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.MEZZANINE_TAG)) {
                mediaFiles.setMezzanine(child.getUrlValue());
            } else if (child.is(XmlTags.MEDIA_FILE_TAG)) {
                mediaFiles.addMediaFile(createLinearInlineChildTypeMediaFilesMediaFile(child));
            } else if (child.is(XmlTags.INTERACTIVE_CREATIVE_FILE_TAG)) {
                mediaFiles.addInteractiveCreativeFile(createLinearInlineChildTypeMediaFilesInteractiveCreativeFile(child));
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return mediaFiles;
    }

    /**
     * Create an instance of {@link LinearInlineChildType.MediaFiles.MediaFile }
     */
    public LinearInlineChildType.MediaFiles.MediaFile createLinearInlineChildTypeMediaFilesMediaFile(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.MEDIA_FILE_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.MEDIA_FILE_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        LinearInlineChildType.MediaFiles.MediaFile mediaFile = new LinearInlineChildType.MediaFiles.MediaFile();
        mediaFile.setId(attrs.getValue(XmlAttrs.ID_ATTR));
        mediaFile.setDelivery(attrs.getValue(XmlAttrs.DELIVERY_ATTR));
        mediaFile.setType(attrs.getValue(XmlAttrs.TYPE_ATTR));

        mediaFile.setBitrate(attrs.getIntValue(XmlAttrs.BITRATE_ATTR));
        mediaFile.setMinBitrate(attrs.getIntValue(XmlAttrs.MIN_BITRATE_ATTR));
        mediaFile.setMaxBitrate(attrs.getIntValue(XmlAttrs.MAX_BITRATE_ATTR));
        mediaFile.setWidth(attrs.getIntValue(XmlAttrs.WIDTH_ATTR));
        mediaFile.setHeight(attrs.getIntValue(XmlAttrs.HEIGHT_ATTR));
        mediaFile.setScalable(attrs.getBoolValue(XmlAttrs.SCALABLE_ATTR));
        mediaFile.setMaintainAspectRatio(attrs.getBoolValue(XmlAttrs.MAINTAIN_ASPECT_RATIO_ATTR));
        mediaFile.setCodec(attrs.getValue(XmlAttrs.CODEC_ATTR));
        mediaFile.setApiFramework(attrs.getValue(XmlAttrs.API_FRAMEWORK_ATTR));

        mediaFile.setValue(saxElement.getUrlValue());

        return mediaFile;
    }

    /**
     * Create an instance of {@link LinearInlineChildType.MediaFiles.InteractiveCreativeFile }
     */
    public LinearInlineChildType.MediaFiles.InteractiveCreativeFile createLinearInlineChildTypeMediaFilesInteractiveCreativeFile(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.INTERACTIVE_CREATIVE_FILE_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.INTERACTIVE_CREATIVE_FILE_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        LinearInlineChildType.MediaFiles.InteractiveCreativeFile interactiveCreativeFile = new LinearInlineChildType.MediaFiles.InteractiveCreativeFile();
        interactiveCreativeFile.setType(attrs.getValue(XmlAttrs.TYPE_ATTR));
        interactiveCreativeFile.setApiFramework(attrs.getValue(XmlAttrs.API_FRAMEWORK_ATTR));
        interactiveCreativeFile.setValue(saxElement.getUrlValue());

        return interactiveCreativeFile;
    }

    /**
     * Create an instance of {@link VideoClicksInlineChildType }
     */
    public VideoClicksInlineChildType createVideoClicksInlineChildType(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.VIDEO_CLICKS_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.VIDEO_CLICKS_TAG + " element");
        }

        VideoClicksInlineChildType clicks = new VideoClicksInlineChildType();

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.CLICK_THROUGH_TAG)) {
                clicks.setClickThrough(createVideoClicksInlineChildTypeClickThrough(child));
            } else if (child.is(XmlTags.CLICK_TRACKING_TAG)) {
                clicks.addClickTracking(createVideoClicksBaseTypeClickTracking(child));
            } else if (child.is(XmlTags.CUSTOM_CLICK_TAG)) {
                clicks.addCustomClick(createVideoClicksBaseTypeCustomClick(child));
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return clicks;
    }

    /**
     * Create an instance of {@link VideoClicksInlineChildType.ClickThrough }
     */
    public VideoClicksInlineChildType.ClickThrough createVideoClicksInlineChildTypeClickThrough(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.CLICK_THROUGH_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.CLICK_THROUGH_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        VideoClicksInlineChildType.ClickThrough clickThrough = new VideoClicksInlineChildType.ClickThrough();
        clickThrough.setId(attrs.getValue(XmlAttrs.ID_ATTR));
        clickThrough.setValue(saxElement.getUrlValue());

        return clickThrough;
    }

    /**
     * Create an instance of {@link VideoClicksBaseType.ClickTracking }
     */
    public VideoClicksBaseType.ClickTracking createVideoClicksBaseTypeClickTracking(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.CLICK_TRACKING_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.CLICK_TRACKING_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        VideoClicksBaseType.ClickTracking clickTracking = new VideoClicksBaseType.ClickTracking();
        clickTracking.setId(attrs.getValue(XmlAttrs.ID_ATTR));
        clickTracking.setValue(saxElement.getUrlValue());

        return clickTracking;
    }

    /**
     * Create an instance of {@link VideoClicksBaseType.CustomClick }
     */
    public VideoClicksBaseType.CustomClick createVideoClicksBaseTypeCustomClick(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.CUSTOM_CLICK_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.CUSTOM_CLICK_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        VideoClicksBaseType.CustomClick customClick = new VideoClicksBaseType.CustomClick();
        customClick.setId(attrs.getValue(XmlAttrs.ID_ATTR));
        customClick.setValue(saxElement.getUrlValue());

        return customClick;
    }

    /**
     * Create an instance of {@link TrackingEventsType }
     */
    public TrackingEventsType createTrackingEventsType(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.TRACKING_EVENTS_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.TRACKING_EVENTS_TAG + " element");
        }

        TrackingEventsType trackingEvents = new TrackingEventsType();

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.TRACKING_TAG)) {
                trackingEvents.addTracking(createTrackingEventsTypeTracking(child));
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return trackingEvents;
    }

    /**
     * Create an instance of {@link TrackingEventsType.Tracking }
     */
    public TrackingEventsType.Tracking createTrackingEventsTypeTracking(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.TRACKING_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.TRACKING_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        TrackingEventsType.Tracking tracking = new TrackingEventsType.Tracking();
        tracking.setEvent(attrs.getValue(XmlAttrs.EVENT_ATTR));
        tracking.setOffset(attrs.getValue(XmlAttrs.OFFSET_ATTR));
        tracking.setValue(saxElement.getUrlValue());

        return tracking;
    }

    /**
     * Create an instance of {@link LinearBaseType.Icons }
     */
    public LinearBaseType.Icons createLinearBaseTypeIcons(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.ICONS_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.ICONS_TAG + " element");
        }

        LinearBaseType.Icons icons = new LinearBaseType.Icons();

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.ICON_TAG)) {
                icons.setIcon(createIconType(child));
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return icons;
    }

    /**
     * Create an instance of {@link IconType }
     */
    public IconType createIconType(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.ICON_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.ICON_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        IconType icon = new IconType();
        icon.setProgram(attrs.getValue(XmlAttrs.PROGRAM_ATTR));
        icon.setWidth(attrs.getIntValue(XmlAttrs.WIDTH_ATTR));
        icon.setHeight(attrs.getIntValue(XmlAttrs.HEIGHT_ATTR));
        icon.setXPosition(attrs.getValue(XmlAttrs.X_POSITION_ATTR));
        icon.setYPosition(attrs.getValue(XmlAttrs.Y_POSITION_ATTR));
        icon.setDuration(attrs.getValue(XmlAttrs.DURATION_ATTR));
        icon.setOffset(attrs.getValue(XmlAttrs.OFFSET_ATTR));
        icon.setApiFramework(attrs.getValue(XmlAttrs.API_FRAMEWORK_ATTR));
        icon.setPxratio(attrs.getFloatObject(XmlAttrs.PXRATIO_ATTR));

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.STATIC_RESOURCE_TAG)) {
                icon.addStaticResource(createCreativeResourceNonVideoTypeStaticResource(child));
            } else if (child.is(XmlTags.IFRAME_RESOURCE_TAG)) {
                icon.addIFrameResource(child.getUrlValue());
            } else if (child.is(XmlTags.HTMLRESOURCE_TAG)) {
                icon.addHTMLResource(createHTMLResourceType(child));
            } else if (child.is(XmlTags.ICON_CLICKS_TAG)) {
                icon.setIconClicks(createIconTypeIconClicks(child));
            } else if (child.is(XmlTags.ICON_VIEW_TRACKING_TAG)) {
                icon.addIconViewTracking(child.getUrlValue());
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return icon;
    }

    /**
     * Create an instance of {@link CreativeResourceNonVideoType.StaticResource }
     */
    public CreativeResourceNonVideoType.StaticResource createCreativeResourceNonVideoTypeStaticResource(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.STATIC_RESOURCE_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.STATIC_RESOURCE_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        CreativeResourceNonVideoType.StaticResource staticResource = new CreativeResourceNonVideoType.StaticResource();
        staticResource.setCreativeType(attrs.getValue(XmlAttrs.CREATIVE_TYPE_ATTR));
        staticResource.setValue(saxElement.getUrlValue());

        return staticResource;
    }

    /**
     * Create an instance of {@link HTMLResourceType }
     */
    public HTMLResourceType createHTMLResourceType(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.HTMLRESOURCE_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.HTMLRESOURCE_TAG + " element");
        }

        HTMLResourceType htmlResource = new HTMLResourceType();
        htmlResource.setValue(saxElement.getValue());

        return htmlResource;
    }

    /**
     * Create an instance of {@link IconType.IconClicks }
     */
    public IconType.IconClicks createIconTypeIconClicks(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.ICON_CLICKS_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.ICON_CLICKS_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        IconType.IconClicks iconClicks = new IconType.IconClicks();

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.ICON_CLICK_THROUGH_TAG)) {
                iconClicks.setIconClickThrough(child.getUrlValue());
            } else if (child.is(XmlTags.ICON_CLICK_TRACKING_TAG)) {
                iconClicks.addIconClickTracking(createIconTrackingUriType(child));
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return iconClicks;
    }

    /**
     * Create an instance of {@link IconTrackingUriType }
     */
    public IconTrackingUriType createIconTrackingUriType(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.ICON_CLICK_TRACKING_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.ICON_CLICK_TRACKING_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        IconTrackingUriType iconTracking = new IconTrackingUriType();
        iconTracking.setId(attrs.getValue(XmlAttrs.ID_ATTR));
        iconTracking.setValue(saxElement.getUrlValue());

        return iconTracking;
    }

    /**
     * Create an instance of {@link CreativeInlineChildType.NonLinearAds }
     */
    public CreativeInlineChildType.NonLinearAds createCreativeInlineChildTypeNonLinearAds(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.NON_LINEAR_ADS_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.NON_LINEAR_ADS_TAG + " element");
        }

        CreativeInlineChildType.NonLinearAds nonLinearAds = new CreativeInlineChildType.NonLinearAds();

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.NON_LINEAR_TAG)) {
                nonLinearAds.addNonLinear(createNonLinearAdInlineChildType(child));
            } else if (child.is(XmlTags.TRACKING_EVENTS_TAG)) {
                nonLinearAds.setTrackingEvents(createTrackingEventsType(child));
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return nonLinearAds;
    }

    /**
     * Create an instance of {@link NonLinearAdInlineChildType }
     */
    public NonLinearAdInlineChildType createNonLinearAdInlineChildType(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.NON_LINEAR_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.NON_LINEAR_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        NonLinearAdInlineChildType nonLinearAdInline = new NonLinearAdInlineChildType();

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.AD_PARAMETERS_TAG)) {
                nonLinearAdInline.setAdParameters(createAdParametersType(child));
            } else if (child.is(XmlTags.NON_LINEAR_CLICK_THROUGH_TAG)) {
                nonLinearAdInline.setNonLinearClickThrough(child.getUrlValue());
            } else if (child.is(XmlTags.NON_LINEAR_CLICK_TRACKING_TAG)) {
                nonLinearAdInline.addNonLinearClickTracking(createNonLinearAdInlineChildTypeNonLinearClickTracking(child));
            } else if (child.is(XmlTags.HTMLRESOURCE_TAG)) {
                nonLinearAdInline.addHTMLResource(createHTMLResourceType(child));
            } else if (child.is(XmlTags.IFRAME_RESOURCE_TAG)) {
                nonLinearAdInline.addIFrameResource(child.getUrlValue());
            } else if (child.is(XmlTags.STATIC_RESOURCE_TAG)) {
                nonLinearAdInline.addStaticResource(createCreativeResourceNonVideoTypeStaticResource(child));
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return nonLinearAdInline;
    }

    /**
     * Create an instance of {@link NonLinearAdInlineChildType.NonLinearClickTracking }
     */
    public NonLinearAdInlineChildType.NonLinearClickTracking createNonLinearAdInlineChildTypeNonLinearClickTracking(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.NON_LINEAR_CLICK_TRACKING_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.NON_LINEAR_CLICK_TRACKING_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        NonLinearAdInlineChildType.NonLinearClickTracking clickTracking = new NonLinearAdInlineChildType.NonLinearClickTracking();
        clickTracking.setId(attrs.getValue(XmlAttrs.ID_ATTR));
        clickTracking.setValue(saxElement.getUrlValue());

        return clickTracking;
    }

    /**
     * Create an instance of {@link CompanionAdsCollectionType }
     */
    public CompanionAdsCollectionType createCompanionAdsCollectionType(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.COMPANION_ADS_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.COMPANION_ADS_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        CompanionAdsCollectionType companionAds = new CompanionAdsCollectionType();
        companionAds.setRequired(attrs.getValue(XmlAttrs.REQUIRED_ATTR));

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.COMPANION_TAG)) {
                companionAds.addCompanion(createCompanionAdType(child));
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return companionAds;
    }

    /**
     * Create an instance of {@link CompanionAdType }
     */
    public CompanionAdType createCompanionAdType(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.COMPANION_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.COMPANION_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        CompanionAdType companionAd = new CompanionAdType();
        companionAd.setId(attrs.getValue(XmlAttrs.ID_ATTR));
        companionAd.setWidth(attrs.getIntValue(XmlAttrs.WIDTH_ATTR));
        companionAd.setHeight(attrs.getIntValue(XmlAttrs.HEIGHT_ATTR));
        companionAd.setAssetWidth(attrs.getIntValue(XmlAttrs.ASSET_WIDTH_ATTR));
        companionAd.setAssetHeight(attrs.getIntValue(XmlAttrs.ASSET_HEIGHT_ATTR));
        companionAd.setExpandedWidth(attrs.getIntValue(XmlAttrs.EXPANDED_WIDTH_ATTR));
        companionAd.setExpandedHeight(attrs.getIntValue(XmlAttrs.EXPANDED_HEIGHT_ATTR));
        companionAd.setApiFramework(attrs.getValue(XmlAttrs.API_FRAMEWORK_ATTR));
        companionAd.setAdSlotID(attrs.getValue(XmlAttrs.AD_SLOT_ID_ATTR));
        companionAd.setPxratio(attrs.getFloatObject(XmlAttrs.PXRATIO_ATTR));

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.STATIC_RESOURCE_TAG)) {
                companionAd.addStaticResource(createCreativeResourceNonVideoTypeStaticResource(child));
            } else if (child.is(XmlTags.IFRAME_RESOURCE_TAG)) {
                companionAd.addIFrameResource(child.getUrlValue());
            } else if (child.is(XmlTags.HTMLRESOURCE_TAG)) {
                companionAd.addHTMLResource(createHTMLResourceType(child));
            } else if (child.is(XmlTags.AD_PARAMETERS_TAG)) {
                companionAd.setAdParameters(createAdParametersType(child));
            } else if (child.is(XmlTags.ALT_TEXT_TAG)) {
                companionAd.setAltText(child.getValue());
            } else if (child.is(XmlTags.COMPANION_CLICK_THROUGH_TAG)) {
                companionAd.setCompanionClickThrough(child.getUrlValue());
            } else if (child.is(XmlTags.COMPANION_CLICK_TRACKING_TAG)) {
                companionAd.addCompanionClickTracking(createCompanionAdTypeCompanionClickTracking(child));
            } else if (child.is(XmlTags.TRACKING_EVENTS_TAG)) {
                companionAd.setTrackingEvents(createTrackingEventsType(child));
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return companionAd;
    }

    /**
     * Create an instance of {@link CompanionAdType.CompanionClickTracking }
     */
    public CompanionAdType.CompanionClickTracking createCompanionAdTypeCompanionClickTracking(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.COMPANION_CLICK_TRACKING_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.COMPANION_CLICK_TRACKING_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        CompanionAdType.CompanionClickTracking companionClickTracking = new CompanionAdType.CompanionClickTracking();
        companionClickTracking.setId(attrs.getValue(XmlAttrs.ID_ATTR));
        companionClickTracking.setValue(saxElement.getUrlValue());

        return companionClickTracking;
    }

    /**
     * Create an instance of {@link AdVerificationsWrapperType }
     */
    public AdVerificationsWrapperType createAdVerificationsWrapperType(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.AD_VERIFICATIONS_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.AD_VERIFICATIONS_TAG + " element");
        }

        AdVerificationsWrapperType adVerifications = new AdVerificationsWrapperType();

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.VERIFICATION_TAG)) {
                adVerifications.addVerification(createVerificationWrapperType(child));
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return adVerifications;
    }

    /**
     * Create an instance of {@link VerificationWrapperType }
     */
    public VerificationWrapperType createVerificationWrapperType(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.VERIFICATION_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.VERIFICATION_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        VerificationWrapperType verification = new VerificationWrapperType();
        verification.setVendor(attrs.getValue(XmlAttrs.VENDOR_ATTR));

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.VIEWABLE_IMPRESSION_TAG)) {
                verification.setViewableImpression(createVerificationWrapperTypeViewableImpression(child));
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return verification;
    }

    /**
     * Create an instance of {@link VerificationWrapperType.ViewableImpression }
     */
    public VerificationWrapperType.ViewableImpression createVerificationWrapperTypeViewableImpression(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.VIEWABLE_IMPRESSION_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.VIEWABLE_IMPRESSION_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        VerificationWrapperType.ViewableImpression viewableImpression = new VerificationWrapperType.ViewableImpression();
        viewableImpression.setId(attrs.getValue(XmlAttrs.ID_ATTR));

        return viewableImpression;
    }

    /**
     * Create an instance of {@link WrapperType.Creatives }
     */
    public WrapperType.Creatives createWrapperTypeCreatives(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.CREATIVES_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.CREATIVES_TAG + " element");
        }

        WrapperType.Creatives creatives = new WrapperType.Creatives();

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.CREATIVE_TAG)) {
                creatives.addCreative(createCreativeWrapperChildType(child));
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return creatives;
    }

    /**
     * Create an instance of {@link CreativeWrapperChildType }
     */
    public CreativeWrapperChildType createCreativeWrapperChildType(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.CREATIVE_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.CREATIVE_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        CreativeWrapperChildType creative = new CreativeWrapperChildType();
        creative.setId(attrs.getValue(XmlAttrs.ID_ATTR));
        creative.setSequence(attrs.getIntValue(XmlAttrs.SEQUENCE_ATTR));
        creative.setAdId(attrs.getValue(XmlAttrs.AD_ID_ATTR));

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.LINEAR_TAG)) {
                creative.setLinear(createLinearWrapperChildType(child));
            } else if (child.is(XmlTags.NON_LINEAR_ADS_TAG)) {
                creative.setNonLinearAds(createCreativeWrapperChildTypeNonLinearAds(child));
            } else if (child.is(XmlTags.COMPANION_ADS_TAG)) {
                creative.setCompanionAds(createCompanionAdsCollectionType(child));
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return creative;
    }

    /**
     * Create an instance of {@link LinearWrapperChildType }
     */
    public LinearWrapperChildType createLinearWrapperChildType(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.LINEAR_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.LINEAR_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        LinearWrapperChildType linear = new LinearWrapperChildType();
        linear.setSkipoffset(attrs.getValue(XmlAttrs.SKIPOFFSET_ATTR));

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.TRACKING_EVENTS_TAG)) {
                linear.setTrackingEvents(createTrackingEventsType(child));
            } else if (child.is(XmlTags.VIDEO_CLICKS_TAG)) {
                linear.setVideoClicks(createVideoClicksBaseType(child));
            } else if (child.is(XmlTags.ICONS_TAG)) {
                linear.setIcons(createLinearBaseTypeIcons(child));
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return linear;
    }

    /**
     * Create an instance of {@link VideoClicksBaseType }
     */
    public VideoClicksBaseType createVideoClicksBaseType(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.VIDEO_CLICKS_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.VIDEO_CLICKS_TAG + " element");
        }

        VideoClicksBaseType videoClicks = new VideoClicksBaseType();

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.CLICK_TRACKING_TAG)) {
                videoClicks.addClickTracking(createVideoClicksBaseTypeClickTracking(child));
            } else if (child.is(XmlTags.CUSTOM_CLICK_TAG)) {
                videoClicks.addCustomClick(createVideoClicksBaseTypeCustomClick(child));
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return videoClicks;
    }

    /**
     * Create an instance of {@link CreativeWrapperChildType.NonLinearAds }
     */
    public CreativeWrapperChildType.NonLinearAds createCreativeWrapperChildTypeNonLinearAds(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.NON_LINEAR_ADS_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.NON_LINEAR_ADS_TAG + " element");
        }

        CreativeWrapperChildType.NonLinearAds nonLinearAds = new CreativeWrapperChildType.NonLinearAds();

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.NON_LINEAR_TAG)) {
                nonLinearAds.addNonLinear(createNonLinearAdBaseType(child));
            } else if (child.is(XmlTags.TRACKING_EVENTS_TAG)) {
                nonLinearAds.setTrackingEvents(createTrackingEventsType(child));
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return nonLinearAds;
    }

    /**
     * Create an instance of {@link NonLinearAdBaseType }
     */
    public NonLinearAdBaseType createNonLinearAdBaseType(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.NON_LINEAR_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.NON_LINEAR_TAG + " element");
        }

        NonLinearAdBaseType nonLinear = new NonLinearAdBaseType();

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.NON_LINEAR_CLICK_TRACKING_TAG)) {
                nonLinear.setNonLinearClickTracking(createNonLinearAdBaseTypeNonLinearClickTracking(child));
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return nonLinear;
    }

    /**
     * Create an instance of {@link NonLinearAdBaseType.NonLinearClickTracking }
     */
    public NonLinearAdBaseType.NonLinearClickTracking createNonLinearAdBaseTypeNonLinearClickTracking(SaxElement saxElement) throws VastException, SAXException {
        if (saxElement.isNot(XmlTags.NON_LINEAR_CLICK_TRACKING_TAG)) {
            throw new VastException(VastError.VAST_XMLPARSE_ERROR_CODE, "Invalid " + XmlTags.NON_LINEAR_CLICK_TRACKING_TAG + " element");
        }

        SaxAttributes attrs = saxElement.getAttributes();

        NonLinearAdBaseType.NonLinearClickTracking clickTracking = new NonLinearAdBaseType.NonLinearClickTracking();
        clickTracking.setId(attrs.getValue(XmlAttrs.ID_ATTR));
        clickTracking.setValue(saxElement.getUrlValue());

        return clickTracking;
    }

    /**
     * Create an instance of {@link AdDefinitionBaseType }
     */
    public AdDefinitionBaseType createAdDefinitionBaseType(SaxElement saxElement) throws VastException, SAXException {
        AdDefinitionBaseType adDefinitionBaseType = new AdDefinitionBaseType();

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.AD_SYSTEM_TAG)) {
                adDefinitionBaseType.setAdSystem(createAdDefinitionBaseTypeAdSystem(child));
            } else if (child.is(XmlTags.IMPRESSION_TAG)) {
                adDefinitionBaseType.addImpression(createImpressionType(child));
            } else if (child.is(XmlTags.PRICING_TAG)) {
                adDefinitionBaseType.setPricing(createAdDefinitionBaseTypePricing(child));
            } else if (child.is(XmlTags.ERROR_TAG)) {
                adDefinitionBaseType.setError(child.getUrlValue());
            } else if (child.is(XmlTags.VIEWABLE_IMPRESSION_TAG)) {
                adDefinitionBaseType.setViewableImpression(createViewableImpressionType(child));
            } else if (child.is(XmlTags.EXTENSIONS_TAG)) {
                adDefinitionBaseType.setExtensions(createAdDefinitionBaseTypeExtensions(child));
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return adDefinitionBaseType;
    }

    /**
     * Create an instance of {@link CreativeResourceNonVideoType }
     */
    public CreativeResourceNonVideoType createCreativeResourceNonVideoType(SaxElement saxElement) throws VastException, SAXException {
        CreativeResourceNonVideoType resourceNonVideoType = new CreativeResourceNonVideoType();

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.STATIC_RESOURCE_TAG)) {
                resourceNonVideoType.addStaticResource(createCreativeResourceNonVideoTypeStaticResource(child));
            } else if (child.is(XmlTags.IFRAME_RESOURCE_TAG)) {
                resourceNonVideoType.addIFrameResource(child.getUrlValue());
            } else if (child.is(XmlTags.HTMLRESOURCE_TAG)) {
                resourceNonVideoType.addHTMLResource(createHTMLResourceType(child));
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return resourceNonVideoType;
    }

    /**
     * Create an instance of {@link LinearBaseType }
     */
    public LinearBaseType createLinearBaseType(SaxElement saxElement) throws VastException, SAXException {
        SaxAttributes attrs = saxElement.getAttributes();

        LinearBaseType linearBaseType = new LinearBaseType();
        linearBaseType.setSkipoffset(attrs.getValue(XmlAttrs.SKIPOFFSET_ATTR));

        for (SaxElement child : saxElement.getChilds()) {
            if (child.is(XmlTags.TRACKING_EVENTS_TAG)) {
                linearBaseType.setTrackingEvents(createTrackingEventsType(child));
            } else if (child.is(XmlTags.ICONS_TAG)) {
                linearBaseType.setIcons(createLinearBaseTypeIcons(child));
            } else {
                LogD("Unknown tag: '" + child.getName() + "' in '" + child.getName() + "'");
            }
        }

        return linearBaseType;
    }

    /**
     * Create an instance of {@link CreativeBaseType }
     */
    public CreativeBaseType createCreativeBaseType(SaxElement saxElement) throws VastException, SAXException {
        SaxAttributes attrs = saxElement.getAttributes();

        CreativeBaseType creativeBaseType = new CreativeBaseType();

        creativeBaseType.setId(attrs.getValue(XmlAttrs.ID_ATTR));
        creativeBaseType.setSequence(attrs.getIntValue(XmlAttrs.SEQUENCE_ATTR));
        creativeBaseType.setAdId(attrs.getValue(XmlAttrs.AD_ID_ATTR));
        creativeBaseType.setApiFramework(attrs.getValue(XmlAttrs.API_FRAMEWORK_ATTR));

        return creativeBaseType;
    }
}
