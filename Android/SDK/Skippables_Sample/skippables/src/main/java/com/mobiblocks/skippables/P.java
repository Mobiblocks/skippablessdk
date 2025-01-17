package com.mobiblocks.skippables;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.Serializable;
import java.net.URL;
import java.util.Date;

/**
 * Created by daniel on 2/7/18.
 * <p>
 * Copyright Mobiblocks 2018. All rights reserved.
 */
class P implements Serializable {
    private static final long serialVersionUID = 1352111171012111128L;

    final URL u;
    final Date e;
    final String d; // data
    final String s; // sessionID
    final String i; // identifier
    final boolean le; // logError
    final boolean ls; // logSession

    private P(URL u, Date e, JSONObject d, String s, String i, boolean le, boolean ls) {
        this.e = e;
        this.u = u;
        this.d = d == null ? null : d.toString();
        this.s = s;
        this.i = i;
        this.le = le;
        this.ls = ls;
    }

    static P pair(URL u, Date e, JSONObject d, String s, String i, boolean le, boolean ls) {
        return new P(u, e, d, s, i, le, ls);
    }

    JSONObject getD() {
        if (d == null) {
            return null;
        }

        try {
            return new JSONObject(d);
        } catch (JSONException ignored) {
            return null;
        }
    }
}
