package com.mobiblocks.skippables;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.res.Resources;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.content.LocalBroadcastManager;
import android.text.Editable;
import android.text.InputType;
import android.text.TextWatcher;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;

import java.util.UUID;

public class SkiAdReportActivity extends Activity {

    private static final String EXTRA_EMAIL = "extra_email";
    private static final String EXTRA_FEEDBACK = "extra_feedback";
    private static final String EXTRA_REPORT_ID = "extra_report_id";
    private static final String EXTRA_REPORT_RESULT = "extra_report_result";
    private LocalBroadcastManager localBroadcastManager;
    private String reportID;

    private static Intent getIntent(@NonNull Context context, String id) {
        Intent intent = new Intent(context, SkiAdReportActivity.class);
        intent.putExtra(EXTRA_REPORT_ID, id);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);

        return intent;
    }

    static void show(@NonNull Context context, @NonNull final SkiAdReportListener listener) {
        String id = UUID.randomUUID().toString();
        
        final LocalBroadcastManager localBroadcastManager = LocalBroadcastManager.getInstance(context);
        final BroadcastReceiver[] reportReceiverTest = {null};
        final BroadcastReceiver reportReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                boolean hz = this == reportReceiverTest[0];
                localBroadcastManager.unregisterReceiver(this);

                listener.onResult(intent.getBooleanExtra(EXTRA_REPORT_RESULT, false), intent);
            }
        };
        reportReceiverTest[0] = reportReceiver;
        localBroadcastManager.registerReceiver(reportReceiver, new IntentFilter(id));
        
        context.startActivity(getIntent(context, id));
    }

    private static Intent getSuccessIntent(String id, String email, String feedback) {
        Intent intent = new Intent(id);
        intent.putExtra(EXTRA_REPORT_ID, id);
        intent.putExtra(EXTRA_REPORT_RESULT, false);
        intent.putExtra(EXTRA_EMAIL, email);
        intent.putExtra(EXTRA_FEEDBACK, feedback);

        return intent;
    }

    private static Intent getCanceledIntent(String id) {
        Intent intent = new Intent(id);
        intent.putExtra(EXTRA_REPORT_ID, id);
        intent.putExtra(EXTRA_REPORT_RESULT, true);

        return intent;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        reportID = getIntent().getStringExtra(EXTRA_REPORT_ID);
        if (reportID == null) {
            finish();
            return;
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            setTheme(android.R.style.Theme_Material_Dialog);
        } else {
            setTheme(android.R.style.Theme_Holo_Dialog);
        }
        setTitle("Report");

        localBroadcastManager = LocalBroadcastManager.getInstance(this);

        LinearLayout linearLayout = new LinearLayout(this);
        linearLayout.setOrientation(LinearLayout.VERTICAL);

        final EditText emailEdit = new EditText(this);
        emailEdit.setHint("Email (optional)");
        emailEdit.setInputType(InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS);
        emailEdit.setSingleLine(true);
        emailEdit.setMinWidth(px(200));

        linearLayout.addView(emailEdit);

        final EditText feedbackEdit = new EditText(this);
        feedbackEdit.setMinWidth(px(200));
        feedbackEdit.setMinHeight(px(200));
        feedbackEdit.setMaxHeight(px(280));
        feedbackEdit.setSingleLine(false);
        feedbackEdit.setMaxLines(7);

        linearLayout.addView(feedbackEdit);

        LinearLayout buttonsLayout = new LinearLayout(this);
        buttonsLayout.setOrientation(LinearLayout.HORIZONTAL);

        Button cancelButton = new Button(this);
        cancelButton.setText("Cancel");
        cancelButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                localBroadcastManager.sendBroadcast(getCanceledIntent(reportID));
                SkiAdReportActivity.this.finish();
            }
        });

        buttonsLayout.addView(cancelButton, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT, 1));

        final Button sendButton = new Button(this);
        sendButton.setText("Send");
        sendButton.setEnabled(false);
        sendButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                localBroadcastManager.sendBroadcast(getSuccessIntent(reportID, emailEdit.getText().toString(), feedbackEdit.getText().toString()));
                SkiAdReportActivity.this.finish();
            }
        });

        buttonsLayout.addView(sendButton, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT, 1));

        linearLayout.addView(buttonsLayout);

        feedbackEdit.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                sendButton.setEnabled(s.length() > 2);
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });
        
        setContentView(linearLayout);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        localBroadcastManager.sendBroadcast(getCanceledIntent(reportID));
    }

    public static String getEmail(Intent data) {
        return data.getStringExtra(EXTRA_EMAIL);
    }

    public static String getFeedback(Intent data) {
        return data.getStringExtra(EXTRA_FEEDBACK);
    }

    private int px(float dp) {
        Resources r = getResources();
        return Math.round(TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp, r.getDisplayMetrics()));
    }

    interface SkiAdReportListener {
        void onResult(boolean canceled, Intent data);
    }
}
