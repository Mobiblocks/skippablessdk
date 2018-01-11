package com.mobiblocks.skippables.vast;

/**
 * Created by daniel on 12/18/17.
 * <p>
 * Copyright Mobiblocks 2017. All rights reserved.
 */

public class VastException extends Exception {
    private final int errorCode;

    public VastException(@VastError.AdVastError int errorCode) {
        this.errorCode = errorCode;
    }

    public VastException(@VastError.AdVastError int errorCode, String message) {
        super(message);

        this.errorCode = errorCode;
    }

    public VastException(@VastError.AdVastError int errorCode, Throwable cause) {
        super(cause);

        this.errorCode = errorCode;
    }

    public VastException(@VastError.AdVastError int errorCode, String message, Throwable cause) {
        super(message, cause);

        this.errorCode = errorCode;
    }
    
    @VastError.AdVastError
    public int getErrorCode() {
        return errorCode;
    }
}
