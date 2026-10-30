package com.valvesoftware;

import android.app.Activity;
import android.os.Build;
import android.util.Log;
import android.view.Display;
import android.view.Surface;
import android.view.Window;
import android.view.WindowManager;

/** App-level preference; unsupported modes and Android display policy stay unchanged. */
public final class RefreshRateController {
    private static final String TAG = "SourceRefreshRate";
    private static final float TARGET_HZ = 120.0f;
    private static final float TOLERANCE_HZ = 1.0f;

    private RefreshRateController() {}

    public static void apply(Activity activity, Surface surface) {
        requestWindow(activity);
        requestSurface(activity, surface);
    }

    public static void requestWindow(Activity activity) {
        if (activity == null || Build.VERSION.SDK_INT < 23) {
            return;
        }
        try {
            Api23.requestWindow(activity);
        } catch (RuntimeException error) {
            Log.w(TAG, "Could not request the supported 120 Hz window mode", error);
        }
    }

    public static void requestSurface(Activity activity, Surface surface) {
        if (activity == null || surface == null || Build.VERSION.SDK_INT < 30 || !surface.isValid()) {
            return;
        }
        try {
            Api30.request(activity, surface);
        } catch (RuntimeException error) {
            Log.w(TAG, "Could not request the supported 120 Hz surface rate", error);
        }
    }

    private static final class Api23 {
        static Display.Mode findMode(Activity activity) {
            Display display = activity.getWindowManager().getDefaultDisplay();
            if (display == null) {
                return null;
            }
            Display.Mode current = display.getMode();
            Display.Mode best = null;
            for (Display.Mode mode : display.getSupportedModes()) {
                if (mode.getPhysicalWidth() != current.getPhysicalWidth()
                        || mode.getPhysicalHeight() != current.getPhysicalHeight()) {
                    continue;
                }
                float difference = Math.abs(mode.getRefreshRate() - TARGET_HZ);
                if (difference <= TOLERANCE_HZ && (best == null
                        || difference < Math.abs(best.getRefreshRate() - TARGET_HZ))) {
                    best = mode;
                }
            }
            return best;
        }

        static void requestWindow(Activity activity) {
            Display.Mode mode = findMode(activity);
            if (mode == null) {
                return;
            }
            Window window = activity.getWindow();
            WindowManager.LayoutParams attributes = window.getAttributes();
            if (attributes.preferredDisplayModeId == mode.getModeId()
                    && Math.abs(attributes.preferredRefreshRate - mode.getRefreshRate()) < 0.01f) {
                return;
            }
            attributes.preferredDisplayModeId = mode.getModeId();
            attributes.preferredRefreshRate = mode.getRefreshRate();
            window.setAttributes(attributes);
        }
    }

    private static final class Api30 {
        static void request(Activity activity, Surface surface) {
            Display.Mode mode = Api23.findMode(activity);
            if (mode != null) {
                if (Build.VERSION.SDK_INT >= 31) {
                    Api31.request(surface, mode.getRefreshRate());
                } else {
                    surface.setFrameRate(mode.getRefreshRate(), Surface.FRAME_RATE_COMPATIBILITY_DEFAULT);
                }
            }
        }
    }

    private static final class Api31 {
        static void request(Surface surface, float rate) {
            surface.setFrameRate(rate, Surface.FRAME_RATE_COMPATIBILITY_DEFAULT,
                    Surface.CHANGE_FRAME_RATE_ALWAYS);
        }
    }
}
