package com.mobiblocks.skippables.vast;

/**
 * Created by daniel on 12/18/17.
 * <p>
 * Copyright Mobiblocks 2017. All rights reserved.
 */

public class VastException extends Exception {
    private final VAST vast;
    private final int errorCode;

    public VastException(@VastError.AdVastError int errorCode) {
        this.vast = null;
        this.errorCode = errorCode;
    }

    public VastException(VAST vast, @VastError.AdVastError int errorCode) {
        this.vast = vast;
        this.errorCode = errorCode;
    }

    public VastException(@VastError.AdVastError int errorCode, String message) {
        super(message);

        this.vast = null;
        this.errorCode = errorCode;
    }

    public VastException(VAST vast, @VastError.AdVastError int errorCode, String message) {
        super(message);

        this.vast = vast;
        this.errorCode = errorCode;
    }

    public VastException(VAST vast, @VastError.AdVastError int errorCode, Throwable cause) {
        super(cause);

        this.vast = vast;
        this.errorCode = errorCode;
    }

    public VastException(VAST vast, @VastError.AdVastError int errorCode, String message, Throwable cause) {
        super(message, cause);

        this.vast = vast;
        this.errorCode = errorCode;
    }

    public VAST getVast() {
        return vast;
    }

    @VastError.AdVastError
    public int getErrorCode() {
        return errorCode;
    }
}
